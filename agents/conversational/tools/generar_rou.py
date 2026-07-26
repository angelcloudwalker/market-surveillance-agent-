import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../../.."))

from strands import tool
from agents.shared.db import query, execute
from datetime import date


@tool
def generar_rou(alerta_id: int, narrativa: str) -> dict:
    """
    Genera un borrador de Reporte de Operación Inusual (ROU) para la alerta indicada.
    Actualiza el estado de la alerta a 'confirmada' y registra la narrativa en notas_ople.
    - alerta_id: ID de la alerta a reportar
    - narrativa: texto elaborado por el OPLE describiendo los hechos y fundamento legal
    Retorna el borrador estructurado listo para revisión final.
    """
    alertas = query("""
        SELECT a.id, a.patron, a.nivel, a.fecha_jornada, a.resumen, a.score,
               c.nombre AS cliente, c.rfc, c.tipo AS tipo_cliente,
               c.nivel_riesgo, c.pais,
               ec.numero_cuenta,
               i.ticker, i.nombre AS instrumento
        FROM surveillance.alertas a
        JOIN surveillance.espejo_cuentas ec ON ec.id = a.cuenta_id
        JOIN surveillance.espejo_clientes c  ON c.id  = ec.cliente_id
        LEFT JOIN surveillance.espejo_instrumentos i ON i.id = a.instrumento_id
        WHERE a.id = %s
    """, (alerta_id,))

    if not alertas:
        return {"error": f"Alerta {alerta_id} no encontrada"}

    a = alertas[0]

    execute("""
        UPDATE surveillance.alertas
        SET estado = 'confirmada', notas_ople = %s, confirmada_en = NOW()
        WHERE id = %s
    """, (narrativa, alerta_id))

    rou = f"""
REPORTE DE OPERACIÓN INUSUAL — BORRADOR
========================================
Fecha de elaboración : {date.today().isoformat()}
Alerta ID            : {a['id']}
Patrón detectado     : {a['patron'].upper()}
Nivel de riesgo      : {a['nivel']}
Score                : {a['score']}
Fecha de jornada     : {a['fecha_jornada']}

SUJETO OBLIGADO
---------------
Cliente              : {a['cliente']}
RFC                  : {a['rfc']}
Tipo                 : {a['tipo_cliente']}
Nivel de riesgo      : {a['nivel_riesgo']}
País                 : {a['pais']}
Cuenta               : {a['numero_cuenta']}

INSTRUMENTO
-----------
Ticker               : {a['ticker'] or 'N/A'}
Nombre               : {a['instrumento'] or 'N/A'}

DESCRIPCIÓN DEL SISTEMA
-----------------------
{a['resumen']}

ANÁLISIS DEL OPLE
-----------------
{narrativa}

========================================
ESTADO: PENDIENTE DE FIRMA Y ENVÍO A UIF
    """.strip()

    return {"rou": rou, "alerta_actualizada": True}
