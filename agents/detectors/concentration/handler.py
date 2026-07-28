from datetime import date, datetime, timezone
from pathlib import Path

from shared.db import query, execute

FILTER_SQL = (Path(__file__).parent / "filter.sql").read_text()


def _calcular_nivel(pct_titulos: float, cuentas_participantes: int) -> str:
    if pct_titulos >= 50 or (pct_titulos >= 30 and cuentas_participantes <= 3):
        return "ALTO"
    return "MEDIO"


def _calcular_score(pct_titulos: float, pct_vs_promedio: float) -> float:
    score_concentracion = min(60.0, pct_titulos * 0.8)
    score_vs_promedio   = min(40.0, pct_vs_promedio / 5)
    return round(score_concentracion + score_vs_promedio, 2)


def _construir_resumen(row: dict) -> str:
    return (
        f"Cuenta {row['numero_cuenta']} ({row['nombre']}, riesgo {row['nivel_riesgo']}) "
        f"concentró el {float(row['pct_titulos']):.1f}% del volumen total de {row['ticker']} "
        f"el {row['fecha']} ({row['titulos_cuenta']:,} de {row['titulos_totales_jornada']:,} títulos). "
        f"Participaron {row['cuentas_participantes']} cuentas en total. "
        f"Representa el {float(row['pct_vs_promedio']):.1f}% del volumen promedio diario del instrumento."
    )


def _registrar_alerta(row: dict, nivel: str, score: float, resumen: str) -> int:
    rows = query("""
        INSERT INTO surveillance.alertas
            (patron, nivel, cuenta_id, instrumento_id, fecha_jornada, score, resumen)
        VALUES
            ('concentration', %s, %s, %s, %s, %s, %s)
        RETURNING id
    """, (nivel, row["cuenta_id"], row["instrumento_id"], row["fecha"], score, resumen))
    return rows[0]["id"]


def _registrar_evidencia(alerta_id: int, cuenta_id: int, instrumento_id: int, fecha: str) -> None:
    operaciones = query("""
        SELECT id FROM surveillance.espejo_operaciones
        WHERE cuenta_id      = %s
          AND instrumento_id = %s
          AND fecha          = %s
          AND estado         = 'ejecutada'
    """, (cuenta_id, instrumento_id, fecha))
    for op in operaciones:
        execute("""
            INSERT INTO surveillance.evidencia_operaciones (alerta_id, operacion_id, rol)
            VALUES (%s, %s, 'principal')
        """, (alerta_id, op["id"]))


def run(fecha_jornada: date | str | None = None) -> int:
    fecha = str(fecha_jornada or date.today())

    candidatos = query(FILTER_SQL, {"fecha_jornada": fecha})
    if not candidatos:
        print(f"[concentration] {fecha}: sin candidatos")
        return 0

    alertas = 0
    for row in candidatos:
        try:
            pct_titulos        = float(row["pct_titulos"] or 0)
            pct_vs_promedio    = float(row["pct_vs_promedio"] or 0)
            cuentas            = int(row["cuentas_participantes"] or 1)
            nivel     = _calcular_nivel(pct_titulos, cuentas)
            score     = _calcular_score(pct_titulos, pct_vs_promedio)
            resumen   = _construir_resumen(row)
            alerta_id = _registrar_alerta(row, nivel, score, resumen)
            _registrar_evidencia(alerta_id, row["cuenta_id"], row["instrumento_id"], row["fecha"])
            alertas += 1
            print(f"[concentration] alerta {nivel} — {row['numero_cuenta']} / {row['ticker']} / score {score}")
        except Exception as e:
            print(f"[concentration] error en cuenta {row.get('cuenta_id', '?')}: {e}")

    return alertas


def lambda_handler(event: dict, context) -> dict:
    fecha = event.get("fecha_jornada") or str(date.today())
    alertas = run(fecha)
    return {"patron": "concentration", "fecha": fecha, "alertas": alertas}


if __name__ == "__main__":
    run("2025-01-15")
