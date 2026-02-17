"""Streamlit chat interface. Run with: streamlit run src/ui/app.py"""
import streamlit as st
from elasticsearch import Elasticsearch
from src.agent.graph import run_agent
from src.config import settings

st.set_page_config(page_title="Local AI Agent", page_icon="🔍", layout="centered")
st.title("Local AI Agent")
st.caption("Elasticsearch + Ollama + LangGraph")

with st.sidebar:
    st.header("Configuration")
    st.text(f"LLM: {settings.LLM_MODEL}")
    st.text(f"Embeddings: {settings.EMBEDDING_MODEL}")
    st.text(f"ES Index: {settings.ES_INDEX_NAME}")
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
                st.text("Documents: index not yet created")
        else:
            st.error("Elasticsearch: Not reachable")
    except Exception:
        st.error("Elasticsearch: Not reachable")
    try:
        import httpx
        resp = httpx.get(f"{settings.OLLAMA_BASE_URL}/api/tags", timeout=5)
        if resp.status_code == 200: st.success("Ollama: Connected")
        else: st.error("Ollama: Not reachable")
    except Exception:
        st.error("Ollama: Not reachable")
    st.divider()
    if st.button("Clear Chat"):
        st.session_state.messages = []
        st.rerun()

if "messages" not in st.session_state:
    st.session_state.messages = []

for msg in st.session_state.messages:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])
        if msg.get("route"): st.caption(f"Route: {msg['route']}")

if prompt := st.chat_input("Ask me anything..."):
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)
    with st.chat_message("assistant"):
        with st.spinner("Thinking..."):
            result = run_agent(prompt)
        response = result.get("generation", "I couldn't generate a response.")
        route = result.get("route", "unknown")
        st.markdown(response)
        st.caption(f"Route: {route}")
    st.session_state.messages.append({"role": "assistant", "content": response, "route": route})
