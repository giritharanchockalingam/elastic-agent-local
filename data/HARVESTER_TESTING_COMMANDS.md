# Harvester Testing Commands

## Prerequisites

1. **Install dependencies:**
   ```bash
   pnpm install
   ```

2. **Verify allowlist:**
   ```bash
   cat config/harvest.allowlist.json
   ```
   Should show `thethangamgrand.com` in allowedDomains.

## Testing Commands

### 1. Test Allowlist Enforcement (Should Fail)

```bash
# Try to harvest from non-allowlisted domain (should fail)
pnpm harvest:thangamgrand --tenant 00000000-0000-0000-0000-000000000001 --property 00000000-0000-0000-0000-000000000010 --domain example.com --dry-run
```

**Expected:** Error message about domain not being in allowlist.

---

### 2. Test Dry-Run Mode (Safe - No Writes)

```bash
# Harvest from thethangamgrand.com in dry-run mode
pnpm harvest:thangamgrand --tenant 00000000-0000-0000-0000-000000000001 --property 00000000-0000-0000-0000-000000000010 --dry-run
```

**Expected Output:**
- ✅ Shows "Harvesting from: thethangamgrand.com"
- ✅ Shows "Mode: dry-run"
- ✅ Shows extracted facts as JSON
- ✅ Shows "Dry-run complete. Use --apply to write to database."

---

### 3. Test with Custom Domain (if needed)

```bash
# Use explicit domain flag
pnpm harvest:thangamgrand --tenant 00000000-0000-0000-0000-000000000001 --property 00000000-0000-0000-0000-000000000010 --domain thethangamgrand.com --dry-run
```

---

### 4. Get Real Tenant/Property IDs from Database

If you need to find actual tenant/property IDs:

```sql
-- Get tenant ID
SELECT id, name, code, brand_slug FROM tenants WHERE code = 'GHG' LIMIT 1;

-- Get property ID
SELECT id, name, code, property_slug FROM properties WHERE code IN ('DTW', 'JFK') LIMIT 1;
```

Then use those IDs in the commands above.

---

### 5. Test Apply Mode (Will Show Warning - Not Yet Implemented)

```bash
# Try apply mode (will show warning)
pnpm harvest:thangamgrand --tenant 00000000-0000-0000-0000-000000000001 --property 00000000-0000-0000-0000-000000000010 --apply
```

**Expected:** Warning that apply mode is not yet implemented.

---

## Quick Test Script

Create a test script for easier testing:

```bash
# Save as: scripts/test-harvester.sh
#!/bin/bash

TENANT_ID="${1:-00000000-0000-0000-0000-000000000001}"
PROPERTY_ID="${2:-00000000-0000-0000-0000-000000000010}"

echo "🧪 Testing Harvester"
echo "Tenant ID: $TENANT_ID"
echo "Property ID: $PROPERTY_ID"
echo ""

pnpm harvest:thangamgrand --tenant "$TENANT_ID" --property "$PROPERTY_ID" --dry-run
```

Make it executable:
```bash
chmod +x scripts/test-harvester.sh
```

Run it:
```bash
./scripts/test-harvester.sh
```

Or with custom IDs:
```bash
./scripts/test-harvester.sh <your-tenant-id> <your-property-id>
```

---

## Troubleshooting

### Error: "tsx: command not found"
```bash
pnpm install tsx
```

### Error: "Domain not in allowlist"
- Check `config/harvest.allowlist.json`
- Ensure `thethangamgrand.com` is in `allowedDomains` array

### Error: "Failed to fetch"
- Check internet connection
- Verify thethangamgrand.com is accessible
- Check if site blocks automated requests (may need to adjust User-Agent)

### Error: "Cannot find module"
```bash
# Make sure you're in the project root
cd /Users/giritharanchockalingam/Desktop/GitHub/hms-gcp-refactor

# Reinstall dependencies
pnpm install
```

---

## Expected JSON Output Structure

When dry-run completes successfully, you should see JSON like:

```json
{
  "rooms": [
    {
      "name": "Deluxe Room",
      "features": [],
      "category": undefined
    }
  ],
  "services": [
    {
      "name": "Restaurant",
      "type": "restaurant"
    }
  ],
  "images": [
    {
      "url": "https://thethangamgrand.com/images/...",
      "alt": "...",
      "category": "lobby"
    }
  ],
  "location": {
    "phone": "+91-...",
    "generalEmail": "info@..."
  },
  "contact": {
    "phone": "+91-...",
    "generalEmail": "info@..."
  },
  "nearby": []
}
```

---

## Next Steps After Testing

Once dry-run works:
1. Review extracted facts JSON
2. Enhance extraction logic if needed
3. Implement rewrite engine
4. Create database tables
5. Implement apply mode

