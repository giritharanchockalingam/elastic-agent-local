#!/bin/bash
###############################################################################
# deploy-fix.sh — ONE script to fix everything for Silicon + Intel Macs
#
# Fixes:
#   1. Web search returning "I can't access real-time info" instead of results
#   2. Intel Mac extreme slowness (CPU-only Ollama)
#   3. Correct attribute names matching config.py (UPPERCASE, LLM_MODEL, etc.)
#   4. Better prompts that force LLM to use provided context
#   5. Updated UI with debug panel for web search results
#
# Usage:
#   Silicon Mac:  bash deploy-fix.sh
#   Intel Mac:    /bin/bash deploy-fix.sh
###############################################################################

set -e
cd "$(dirname "$0")"

ARCH=$(uname -m)
echo "==========================================="
echo "  Elastic Agent Local — Deploy Fix"
echo "  Architecture: $ARCH"
echo "==========================================="
echo ""

###############################################################################
# 1. WEB SEARCH TOOL
###############################################################################
echo "[1/5] Writing src/tools/web_search.py ..."

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
        return "Error: duckduckgo-search not installed. Run: pip install duckduckgo-search>=7.0.0"
    except Exception as e:
        return f"Web search error for '{query}': {str(e)}"
PYEOF
echo "  ✓ web_search.py"

###############################################################################
# 2. ELASTIC SEARCH TOOL
###############################################################################
echo "[2/5] Writing src/tools/elastic_search.py ..."

cat > src/tools/elastic_search.py << 'PYEOF'
"""Elasticsearch knowledge base search tool."""
from langchain_core.tools import tool
from langchain_elasticsearch import ElasticsearchStore
from langchain_ollama import OllamaEmbeddings
from src.config import settings


def _get_store() -> ElasticsearchStore:
    """Create ES vector store instance."""
    embeddings = OllamaEmbeddings(
        model=settings.EMBEDDING_MODEL,
        base_url=settings.OLLAMA_BASE_URL,
    )
    return ElasticsearchStore(
        index_name=settings.ES_INDEX_NAME,
        embedding=embeddings,
        es_url=settings.ELASTICSEARCH_URL,
    )


@tool
def search_knowledge_base(query: str) -> str:
    """Search the local Elasticsearch knowledge base for relevant documents.
    Use this tool for questions about Elasticsearch, search, vectors,
    AI agents, RAG, LangChain, LangGraph, or MCP.
    """
    try:
        store = _get_store()
        results = store.similarity_search(query, k=4)

        if not results:
            return "No relevant documents found in the knowledge base."

        formatted = []
        for i, doc in enumerate(results, 1):
            source = doc.metadata.get("source", "unknown")
            formatted.append(f"[Doc {i}] (source: {source})\n{doc.page_content}")

        return "\n\n---\n\n".join(formatted)
    except Exception as e:
        return f"Knowledge base search error: {str(e)}"
PYEOF
echo "  ✓ elastic_search.py"

###############################################################################
# 3. AGENT NODES — uses ChatPromptTemplate (no f-string triple quotes!)
###############################################################################
echo "[3/5] Writing src/agent/nodes.py ..."

if [ "$ARCH" = "x86_64" ]; then
    echo "  → Intel Mac detected: will use CPU optimizations"
else
    echo "  → Apple Silicon detected: GPU accelerated"
fi

cat > src/agent/nodes.py << 'PYEOF'
"""Agent node functions for the LangGraph workflow.

Each node takes AgentState, performs an action, and returns a partial state update.

Optimized: keyword routing + skip LLM grading = only 1 LLM call per question.
This makes it fast on both Apple Silicon (GPU) and Intel (CPU-only).
"""

import platform
from langchain_core.messages import AIMessage
from langchain_core.prompts import ChatPromptTemplate
from langchain_ollama import ChatOllama

from src.config import settings
from src.tools.elastic_search import search_knowledge_base
from src.tools.web_search import web_search


def _get_llm() -> ChatOllama:
    """Create the ChatOllama LLM instance with arch-aware settings."""
    is_intel = platform.machine() == "x86_64"
    return ChatOllama(
        model=settings.LLM_MODEL,
        base_url=settings.OLLAMA_BASE_URL,
        temperature=0,
        num_predict=256 if is_intel else 512,
        timeout=120 if is_intel else 60,
    )


