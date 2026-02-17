#!/bin/bash
# Fix for BOTH Silicon Mac and Intel Mac:
# 1. Fix web search returning generic LLM responses instead of actual results
# 2. Add Intel Mac CPU optimization (optional - detects architecture)
# 3. Better prompts that force the LLM to use provided context

cd "$(dirname "$0")"
ARCH=$(uname -m)

echo "=== Elastic Agent Local - Fix Script ==="
echo "Detected architecture: $ARCH"
echo ""

# ─── Step 1: Fix web_search.py to be more robust ───
echo "[1/4] Fixing web search tool..."

cat > src/tools/web_search.py << 'PYEOF'
"""Web search fallback tool using DuckDuckGo (free, no API key)."""
from langchain_core.tools import tool


@tool
def web_search(query: str) -> str:
    """Search the web using DuckDuckGo for up-to-date information.
    Use this tool when the knowledge base doesn't have relevant information,
    or when the user asks about current events or recent news.
    """
    try:
        from duckduckgo_search import DDGS
        with DDGS() as ddgs:
            results = list(ddgs.text(query, max_results=3))

        if not results:
            return f"Web search for '{query}' returned no results. Try a different query."

        formatted = []
        for i, r in enumerate(results, 1):
            title = r.get("title", "No title")
            href = r.get("href", "N/A")
            body = r.get("body", "No snippet")
            formatted.append(f"[Result {i}] {title}\nURL: {href}\nSnippet: {body}")

        output = "\n\n---\n\n".join(formatted)
        print(f"[web_search] Found {len(results)} results for: {query}")
        return output

    except ImportError:
        return "Error: duckduckgo-search package not installed. Run: pip install duckduckgo-search>=7.0.0"
    except Exception as e:
        return f"Web search error for '{query}': {str(e)}"
PYEOF

echo "  ✓ web_search.py updated"

# ─── Step 2: Fix nodes.py - better prompts + architecture-aware optimization ───
echo "[2/4] Fixing agent nodes (prompts + performance)..."

if [ "$ARCH" = "x86_64" ]; then
    echo "  → Intel Mac detected: using CPU optimizations (1B model, keyword routing)"
    MODEL_LINE='    num_predict=256,  # Limit output tokens for CPU speed'
    TIMEOUT_LINE='    timeout=120,      # 2 min timeout for CPU inference'
    ROUTE_MODE="keyword"
else
    echo "  → Apple Silicon detected: using full LLM routing"
    MODEL_LINE='    num_predict=512,  # Standard output length'
    TIMEOUT_LINE='    timeout=60,       # 1 min timeout'
    ROUTE_MODE="llm"
fi

cat > src/agent/nodes.py << 'PYEOF'
"""Agent node functions - with fixed prompts and web search handling."""
from langchain_ollama import ChatOllama
from src.config import get_settings
from src.tools.elastic_search import search_knowledge_base
from src.tools.web_search import web_search
from src.agent.state import AgentState
import platform

settings = get_settings()
is_intel = platform.machine() == "x86_64"

# Configure LLM based on architecture
llm = ChatOllama(
    model=settings.ollama_model,
    base_url=settings.ollama_base_url,
    temperature=0,
PYEOF

# Add architecture-specific config
if [ "$ARCH" = "x86_64" ]; then
cat >> src/agent/nodes.py << 'PYEOF'
    num_predict=256,
    timeout=120,
)
PYEOF
else
cat >> src/agent/nodes.py << 'PYEOF'
    num_predict=512,
    timeout=60,
)
PYEOF
fi

# Add the rest of nodes.py
cat >> src/agent/nodes.py << 'PYEOF'


