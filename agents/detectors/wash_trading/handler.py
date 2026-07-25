# =============================================================================
# DETECTOR: Wash Trading
# Referencia legal: Art. 212 LMV — manipulación de mercado
#
# DEFINICIÓN
# Compra y venta del mismo instrumento entre cuentas controladas por la misma
# entidad, creando volumen artificial sin cambio económico real.
#
# CASOS IMPLEMENTADOS
#   Caso 1 — Mismo cliente, mismo operador, precio exacto, cantidad exacta
#   Caso 2 — Mismo cliente, diferente operador, precio exacto, cantidad exacta
#   Caso 3 — Mismo cliente, precio similar (±0.5%), cantidad similar (±5%)
#
# CASOS PENDIENTES
#   Caso 4 — Diferente cliente, mismo operador (coordinación implícita)
#             SQL detecta el par pero determinar coordinación requiere análisis
#             de comportamiento histórico. Implementar con agente LLM.
#   Caso 5 — Diferente cliente, diferente operador, precios cruzados
#             Requiere modelos de series de tiempo. Fuera de alcance MVP.
# =============================================================================

from datetime import datetime, timezone
from pathlib import Path

import sys
sys.path.append(str(Path(__file__).resolve().parents[2]))

from shared.db import query, execute

FILTER_CASO1 = (Path(__file__).parent / "filter_caso1.sql").read_text()
FILTER_CASO2 = (Path(__file__).parent / "filter_caso2.sql").read_text()
FILTER_CASO3 = (Path(__file__).parent / "filter_caso3.sql").read_text()


def _calcular_nivel(segundos: float, pct_volumen: float) -> str:
    if segundos < 60 or pct_volumen > 20:
        return "ALTO"
    return "MEDIO"


def _calcular_score(segundos: float, pct_volumen: float) -> float:
    score_tiempo  = max(0.0, 100 - (segundos / 3))   # 0s=100, 300s=0
    score_volumen = min(100.0, pct_volumen * 2)       # 50%=100
    return round((score_tiempo + score_volumen) / 2, 2)


def _resumen(row: dict, segundos: float, pct_volumen: float, caso: int) -> str:
    precio_venta  = float(row.get("precio_venta")  or row.get("precio") or 0)
    precio_compra = float(row.get("precio_compra") or row.get("precio") or 0)
    titulos_venta  = row.get("titulos_venta")  or row.get("titulos")
    titulos_compra = row.get("titulos_compra") or row.get("titulos")

    base = (
        f"Wash trading caso {caso} en {row['ticker']}: "
        f"cuenta {row['num_cuenta_venta']} vendió {titulos_venta:,} títulos "
        f"a ${precio_venta:,.2f} y cuenta {row['num_cuenta_compra']} compró "
        f"{titulos_compra:,} títulos a ${precio_compra:,.2f} "
        f"con {segundos:.0f}s de diferencia. "
        f"Cliente: {row['cliente']} (riesgo {row['nivel_riesgo']}). "
        f"Volumen: {pct_volumen:.1f}% del promedio diario."
    )
    if caso == 3:
        base += (
            f" Diferencia precio: {float(row['diferencia_precio_pct']):.2f}%, "
            f"cantidad: {float(row['diferencia_cantidad_pct']):.2f}%."
        )
    return base


def _registrar_alerta(row: dict, nivel: str, score: float, resumen: str) -> int:
    rows = query("""
        INSERT INTO surveillance.alertas
            (patron, nivel, cuenta_id, instrumento_id, fecha_jornada, score, resumen)
        VALUES
            ('wash_trading', %s, %s, %s, %s, %s, %s)
        RETURNING id
    """, (nivel, row["cuenta_vendedora"], row["instrumento_id"], row["fecha"], score, resumen))
    return rows[0]["id"]


def _registrar_evidencia(alerta_id: int, row: dict) -> None:
    # Buscamos la operación de venta y la de compra por cuenta + instrumento + fecha
    ops = query("""
        SELECT id, tipo FROM surveillance.espejo_operaciones
        WHERE instrumento_id = %s
          AND fecha = %s
          AND estado = 'ejecutada'
          AND cuenta_id IN (%s, %s)
    """, (row["instrumento_id"], row["fecha"], row["cuenta_vendedora"], row["cuenta_compradora"]))

    for op in ops:
        rol = "principal" if op["tipo"] == "venta" else "contraparte"
        execute("""
            INSERT INTO surveillance.evidencia_operaciones (alerta_id, operacion_id, rol)
            VALUES (%s, %s, %s)
        """, (alerta_id, op["id"], rol))


def _procesar(filter_sql: str, fecha: str, caso: int) -> int:
    alertas = 0
    for row in query(filter_sql, (fecha,)):
        try:
            segundos    = float(row["segundos_diferencia"] or 0)
            vol_promedio = float(row.get("volumen_promedio_diario") or 1)
            titulos     = float(row.get("titulos_venta") or row.get("titulos") or 0)
            pct_volumen = (titulos / vol_promedio) * 100

            nivel   = _calcular_nivel(segundos, pct_volumen)
            score   = _calcular_score(segundos, pct_volumen)
            resumen = _resumen(row, segundos, pct_volumen, caso)

            alerta_id = _registrar_alerta(row, nivel, score, resumen)
            _registrar_evidencia(alerta_id, row)
            alertas += 1
            print(f"[wash_trading/caso{caso}] alerta {nivel} — {row['num_cuenta_venta']} ↔ {row['num_cuenta_compra']} / {row['ticker']} / score {score}")
        except Exception as e:
            print(f"[wash_trading/caso{caso}] error en {row.get('ticker', '?')}: {e}")
    return alertas


def run(fecha_jornada=None) -> int:
    fecha = str(fecha_jornada or datetime.now(timezone.utc).date())

    total  = _procesar(FILTER_CASO1, fecha, 1)
    total += _procesar(FILTER_CASO2, fecha, 2)
    total += _procesar(FILTER_CASO3, fecha, 3)

    if not total:
        print(f"[wash_trading] {fecha}: sin candidatos")
    return total


def lambda_handler(event: dict, context) -> dict:
    fecha = event.get("fecha_jornada") or str(datetime.now(timezone.utc).date())
    try:
        alertas = run(fecha)
        return {"patron": "wash_trading", "fecha": fecha, "alertas": alertas}
    except Exception as e:
        print(f"[wash_trading] fallo general: {e}")
        return {"patron": "wash_trading", "fecha": fecha, "alertas": 0, "error": str(e)}


if __name__ == "__main__":
    run("2025-01-15")
