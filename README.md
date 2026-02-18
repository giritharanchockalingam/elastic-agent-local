# Elastic Agent Local

A **$0-cost local implementation** of the [Elastic AI Agent Builder](https://www.elastic.co/search-labs/blog/ai-agentic-workflows-elastic-ai-agent-builder) architecture using 100% free, open-source components. No API keys, no cloud bills, no Enterprise license — everything runs on your Mac.

---

## What Is This?

In October 2025, Elastic announced **AI Agent Builder** — a platform for building context-driven AI agents powered by Elasticsearch. It reached [general availability in January 2026](https://www.elastic.co/search-labs/blog/agent-builder-elastic-ga) with support for [MCP](https://www.elastic.co/search-labs/blog/agent-builder-mcp-reference-architecture-elasticsearch) (Model Context Protocol) and [A2A](https://www.elastic.co/search-labs/blog/a2a-protocol-mcp-llm-agent-newsroom-elasticsearch) (Agent-to-Agent) protocols.

**The problem:** Agent Builder requires an Elastic Cloud or Enterprise license.

**This project** replicates the core architecture — adaptive RAG with routing, grading, and tool use — using only free components you can run locally.

---

## Why the Hype?

The excitement around Elastic's Agent Builder stems from three converging trends:

### 1. Agentic RAG (the research breakthrough)

Traditional RAG follows a rigid retrieve-then-generate pipeline. A [January 2025 survey paper on arXiv](https://arxiv.org/abs/2501.09136) formalized **Agentic RAG** — embedding autonomous agents into the RAG pipeline with design patterns like reflection, planning, tool use, and multi-agent collaboration. Instead of a fixed pipeline, agents dynamically decide what to fetch, which tools to call, when to re-query, and how to verify answers.

### 2. Context Engineering (Elastic's approach)

Elastic positions Agent Builder as a **context engineering platform** — going beyond simple vector search to intelligently select tools, prepare data, and deliver precisely the right context to LLMs. This means the agent doesn't just search; it understands data structure, translates natural language into optimized queries (semantic, hybrid, or structured), and returns only what matters.

### 3. Open Protocols (MCP + A2A)

Agent Builder natively supports **MCP** (standardized tool access — works with Claude Desktop, Cursor, VS Code) and **A2A** (agent-to-agent coordination for multi-agent workflows). This interoperability, combined with partnerships like Microsoft Foundry integration, positions it as an enterprise-grade platform rather than a demo.

---

## Architecture

This project implements the **Adaptive RAG** pattern from the Elastic blog:

```
                         ┌──────────────┐
                         │  User Query  │
                         └──────┬───────┘
                                │
                         ┌──────▼───────┐
                         │    Router    │  ← Keyword matching (instant)
                         └──────┬───────┘
                    ┌───────────┼───────────┐
                    │           │           │
             ┌──────▼──┐ ┌─────▼────┐ ┌────▼───────┐
             │  Vector  │ │   Web    │ │   Direct   │
             │  Search  │ │  Search  │ │  Response  │
             └──────┬───┘ └─────┬────┘ └────┬───────┘
                    │           │           │
             ┌──────▼──┐       │           │
             │  Grade  │       │           │
             │  Docs   │       │           │
             └──────┬───┘       │           │
              ┌─────┼─────┐    │           │
              │           │    │           │
        ┌─────▼───┐ ┌─────▼────▼┐          │
        │ Generate │ │ Generate  │          │
        │ from KB  │ │ from Web  │          │
        └─────┬───┘ └─────┬─────┘          │
              │           │                │
              └───────────┴────────────────┘
                          │
                   ┌──────▼───────┐
                   │   Response   │
                   └──────────────┘
```

### How It Maps to Elastic Agent Builder

| Elastic Agent Builder (Enterprise)      | This Project (Free)                    |
|-----------------------------------------|----------------------------------------|
| Elasticsearch Cloud                     | Elasticsearch 8.17 (Docker, local)     |
| Elastic AI Connector (OpenAI/Azure)     | Ollama + llama3.2 (local LLM)          |
| Elastic Learned Sparse Encoder          | nomic-embed-text (local embeddings)    |
| Agent Builder orchestration             | LangGraph StateGraph                   |
| Agent Builder built-in search tool      | LangChain ElasticsearchStore           |
| Agent Builder custom tools (MCP)        | DuckDuckGo search + Calculator tools   |
| Kibana Agent Chat UI                    | Streamlit chat interface               |
| Elastic Workflows (YAML)               | LangGraph conditional edges            |

---

## Tech Stack

| Component             | Version    | Role                                  |
|-----------------------|------------|---------------------------------------|
| **Elasticsearch**     | 8.17       | Vector store + hybrid search          |
| **Kibana**            | 8.17       | Data visualization (optional)         |
| **Ollama**            | latest     | Local LLM inference server            |
| **llama3.2** (3B)     | latest     | Reasoning and generation              |
| **nomic-embed-text**  | latest     | Document embeddings (768-dim)         |
| **LangGraph**         | 1.0+       | Agent workflow orchestration          |
| **LangChain**         | 1.0+       | Tool framework and integrations       |
| **Streamlit**         | 1.40+      | Chat UI                               |
| **DuckDuckGo Search** | 7.0+       | Web search fallback (no API key)      |
| **Docker Compose**    | v2         | Container orchestration               |

---

## Prerequisites

- **Docker Desktop** — [docker.com](https://www.docker.com/products/docker-desktop)
- **Ollama** — [ollama.com](https://ollama.com)
- **Python 3.11+** — `python3 --version`
- **~8 GB free RAM** (Elasticsearch needs ~2 GB, Ollama needs ~4 GB for llama3.2)

---

## Quick Start

### One Command

```bash
# Apple Silicon Mac
bash start.sh

# Intel Mac
/bin/bash start.sh
```

This starts everything: Docker, Elasticsearch, Kibana, Ollama, pulls models, installs Python deps, ingests documents, and launches the chat UI at http://localhost:8501.

### Step by Step

```bash
# 1. Clone the repo
git clone https://github.com/giritharanchockalingam/elastic-agent-local.git
cd elastic-agent-local

# 2. Copy environment file
cp .env.example .env

# 3. Start Elasticsearch + Kibana
docker compose up -d

# 4. Pull Ollama models
ollama pull llama3.2
ollama pull nomic-embed-text

# 5. Create Python virtual environment
python3 -m venv .venv
source .venv/bin/activate
pip install -e "."

# 6. Ingest sample documents
python -m src.ingest.loader

# 7. Launch the chat UI
streamlit run src/ui/app.py
```

Open http://localhost:8501 in your browser.

---

## Project Structure

```
elastic-agent-local/
├── docker-compose.yml          # Elasticsearch 8.17 + Kibana
├── pyproject.toml              # Python dependencies
├── start.sh                    # One-command startup script
├── .env.example                # Environment config template
├── data/
│   ├── sample-elasticsearch.txt  # Sample: ES features & Query DSL
│   └── sample-agents.txt        # Sample: AI agents & RAG patterns
├── src/
│   ├── config.py               # Pydantic Settings (loads .env)
│   ├── ingest/
│   │   └── loader.py           # Document chunking & embedding pipeline
│   ├── tools/
│   │   ├── elastic_search.py   # Vector similarity search tool
│   │   ├── web_search.py       # DuckDuckGo search fallback
│   │   └── calculator.py       # Safe math expression evaluator
│   ├── agent/
│   │   ├── state.py            # AgentState TypedDict schema
│   │   ├── nodes.py            # 7 workflow nodes (route, retrieve, grade, generate...)
│   │   └── graph.py            # LangGraph StateGraph definition
│   └── ui/
│       └── app.py              # Streamlit chat interface
└── tests/
    ├── test_tools.py           # Tool unit tests (placeholder)
    └── test_agent.py           # Agent integration tests (placeholder)
```

---

## Configuration

All settings are in `.env` (copy from `.env.example`):

```env
ELASTICSEARCH_URL=http://localhost:9200
ES_INDEX_NAME=knowledge-base
OLLAMA_BASE_URL=http://localhost:11434
LLM_MODEL=llama3.2
EMBEDDING_MODEL=nomic-embed-text
CHUNK_SIZE=500
CHUNK_OVERLAP=50
```

### Model Options

| Model               | Size   | Speed        | Quality    | Best For             |
|----------------------|--------|-------------|------------|----------------------|
| llama3.2 (default)   | 2 GB   | Fast (GPU)  | Good       | Apple Silicon Macs   |
| llama3.2:1b          | 1.3 GB | Faster      | Acceptable | Intel Macs (CPU)     |
| llama3.1:8b          | 4.7 GB | Slower      | Better     | Quality-focused      |
| mistral              | 4.1 GB | Medium      | Good       | Alternative          |

To change models, update `LLM_MODEL` in `.env` and pull with `ollama pull <model>`.

---

## Usage Examples

**Knowledge base query** (routes to Elasticsearch):
> "What is Elasticsearch and how does it handle vector search?"

**Web search** (routes to DuckDuckGo):
> "What's the latest news about AI agents?"

**Direct response** (no retrieval needed):
> "Hello! What can you help me with?"

**Add your own documents:**
Drop `.txt` or `.md` files into the `data/` folder and re-run ingestion:
```bash
source .venv/bin/activate
python -m src.ingest.loader
```

---

## Troubleshooting

### Intel Mac: "Bad CPU type in executable"

If you see `bash: /opt/homebrew/bin/bash: Bad CPU type in executable`, your Intel Mac has ARM Homebrew binaries in PATH. Fix:

```bash
/bin/bash start.sh    # Use system bash instead
```

Also consider using `llama3.2:1b` for faster CPU inference — edit `.env`:
```
LLM_MODEL=llama3.2:1b
```

### Elasticsearch won't start

Check Docker memory allocation (needs at least 4 GB for Docker Desktop):
```bash
docker compose logs elasticsearch
```

### Ollama model pull fails

Ensure Ollama is running:
```bash
ollama serve    # Start Ollama
ollama list     # Check installed models
```

### Streamlit shows "Ollama: Not reachable"

Verify Ollama is running at the expected URL:
```bash
curl http://localhost:11434/api/tags
```

---

## How It Was Built

This project was built entirely through **vibecoding** — using AI-assisted development (Claude via Cowork) to architect, implement, and deploy the full stack in a single session. The process followed a 10-phase approach from scaffolding through deployment, with iterative testing at each stage.

---

## Cost Breakdown

| Resource          | Cost      |
|-------------------|-----------|
| Elasticsearch     | $0 (OSS Docker image)    |
| Kibana            | $0 (OSS Docker image)    |
| Ollama            | $0 (open source)         |
| llama3.2          | $0 (open weights)        |
| nomic-embed-text  | $0 (open weights)        |
| LangGraph         | $0 (open source)         |
| Streamlit         | $0 (open source)         |
| DuckDuckGo Search | $0 (no API key)          |
| **Total**         | **$0**                   |

---

## References

- [How to Build AI Agentic Workflows with Elasticsearch](https://www.elastic.co/search-labs/blog/ai-agentic-workflows-elastic-ai-agent-builder) — The original Elastic blog post this project replicates
- [Agent Builder GA Announcement](https://www.elastic.co/search-labs/blog/agent-builder-elastic-ga) — General availability with MCP and A2A
- [Agentic RAG Survey Paper (arXiv 2501.09136)](https://arxiv.org/abs/2501.09136) — Academic survey on Agentic RAG architectures
- [Elastic Agent Builder + MCP Reference Architecture](https://www.elastic.co/search-labs/blog/agent-builder-mcp-reference-architecture-elasticsearch) — MCP integration patterns
- [A2A Protocol + MCP in Elasticsearch](https://www.elastic.co/search-labs/blog/a2a-protocol-mcp-llm-agent-newsroom-elasticsearch) — Multi-agent workflows
- [Elastic AI Agent Builder: Context Engineering](https://www.elastic.co/search-labs/blog/elastic-ai-agent-builder-context-engineering-introduction) — Context engineering deep dive

---

## License

MIT
