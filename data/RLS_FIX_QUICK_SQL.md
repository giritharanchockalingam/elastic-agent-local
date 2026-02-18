# Quick RLS Fix SQL (Idempotent)

Run this in Supabase SQL Editor - it's safe to run multiple times:

```sql
BEGIN;

-- Drop and recreate service role policies (idempotent)
DROP POLICY IF EXISTS "Service role can manage ingestion runs" ON public.public_ingestion_runs;
CREATE POLICY "Service role can manage ingestion runs"
ON public.public_ingestion_runs
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS "Service role can manage property content" ON public.public_property_content;
CREATE POLICY "Service role can manage property content"
ON public.public_property_content
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS "Service role can manage property images" ON public.public_property_images;
CREATE POLICY "Service role can manage property images"
ON public.public_property_images
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

COMMIT;
```

This will work even if the policies already exist.

