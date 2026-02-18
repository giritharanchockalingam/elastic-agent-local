# Harvester Reconnaissance Summary

## Step 1: Repository Analysis

### Supabase Usage Patterns

**Client Initialization:**
- File: `src/integrations/supabase/client.ts`
- Uses: `createClient()` from `@supabase/supabase-js`
- Environment vars: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`
- For CLI: Will need to use service role key (server-side only)

**Storage Bucket Patterns:**
- Existing buckets:
  - `menu-images` (public)
  - `housekeeping-photos` (private, staff only)
  - `guest-documents` (private, staff only)
- Upload pattern:
  ```typescript
  await supabase.storage.from('bucket-name').upload(path, file)
  ```
- Public URL pattern:
  ```typescript
  const { data } = supabase.storage.from('bucket-name').getPublicUrl(path)
  ```

**RLS Patterns:**
- Uses `has_role(auth.uid(), 'admin'::app_role)` for staff/admin checks
- Public views: `public_tenants`, `public_properties` (already created)
- Anon can INSERT into `leads` and `booking_requests` (rate limited)
- Staff can SELECT/UPDATE leads and booking_requests for their property/tenant

### Database Schema

**Existing Tables:**
- `tenants` (id, name, code, brand_slug, is_public, settings JSONB)
- `properties` (id, tenant_id, name, code, property_slug, is_public, public_metadata JSONB)
- `public_tenants` view (public-safe tenant data)
- `public_properties` view (public-safe property data)

**Missing Tables (to create):**
- `public_property_content` - Marketing content
- `public_property_images` - Image metadata
- `public_ingestion_runs` - Harvest run logs

### Project Structure

**Scripts Directory:**
- Location: `/scripts/` (exists)
- Contains: `.sh`, `.sql`, `.cjs` files
- Pattern: Shell scripts for deployment, SQL for migrations

**TypeScript/Node Environment:**
- Type: `"module"` in package.json
- Runtime: Node.js (for CLI scripts)
- Dependencies: `@supabase/supabase-js` available

### Files Found

1. **Supabase Client:** `src/integrations/supabase/client.ts`
2. **Storage Examples:**
   - `src/pages/MenuManagement.tsx` (menu-images bucket)
   - `src/pages/Housekeeping.tsx` (housekeeping-photos bucket)
3. **RLS Policies:**
   - `supabase/migrations/20250121000006_staff_access_leads_booking_requests.sql`
4. **Public Views:**
   - `supabase/migrations/20250121000000_public_portal_slugs_complete.sql`

## Implementation Plan

### Phase 1: Database Schema
- Create `public_property_content` table
- Create `public_property_images` table
- Create `public_ingestion_runs` table
- Create `public-assets` storage bucket
- Add RLS policies

### Phase 2: CLI Harvester
- Allowlist config: `config/harvest.allowlist.json`
- Crawler: `scripts/harvest-and-rewrite-property-site.ts`
- Extract structured facts (not prose)
- Output JSON for dry-run mode

### Phase 3: Rewrite Engine
- `src/lib/ingestion/rewrite.ts`
- Original marketing copy generation
- No verbatim spans > 6 words

### Phase 4: Apply Mode
- Image download + dedupe
- Upload to Supabase Storage
- Write content records to DB

### Phase 5: UI Integration
- Update public pages to render harvested content
- Gallery carousel
- Services grid
- Room cards

## Security Considerations

1. **Allowlist Enforcement:** Must check allowlist before crawling
2. **Rate Limiting:** Delay between requests (≥250ms)
3. **RLS:** All public tables must have proper RLS policies
4. **Storage:** Public bucket with read-only for anon
5. **PII Protection:** Never ingest staff names, guest data, or operational details