# ──────────────────────────────────────────────
# Node: route_question (keyword-based — no LLM call)
# ──────────────────────────────────────────────
def route_question(state: dict) -> dict:
    """Classify the question using keyword matching (instant, no LLM call)."""
    print("--- NODE: route_question ---")

    question = state["question"]
    q_lower = question.lower()

    kb_keywords = [
        "elasticsearch", "elastic", "search", "index", "query", "vector",
        "agent", "rag", "langchain", "langgraph", "mcp", "embedding",
        "document", "knowledge", "ingest", "kibana", "mapping", "esql",
        "retrieval", "chunk", "ollama",
    ]
    web_keywords = [
        "latest", "news", "current", "today", "weather", "price",
        "stock", "score", "who won", "what happened", "recent",
        "2024", "2025", "2026", "yesterday", "this week",
    ]

    if any(kw in q_lower for kw in kb_keywords):
        route = "vectorstore"
    elif any(kw in q_lower for kw in web_keywords):
        route = "websearch"
    else:
        route = "direct"

    print(f"   Route: {route}")
    return {"route": route}


# ──────────────────────────────────────────────
# Node: retrieve
# ──────────────────────────────────────────────
def retrieve(state: dict) -> dict:
    """Retrieve relevant documents from the knowledge base."""
    print("--- NODE: retrieve ---")

    question = state["question"]
    result = search_knowledge_base.invoke(question)
    documents = [result] if result else []

    print(f"   Retrieved {len(documents)} document(s)")
    return {"documents": documents}


# ──────────────────────────────────────────────
# Node: grade_documents (content check — no LLM call)
# ──────────────────────────────────────────────
def grade_documents(state: dict) -> dict:
    """Grade documents by checking content length (no LLM call for speed)."""
    print("--- NODE: grade_documents ---")

    documents = state.get("documents", [])

    if not documents:
        print("   No documents — routing to websearch")
        return {"documents": [], "route": "websearch"}

    total_content = "".join(documents)
    if len(total_content.strip()) > 50:
        print(f"   Documents look relevant ({len(total_content)} chars)")
        return {"documents": documents, "route": "vectorstore"}
    else:
        print("   Documents too short — routing to websearch")
        return {"documents": [], "route": "websearch"}


# ──────────────────────────────────────────────
# Node: generate
# ──────────────────────────────────────────────
def generate(state: dict) -> dict:
    """Generate a response using retrieved documents as context."""
    print("--- NODE: generate ---")

    llm = _get_llm()
    question = state["question"]
    documents = state.get("documents", [])
    context = "\n\n".join(documents)

    prompt = ChatPromptTemplate.from_messages([
        ("system",
         "You are a helpful assistant. Answer the user's question based ONLY on the provided context.\n"
         "Do NOT say you cannot access information — the context below IS your information source.\n"
         "If the context doesn't fully answer the question, say what you can from it.\n"
         "Be concise and accurate.\n\n"
         "Context:\n{context}"),
        ("human", "{question}"),
    ])

    chain = prompt | llm
    response = chain.invoke({"context": context, "question": question})
    generation = response.content

    print(f"   Generated response ({len(generation)} chars)")
    return {
        "generation": generation,
        "messages": [AIMessage(content=generation)],
    }


# ──────────────────────────────────────────────
# Node: web_search_node
# ──────────────────────────────────────────────
def web_search_node(state: dict) -> dict:
    """Search the web for information."""
    print("--- NODE: web_search ---")

    question = state["question"]
    result = web_search.invoke(question)
    web_results = [result] if result else []

    print(f"   Got {len(web_results)} web result(s)")
    if web_results:
        print(f"   Preview: {web_results[0][:200]}")
    return {"web_results": web_results}


# ──────────────────────────────────────────────
# Node: generate_with_web
# ──────────────────────────────────────────────
def generate_with_web(state: dict) -> dict:
    """Generate a response using web search results as context."""
    print("--- NODE: generate_with_web ---")

    llm = _get_llm()
    question = state["question"]
    web_results = state.get("web_results", [])
    context = "\n\n".join(web_results)

    prompt = ChatPromptTemplate.from_messages([
        ("system",
         "You are a helpful assistant. Answer the user's question using ONLY the web search results below.\n"
         "These are REAL, LIVE search results from DuckDuckGo — use them to answer.\n"
         "Do NOT say 'I cannot access real-time information' — the results below ARE real-time info.\n"
         "Cite sources (URLs) where possible. Be concise and accurate.\n\n"
         "Web search results:\n{context}"),
        ("human", "{question}"),
    ])

    chain = prompt | llm
    response = chain.invoke({"context": context, "question": question})
    generation = response.content

    print(f"   Generated response ({len(generation)} chars)")
    return {
        "generation": generation,
        "messages": [AIMessage(content=generation)],
    }


# ──────────────────────────────────────────────
# Node: direct_response
# ──────────────────────────────────────────────
def direct_response(state: dict) -> dict:
    """Respond directly without retrieval (greetings, chitchat, general knowledge)."""
    print("--- NODE: direct_response ---")

    llm = _get_llm()
    question = state["question"]

    prompt = ChatPromptTemplate.from_messages([
        ("system",
         "You are a friendly, helpful assistant. Respond naturally to the user. "
         "Keep your answers concise."),
        ("human", "{question}"),
    ])

    chain = prompt | llm
    response = chain.invoke({"question": question})
    generation = response.content

    print(f"   Generated response ({len(generation)} chars)")
    return {
        "generation": generation,
        "messages": [AIMessage(content=generation)],
    }
