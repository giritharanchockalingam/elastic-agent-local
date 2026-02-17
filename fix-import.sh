#!/bin/bash
# Quick fix: config.py exports 'settings' not 'get_settings()'
cd "$(dirname "$0")"

echo "Fixing import in nodes.py..."

# Fix the import - replace get_settings with settings
sed -i.bak 's/from src.config import get_settings/from src.config import settings/' src/agent/nodes.py
# Remove the get_settings() call if present
sed -i.bak 's/settings = get_settings()/# settings imported from src.config/' src/agent/nodes.py
rm -f src/agent/nodes.py.bak

echo "✓ Fixed. Restarting streamlit..."
echo "  source .venv/bin/activate && streamlit run src/ui/app.py"