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
