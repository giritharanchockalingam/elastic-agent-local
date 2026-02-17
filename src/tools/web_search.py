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
            return "No web results found."
        formatted = []
        for i, r in enumerate(results, 1):
            formatted.append(f"[Result {i}] {r.get('title', 'No title')}\nURL: {r.get('href', 'N/A')}\n{r.get('body', 'No snippet')}")
        return "\n\n---\n\n".join(formatted)
    except Exception as e:
        return f"Error performing web search: {e}"
