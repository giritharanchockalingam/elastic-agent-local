# elastic-agent-local

A **$0-cost, fully local** agentic RAG system that replicates the [Elastic AI Agent Builder](https://www.elastic.co/search-labs/blog/ai-agentic-workflows-elastic-ai-agent-builder) architecture using 100% free, open-source components.

No API keys. No cloud subscriptions. No data leaves your machine.

```
User  →  Streamlit UI  →  LangGraph Agent  →  Tools
                                                 ├── Elasticsearch (vector search)
                                                 ├── DuckDuckGo (web fallback)
                                                 └── Calculator
                            ↕
                        Ollama (local LLM)
```

## Architecture

This project mirrors the five pillars of Elastic's AI Agent Builder:

| Elastic Agent Builder (Enterprise) | This Project ($0)              |
|------------------------------------|--------------------------------|
| Elastic Cloud + Enterprise license | Elasticsearch 8.17 (Docker)    |
| Elastic-managed LLM connector      | Ollama (local LLMs)            |
| Agent Builder orchestration         | LangGraph + LangChain          |
| Built-in tools & MCP server         | Custom tools + open MCP        |
| Kibana Agent Builder UI             | Streamlit chat interface        |

### Agent Workflow

The LangGraph agent uses an **Adaptive RAG** pattern with routing, retrieval, grading, and fallback:

```
START → route_question
  ├─ 'vectorstore' → retrieve → grade_documents
  │                               ├─ relevant docs → generate → END
  │                               └─ no relevant docs → web_search → generate_with_web → END
  ├─ 'websearch'   → web_search → generate_with_web → END
  └─ 'direct'      → direct_response → END
```

The router LLM classifies each question and dynamically selects the best path.

## Tech Stack

| Component        | Version   | Port  | Purpose                        |
|------------------|-----------|-------|--------------------------------|
| Elasticsearch    | 8.17      | 9200  | Vector store + hybrid search   |
| Kibana           | 8.17      | 5601  | Data management UI             |
| Ollama           | latest    | 11434 | Local LLM inference            |
| llama3.2         | 3B        | —     | Reasoning and generation       |
| nomic-embed-text | 274MB     | —     | Document & query embeddings    |
| LangGraph        | 1.0+      | —     | Agent workflow orchestration   |
| LangChain        | 1.0+      | —     | Tool framework & integrations  |
| Streamlit        | 1.54+     | 8501  | Chat UI                        |
| Python           | 3.11+     | —     | Runtime                        |
| Docker           | latest    | —     | Container runtime              |

## Prerequisites

Install these before starting:

- **Docker Desktop** — [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)
- **Python 3.11+** — [python.org](https://www.python.org/) (or via `brew install python`)
- **Ollama** — [ollama.com](https://ollama.com/) (or via `brew install ollama`)
- **16 GB RAM recommended** (8 GB minimum — use smaller models)

### macOS (Homebrew)

```bash
brew install python ollama
brew install --cask docker
```

### Verify prerequisites

```bash
docker --version        # Docker version 27.x+
python3 --version       # Python 3.11+
ollama --version        # ollama version 0.15+
```

## Quick Start

### Option A: One-command startup

```bash
git clone <this-repo> && cd elastic-agent-local
bash start.sh
```

### Option B: Step by step

```bash
# 1. Clone and enter the project
git clone <this-repo>
cd elastic-agent-local

# 2. Copy environment config
cp .env.example .env

# 3. Start Elasticsearch + Kibana
docker compose up -d

# 4. Wait for Elasticsearch to be healthy (takes ~30 seconds)
until curl -s http://localhost:9200 > /dev/null 2>&1; do
  echo "Waiting for Elasticsearch..."
  sleep 5
done
echo "Elasticsearch is ready!"

# 5. Start Ollama and pull models
brew services start ollama    # macOS
# OR: ollama serve &          # Linux

ollama pull llama3.2
ollama pull nomic-embed-text

# 6. Create Python virtual environment and install dependencies
python3 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"

# 7. Ingest sample documents into Elasticsearch
python -m src.ingest.loader

# 8. Launch the chat UI
streamlit run src/ui/app.py
```

Open **http://localhost:8501** in your browser. You should see the chat interface with green "Connected" status for both Elasticsearch and Ollama in the sidebar.

## Usage

### Chat Interface

The Streamlit UI at `http://localhost:8501` provides:

- **Chat input** — type any question
- **Route indicator** — shows which path the agent took (vectorstore/websearch/direct)
- **Sidebar** — connection status, model info, document count, clear chat button

### Example queries

| Query | Expected Route | What Happens |
|-------|---------------|--------------|
| "What is Elasticsearch?" | vectorstore | Retrieves from ingested docs, grades relevance, generates answer |
| "What are AI agents?" | vectorstore | Same — uses knowledge base |
| "What happened in the news today?" | websearch | Falls back to DuckDuckGo, generates from web results |
| "Hello!" | direct | Responds directly without any retrieval |
| "What is 42 * 17?" | direct | LLM answers (calculator tool available for extensions) |

### Adding your own documents

Drop `.txt` or `.md` files into the `data/` folder, then re-run ingestion:

```bash
source .venv/bin/activate
python -m src.ingest.loader
```

### Using the Makefile

```bash
make setup    # Install all dependencies
make up       # Start Elasticsearch + Kibana
make down     # Stop containers
make ingest   # Run the document ingestion pipeline
make chat     # Launch the Streamlit UI
make test     # Run pytest
make clean    # Remove ES data volume and reset
make all      # Full setup + ingest + launch
```

### Running the agent from the command line

```bash
source .venv/bin/activate
python -m src.agent.graph
```

This runs a quick test with "Hello, what can you help me with?" and prints the response and route.

## Project Structure

```
elastic-agent-local/
├── docker-compose.yml           # Elasticsearch 8.17 + Kibana (Docker)
├── pyproject.toml               # Python dependencies
├── .env.example                 # Environment variable template
├── .env                         # Your local config (gitignored)
├── start.sh                     # One-command startup script
├── Makefile                     # Common operations
├── README.md                    # This file
│
├── src/
│   ├── config.py                # Pydantic Settings (loads from .env)
│   │
│   ├── agent/                   # LangGraph agent core
│   │   ├── state.py             # AgentState TypedDict
│   │   ├── nodes.py             # Node functions (route, retrieve, grade, generate)
│   │   └── graph.py             # StateGraph workflow assembly
│   │
│   ├── tools/                   # Agent tools
│   │   ├── elastic_search.py    # Elasticsearch similarity search (@tool)
│   │   ├── web_search.py        # DuckDuckGo web search fallback (@tool)
│   │   └── calculator.py        # Safe math expression evaluator (@tool)
│   │
│   ├── ingest/                  # Data ingestion pipeline
│   │   └── loader.py            # Load → Chunk → Embed → Store in ES
│   │
│   └── ui/
│       └── app.py               # Streamlit chat interface
│
├── data/                        # Documents to ingest (add your .txt/.md files here)
│   ├── sample-elasticsearch.txt # Sample: Elasticsearch concepts
│   └── sample-agents.txt        # Sample: AI agent patterns
│
└── tests/
    ├── test_tools.py
    └── test_agent.py
```

## Configuration

All settings are in `.env` (copied from `.env.example`):

```bash
# Elasticsearch
ELASTICSEARCH_URL=http://localhost:9200
ES_INDEX_NAME=knowledge-base

# Ollama (local LLM)
OLLAMA_BASE_URL=http://localhost:11434
LLM_MODEL=llama3.2              # Change to qwen2.5:14b for better quality
EMBEDDING_MODEL=nomic-embed-text

# Document ingestion
CHUNK_SIZE=500
CHUNK_OVERLAP=50
```

### Choosing a model

| Your RAM | Model | Command | Quality |
|----------|-------|---------|---------|
| 8 GB     | llama3.2 (3B) | `ollama pull llama3.2` | Good |
| 16 GB    | llama3.1:8b | `ollama pull llama3.1:8b` | Better |
| 32 GB    | qwen2.5:14b | `ollama pull qwen2.5:14b` | Best |

Update `LLM_MODEL` in `.env` after pulling a different model.

## Troubleshooting

### Elasticsearch won't start
```bash
docker compose logs elasticsearch    # Check for errors
docker compose down && docker compose up -d   # Restart
```

### Ollama not reachable
```bash
brew services restart ollama    # macOS
ollama list                     # Verify models are pulled
curl http://localhost:11434     # Should return "Ollama is running"
```

### "No documents found" during ingestion
Make sure you have `.txt` or `.md` files in the `data/` folder:
```bash
ls data/
```

### Pydantic V1 warning with Python 3.14
This is a harmless deprecation warning from langchain_core. It doesn't affect functionality.

### Port already in use
```bash
# Kill existing Streamlit process
lsof -ti:8501 | xargs kill -9

# Kill existing Elasticsearch
docker compose down
```

## How It Was Built

This project was built using a **vibecoding** approach — natural language prompts fed to an AI coding assistant across 10 phases:

1. **Phase 1** — Project scaffolding (pyproject.toml, docker-compose.yml, config)
2. **Phase 2** — Infrastructure setup (Docker, Ollama, Python venv)
3. **Phase 3** — Document ingestion pipeline (load → chunk → embed → store)
4. **Phase 4** — Agent tools (Elasticsearch search, DuckDuckGo, calculator)
5. **Phase 5** — Agent core (LangGraph state, nodes, workflow graph)
6. **Phase 6** — Streamlit chat UI
7. **Phase 7** — MCP integration (optional)
8. **Phase 8** — Testing
9. **Phase 9** — Deployment scripts
10. **Phase 10** — Extensions (memory, multi-agent, observability)

See `vibecoding-elastic-agent-guide.md` for the full playbook with copy-paste prompts.

## Cost Breakdown

| Resource          | Cost |
|-------------------|------|
| Elasticsearch     | $0 — Basic license, local Docker |
| Kibana            | $0 — Basic license, local Docker |
| Ollama            | $0 — Open source |
| LLM models        | $0 — Open weights, local inference |
| LangGraph/Chain   | $0 — Open source, MIT license |
| Streamlit         | $0 — Open source |
| DuckDuckGo search | $0 — Free, no API key |
| **Total**         | **$0** |

## References

- [How to Build AI Agentic Workflows with Elasticsearch](https://www.elastic.co/search-labs/blog/ai-agentic-workflows-elastic-ai-agent-builder) — Original architecture
- [Local RAG Agent with LangGraph, Llama3 & Elasticsearch](https://www.elastic.co/search-labs/blog/local-rag-agent-elasticsearch-langgraph-llama3) — Elastic's local agent tutorial
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [LangChain Ollama Integration](https://python.langchain.com/docs/integrations/providers/ollama)
- [Ollama Model Library](https://ollama.com/library)

## License

MIT
