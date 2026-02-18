#!/usr/bin/env bash
###############################################################################
# start.sh — One-command startup for Elastic Agent Local
#
# Starts Docker (ES + Kibana), Ollama, pulls models, installs Python deps,
# ingests documents, and launches the Streamlit chat UI.
#
# Usage:
#   Apple Silicon Mac:  bash start.sh
#   Intel Mac:          /bin/bash start.sh
###############################################################################

set -e
cd "$(dirname "$0")"

echo ""
echo "==========================================="
echo "  ⚡ Elastic Agent Local — Starting Up"
echo "==========================================="
echo ""

# ── [1/7] Docker ──
echo "[1/7] Checking Docker..."
if ! command -v docker &>/dev/null; then
    echo "  ✗ Docker not found. Install Docker Desktop: https://docker.com/products/docker-desktop"
    exit 1
fi
if ! docker info &>/dev/null; then
    echo "  ✗ Docker is not running. Please start Docker Desktop."
    exit 1
fi
echo "  ✓ Docker is running"

# ── [2/7] Elasticsearch + Kibana ──
echo "[2/7] Starting Elasticsearch + Kibana..."
docker compose up -d
echo "  Waiting for Elasticsearch..."
until curl -fsSL http://localhost:9200/_cluster/health &>/dev/null; do
    sleep 3
done
echo "  ✓ Elasticsearch is ready"

# ── [3/7] Ollama ──
echo "[3/7] Checking Ollama..."
if ! command -v ollama &>/dev/null; then
    echo "  ✗ Ollama not found. Install from: https://ollama.com"
    exit 1
fi
if ! curl -fsSL http://localhost:11434/api/tags &>/dev/null; then
    echo "  Starting Ollama..."
    ollama serve &>/dev/null &
    sleep 5
fi
echo "  ✓ Ollama is running"

# ── [4/7] Pull models ──
echo "[4/7] Pulling models (if needed)..."
ollama pull llama3.2 2>/dev/null || true
ollama pull nomic-embed-text 2>/dev/null || true
echo "  ✓ Models ready"

# ── [5/7] Python environment ──
echo "[5/7] Setting up Python environment..."
if [ ! -d .venv ]; then
    python3 -m venv .venv
fi
source .venv/bin/activate
pip install -e "." --quiet
echo "  ✓ Python dependencies installed"

# ── [6/7] Ingest documents ──
echo "[6/7] Ingesting documents..."
INDEX_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9200/knowledge-base)
if [ "$INDEX_EXISTS" = "200" ]; then
    COUNT=$(curl -s http://localhost:9200/knowledge-base/_count | python3 -c "import sys,json; print(json.load(sys.stdin).get('count',0))")
    if [ "$COUNT" -gt "0" ]; then
        echo "  ✓ Index already has $COUNT chunks — skipping ingestion"
    else
        python -m src.ingest.loader
    fi
else
    python -m src.ingest.loader
fi

# ── [7/7] Launch UI ──
echo "[7/7] Launching Streamlit UI..."
echo ""
echo "==========================================="
echo "  ✅ All systems go!"
echo "  📊 Kibana:      http://localhost:5601"
echo "  🔍 Elasticsearch: http://localhost:9200"
echo "  💬 Chat UI:     http://localhost:8501"
echo "==========================================="
echo ""
streamlit run src/ui/app.py
