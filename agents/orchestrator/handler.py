import json
import os
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone

import boto3

DETECTORS = [
    "detector-wash-trading",
    "detector-spoofing",
    "detector-concentration",
    "detector-dormant",
    "detector-structuring",
]

# TODO: siguiente ciclo — async + tabla surveillance.ejecuciones para tracking de progreso


def _invoke(client, function_name: str, fecha: str) -> tuple[str, dict]:
    patron = function_name.replace("detector-", "").replace("-", "_")
    try:
        response = client.invoke(
            FunctionName=function_name,
            InvocationType="RequestResponse",
            Payload=json.dumps({"fecha_jornada": fecha}),
        )
        result = json.loads(response["Payload"].read())
        return patron, result
    except Exception as e:
        print(f"[orchestrator] {function_name} falló: {e}")
        return patron, {"alertas": 0, "error": str(e)}


def run(fecha: str) -> dict:
    client = boto3.client("lambda", region_name=os.environ.get("AWS_REGION", "us-east-1"))
    resultados = {}

    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = {
            executor.submit(_invoke, client, name, fecha): name
            for name in DETECTORS
        }
        for future in as_completed(futures):
            patron, result = future.result()
            resultados[patron] = result

    total = sum(v.get("alertas", 0) for v in resultados.values())
    print(f"[orchestrator] {fecha}: {total} alertas totales — {resultados}")
    return {"fecha": fecha, "total": total, "detectors": resultados}


def lambda_handler(event: dict, context) -> dict:
    # API Gateway HTTP API envía el body como string en event["body"]
    if "body" in event and event["body"]:
        try:
            body = json.loads(event["body"])
        except (json.JSONDecodeError, TypeError):
            body = {}
    else:
        body = event
    fecha = body.get("fecha_jornada") or str(datetime.now(timezone.utc).date())
    return run(fecha)


if __name__ == "__main__":
    import sys
    run(sys.argv[1] if len(sys.argv) > 1 else str(datetime.now(timezone.utc).date()))
