"""Configuration management using Pydantic Settings.

Loads settings from environment variables and .env file.
All defaults are tuned for local development at $0 cost.
"""

from pathlib import Path

from dotenv import load_dotenv
from pydantic_settings import BaseSettings

# Load .env from project root
_project_root = Path(__file__).resolve().parent.parent
load_dotenv(_project_root / ".env")


class Settings(BaseSettings):
    """Application settings with sensible local defaults."""

    # Elasticsearch
    ELASTICSEARCH_URL: str = "http://localhost:9200"
    ES_INDEX_NAME: str = "knowledge-base"

    # Ollama
    OLLAMA_BASE_URL: str = "http://localhost:11434"
    LLM_MODEL: str = "llama3.2"
    EMBEDDING_MODEL: str = "nomic-embed-text"

    # Ingestion
    CHUNK_SIZE: int = 500
    CHUNK_OVERLAP: int = 50

    # Paths
    DATA_DIR: str = str(_project_root / "data")

    model_config = {"env_file": str(_project_root / ".env"), "extra": "ignore"}


# Singleton — import this everywhere
settings = Settings()