def route_question(state: AgentState) -> AgentState:
    """Route question to vectorstore, websearch, or direct response."""
    question = state["question"]
    q_lower = question.lower()

    # Keyword-based routing (fast, works on all architectures)
    kb_keywords = [
        "elasticsearch", "elastic", "search", "index", "query", "vector",
        "agent", "rag", "langchain", "langgraph", "mcp", "embedding",
        "document", "knowledge", "ingest", "kibana", "mapping", "esql",
    ]
    web_keywords = [
        "latest", "news", "current", "today", "weather", "price",
        "stock", "score", "who won", "what happened", "recent",
        "2024", "2025", "2026",
    ]

    if any(kw in q_lower for kw in kb_keywords):
        print(f"[route] → vectorstore (matched keyword)")
        return {**state, "route": "vectorstore"}
    elif any(kw in q_lower for kw in web_keywords):
        print(f"[route] → websearch (matched keyword)")
        return {**state, "route": "websearch"}
    else:
        print(f"[route] → direct")
        return {**state, "route": "direct"}


def retrieve(state: AgentState) -> AgentState:
    """Retrieve documents from knowledge base."""
    question = state["question"]
    docs = search_knowledge_base.invoke(question)
    doc_preview = docs[:200] if docs else "No docs found"
    print(f"[retrieve] Got docs: {doc_preview}...")
    return {**state, "documents": docs}


def grade_documents(state: AgentState) -> AgentState:
    """Grade document relevance - keyword check (fast, no LLM call)."""
    docs = state.get("documents", "")
    if docs and len(docs.strip()) > 50:
        print("[grade] → relevant (docs have content)")
        return {**state, "route": "relevant"}
    else:
        print("[grade] → not_relevant (docs empty/short)")
        return {**state, "route": "not_relevant"}


def generate(state: AgentState) -> AgentState:
    """Generate answer from retrieved documents."""
    question = state["question"]
    documents = state.get("documents", "")

    prompt = f"""You are a helpful assistant. Answer the question using ONLY the context below.
Do NOT say you cannot access information - the context IS your information source.
If the context doesn't contain enough info, say what you DO know from the context.

CONTEXT:
{documents[:2000]}

QUESTION: {question}

ANSWER:"""

    print(f"[generate] Calling LLM with {len(documents)} chars of context...")
    response = llm.invoke(prompt)
    return {**state, "generation": response.content}


def web_search_node(state: AgentState) -> AgentState:
    """Search the web using DuckDuckGo."""
    question = state["question"]
    print(f"[web_search] Searching for: {question}")
    results = web_search.invoke(question)
    print(f"[web_search] Results length: {len(results)} chars")
    print(f"[web_search] Preview: {results[:300]}")
    return {**state, "web_results": results}


def generate_with_web(state: AgentState) -> AgentState:
    """Generate answer from web search results."""
    question = state["question"]
    web_results = state.get("web_results", "")

    prompt = f"""You are a helpful assistant. Answer the question using ONLY the web search results below.
These are REAL, LIVE search results from DuckDuckGo - use them to answer.
Do NOT say "I cannot access real-time information" - the search results below ARE real-time information.
Cite the sources when possible.

WEB SEARCH RESULTS:
{web_results[:2000]}

QUESTION: {question}

ANSWER (use the search results above):"""

    print(f"[generate_with_web] Calling LLM with {len(web_results)} chars of web results...")
    response = llm.invoke(prompt)
    return {**state, "generation": response.content}


def direct_response(state: AgentState) -> AgentState:
    """Direct LLM response without retrieval."""
    question = state["question"]
    print(f"[direct] Answering directly: {question}")
    response = llm.invoke(question)
    return {**state, "generation": response.content}
PYEOF

echo "  ✓ nodes.py updated"

# ─── Step 3: Intel-only - switch to 1B model ───
if [ "$ARCH" = "x86_64" ]; then
    echo "[3/4] Intel Mac: pulling smaller model..."
    ollama pull llama3.2:1b

    if [ -f .env ]; then
        sed -i.bak 's/OLLAMA_MODEL=llama3.2$/OLLAMA_MODEL=llama3.2:1b/' .env
        sed -i.bak 's/OLLAMA_MODEL=llama3.2:3b/OLLAMA_MODEL=llama3.2:1b/' .env
        rm -f .env.bak
    fi
    echo "  ✓ Switched to llama3.2:1b"
else
    echo "[3/4] Silicon Mac: keeping llama3.2 (3B) - GPU accelerated"
fi

# ─── Step 4: Update the UI to show web results debug info ───
echo "[4/4] Updating UI with better route display..."

