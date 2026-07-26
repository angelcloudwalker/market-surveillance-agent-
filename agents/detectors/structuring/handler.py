from datetime import date, datetime, timezone
from pathlib import Path

import sys
sys.path.append(str(Path(__file__).resolve().parents[2]))

from shared.db import query, execute

FILTER_CASO1 = (Path(__file__).parent / "filter_caso1.sql").read_text()
FILTER_CASO2 = (Path(__file__).parent / "filter_caso2.sql").read_text()
FILTER_CASO3 = (Path(__file__).parent / "filter_caso3.sql").read_text()


def _get_umbral() -> float:
    rows = query("SELECT valor FROM surveillance.parametros WHERE clave = 'limite_structuring_mxn'", {})
    return float(rows[0]["valor"]) if rows else 70027.65


# ---------------------------------------------------------------------------
# Caso 1 — mismo día, mismo instrumento
# ---------------------------------------------------------------------------

def _nivel_caso1(num_ops: int, importe_total: float, umbral: float) -> str:
    if num_ops >= 7 or importe_total >= umbral * 3:
        return "ALTO"
    return "MEDIO"


def _score_caso1(desviacion: float, importe_promedio: float) -> float:
    """Más regular (desviación baja) = más sospechoso = score más alto."""
    if not importe_promedio:
        return 50.0
    coef_variacion = (desviacion or 0) / importe_promedio
    return round(max(0.0, min(100.0, 100 - coef_variacion * 200)), 2)


def _resumen_caso1(row: dict, umbral: float) -> str:
    return (
        f"Cuenta {row['numero_cuenta']} ({row['nombre']}, riesgo {row['nivel_riesgo']}) "
        f"realizó {row['num_operaciones']} operaciones sobre {row['ticker']} el {row['fecha']}. "
        f"Ninguna superó ${umbral:,.0f} MXN individualmente "
        f"(máximo ${float(row['importe_maximo']):,.0f}) pero el acumulado fue "
        f"${float(row['importe_total']):,.0f}. "
        f"Desviación estándar: ${float(row['desviacion_importe'] or 0):,.0f} — "
        f"{'patrón muy regular, alta sospecha' if float(row['desviacion_importe'] or 0) < 1000 else 'patrón con variación'}."
    )


# ---------------------------------------------------------------------------
# Caso 2 — varios días, mismo instrumento
# ---------------------------------------------------------------------------

def _nivel_caso2(num_dias: int, importe_total: float, umbral: float) -> str:
    if num_dias >= 5 or importe_total >= umbral * 5:
        return "ALTO"
    return "MEDIO"


def _score_caso2(desviacion: float, importe_promedio: float, num_dias: int) -> float:
    """Regularidad de importes + dispersión en más días = más sospechoso."""
    if not importe_promedio:
        return 50.0
    coef_variacion  = (desviacion or 0) / importe_promedio
    score_regularidad = max(0.0, 70 - coef_variacion * 140)
    score_dias        = min(30.0, num_dias * 6)
    return round(score_regularidad + score_dias, 2)


def _resumen_caso2(row: dict, umbral: float) -> str:
    return (
        f"Cuenta {row['numero_cuenta']} ({row['nombre']}, riesgo {row['nivel_riesgo']}) "
        f"fragmentó operaciones sobre {row['ticker']} en {row['num_dias']} días distintos "
        f"({row['fecha_inicio']} al {row['fecha_fin']}). "
        f"{row['num_operaciones']} operaciones, ninguna superó ${umbral:,.0f} MXN "
        f"(máximo ${float(row['importe_maximo']):,.0f}) pero el acumulado fue "
        f"${float(row['importe_total']):,.0f}."
    )


# ---------------------------------------------------------------------------
# Caso 3 — mismo día, varios instrumentos
# ---------------------------------------------------------------------------

def _nivel_caso3(num_instrumentos: int, importe_total: float, umbral: float) -> str:
    if num_instrumentos >= 4 or importe_total >= umbral * 3:
        return "ALTO"
    return "MEDIO"


def _resumen_caso3(row: dict, umbral: float, tipo: str) -> str:
    return (
        f"Cuenta {row['numero_cuenta']} ({row['nombre']}, riesgo {row['nivel_riesgo']}) "
        f"fragmentó {row['num_operaciones']} {tipo}s en {row['num_instrumentos']} instrumentos distintos "
        f"el {row['fecha']}. Ninguna superó ${umbral:,.0f} MXN individualmente "
        f"(máximo ${float(row['importe_maximo']):,.0f}) pero el acumulado fue "
        f"${float(row['importe_total']):,.0f}."
    )


# ---------------------------------------------------------------------------
# Registro y orquestación
# ---------------------------------------------------------------------------

def _registrar_alerta(row: dict, nivel: str, score: float, resumen: str, fecha_jornada: str) -> int:
    rows = query("""
        INSERT INTO surveillance.alertas
            (patron, nivel, cuenta_id, instrumento_id, fecha_jornada, score, resumen)
        VALUES
            ('structuring', %s, %s, %s, %s, %s, %s)
        RETURNING id
    """, (nivel, row["cuenta_id"], row.get("instrumento_id"), fecha_jornada, score, resumen))
    return rows[0]["id"]


