import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../../.."))

from strands import tool
from agents.shared.db import query


@tool
def buscar_contexto_mercado(ticker: str = "", fecha: str = "", terminos: str = "") -> list[dict]:
    """
    Busca hechos relevantes, noticias macro y contexto sectorial registrados
    en el sistema. Al menos uno de los parámetros debe tener valor.
    - ticker: símbolo del instrumento, ej. 'AMXL', 'FEMSAUBD'
    - fecha: fecha de la jornada en formato YYYY-MM-DD
    - terminos: palabras clave para búsqueda full-text, ej. 'fusión adquisición'
    """
    conditions = []
    params = []

    if ticker:
        conditions.append("ticker = %s")
        params.append(ticker.upper())
    if fecha:
        conditions.append("fecha = %s")
        params.append(fecha)
    if terminos:
        conditions.append(
            "to_tsvector('spanish', descripcion) @@ plainto_tsquery('spanish', %s)"
        )
        params.append(terminos)

    if not conditions:
        return [{"error": "Proporciona al menos ticker, fecha o terminos"}]

    where = " AND ".join(conditions)
    resultados = query(f"""
        SELECT fecha, ticker, tipo, fuente, descripcion
        FROM surveillance.contexto_mercado
        WHERE {where}
        ORDER BY fecha DESC
        LIMIT 10
    """, tuple(params))

    return resultados
