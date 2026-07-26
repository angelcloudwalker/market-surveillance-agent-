import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../../.."))

from strands import tool
from agents.shared.db import query


@tool
def consultar_legislacion(terminos: str) -> list[dict]:
    """
    Busca artículos relevantes en la base de conocimiento regulatorio
    (LFPIORPI, LMV, RISCHP, GAFI, etc.) usando búsqueda full-text en español.
    Usar cuando se necesite fundamentar legalmente una alerta o acción.
    Ejemplos de terminos: 'operaciones inusuales reporte', 'lavado dinero umbral',
    'manipulación mercado sanciones'.
    """
    resultados = query("""
        SELECT ordenamiento, articulo, titulo,
               contenido,
               ts_rank(
                   to_tsvector('spanish', contenido || ' ' || titulo),
                   plainto_tsquery('spanish', %s)
               ) AS relevancia
        FROM surveillance.legislacion
        WHERE to_tsvector('spanish', contenido || ' ' || titulo)
              @@ plainto_tsquery('spanish', %s)
        ORDER BY relevancia DESC
        LIMIT 5
    """, (terminos, terminos))

    return resultados
