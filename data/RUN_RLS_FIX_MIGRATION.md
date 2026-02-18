# Run RLS Fix Migration

## Issue

The harvester is getting RLS errors because the service role key needs explicit policies to write to `public_ingestion_runs`, `public_property_content`, and `public_property_images`.

## Quick Fix

**Run this SQL in Supabase SQL Editor:**

1. Go to: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/sql/new
2. Copy and paste the contents of: `supabase/migrations/20250121000008_fix_ingestion_rls_service_role.sql`
3. Click "Run"

Or copy/paste this quick fix:

```sql
BEGIN;

-- Allow service_role to manage ingestion runs
CREATE POLICY "Service role can manage ingestion runs"
ON public.public_ingestion_runs
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Allow service_role to manage content
CREATE POLICY "Service role can manage property content"
ON public.public_property_content
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Allow service_role to manage images
CREATE POLICY "Service role can manage property images"
ON public.public_property_images
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

COMMIT;
```

## After Running Migration

Try the harvester again:

```bash
npm run harvest:thangamgrand:npm -- --tenant grand-hospitality --property airport-hotel --apply
```

The service role key should now be able to write to these tables.

