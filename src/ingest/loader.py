"""Document ingestion pipeline.

Reads files from data/, chunks them, generates embeddings via Ollama,
and stores them in Elasticsearch.

Usage:
    python -m src.ingest.loader
"""

import sys
from datetime import datetime, timezone
from pathlib import Path

from langchain_community.document_loaders import DirectoryLoader, TextLoader
from langchain_elasticsearch import ElasticsearchStore
from langchain_ollama import OllamaEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

from src.config import settings


def get_embeddings() -> OllamaEmbeddings:
    """Create the Ollama embeddings instance."""
    return OllamaEmbeddings(
        model=settings.EMBEDDING_MODEL,
        base_url=settings.OLLAMA_BASE_URL,
    )


def get_vector_store() -> ElasticsearchStore:
    """Create the Elasticsearch vector store instance."""
    return ElasticsearchStore(
        index_name=settings.ES_INDEX_NAME,
        embedding=get_embeddings(),
        es_url=settings.ELASTICSEARCH_URL,
    )


def load_documents(data_dir: str) -> list:
    """Load documents from the data directory (.txt, .md, .csv files)."""
    docs = []
    data_path = Path(data_dir)

    if not data_path.exists():
        print(f"  Data directory not found: {data_path}")
        return docs

    # Load all supported text formats using TextLoader (no extra deps needed)
    for pattern in ["*.txt", "*.md", "*.csv", "*.rst"]:
        files = list(data_path.glob(pattern))
        if files:
            print(f"  Found {len(files)} {pattern} files")
            loader = DirectoryLoader(
                str(data_path),
                glob=pattern,
                loader_cls=TextLoader,
                loader_kwargs={"encoding": "utf-8", "autodetect_encoding": True},
                silent_errors=True,  # Skip files that fail to load
            )
            loaded = loader.load()
            docs.extend(loaded)
            print(f"    Loaded {len(loaded)} files successfully")

    return docs


def chunk_documents(docs: list) -> list:
    """Split documents into chunks."""
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=settings.CHUNK_SIZE,
        chunk_overlap=settings.CHUNK_OVERLAP,
        length_function=len,
        add_start_index=True,
    )
    chunks = splitter.split_documents(docs)

    # Add metadata to each chunk
    for i, chunk in enumerate(chunks):
        chunk.metadata["chunk_index"] = i
        chunk.metadata["ingested_at"] = datetime.now(timezone.utc).isoformat()

    return chunks


def ingest(data_dir: str | None = None) -> int:
    """Run the full ingestion pipeline. Returns number of chunks ingested."""
    data_dir = data_dir or settings.DATA_DIR

    print(f"Loading documents from: {data_dir}")
    docs = load_documents(data_dir)
    if not docs:
        print("  No documents found. Add .txt or .md files to the data/ folder.")
        return 0

    print(f"Chunking {len(docs)} documents (size={settings.CHUNK_SIZE}, overlap={settings.CHUNK_OVERLAP})")
    chunks = chunk_documents(docs)
    print(f"   Created {len(chunks)} chunks")

    print(f"Embedding and storing in Elasticsearch index: {settings.ES_INDEX_NAME}")
    vector_store = get_vector_store()

    # Ingest in batches to avoid timeout on large document sets
    batch_size = 50
    total = len(chunks)
    for i in range(0, total, batch_size):
        batch = chunks[i : i + batch_size]
        vector_store.add_documents(batch)
        print(f"   Ingested {min(i + batch_size, total)}/{total} chunks...")

    print(f"Ingested {total} chunks successfully!")
    return total


if __name__ == "__main__":
    data_dir = sys.argv[1] if len(sys.argv) > 1 else None
    ingest(data_dir)
