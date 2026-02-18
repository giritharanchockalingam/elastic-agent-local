# Step 1: Harvester Reconnaissance - COMPLETE

## Summary

### Files Found & Analyzed

1. **Supabase Client:** `src/integrations/supabase/client.ts`
   - Uses `createClient()` from `@supabase/supabase-js`
   - Environment: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`
   - For CLI: Will need service role key (server-side only)

2. **Storage Buckets:**
   - `menu-images` (public)
   - `housekeeping-photos` (private)
   - `guest-documents` (private)
   - Pattern: `supabase.storage.from('bucket').upload(path, file)`
   - Public URL: `supabase.storage.from('bucket').getPublicUrl(path)`

3. **RLS Patterns:**
   - Uses `has_role(auth.uid(), 'admin'::app_role)` for access control
   - Public views: `public_tenants`, `public_properties`
   - Anon can INSERT into `leads`, `booking_requests` (rate limited)

4. **Database Schema:**
   - `tenants` table: id, name, code, brand_slug, is_public, settings JSONB
   - `properties` table: id, tenant_id, name, code, property_slug, is_public, public_metadata JSONB
   - No existing public content tables (need to create)

### Files Created

1. **`config/harvest.allowlist.json`**
   - Allowlist configuration
   - Default: dry-run mode
   - Max 25 pages, 250ms delay

2. **`scripts/harvest-and-rewrite-property-site.ts`**
   - CLI harvester script (dry-run mode implemented)
   - Extracts structured facts (not prose)
   - Outputs JSON structure

3. **`docs/HARVESTER_RECON_SUMMARY.md`**
   - Complete reconnaissance documentation

## Sample Output JSON Structure

```json
{
  "rooms": [
    {
      "name": "Deluxe Room",
      "features": ["King bed", "City view", "Free WiFi"],
      "priceFromText": "From ₹5,000",
      "category": "standard"
    }
  ],
  "services": [
    {
      "name": "Restaurant",
      "type": "restaurant",
      "description": "Multi-cuisine dining"
    },
    {
      "name": "Spa",
      "type": "spa"
    }
  ],
  "images": [
    {
      "url": "https://thethangamgrand.com/images/lobby.jpg",
      "alt": "Hotel lobby",
      "category": "lobby",
      "caption": "Elegant lobby area"
    }
  ],
  "location": {
    "address": "123 Main Street",
    "city": "Chennai",
    "state": "Tamil Nadu",
    "country": "India",
    "phone": "+91-44-12345678",
    "generalEmail": "info@thethangamgrand.com"
  },
  "contact": {
    "phone": "+91-44-12345678",
    "generalEmail": "info@thethangamgrand.com"
  },
  "nearby": [
    {
      "name": "Marina Beach",
      "distance": "2 km",
      "type": "attraction"
    }
  ]
}
```

## Next Steps

1. ✅ **Step 1 Complete:** Reconnaissance done
2. ⏭️ **Step 2:** Enhance crawler with proper HTML parsing (cheerio/jsdom)
3. ⏭️ **Step 3:** Implement rewrite engine
4. ⏭️ **Step 4:** Create database tables + storage bucket
5. ⏭️ **Step 5:** Implement apply mode
6. ⏭️ **Step 6:** Wire UI to display content

## Testing

To test the harvester in dry-run mode:

```bash
pnpm install  # Install tsx if not already installed
pnpm harvest:thangamgrand --tenant <tenantId> --property <propertyId> --dry-run
```

**Note:** The current implementation uses basic regex patterns for extraction. For production, we should use a proper HTML parser like `cheerio` or `jsdom` for more accurate extraction.

