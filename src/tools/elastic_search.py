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
