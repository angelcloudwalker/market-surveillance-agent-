import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../../.."))

from strands import tool
from agents.shared.db import query


@tool
def buscar_operaciones(alerta_id: int) -> dict:
    """
    Retorna el detalle completo de una alerta: metadatos, cliente, instrumento
    y todas las operaciones de evidencia con su rol dentro del patrón detectado.
    Usar cuando el OPLE pide analizar o profundizar en una alerta específica.
    """
    alertas = query("""
        SELECT a.id, a.patron, a.nivel, a.estado, a.fecha_jornada,
               a.resumen, a.score, a.notas_ople,
               c.nombre AS cliente, c.tipo AS tipo_cliente,
               c.nivel_riesgo, c.pais,
               i.ticker, i.nombre AS instrumento, i.sector, i.mercado
        FROM surveillance.alertas a
        JOIN surveillance.espejo_cuentas ec ON ec.id = a.cuenta_id
        JOIN surveillance.espejo_clientes c  ON c.id  = ec.cliente_id
        LEFT JOIN surveillance.espejo_instrumentos i ON i.id = a.instrumento_id
        WHERE a.id = %s
    """, (alerta_id,))

    if not alertas:
        return {"error": f"Alerta {alerta_id} no encontrada"}

    alerta = alertas[0]

    operaciones = query("""
        SELECT eo.id, eo.tipo, eo.cantidad, eo.precio, eo.monto_total,
               eo.timestamp, eo.estado AS estado_op,
               ev.rol,
               op.nombre AS operador
        FROM surveillance.evidencia_operaciones ev
        JOIN surveillance.espejo_operaciones eo ON eo.id = ev.operacion_id
        LEFT JOIN surveillance.espejo_operadores op ON op.id = eo.operador_id
        WHERE ev.alerta_id = %s
        ORDER BY eo.timestamp
    """, (alerta_id,))

    ordenes = query("""
        SELECT ord.id, ord.tipo, ord.cantidad, ord.precio,
               ord.timestamp_envio, ord.timestamp_cancelacion, ord.estado,
               ev.rol
        FROM surveillance.evidencia_ordenes ev
        JOIN surveillance.espejo_ordenes ord ON ord.id = ev.orden_id
        WHERE ev.alerta_id = %s
        ORDER BY ord.timestamp_envio
    """, (alerta_id,))

    return {
        "alerta": alerta,
        "operaciones": operaciones,
        "ordenes": ordenes,
    }