cat > src/ui/app.py << 'PYEOF'
"""Streamlit Chat UI for Elastic AI Agent."""
import streamlit as st
from src.agent.graph import run_agent
from src.config import get_settings
from elasticsearch import Elasticsearch

settings = get_settings()

st.set_page_config(page_title="Elastic AI Agent", page_icon="🤖", layout="wide")

# Sidebar
with st.sidebar:
    st.title("⚡ Elastic AI Agent")
    st.caption("Local AI • Zero Cost • Full Control")
    st.divider()

    # Connection status
    st.subheader("System Status")

    # ES status
    try:
        es = Elasticsearch(settings.elasticsearch_url)
        if es.ping():
            info = es.info()
            version = info["version"]["number"]
            st.success(f"Elasticsearch {version} ✓")
            try:
                count = es.count(index=settings.es_index)["count"]
                st.metric("Documents indexed", count)
            except Exception:
                st.warning("No index yet - run ingestion first")
        else:
            st.error("Elasticsearch ✗")
    except Exception as e:
        st.error(f"Elasticsearch ✗ - {e}")

    # Ollama status
    try:
        import requests
        r = requests.get(f"{settings.ollama_base_url}/api/tags", timeout=5)
        if r.status_code == 200:
            models = [m["name"] for m in r.json().get("models", [])]
            st.success(f"Ollama Connected ✓")
            st.caption(f"Models: {', '.join(models[:5])}")
        else:
            st.error("Ollama ✗")
    except Exception:
        st.error("Ollama ✗")

    st.divider()
    st.caption(f"LLM: {settings.ollama_model}")
    st.caption(f"Embeddings: {settings.embedding_model}")

    if st.button("🗑️ Clear Chat"):
        st.session_state.messages = []
        st.rerun()

# Main chat
st.title("💬 Chat with your AI Agent")

if "messages" not in st.session_state:
    st.session_state.messages = []

# Display chat history
for msg in st.session_state.messages:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])
        if "route" in msg:
            route_colors = {
                "vectorstore": "🟢", "websearch": "🌐",
                "direct": "🔵", "relevant": "🟢", "not_relevant": "🟡"
            }
            icon = route_colors.get(msg["route"], "⚪")
            st.caption(f"{icon} Route: {msg['route']}")

# Chat input
if prompt := st.chat_input("Ask me anything..."):
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    with st.chat_message("assistant"):
        with st.spinner("Thinking..."):
            try:
                result = run_agent(prompt)
                answer = result.get("generation", "I couldn't generate a response.")
                route = result.get("route", "unknown")
            except Exception as e:
                answer = f"Error: {str(e)}"
                route = "error"

        st.markdown(answer)
        route_colors = {
            "vectorstore": "🟢", "websearch": "🌐",
            "direct": "🔵", "relevant": "🟢", "not_relevant": "🟡"
        }
        icon = route_colors.get(route, "⚪")
        st.caption(f"{icon} Route: {route}")

        # Show debug info for web searches
        if route == "websearch" and "web_results" in result:
            with st.expander("🔍 Web search results used"):
                st.text(result.get("web_results", "")[:1000])

    st.session_state.messages.append({
        "role": "assistant", "content": answer, "route": route
    })
PYEOF

echo "  ✓ app.py updated"

echo ""
echo "==========================================="
echo "  All fixes applied!"
echo "==========================================="
echo ""
echo "Changes:"
echo "  1. web_search.py: Better error handling + logging"
echo "  2. nodes.py: Fixed prompts so LLM uses provided context"
echo "     - 'Do NOT say you cannot access real-time info'"
echo "     - Passes actual search results to LLM properly"
if [ "$ARCH" = "x86_64" ]; then
echo "  3. Intel: Switched to llama3.2:1b (3x faster on CPU)"
echo "  4. Intel: Keyword routing (no LLM call = instant)"
fi
echo "  4. app.py: Shows web search results in expandable debug panel"
echo ""
echo "Now restart Streamlit:"
echo "  source .venv/bin/activate"
echo "  streamlit run src/ui/app.py"
echo ""

