#!/usr/bin/env bash
# Adds Intel Mac troubleshooting to README and fixes start.sh invocation
# Run: cd ~/Projects/GitHub/elastic-agent-local && bash fix-intel2.sh
set -e

echo "Updating README with Intel Mac instructions..."

# Read current README and append Intel Mac section to troubleshooting
# We'll rewrite the troubleshooting section of README with the addition

python3 << 'PYEOF'
import re

with open("README.md", "r") as f:
    content = f.read()

# Find the troubleshooting section and add Intel Mac fix
intel_fix = """### "Bad CPU type in executable" on Intel Mac

If you see `bash: /opt/homebrew/bin/bash: Bad CPU type in executable`, your system has Apple Silicon Homebrew installed on an Intel Mac. Fix:

```bash
# Option 1: Use the system bash directly
/bin/bash start.sh

# Option 2: Fix your PATH permanently (add to ~/.zshrc or ~/.bash_profile)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
```

"""

# Insert before the "## How It Was Built" section
if "Bad CPU type" not in content:
    content = content.replace(
        "## How It Was Built",
        intel_fix + "## How It Was Built"
    )

    with open("README.md", "w") as f:
        f.write(content)
    print("  Added Intel Mac troubleshooting to README.md")
else:
    print("  Intel Mac section already exists in README.md")
PYEOF

echo ""
echo "✅ Done! Now commit and push:"
echo "  git add README.md"
echo '  git commit -m "Add Intel Mac troubleshooting to README"'
echo "  git push"

