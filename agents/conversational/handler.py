import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from strands import Agent
from strands.models.bedrock import BedrockModel
from bedrock_agentcore.runtime import BedrockAgentCoreApp

from shared.db import query, execute
from tools.buscar_operaciones import buscar_operaciones
from tools.consultar_legislacion import consultar_legislacion
from tools.buscar_contexto_mercado import buscar_contexto_mercado
from tools.generar_rou import generar_rou
from tools.buscar_notas_cliente import buscar_notas_cliente

# =============================================================================
# App AgentCore
# =============================================================================

app = BedrockAgentCoreApp()

SKILLS_DIR = Path(__file__).parent / "skills"
MODEL_ID = "us.anthropic.claude-haiku-4-5-20251001-v1:0"

SYSTEM_PROMPT = """Eres un asistente especializado en vigilancia de mercados financieros para el OPLE
(Oficial de Prevención de Lavado de Dinero y Financiamiento al Terrorismo) de una casa de bolsa mexicana.

Al inicio de cada sesión recibirás el contexto de la alerta que el OPLE seleccionó.
Usa las herramientas disponibles para profundizar el análisis cuando sea necesario.
Fundamenta tus observaciones en la regulación aplicable (LFPIORPI, LMV, RISCHP, GAFI).
Sé preciso, conciso y usa terminología regulatoria correcta."""

# session_id → {"agent": Agent, "alerta_id": int, "analisis_id": int, "ople_id": str, "confirmacion_rou": bool}
_sesiones: dict = {}


# =============================================================================
# Helpers
# =============================================================================

def _cargar_skill(patron: str) -> str:
    path = SKILLS_DIR / f"{patron}.md"
    return "\n\n" + path.read_text() if path.exists() else ""


def _contexto_alerta(alerta_id: int) -> str:
    rows = query("""
        SELECT a.id, a.patron, a.nivel, a.estado, a.fecha_jornada,
               a.resumen, a.score,
               c.nombre AS cliente, c.rfc, c.tipo AS tipo_cliente, c.nivel_riesgo,
               i.ticker, i.nombre AS instrumento
        FROM surveillance.alertas a
        JOIN surveillance.espejo_cuentas ec ON ec.id = a.cuenta_id
        JOIN surveillance.espejo_clientes c  ON c.id  = ec.cliente_id
        LEFT JOIN surveillance.espejo_instrumentos i ON i.id = a.instrumento_id
        WHERE a.id = %s
    """, (alerta_id,))

    if not rows:
        return f"Alerta {alerta_id} no encontrada."
    a = rows[0]
    return (
        f"Alerta #{a['id']} | {a['patron'].upper()} | Nivel {a['nivel']} | Score {a['score']} | {a['fecha_jornada']}\n"
        f"Cliente: {a['cliente']} ({a['rfc']}) — {a['tipo_cliente']} — riesgo {a['nivel_riesgo']}\n"
        f"Instrumento: {a['ticker'] or 'N/A'} — {a['instrumento'] or 'N/A'}\n"
        f"Resumen del sistema: {a['resumen']}"
    )


def _make_audit_hook(analisis_id: int, ople_id: str):
    def hook(**kwargs):
        entrada = None
        event_type = kwargs.get("event_type") or kwargs.get("type")

        if event_type == "tool_use" or ("tool_use" in kwargs and kwargs.get("tool_use")):
            tu = kwargs.get("tool_use") or kwargs
            entrada = {
                "tipo":  "tool_use",
                "ts":    datetime.now(timezone.utc).isoformat(),
                "tool":  tu.get("name") if isinstance(tu, dict) else getattr(tu, "name", ""),
                "input": tu.get("input") if isinstance(tu, dict) else getattr(tu, "input", {}),
            }
        elif event_type == "tool_result" or ("tool_result" in kwargs and kwargs.get("tool_result")):
            tr = kwargs.get("tool_result") or kwargs
            entrada = {
                "tipo": "tool_result",
                "ts":   datetime.now(timezone.utc).isoformat(),
                "ok":   not (tr.get("status") == "error" if isinstance(tr, dict) else False),
            }
        elif "message" in kwargs and kwargs.get("message"):
            msg = kwargs["message"]
            entrada = {
                "tipo":    "mensaje",
                "ts":      datetime.now(timezone.utc).isoformat(),
                "role":    msg.get("role") if isinstance(msg, dict) else getattr(msg, "role", ""),
                "content": str(msg.get("content") if isinstance(msg, dict) else getattr(msg, "content", "")),
            }

        if entrada:
            execute("""
                UPDATE surveillance.analisis_alerta
                SET historial_raw = historial_raw || %s::jsonb
                WHERE id = %s
            """, (json.dumps([entrada], default=str), analisis_id))

    return hook


