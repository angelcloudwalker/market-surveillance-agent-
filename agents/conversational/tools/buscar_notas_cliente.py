import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../../.."))

from strands import tool
from agents.shared.db import query


@tool
def buscar_notas_cliente(cliente_id: int) -> list[dict]:
    """
    Retorna todas las notas internas registradas por cualquier área de la institución
    sobre un cliente específico, ordenadas de más reciente a más antigua.
    Usar al inicio del análisis de cualquier alerta para obtener contexto institucional
    que puede justificar o agravar el comportamiento detectado.
    """
    return query("""
        SELECT autor, area, contenido, creada_en
        FROM surveillance.notas_cliente
        WHERE cliente_id = %s
        ORDER BY creada_en DESC
        LIMIT 20
    """, (cliente_id,))
