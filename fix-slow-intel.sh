#!/bin/bash
# Fix for slow LLM responses on Intel Mac (CPU-only Ollama)
# Switches to llama3.2:1b (much faster on CPU) and adds timeouts

cd "$(dirname "$0")"

echo "=== Fixing slow responses for Intel Mac ==="

# Step 1: Pull the smaller 1B model
echo "[1/3] Pulling llama3.2:1b (faster for CPU-only)..."
ollama pull llama3.2:1b

# Step 2: Update .env to use 1B model
echo "[2/3] Updating .env to use llama3.2:1b..."
if [ -f .env ]; then
    # Replace the model name
    sed -i.bak 's/OLLAMA_MODEL=llama3.2/OLLAMA_MODEL=llama3.2:1b/' .env
    rm -f .env.bak
else
    cat > .env << 'ENVEOF'
ELASTICSEARCH_URL=http://localhost:9200
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.2:1b
EMBEDDING_MODEL=nomic-embed-text
ES_INDEX=knowledge-base
CHUNK_SIZE=500
CHUNK_OVERLAP=50
ENVEOF
fi

echo "Current .env:"
cat .env

# Step 3: Update nodes.py to add timeout and simplify prompts for smaller model
echo "[3/3] Optimizing agent nodes for faster responses..."

cat > src/agent/nodes.py << 'PYEOF'
"""Agent node functions - optimized for CPU-only (Intel Mac)."""
from langchain_ollama import ChatOllama
from src.config import get_settings
from src.tools.elastic_search import search_knowledge_base
from src.tools.web_search import web_search
from src.agent.state import AgentState

settings = get_settings()

# Shorter timeout for CPU-only inference
llm = ChatOllama(
    model=settings.ollama_model,
    base_url=settings.ollama_base_url,
    temperature=0,
    num_predict=256,  # Limit output tokens for speed
    timeout=120,      # 2 min timeout per call
)


def route_question(state: AgentState) -> AgentState:
    """Route: vectorstore, websearch, or direct. Simplified prompt for speed."""
    question = state["question"]

    # Simple keyword routing instead of LLM call (much faster on CPU)
    q_lower = question.lower()
    search_keywords = ["elasticsearch", "search", "index", "query", "vector",
                       "agent", "rag", "langchain", "langgraph", "mcp",
                       "embedding", "document", "knowledge", "ingest"]

    if any(kw in q_lower for kw in search_keywords):
        return {**state, "route": "vectorstore"}
    elif any(kw in q_lower for kw in ["latest", "news", "current", "today", "weather"]):
        return {**state, "route": "websearch"}
    else:
        return {**state, "route": "direct"}


def retrieve(state: AgentState) -> AgentState:
    """Retrieve documents from knowledge base."""
    question = state["question"]
    docs = search_knowledge_base.invoke(question)
    return {**state, "documents": docs}


def grade_documents(state: AgentState) -> AgentState:
    """Skip LLM grading for speed - if we got docs, use them."""
    docs = state.get("documents", "")
    if docs and len(docs.strip()) > 20:
        return {**state, "route": "relevant"}
    else:
        return {**state, "route": "not_relevant"}


def generate(state: AgentState) -> AgentState:
    """Generate answer from retrieved documents."""
    question = state["question"]
    documents = state.get("documents", "")

    prompt = f"""Answer based on this context. Be concise.

Context: {documents[:1500]}

Question: {question}
Answer:"""

    response = llm.invoke(prompt)
    return {**state, "generation": response.content}


def web_search_node(state: AgentState) -> AgentState:
    """Search the web."""
    question = state["question"]
    results = web_search.invoke(question)
    return {**state, "web_results": results}


def generate_with_web(state: AgentState) -> AgentState:
    """Generate from web results."""
    question = state["question"]
    web_results = state.get("web_results", "")

    prompt = f"""Answer based on these web results. Be concise.

Web Results: {web_results[:1500]}

Question: {question}
Answer:"""

    response = llm.invoke(prompt)
    return {**state, "generation": response.content}


def direct_response(state: AgentState) -> AgentState:
    """Direct LLM response."""
    question = state["question"]
    response = llm.invoke(question)
    return {**state, "generation": response.content}
PYEOF

echo ""
echo "=== Done! Changes made: ==="
echo "1. Pulled llama3.2:1b (1B params = ~3x faster than 3B on CPU)"
echo "2. Updated .env to use llama3.2:1b"
echo "3. Optimized agent nodes:"
echo "   - Keyword routing instead of LLM call (instant)"
echo "   - Skip LLM doc grading (instant)"
echo "   - Shorter prompts + 256 token limit"
echo "   - 2 min timeout per LLM call"
echo ""
echo "Now restart Streamlit:"
echo "  source .venv/bin/activate"
echo "  streamlit run src/ui/app.py"