def _make_rou_guard(session_id: str):
    def guard(tool_name: str, tool_input: dict) -> bool | str:
        if tool_name == "generar_rou":
            sesion = _sesiones.get(session_id, {})
            if not sesion.get("confirmacion_rou", False):
                return (
                    "No puedes generar el ROU sin confirmación explícita del OPLE. "
                    "Indica al OPLE que confirme con el botón 'Confirmar ROU' antes de proceder."
                )
        return True
    return guard


def _crear_agente(alerta_id: int, analisis_id: int, ople_id: str, session_id: str) -> Agent:
    alerta_info = query("SELECT patron FROM surveillance.alertas WHERE id = %s", (alerta_id,))
    patron = alerta_info[0]["patron"] if alerta_info else ""
    system = SYSTEM_PROMPT + _cargar_skill(patron)

    return Agent(
        model=BedrockModel(model_id=MODEL_ID),
        system_prompt=system,
        tools=[buscar_operaciones, consultar_legislacion, buscar_contexto_mercado, generar_rou, buscar_notas_cliente],
        callback_handler=_make_audit_hook(analisis_id, ople_id),
    )


# =============================================================================
# Entrypoint AgentCore
# =============================================================================

@app.entrypoint
def invoke(payload: dict, context):
    session_id = context.session_id
    accion = payload.get("accion", "chat")

    # --- iniciar ---
    if accion == "iniciar":
        alerta_id = int(payload["alerta_id"])
        ople_id   = payload.get("ople_id", "desconocido")

        rows = query("""
            INSERT INTO surveillance.analisis_alerta (alerta_id, ople_id)
            VALUES (%s, %s) RETURNING id
        """, (alerta_id, ople_id))
        analisis_id = rows[0]["id"]

        agent = _crear_agente(alerta_id, analisis_id, ople_id, session_id)
        _sesiones[session_id] = {
            "agent": agent,
            "alerta_id": alerta_id,
            "analisis_id": analisis_id,
            "ople_id": ople_id,
            "confirmacion_rou": False,
        }

        # primer mensaje con contexto de la alerta
        contexto = _contexto_alerta(alerta_id)
        respuesta = agent(f"[Contexto de la alerta seleccionada]\n{contexto}\n\n¿En qué puedo ayudarte con esta alerta?")
        return {"analisis_id": analisis_id, "respuesta": str(respuesta)}

    # --- chat ---
    if accion == "chat":
        sesion = _sesiones.get(session_id)
        if not sesion:
            return {"error": "Sesión no encontrada. Usa accion=iniciar primero."}

        if payload.get("confirmacion_rou"):
            sesion["confirmacion_rou"] = True

        respuesta = sesion["agent"](payload["mensaje"])
        tokens_in  = getattr(respuesta.metrics, "input_tokens",  0) or getattr(respuesta.metrics, "inputTokens",  0)
        tokens_out = getattr(respuesta.metrics, "output_tokens", 0) or getattr(respuesta.metrics, "outputTokens", 0)
        return {
            "respuesta": str(respuesta),
            "tokens": {"input": tokens_in, "output": tokens_out, "total": tokens_in + tokens_out},
        }

    # --- cerrar ---
    if accion == "cerrar":
        sesion = _sesiones.pop(session_id, None)
        analisis_id   = int(payload.get("analisis_id", sesion["analisis_id"] if sesion else 0))
        decision      = payload["decision"]
        justificacion = payload.get("justificacion", "")

        execute("""
            UPDATE surveillance.analisis_alerta
            SET fin = NOW(), decision = %s, justificacion = %s
            WHERE id = %s
        """, (decision, justificacion[:500], analisis_id))

        rows = query("SELECT alerta_id FROM surveillance.analisis_alerta WHERE id = %s", (analisis_id,))
        if rows:
            execute("UPDATE surveillance.alertas SET estado = %s WHERE id = %s",
                    (decision, rows[0]["alerta_id"]))

        # Suspender la MicroVM — deja de cobrar hasta el siguiente request
        agent_arn = os.environ.get("AGENT_RUNTIME_ARN")
        if agent_arn and session_id:
            try:
                import boto3
                boto3.client("bedrock-agentcore", region_name=os.environ.get("AWS_REGION", "us-east-1")).stop_runtime_session(
                    runtimeSessionId=session_id,
                    agentRuntimeArn=agent_arn,
                )
                print(f"[agentcore] sesión {session_id} detenida")
            except Exception as e:
                print(f"[agentcore] no se pudo detener sesión: {e}")

        return {"ok": True}

    return {"error": f"accion desconocida: {accion}"}


if __name__ == "__main__":
    app.run()
