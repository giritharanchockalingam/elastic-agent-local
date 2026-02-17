"""Agent node functions for the LangGraph workflow."""
from langchain_core.messages import AIMessage
from langchain_core.prompts import ChatPromptTemplate
from langchain_ollama import ChatOllama
from src.config import settings
from src.tools.elastic_search import search_knowledge_base
from src.tools.web_search import web_search

def _get_llm():
    return ChatOllama(model=settings.LLM_MODEL, base_url=settings.OLLAMA_BASE_URL, temperature=0)

def route_question(state: dict) -> dict:
    print("--- NODE: route_question ---")
    llm = _get_llm()
    prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a router. Respond with ONLY one word:\n- 'vectorstore' — topic likely in a knowledge base\n- 'websearch' — current events or real-time info\n- 'direct' — greeting, chitchat, math, or general knowledge"),
        ("human", "{question}"),
    ])
    response = (prompt | llm).invoke({"question": state["question"]})
    route = response.content.strip().lower().replace("'", "").replace('"', '')
    if "vector" in route: route = "vectorstore"
    elif "web" in route: route = "websearch"
    else: route = "direct"
    print(f"   Route: {route}")
    return {"route": route}

def retrieve(state: dict) -> dict:
    print("--- NODE: retrieve ---")
    result = search_knowledge_base.invoke(state["question"])
    documents = [result] if result else []
    print(f"   Retrieved {len(documents)} document(s)")
    return {"documents": documents}

def grade_documents(state: dict) -> dict:
    print("--- NODE: grade_documents ---")
    llm = _get_llm()
    documents = state.get("documents", [])
    if not documents:
        print("   No documents to grade — routing to websearch")
        return {"documents": [], "route": "websearch"}
    prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a relevance grader. Respond with ONLY 'yes' or 'no'."),
        ("human", "Question: {question}\n\nDocument:\n{document}\n\nIs this document relevant?"),
    ])
    chain = prompt | llm
    relevant_docs = []
    for doc in documents:
        response = chain.invoke({"question": state["question"], "document": doc})
        if "yes" in response.content.strip().lower():
            relevant_docs.append(doc)
    if relevant_docs:
        print(f"   {len(relevant_docs)} relevant document(s) found")
        return {"documents": relevant_docs, "route": "vectorstore"}
    else:
        print("   No relevant documents — routing to websearch")
        return {"documents": [], "route": "websearch"}

def generate(state: dict) -> dict:
    print("--- NODE: generate ---")
    llm = _get_llm()
    context = "\n\n".join(state.get("documents", []))
    prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a helpful assistant. Answer based on the provided context. Be concise and accurate.\n\nContext:\n{context}"),
        ("human", "{question}"),
    ])
    response = (prompt | llm).invoke({"context": context, "question": state["question"]})
    print(f"   Generated response ({len(response.content)} chars)")
    return {"generation": response.content, "messages": [AIMessage(content=response.content)]}

def web_search_node(state: dict) -> dict:
    print("--- NODE: web_search ---")
    result = web_search.invoke(state["question"])
    web_results = [result] if result else []
    print(f"   Got {len(web_results)} web result(s)")
    return {"web_results": web_results}

def generate_with_web(state: dict) -> dict:
    print("--- NODE: generate_with_web ---")
    llm = _get_llm()
    context = "\n\n".join(state.get("web_results", []))
    prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a helpful assistant. Answer based on web search results. Cite sources where possible.\n\nWeb results:\n{context}"),
        ("human", "{question}"),
    ])
    response = (prompt | llm).invoke({"context": context, "question": state["question"]})
    print(f"   Generated response ({len(response.content)} chars)")
    return {"generation": response.content, "messages": [AIMessage(content=response.content)]}

def direct_response(state: dict) -> dict:
    print("--- NODE: direct_response ---")
    llm = _get_llm()
    prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a friendly, helpful assistant. Respond naturally. Keep answers concise."),
        ("human", "{question}"),
    ])
    response = (prompt | llm).invoke({"question": state["question"]})
    print(f"   Generated response ({len(response.content)} chars)")
    return {"generation": response.content, "messages": [AIMessage(content=response.content)]}
