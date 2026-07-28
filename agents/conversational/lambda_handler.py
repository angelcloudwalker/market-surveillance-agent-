import json
import os
import sys
from pathlib import Path

# Lambda layer monta en /opt/python — ajustar path para imports
sys.path.insert(0, "/opt/python")
sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from handler import iniciar_analisis, chat, cerrar_analisis


def lambda_handler(event: dict, context) -> dict:
    body = event.get("body")
    if body:
        try:
            data = json.loads(body)
        except (json.JSONDecodeError, TypeError):
            return {"statusCode": 400, "body": json.dumps({"error": "body inválido"})}
    else:
        data = event

    accion = data.get("accion", "chat")

    try:
        if accion == "iniciar":
            analisis_id = iniciar_analisis(
                alerta_id=int(data["alerta_id"]),
                ople_id=data.get("ople_id", "desconocido"),
            )
            result = {"analisis_id": analisis_id}

        elif accion == "chat":
            result = chat(
                alerta_id=int(data["alerta_id"]),
                analisis_id=int(data["analisis_id"]),
                mensaje=data["mensaje"],
                historial=data.get("historial"),
                ople_id=data.get("ople_id", "desconocido"),
                confirmacion_rou=bool(data.get("confirmacion_rou", False)),
            )

        elif accion == "cerrar":
            cerrar_analisis(
                analisis_id=int(data["analisis_id"]),
                decision=data["decision"],
                justificacion=data.get("justificacion", ""),
            )
            result = {"ok": True}

        else:
            return {"statusCode": 400, "body": json.dumps({"error": f"accion desconocida: {accion}"})}

    except KeyError as e:
        return {"statusCode": 400, "body": json.dumps({"error": f"campo requerido: {e}"})}
    except Exception as e:
        print(f"[conversational] error: {e}")
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(result, default=str),
    }
