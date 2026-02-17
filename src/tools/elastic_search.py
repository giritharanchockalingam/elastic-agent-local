"""Elasticsearch search tool for the agent."""
from langchain_core.tools import tool
from langchain_elasticsearch import ElasticsearchStore
from langchain_ollama import OllamaEmbeddings
from src.config import settings

def _get_vector_store() -> ElasticsearchStore:
    embeddings = OllamaEmbeddings(model=settings.EMBEDDING_MODEL, base_url=settings.OLLAMA_BASE_URL)
    return ElasticsearchStore(index_name=settings.ES_INDEX_NAME, embedding=embeddings, es_url=settings.ELASTICSEARCH_URL)

@tool
def search_knowledge_base(query: str) -> str:
    """Search the local knowledge base for information relevant to the query.
    Use this tool when the user asks a question that might be answered by
    documents in the knowledge base. Returns the most relevant text passages
    with source metadata.
    """
    try:
        store = _get_vector_store()
        results = store.similarity_search(query, k=4)
        if not results:
            return "No relevant documents found in the knowledge base."
        formatted = []
        for i, doc in enumerate(results, 1):
            source = doc.metadata.get("source", "unknown")
            formatted.append(f"[Result {i}] (Source: {source})\n{doc.page_content}")
        return "\n\n---\n\n".join(formatted)
    except Exception as e:
        return f"Error searching knowledge base: {e}"
