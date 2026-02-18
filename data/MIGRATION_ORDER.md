# Public Portal Migration Order

## ⚠️ IMPORTANT: Run Migrations in This Exact Order

The public portal requires migrations to be run in a specific order. If you get errors about missing views or columns, check this order.

## Migration Order

### 1. Schema Foundation (REQUIRED FIRST)
**File:** `supabase/migrations/20250121000000_public_portal_slugs_complete.sql`

**What it does:**
- Adds `brand_slug` to `tenants` table
- Adds `property_slug` to `properties` table
- Backfills slugs for existing rows
- Adds `is_public` flags to both tables
- Adds `public_metadata` JSONB to properties
- Creates `public_tenants` view
- Creates `public_properties` view
- Sets up RLS policies

**Status:** ✅ Must run first

---

### 2. Leads & Booking Requests
**File:** `supabase/migrations/20250121000001_public_portal_leads_booking_requests.sql`

**What it does:**
- Creates `leads` table
- Creates `booking_requests` table
- Creates `rate_limits` table
- Sets up RLS policies
- Creates audit logging triggers

**Status:** ✅ Run after schema migration

---

### 3. Seed Demo Data
**File:** `supabase/migrations/20250121000002_seed_public_portal_demo.sql`

**What it does:**
- Creates demo tenant: "Grand Hospitality Group" (slug: `grand-hospitality`)
- Creates demo properties: "Downtown Hotel" and "Airport Hotel"
- Creates demo room types (if table exists)
- Creates demo restaurant (if table exists)

**Status:** ✅ Run after schema migration

**Note:** This migration is idempotent and handles missing columns gracefully.

---

### 4. Fix Public Status (Optional but Recommended)
**File:** `supabase/migrations/20250121000003_fix_public_tenant_status.sql`

**What it does:**
- Ensures tenant with code 'GHG' has `is_public = TRUE`
- Ensures properties with codes 'DTW' and 'JFK' have `is_public = TRUE`

**Status:** ✅ Run after seed migration

---

### 5. Create Views Standalone (If Needed)
**File:** `supabase/migrations/20250121000004_create_public_views_standalone.sql`

**What it does:**
- Creates `public_tenants` and `public_properties` views
- Works even if `is_public` columns don't exist yet
- Grants permissions to `anon` and `authenticated` roles

**Status:** ✅ Use if views don't exist and main migration can't run

---

## Quick Fix: If Views Don't Exist

If you get `relation "public_tenants" does not exist`:

1. **Option A:** Run migration `20250121000000_public_portal_slugs_complete.sql` (recommended)
2. **Option B:** Run migration `20250121000004_create_public_views_standalone.sql` (quick fix)

---

## Verification Queries

After running migrations, verify:

```sql
-- Check if views exist
SELECT table_name 
FROM information_schema.views 
WHERE table_schema = 'public' 
AND table_name IN ('public_tenants', 'public_properties');

-- Check if tenant is public
SELECT id, code, brand_slug, is_public, status 
FROM public.tenants 
WHERE code = 'GHG';

-- Check if properties are public
SELECT id, code, property_slug, is_public, status 
FROM public.properties 
WHERE code IN ('DTW', 'JFK');

-- Test public_tenants view
SELECT * FROM public_tenants WHERE brand_slug = 'grand-hospitality';

-- Test public_properties view
SELECT * FROM public_properties WHERE property_slug = 'downtown-hotel';
```

---

## Common Issues

### Issue: `relation "public_tenants" does not exist`
**Solution:** Run migration `20250121000000_public_portal_slugs_complete.sql` or `20250121000004_create_public_views_standalone.sql`

### Issue: `column "is_public" does not exist`
**Solution:** Run migration `20250121000000_public_portal_slugs_complete.sql` first

### Issue: 404 when accessing `/grand-hospitality`
**Solution:** 
1. Ensure tenant has `is_public = TRUE`
2. Run migration `20250121000003_fix_public_tenant_status.sql`
3. Or manually: `UPDATE public.tenants SET is_public = TRUE WHERE code = 'GHG';`

### Issue: View returns no rows
**Solution:** 
1. Check tenant has `is_public = TRUE` and `status = 'active'`
2. Check tenant has `brand_slug` set
3. Run: `UPDATE public.tenants SET is_public = TRUE, brand_slug = 'grand-hospitality' WHERE code = 'GHG';`

