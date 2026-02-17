.PHONY: setup up down ingest chat test mcp clean all help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Install all dependencies
	python3 -m venv .venv
	. .venv/bin/activate && pip install -e ".[dev]"
	@[ -f .env ] || cp .env.example .env
	@echo "✓ Setup complete. Run: source .venv/bin/activate"

up: ## Start Elasticsearch + Kibana
	docker compose up -d
	@echo "Waiting for Elasticsearch..."
	@until curl -s http://localhost:9200 > /dev/null 2>&1; do sleep 2; done
	@echo "✓ Elasticsearch ready at http://localhost:9200"
	@echo "✓ Kibana starting at http://localhost:5601"

down: ## Stop Elasticsearch + Kibana
	docker compose down
	@echo "✓ Containers stopped"

ingest: ## Run the document ingestion pipeline
	. .venv/bin/activate && python -m src.ingest.loader

chat: ## Launch the Streamlit chat UI
	. .venv/bin/activate && streamlit run src/ui/app.py

test: ## Run pytest
	. .venv/bin/activate && pytest tests/ -v

mcp: ## Start the MCP server (requires mcp extra)
	. .venv/bin/activate && python -m src.mcp_server

clean: ## Remove ES data volume and reset
	docker compose down -v
	@echo "✓ Elasticsearch data volume removed"

all: setup up ingest chat ## Full setup → ingest → launch
