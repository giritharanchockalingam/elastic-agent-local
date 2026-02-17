"""LangGraph StateGraph workflow definition.
Usage: python -m src.agent.graph
"""
from langgraph.graph import END, StateGraph
from src.agent.nodes import direct_response, generate, generate_with_web, grade_documents, retrieve, route_question, web_search_node
from src.agent.state import AgentState

def _route_after_question(state):
    route = state.get("route", "direct")
    if route == "vectorstore": return "retrieve"
    elif route == "websearch": return "web_search"
    else: return "direct_response"

def _route_after_grading(state):
    if state.get("documents"): return "generate"
    else: return "web_search"

def build_graph():
    workflow = StateGraph(AgentState)
    workflow.add_node("route_question", route_question)
    workflow.add_node("retrieve", retrieve)
    workflow.add_node("grade_documents", grade_documents)
    workflow.add_node("generate", generate)
    workflow.add_node("web_search", web_search_node)
    workflow.add_node("generate_with_web", generate_with_web)
    workflow.add_node("direct_response", direct_response)
    workflow.set_entry_point("route_question")
    workflow.add_conditional_edges("route_question", _route_after_question, {"retrieve": "retrieve", "web_search": "web_search", "direct_response": "direct_response"})
    workflow.add_edge("retrieve", "grade_documents")
    workflow.add_conditional_edges("grade_documents", _route_after_grading, {"generate": "generate", "web_search": "web_search"})
    workflow.add_edge("web_search", "generate_with_web")
    workflow.add_edge("generate_with_web", END)
    workflow.add_edge("generate", END)
    workflow.add_edge("direct_response", END)
    return workflow.compile()

agent_graph = build_graph()

def run_agent(question: str) -> dict:
    print(f"\n{'='*50}\nQuestion: {question}\n{'='*50}")
    result = agent_graph.invoke({"question": question, "generation": "", "documents": [], "web_results": [], "route": "", "retry_count": 0, "messages": []})
    print(f"{'='*50}\n")
    return result

if __name__ == "__main__":
    result = run_agent("Hello, what can you help me with?")
    print(f"Response: {result['generation']}")
    print(f"Route taken: {result['route']}")
