from datetime import datetime, timezone
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from detectors.structuring   import handler as structuring
from detectors.wash_trading  import handler as wash_trading
from detectors.dormant       import handler as dormant
from detectors.concentration import handler as concentration
from detectors.spoofing      import handler as spoofing

DETECTORES = [structuring, wash_trading, dormant, concentration, spoofing]


def run(fecha_jornada: str | None = None) -> dict:
    fecha = str(fecha_jornada or datetime.now(timezone.utc).date())
    resultados = {}

    for detector in DETECTORES:
        nombre = detector.__name__.split(".")[-2]  # e.g. "structuring"
        try:
            alertas = detector.run(fecha)
            resultados[nombre] = {"alertas": alertas}
        except Exception as e:
            print(f"[orchestrator] {nombre} falló: {e}")
            resultados[nombre] = {"alertas": 0, "error": str(e)}

    total = sum(v["alertas"] for v in resultados.values())
    print(f"[orchestrator] {fecha}: {total} alertas totales — {resultados}")
    return {"fecha": fecha, "total": total, "detectors": resultados}


def lambda_handler(event: dict, context) -> dict:
    fecha = event.get("fecha_jornada") or str(datetime.now(timezone.utc).date())
    return run(fecha)


if __name__ == "__main__":
    import sys as _sys
    fecha_arg = _sys.argv[1] if len(_sys.argv) > 1 else None
    run(fecha_arg)
