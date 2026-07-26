import sys
import os
import json
from datetime import datetime, timezone
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../.."))

from strands import Agent
from strands.models.ollama import OllamaModel
from strands.models.bedrock import BedrockModel
from strands.agent.conversation_manager.summarizing_conversation_manager import SummarizingConversationManager
from agents.shared.db import query, execute
from agents.conversational.tools.buscar_operaciones import buscar_operaciones
from agents.conversational.tools.consultar_legislacion import consultar_legislacion
from agents.conversational.tools.buscar_contexto_mercado import buscar_contexto_mercado
from agents.conversational.tools.generar_rou import generar_rou
from agents.conversational.tools.buscar_notas_cliente import buscar_notas_cliente

SKILLS_DIR = os.path.join(os.path.dirname(__file__), "skills")


def _cargar_skill(patron: str) -> str:
    path = os.path.join(SKILLS_DIR, f"{patron}.md")
    if os.path.exists(path):
        with open(path) as f:
            return "\n\n" + f.read()
    return ""


SYSTEM_PROMPT = """Eres un asistente especializado en vigilancia de mercados financieros para el OPLE
(Oficial de Prevención de Lavado de Dinero y Financiamiento al Terrorismo) de una casa de bolsa mexicana.

Al inicio de cada sesión recibirás el contexto de la alerta que el OPLE seleccionó.
Usa las herramientas disponibles para profundizar el análisis cuando sea necesario.
Fundamenta tus observaciones en la regulación aplicable (LFPIORPI, LMV, RISCHP, GAFI).
Sé preciso, conciso y usa terminología regulatoria correcta."""


# =============================================================================
# HOOKS — observan el ciclo del agente sin modificar su lógica
# Cada tool_use y mensaje se persiste directo en BD — sin acumular en memoria
# =============================================================================

def _make_audit_hook(analisis_id: int, ople_id: str):
    """
    Fábrica del hook de auditoría.
    Cada evento relevante se append al historial_raw en BD usando jsonb_insert.
    Sin acumulación en memoria — el raw vive solo en BD.
    """
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
                "tool": tr.get("tool_use_id", "") if isinstance(tr, dict) else "",
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
            # persiste directo en BD — append al array JSONB sin cargar todo en memoria
            execute("""
                UPDATE surveillance.analisis_alerta
                SET historial_raw = historial_raw || %s::jsonb
                WHERE id = %s
            """, (json.dumps([entrada], default=str), analisis_id))
            print(f"[AUDIT] analisis={analisis_id} | {entrada['tipo']} | {entrada.get('tool') or entrada.get('role', '')}")

    return hook


# =============================================================================
# STEERING — interviene activamente en el flujo del agente
# Bloquea generar_rou hasta que el OPLE confirme explícitamente en Flutter
# =============================================================================

def _make_rou_guard(confirmacion_rou: bool):
    """
    Fábrica del guardarraíl para generar_rou.
    Si retorna string, Strands lo manda al modelo como rechazo
    y el agente le explica al OPLE que necesita confirmación.
    """
    def guard(tool_name: str, tool_input: dict) -> bool | str:
        # STEERING: bloquea generar_rou sin confirmación explícita del OPLE
        if tool_name == "generar_rou" and not confirmacion_rou:
            return (
                "No puedes generar el ROU sin confirmación explícita del OPLE. "
                "Indica al OPLE que confirme con el botón 'Confirmar ROU' antes de proceder."
            )
        return True

    return guard


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


def iniciar_analisis(alerta_id: int, ople_id: str) -> int:
    """
    Crea el registro de análisis en BD al abrir la alerta en Flutter.
    Retorna el analisis_id que Flutter guarda en el estado de la sesión.
    """
    rows = query("""
        INSERT INTO surveillance.analisis_alerta (alerta_id, ople_id)
        VALUES (%s, %s)
        RETURNING id
    """, (alerta_id, ople_id))
    return rows[0]["id"]