def _registrar_evidencia(alerta_id: int, cuenta_id: int, instrumento_id: int | None,
                         fecha_inicio: str, fecha_fin: str, tipo: str) -> None:
    filtro_instrumento = "AND instrumento_id = %s" if instrumento_id else ""
    params = [cuenta_id]
    if instrumento_id:
        params.append(instrumento_id)
    params += [fecha_inicio, fecha_fin, tipo]
    operaciones = query(f"""
        SELECT id FROM surveillance.espejo_operaciones
        WHERE cuenta_id = %s
          {filtro_instrumento}
          AND fecha BETWEEN %s AND %s
          AND tipo = %s
          AND estado = 'ejecutada'
    """, params)
    for op in operaciones:
        execute("""
            INSERT INTO surveillance.evidencia_operaciones (alerta_id, operacion_id, rol)
            VALUES (%s, %s, 'fragmento')
        """, (alerta_id, op["id"]))


def _procesar_caso1(fecha: str, umbral: float) -> int:
    alertas = 0
    for tipo in ("compra", "venta"):
        for row in query(FILTER_CASO1, {"fecha_jornada": fecha, "tipo": tipo}):
            try:
                importe_promedio = float(row["importe_total"]) / row["num_operaciones"]
                nivel   = _nivel_caso1(row["num_operaciones"], float(row["importe_total"]), umbral)
                score   = _score_caso1(float(row["desviacion_importe"] or 0), importe_promedio)
                resumen = _resumen_caso1(row, umbral)
                alerta_id = _registrar_alerta(row, nivel, score, resumen, fecha)
                _registrar_evidencia(alerta_id, row["cuenta_id"], row["instrumento_id"], fecha, fecha, tipo)
                alertas += 1
                print(f"[structuring/caso1] alerta {nivel} — {row['numero_cuenta']} / {row['ticker']} / {tipo} / score {score}")
            except Exception as e:
                print(f"[structuring/caso1] error en cuenta {row['cuenta_id']} / {row.get('ticker', '?')}: {e}")
    return alertas


def _procesar_caso2(fecha: str, umbral: float) -> int:
    alertas = 0
    for tipo in ("compra", "venta"):
        for row in query(FILTER_CASO2, {"fecha_jornada": fecha, "tipo": tipo}):
            try:
                importe_promedio = float(row["importe_total"]) / row["num_operaciones"]
                nivel   = _nivel_caso2(int(row["num_dias"]), float(row["importe_total"]), umbral)
                score   = _score_caso2(float(row["desviacion_importe"] or 0), importe_promedio, int(row["num_dias"]))
                resumen = _resumen_caso2(row, umbral)
                alerta_id = _registrar_alerta(row, nivel, score, resumen, fecha)
                _registrar_evidencia(alerta_id, row["cuenta_id"], row["instrumento_id"], str(row["fecha_inicio"]), str(row["fecha_fin"]), tipo)
                alertas += 1
                print(f"[structuring/caso2] alerta {nivel} — {row['numero_cuenta']} / {row['ticker']} / {tipo} / score {score}")
            except Exception as e:
                print(f"[structuring/caso2] error en cuenta {row['cuenta_id']} / {row.get('ticker', '?')}: {e}")
    return alertas


def _procesar_caso3(fecha: str, umbral: float) -> int:
    alertas = 0
    for tipo in ("compra", "venta"):
        for row in query(FILTER_CASO3, {"fecha_jornada": fecha, "tipo": tipo}):
            try:
                importe_promedio = float(row["importe_total"]) / row["num_operaciones"]
                nivel   = _nivel_caso3(int(row["num_instrumentos"]), float(row["importe_total"]), umbral)
                score   = _score_caso1(float(row["desviacion_importe"] or 0), importe_promedio)
                resumen = _resumen_caso3(row, umbral, tipo)
                alerta_id = _registrar_alerta(row, nivel, score, resumen, fecha)
                _registrar_evidencia(alerta_id, row["cuenta_id"], None, fecha, fecha, tipo)
                alertas += 1
                print(f"[structuring/caso3] alerta {nivel} — {row['numero_cuenta']} / {row['num_instrumentos']} instrumentos / {tipo} / score {score}")
            except Exception as e:
                print(f"[structuring/caso3] error en cuenta {row['cuenta_id']}: {e}")
    return alertas


def run(fecha_jornada: date | str | None = None) -> int:
    fecha  = str(fecha_jornada or datetime.now(timezone.utc).date())
    umbral = _get_umbral()

    total  = _procesar_caso1(fecha, umbral)
    total += _procesar_caso2(fecha, umbral)
    total += _procesar_caso3(fecha, umbral)

    if not total:
        print(f"[structuring] {fecha}: sin candidatos")
    return total


def lambda_handler(event: dict, context) -> dict:
    fecha = event.get("fecha_jornada") or str(datetime.now(timezone.utc).date())
    try:
        alertas = run(fecha)
        return {"patron": "structuring", "fecha": fecha, "alertas": alertas}
    except Exception as e:
        print(f"[structuring] fallo general: {e}")
        return {"patron": "structuring", "fecha": fecha, "alertas": 0, "error": str(e)}


if __name__ == "__main__":
    run("2026-01-15")
