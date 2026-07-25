from datetime import datetime, timezone
from pathlib import Path

import sys
sys.path.append(str(Path(__file__).resolve().parents[2]))

from shared.db import query, execute

FILTER_SQL = (Path(__file__).parent / "filter.sql").read_text()


def _calcular_nivel(dias_inactiva: int, factor_incremento: float) -> str:
    if dias_inactiva >= 365 or factor_incremento >= 20:
        return "ALTO"
    if factor_incremento >= 10:
        return "MEDIO"
    return "BAJO"


def _calcular_score(dias_inactiva: int, factor_incremento: float) -> float:
    score_inactividad = min(50.0, dias_inactiva / 365 * 50)
    score_volumen     = min(50.0, factor_incremento / 30 * 50)
    return round(score_inactividad + score_volumen, 2)


def _construir_resumen(row: dict) -> str:
    return (
        f"Cuenta {row['numero_cuenta']} ({row['nombre']}, riesgo {row['nivel_riesgo']}) "
        f"sin actividad durante {int(row['dias_inactiva'])} días "
        f"(última operación: {row['ultima_fecha_operacion']}). "
        f"Hoy operó ${float(row['importe_total_hoy']):,.0f} en {row['ticker']}, "
        f"{float(row['factor_incremento']):.1f}x su importe promedio histórico "
        f"(${float(row['importe_promedio_historico']):,.0f}). "
        f"Historial previo: {row['total_operaciones_historicas']} operaciones."
    )


def _registrar_alerta(row: dict, nivel: str, score: float, resumen: str) -> int:
    rows = query("""
        INSERT INTO surveillance.alertas
            (patron, nivel, cuenta_id, instrumento_id, fecha_jornada, score, resumen)
        VALUES
            ('dormant', %s, %s, %s, %s, %s, %s)
        RETURNING id
    """, (nivel, row["cuenta_id"], row.get("instrumento_id"), row["fecha"], score, resumen))
    return rows[0]["id"]


def _registrar_evidencia(alerta_id: int, cuenta_id: int, fecha: str) -> None:
    operaciones = query("""
        SELECT id FROM surveillance.espejo_operaciones
        WHERE cuenta_id = %s
          AND fecha = %s
          AND estado = 'ejecutada'
    """, (cuenta_id, fecha))
    for op in operaciones:
        execute("""
            INSERT INTO surveillance.evidencia_operaciones (alerta_id, operacion_id, rol)
            VALUES (%s, %s, 'principal')
        """, (alerta_id, op["id"]))


def run(fecha_jornada=None) -> int:
    fecha = str(fecha_jornada or datetime.now(timezone.utc).date())

    candidatos = query(FILTER_SQL, {"fecha_jornada": fecha})
    if not candidatos:
        print(f"[dormant] {fecha}: sin candidatos")
        return 0

    alertas = 0
    for row in candidatos:
        try:
            dias_inactiva     = int(row["dias_inactiva"] or 0)
            factor_incremento = float(row["factor_incremento"] or 0)
            nivel   = _calcular_nivel(dias_inactiva, factor_incremento)
            score   = _calcular_score(dias_inactiva, factor_incremento)
            resumen = _construir_resumen(row)
            alerta_id = _registrar_alerta(row, nivel, score, resumen)
            _registrar_evidencia(alerta_id, row["cuenta_id"], fecha)
            alertas += 1
            print(f"[dormant] alerta {nivel} — {row['numero_cuenta']} / {row['ticker']} / {dias_inactiva} días / score {score}")
        except Exception as e:
            print(f"[dormant] error en cuenta {row.get('cuenta_id', '?')}: {e}")

    return alertas


def lambda_handler(event: dict, context) -> dict:
    fecha = event.get("fecha_jornada") or str(datetime.now(timezone.utc).date())
    try:
        alertas = run(fecha)
        return {"patron": "dormant", "fecha": fecha, "alertas": alertas}
    except Exception as e:
        print(f"[dormant] fallo general: {e}")
        return {"patron": "dormant", "fecha": fecha, "alertas": 0, "error": str(e)}


if __name__ == "__main__":
    run("2025-01-15")
