#!/usr/bin/env bash
# Fix for Intel Mac compatibility
# Run: cd ~/Projects/GitHub/elastic-agent-local && bash fix-intel.sh
set -e
echo "Fixing Intel Mac compatibility..."

# Fix start.sh — rewrite with /usr/bin/env bash shebang
cat > start.sh << 'STARTEOF'
#!/usr/bin/env bash
# One-command startup for elastic-agent-local
# Usage: bash start.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  elastic-agent-local — Local AI Agent Stack${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ── Check Docker ──
echo -e "${YELLOW}[1/7] Checking Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Install it from https://docker.com${NC}"
    exit 1
fi
if ! docker info &> /dev/null; then
    echo -e "${RED}Docker is not running. Start Docker Desktop and try again.${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Docker is running${NC}"

# ── Start Elasticsearch + Kibana ──
echo -e "${YELLOW}[2/7] Starting Elasticsearch + Kibana...${NC}"
docker compose up -d
echo -e "  Waiting for Elasticsearch to be healthy..."
for i in $(seq 1 30); do
    if curl -s http://localhost:9200/_cluster/health > /dev/null 2>&1; then
        echo -e "${GREEN}  ✓ Elasticsearch is ready (localhost:9200)${NC}"
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo -e "${RED}  Elasticsearch failed to start. Run: docker compose logs elasticsearch${NC}"
        exit 1
    fi
    sleep 2
done
echo -e "${GREEN}  ✓ Kibana is starting (localhost:5601)${NC}"

# ── Check Ollama ──
echo -e "${YELLOW}[3/7] Checking Ollama...${NC}"
if ! command -v ollama &> /dev/null; then
    echo -e "${RED}Ollama is not installed.${NC}"
    echo -e "${RED}  macOS: brew install ollama${NC}"
    echo -e "${RED}  Linux: curl -fsSL https://ollama.com/install.sh | sh${NC}"
    exit 1
fi
if ! curl -s http://localhost:11434 > /dev/null 2>&1; then
    echo -e "  Starting Ollama..."
    if command -v brew &> /dev/null; then
        brew services start ollama 2>/dev/null || nohup ollama serve > /dev/null 2>&1 &
    else
        nohup ollama serve > /dev/null 2>&1 &
    fi
    sleep 5
fi
echo -e "${GREEN}  ✓ Ollama is running (localhost:11434)${NC}"

# ── Pull models ──
echo -e "${YELLOW}[4/7] Pulling LLM models (if needed)...${NC}"
if ! ollama list 2>/dev/null | grep -q "llama3.2"; then
    echo -e "  Pulling llama3.2 (~2GB)..."
    ollama pull llama3.2
else
    echo -e "  llama3.2 already pulled"
fi
if ! ollama list 2>/dev/null | grep -q "nomic-embed-text"; then
    echo -e "  Pulling nomic-embed-text (~274MB)..."
    ollama pull nomic-embed-text
else
    echo -e "  nomic-embed-text already pulled"
fi
echo -e "${GREEN}  ✓ Models ready${NC}"

# ── Python environment ──
echo -e "${YELLOW}[5/7] Setting up Python environment...${NC}"
PYTHON_CMD=""
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo -e "${RED}Python 3.11+ is required. Install from https://python.org${NC}"
    exit 1
fi

if [ ! -d ".venv" ]; then
    $PYTHON_CMD -m venv .venv
    echo -e "  Created virtual environment"
fi
source .venv/bin/activate
if ! pip show elastic-agent-local > /dev/null 2>&1; then
    pip install -e ".[dev]" -q
    echo -e "  Installed dependencies"
else
    echo -e "  Dependencies already installed"
fi
echo -e "${GREEN}  ✓ Python environment ready${NC}"

# ── Copy .env ──
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo -e "  Created .env from .env.example"
fi

# ── Ingest documents ──
echo -e "${YELLOW}[6/7] Checking document ingestion...${NC}"
DOC_COUNT=$(curl -s "http://localhost:9200/knowledge-base/_count" 2>/dev/null | $PYTHON_CMD -c "import sys,json; print(json.load(sys.stdin).get('count',0))" 2>/dev/null || echo "0")
if [ "$DOC_COUNT" = "0" ]; then
    echo -e "  Index is empty — ingesting sample documents..."
    python -m src.ingest.loader
else
    echo -e "  Index has $DOC_COUNT chunks — skipping ingestion"
fi
echo -e "${GREEN}  ✓ Knowledge base ready${NC}"

# ── Launch UI ──
echo -e "${YELLOW}[7/7] Launching chat UI...${NC}"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  All systems go! Opening http://localhost:8501${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Elasticsearch:  http://localhost:9200"
echo -e "  Kibana:         http://localhost:5601"
echo -e "  Chat UI:        http://localhost:8501"
echo -e "  Ollama:         http://localhost:11434"
echo ""
echo -e "  Press Ctrl+C to stop the chat UI."
echo ""
streamlit run src/ui/app.py
STARTEOF

chmod +x start.sh

# Also update README to note Intel Mac compatibility
echo ""
echo "✅ Fixed!"
echo "  - start.sh now uses #!/usr/bin/env bash (works on Intel + Apple Silicon)"
echo "  - Added Linux install instructions for Ollama"
echo "  - Python detection works with python3 or python"
echo ""
echo "Now run:  bash start.sh"

