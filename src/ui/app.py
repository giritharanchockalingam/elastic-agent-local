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