PYEOF
echo "  ✓ nodes.py"

###############################################################################
# 4. STREAMLIT UI — uses requests (not httpx), debug panel for web results
###############################################################################
echo "[4/5] Writing src/ui/app.py ..."

cat > src/ui/app.py << 'PYEOF'
"""Streamlit chat interface for the local AI agent.

Run with: streamlit run src/ui/app.py
"""

import streamlit as st
from elasticsearch import Elasticsearch

from src.agent.graph import run_agent
from src.config import settings

# ── Page config ──
st.set_page_config(
    page_title="Local AI Agent",
    page_icon="🔍",
    layout="centered",
)

st.title("Local AI Agent")
st.caption("Elasticsearch + Ollama + LangGraph — $0 cost")

# ── Sidebar ──
with st.sidebar:
    st.header("Configuration")
    st.text(f"LLM: {settings.LLM_MODEL}")
    st.text(f"Embeddings: {settings.EMBEDDING_MODEL}")
    st.text(f"ES Index: {settings.ES_INDEX_NAME}")

    # Connection status
    st.divider()
    st.subheader("Status")

    try:
        es = Elasticsearch(settings.ELASTICSEARCH_URL)
        if es.ping():
            st.success("Elasticsearch: Connected")
            try:
                count = es.count(index=settings.ES_INDEX_NAME).get("count", 0)
                st.text(f"Documents: {count} chunks")
            except Exception:
                st.warning("No index yet — run ingestion")
        else:
            st.error("Elasticsearch: Not reachable")
    except Exception:
        st.error("Elasticsearch: Not reachable")

    try:
        import requests
        resp = requests.get(f"{settings.OLLAMA_BASE_URL}/api/tags", timeout=5)
        if resp.status_code == 200:
            models = [m["name"] for m in resp.json().get("models", [])]
            st.success("Ollama: Connected")
            if models:
                st.caption(f"Models: {', '.join(models[:5])}")
        else:
            st.error("Ollama: Not reachable")
    except Exception:
        st.error("Ollama: Not reachable")

    st.divider()
    if st.button("Clear Chat"):
        st.session_state.messages = []
        st.rerun()

# ── Chat history ──
if "messages" not in st.session_state:
    st.session_state.messages = []

# Display chat history
for msg in st.session_state.messages:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])
        if msg.get("route"):
            icons = {"vectorstore": "🟢", "websearch": "🌐", "direct": "🔵"}
            icon = icons.get(msg["route"], "⚪")
            st.caption(f"{icon} Route: {msg['route']}")

# ── Chat input ──
if prompt := st.chat_input("Ask me anything..."):
    # Show user message
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # Run agent
    with st.chat_message("assistant"):
        with st.spinner("Thinking..."):
            try:
                result = run_agent(prompt)
                response = result.get("generation", "I couldn't generate a response.")
                route = result.get("route", "unknown")
            except Exception as e:
                response = f"Error: {str(e)}"
                route = "error"
                result = {}

        st.markdown(response)
        icons = {"vectorstore": "🟢", "websearch": "🌐", "direct": "🔵"}
        icon = icons.get(route, "⚪")
        st.caption(f"{icon} Route: {route}")

        # Show web search debug info
        web_results = result.get("web_results", [])
        if web_results:
            with st.expander("🔍 Web search results used"):
                for wr in web_results:
                    st.text(wr[:500])

    st.session_state.messages.append({
        "role": "assistant",
        "content": response,
        "route": route,
    })
PYEOF
echo "  ✓ app.py"

###############################################################################
# 5. INTEL MAC ONLY — pull smaller model + update .env
###############################################################################
if [ "$ARCH" = "x86_64" ]; then
    echo "[5/5] Intel Mac: pulling llama3.2:1b for faster CPU inference..."
    ollama pull llama3.2:1b

    if [ -f .env ]; then
        sed -i.bak 's/LLM_MODEL=llama3.2$/LLM_MODEL=llama3.2:1b/' .env
        sed -i.bak 's/LLM_MODEL=llama3.2:3b/LLM_MODEL=llama3.2:1b/' .env
        rm -f .env.bak
        echo "  ✓ .env updated to llama3.2:1b"
    else
        echo "  ⚠ No .env file found — using defaults from config.py"
    fi
else
    echo "[5/5] Apple Silicon: no model changes needed (GPU accelerated)"
fi

###############################################################################
# DONE
###############################################################################
echo ""
echo "==========================================="
echo "  ✅ All fixes deployed!"
echo "==========================================="
echo ""
echo "Now restart Streamlit:"
echo "  source .venv/bin/activate"
echo "  streamlit run src/ui/app.py"
echo ""
