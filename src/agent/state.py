"""Agent state schema for the LangGraph workflow."""
import operator
from typing import Annotated
from langchain_core.messages import BaseMessage
from typing_extensions import TypedDict

class AgentState(TypedDict):
    question: str
    generation: str
    documents: list[str]
    web_results: list[str]
    route: str
    retry_count: int
    messages: Annotated[list[BaseMessage], operator.add]
