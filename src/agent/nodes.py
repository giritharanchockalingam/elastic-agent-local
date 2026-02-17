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
