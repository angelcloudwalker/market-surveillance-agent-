#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD="$ROOT/build"
mkdir -p "$BUILD"

echo "==> Limpiando build anterior..."
rm -f "$BUILD"/*.zip

# =============================================================================
# Layer — psycopg2-binary + shared/
# =============================================================================
echo "==> Construyendo layer (Docker — linux/amd64)..."
LAYER_DIR=$(mktemp -d)
mkdir -p "$LAYER_DIR/python"

pip install psycopg2-binary \
  --platform manylinux2014_x86_64 \
  --implementation cp \
  --python-version 3.12 \
  --only-binary=:all: \
  -t "$LAYER_DIR/python" -q

# shared/db.py disponible como `from shared.db import ...`
mkdir -p "$LAYER_DIR/python/shared"
cp "$ROOT/agents/shared/db.py" "$LAYER_DIR/python/shared/db.py"
touch "$LAYER_DIR/python/shared/__init__.py"

cd "$LAYER_DIR" && zip -r "$BUILD/layer.zip" python -x "*.pyc" -x "*/__pycache__/*" > /dev/null
rm -rf "$LAYER_DIR"
echo "    layer.zip — OK"

# =============================================================================
# Función para empacar un detector
# pack_detector <nombre> <directorio>
# =============================================================================
pack_detector() {
    local name="$1"
    local dir="$2"
    local tmp=$(mktemp -d)

    cp "$dir/handler.py" "$tmp/handler.py"

    # Copiar todos los .sql del directorio
    for sql in "$dir"/*.sql; do
        [ -f "$sql" ] && cp "$sql" "$tmp/"
    done

    cd "$tmp" && zip -r "$BUILD/${name}.zip" . -x "*.pyc" -x "*/__pycache__/*" > /dev/null
    rm -rf "$tmp"
    echo "    ${name}.zip — OK"
}

# =============================================================================
# Detectores
# =============================================================================
echo "==> Empacando detectores..."
pack_detector "detector_structuring"   "$ROOT/agents/detectors/structuring"
pack_detector "detector_wash_trading"  "$ROOT/agents/detectors/wash_trading"
pack_detector "detector_spoofing"      "$ROOT/agents/detectors/spoofing"
pack_detector "detector_concentration" "$ROOT/agents/detectors/concentration"
pack_detector "detector_dormant"       "$ROOT/agents/detectors/dormant"

# =============================================================================
# Orquestador
# =============================================================================
echo "==> Empacando orquestador..."
tmp=$(mktemp -d)
cp "$ROOT/agents/orchestrator/handler.py" "$tmp/handler.py"
cd "$tmp" && zip -r "$BUILD/orchestrator.zip" . -x "*.pyc" > /dev/null
rm -rf "$tmp"
echo "    orchestrator.zip — OK"

echo "==> Build completo."
ls -lh "$BUILD"/*.zip