def chat(
    alerta_id: int,
    analisis_id: int,
    mensaje: str,
    historial: list[dict] | None = None,
    ople_id: str = "desconocido",
    confirmacion_rou: bool = False,
) -> dict:
    """
    Un turno de conversación.

    - alerta_id       : ID de la alerta seleccionada en Flutter
    - analisis_id     : ID del registro en analisis_alerta — creado por iniciar_analisis()
    - mensaje         : texto del OPLE en este turno
    - historial       : historial resumido que maneja Strands
                        Flutter lo guarda y manda en cada request
                        ~500 tokens por request gracias al summarizing
    - ople_id         : identificador del OPLE para auditoría
    - confirmacion_rou: True cuando el OPLE presiona "Confirmar ROU" en Flutter

    Retorna:
    {
        "respuesta": str,
        "historial": list  ← historial resumido actualizado, Flutter lo guarda
    }
    """
    historial = historial or []

    alerta_info = query("SELECT patron FROM surveillance.alertas WHERE id = %s", (alerta_id,))
    patron = alerta_info[0]["patron"] if alerta_info else ""
    system = SYSTEM_PROMPT + _cargar_skill(patron)

    # model = OllamaModel(
    #     host=os.environ.get("OLLAMA_HOST", "http://localhost:11434"),
    #     model_id=os.environ.get("OLLAMA_MODEL", "llama3.2:3b"),
    # )
    # model = BedrockModel(model_id="amazon.nova-lite-v1:0")  # ❌ descartado — guardrails agresivos bloquean respuestas con términos AML/compliance
    #                                                           # ("lavado de dinero", "financiamiento al terrorismo", "ROU") aunque el contexto sea regulatorio legítimo
    model = BedrockModel(model_id="us.anthropic.claude-haiku-4-5-20251001-v1:0")  # ~$0.25/1M input — rápido y confiable con tools

    # SUMMARIZING: cuando el historial supera 6 turnos, Haiku resume los anteriores
    # El modelo siempre recibe: resumen comprimido + turno actual (~500 tokens)
    # El raw completo se persiste en BD turno a turno desde el hook — sin límite
    conversation_manager = SummarizingConversationManager(
        summary_ratio=0.5,
        preserve_recent_messages=10,
    )
    if historial:
        conversation_manager.messages = historial

    agent = Agent(
        model=model,
        system_prompt=system,
        tools=[buscar_operaciones, consultar_legislacion, buscar_contexto_mercado, generar_rou, buscar_notas_cliente],
        conversation_manager=conversation_manager,
        callback_handler=_make_audit_hook(analisis_id, ople_id),
    )

    if not historial:
        contexto = _contexto_alerta(alerta_id)
        primer_mensaje = f"[Contexto de la alerta seleccionada]\n{contexto}\n\n{mensaje}"
        respuesta = agent(primer_mensaje)
    else:
        respuesta = agent(mensaje)

    tokens_in  = getattr(respuesta.metrics, "input_tokens",  None) or getattr(respuesta.metrics, "inputTokens",  0)
    tokens_out = getattr(respuesta.metrics, "output_tokens", None) or getattr(respuesta.metrics, "outputTokens", 0)
    print(f"[TOKENS] input={tokens_in} | output={tokens_out} | total={tokens_in + tokens_out}")

    return {
        "respuesta": str(respuesta),
        "historial": agent.messages,  # resumido — Flutter lo guarda
        "tokens": {"input": tokens_in, "output": tokens_out, "total": tokens_in + tokens_out},
    }


def cerrar_analisis(
    analisis_id: int,
    decision: str,
    justificacion: str,
) -> None:
    """
    Cierra la sesión — actualiza decision, justificacion y fin en BD.
    El historial_raw ya está completo — se fue guardando turno a turno.
    Actualiza también el estado de la alerta.

    - decision     : 'confirmada' | 'descartada' | 'escalada'
    - justificacion: narrativa del OPLE, se trunca a 500 caracteres
    """
    execute("""
        UPDATE surveillance.analisis_alerta
        SET fin           = NOW(),
            decision      = %s,
            justificacion = %s
        WHERE id = %s
    """, (decision, justificacion[:500], analisis_id))

    rows = query("SELECT alerta_id FROM surveillance.analisis_alerta WHERE id = %s", (analisis_id,))
    if rows:
        execute("""
            UPDATE surveillance.alertas SET estado = %s WHERE id = %s
        """, (decision, rows[0]["alerta_id"]))


# =============================================================================
# APRENDIZAJE: NO TODOS LOS MODELOS SON IGUALES CON TOOLS (function calling)
# =============================================================================
#
# La expectativa natural es que cualquier modelo LLM se comporte igual al usar
# tools/functions, pero la realidad es que hay diferencias importantes:
#
# MODELOS CONFIABLES CON TOOLS:
#   ✅ anthropic.claude-3-haiku / sonnet / opus
#      — Anthropic publicó la especificación de tool_use junto con el modelo.
#        Entrenado extensamente en el ciclo: razonar → llamar tool → esperar
#        resultado → continuar. Respeta tipos de parámetros (int, str, etc.).
#
#   ✅ amazon.nova-pro-v1
#      — La versión Pro de Nova sí tiene buen soporte de function calling,
#        aunque sus guardrails de contenido son más agresivos que Claude.
#
# MODELOS CON PROBLEMAS:
#   ❌ amazon.nova-lite-v1 / nova-micro-v1
#      — Guardrails de contenido muy agresivos: bloquean respuestas que
#        contienen términos AML/compliance legítimos como "lavado de dinero",
#        "financiamiento al terrorismo" o "ROU", aunque el contexto sea
#        100% regulatorio. No apto para este dominio sin configurar guardrails
#        personalizados en la consola de Bedrock.
#
#   ❌ llama3.2:3b (Ollama local)
#      — Modelo pequeño sin fine-tuning robusto para function calling.
#        Observado en pruebas: pasa parámetros con tipo incorrecto, por ejemplo
#        alerta_id=1 (int) lo manda como "Alerta #1" (string), lo que causa
#        fallos silenciosos en las queries SQL.
#        Además tarda ~4-5 min por respuesta en CPU — inviable para demo.
#
# REGLA GENERAL:
#   Para agentes con tools en producción, usar modelos que hayan sido
#   entrenados explícitamente con function calling. El tamaño del modelo
#   importa: modelos <7B parámetros suelen ser inconsistentes con tools.
#   Claude 3 Haiku es el mejor balance costo/confiabilidad para este caso.
# =============================================================================
