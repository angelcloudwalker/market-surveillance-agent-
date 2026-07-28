from datetime import date, datetime, timezone
from pathlib import Path

from shared.db import query, execute

FILTER_SQL = (Path(__file__).parent / "filter.sql").read_text()


def _calcular_nivel(num_ordenes_fantasma: int, segundos_promedio: float) -> str:
    if num_ordenes_fantasma >= 3 or segundos_promedio <= 15:
        return "ALTO"
    return "MEDIO"


def _calcular_score(num_ordenes: int, segundos_promedio: float, pct_volumen: float) -> float:
    score_frecuencia = min(40.0, num_ordenes * 8)
    score_velocidad  = max(0.0, 40 - (segundos_promedio / 60) * 40)
    score_volumen    = min(20.0, pct_volumen / 5)
    return round(score_frecuencia + score_velocidad + score_volumen, 2)


def _construir_resumen(row: dict) -> str:
    return (
        f"Cuenta {row['numero_cuenta']} ({row['nombre']}, riesgo {row['nivel_riesgo']}) "
        f"publicó {row['num_ordenes_fantasma']} órdenes de {row['tipo_presion']} "
        f"sobre {row['ticker']} canceladas en promedio en {float(row['segundos_vida_promedio']):.0f} segundos "
        f"({row['titulos_presion_total']:,} títulos de presión artificial). "
        f"Seguidas de una {row['tipo_operacion_beneficiaria']} ejecutada de "
        f"{row['titulos_beneficiarios']:,} títulos a ${float(row['precio_beneficiario']):,.4f} "
        f"(referencia: ${float(row['precio_referencia']):,.4f}). "
        f"Importe beneficiado: ${float(row['importe_beneficiario']):,.0f}."
    )


def _registrar_alerta(row: dict, nivel: str, score: float, resumen: str) -> int:
    rows = query("""
        INSERT INTO surveillance.alertas
            (patron, nivel, cuenta_id, instrumento_id, fecha_jornada, score, resumen)
        VALUES
            ('spoofing', %s, %s, %s, %s, %s, %s)
        RETURNING id
    """, (nivel, row["cuenta_id"], row["instrumento_id"], row["fecha"], score, resumen))
    return rows[0]["id"]


def _registrar_evidencia(alerta_id: int, row: dict) -> None:
    # Órdenes fantasma — rol 'historico'
    ordenes = query("""
        SELECT id FROM surveillance.espejo_ordenes
        WHERE cuenta_id      = %s
          AND instrumento_id = %s
          AND fecha          = %s
          AND estado         = 'cancelada'
    """, (row["cuenta_id"], row["instrumento_id"], row["fecha"]))
    for ord in ordenes:
        execute("""
            INSERT INTO surveillance.evidencia_operaciones (alerta_id, operacion_id, rol)
            VALUES (%s, %s, 'historico')
        """, (alerta_id, ord["id"]))

    # Operación beneficiaria — rol 'principal'
    if row.get("operacion_beneficiaria_id"):
        execute("""
            INSERT INTO surveillance.evidencia_operaciones (alerta_id, operacion_id, rol)
            VALUES (%s, %s, 'principal')
        """, (alerta_id, row["operacion_beneficiaria_id"]))


def run(fecha_jornada: date | str | None = None) -> int:
    fecha = str(fecha_jornada or date.today())

    candidatos = query(FILTER_SQL, {"fecha_jornada": fecha})
    if not candidatos:
        print(f"[spoofing] {fecha}: sin candidatos")
        return 0

    alertas = 0
    for row in candidatos:
        try:
            num_ordenes   = int(row["num_ordenes_fantasma"] or 0)
            segundos_prom = float(row["segundos_vida_promedio"] or 0)
            pct_volumen   = float(row.get("pct_volumen_orden", 0) or 0)
            nivel     = _calcular_nivel(num_ordenes, segundos_prom)
            score     = _calcular_score(num_ordenes, segundos_prom, pct_volumen)
            resumen   = _construir_resumen(row)
            alerta_id = _registrar_alerta(row, nivel, score, resumen)
            _registrar_evidencia(alerta_id, row)
            alertas += 1
            print(f"[spoofing] alerta {nivel} — {row['numero_cuenta']} / {row['ticker']} / score {score}")
        except Exception as e:
            print(f"[spoofing] error en cuenta {row.get('cuenta_id', '?')}: {e}")

    return alertas


def lambda_handler(event: dict, context) -> dict:
    fecha = event.get("fecha_jornada") or str(date.today())
    alertas = run(fecha)
    return {"patron": "spoofing", "fecha": fecha, "alertas": alertas}


if __name__ == "__main__":
    run("2025-01-15")
