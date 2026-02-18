# Quick Test Commands (No pnpm Required)

## Option 1: Use npm directly (Easiest)

### 1. Install dependencies:
```bash
npm install
```

### 2. Run harvester test:
```bash
npm run harvest:thangamgrand:npm -- --tenant 00000000-0000-0000-0000-000000000001 --property 00000000-0000-0000-0000-000000000010 --dry-run
```

### 3. Or use the test script:
```bash
./scripts/test-harvester.sh
```

---

## Option 2: Install pnpm (Recommended for future)

### Quick install (standalone script):
```bash
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

Then restart terminal or:
```bash
source ~/.zshrc
```

### Verify:
```bash
pnpm --version
```

### Then use:
```bash
pnpm install
pnpm harvest:thangamgrand --tenant 00000000-0000-0000-0000-000000000001 --property 00000000-0000-0000-0000-000000000010 --dry-run
```

---

## Direct Commands (Copy & Paste)

### Using npm (works now):
```bash
cd /Users/giritharanchockalingam/Desktop/GitHub/hms-gcp-refactor
npm install
npm run harvest:thangamgrand:npm -- --tenant 00000000-0000-0000-0000-000000000001 --property 00000000-0000-0000-0000-000000000010 --dry-run
```

### Using npx pnpm (no install needed):
```bash
cd /Users/giritharanchockalingam/Desktop/GitHub/hms-gcp-refactor
npx pnpm install
npx pnpm harvest:thangamgrand --tenant 00000000-0000-0000-0000-000000000001 --property 00000000-0000-0000-0000-000000000010 --dry-run
```

---

## Expected Output

```
🌐 Harvesting from: thethangamgrand.com
📋 Mode: dry-run
⏱️  Delay: 250ms between requests
📄 Max pages: 25
📥 Fetching: https://thethangamgrand.com

📊 Extracted Facts:
{
  "rooms": [...],
  "services": [...],
  "images": [...],
  "location": {...},
  "contact": {...},
  "nearby": []
}

✅ Dry-run complete. Use --apply to write to database.
```

