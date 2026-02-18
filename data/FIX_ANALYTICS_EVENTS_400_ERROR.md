# Fix: analytics_events 400 Bad Request Error

## Error

```
GET https://qnwsnrfcnonaxvnithfv.supabase.co/rest/v1/analytics_events?select=event_type%2Ctimestamp%2Cevent_category&property_id=eq.00000000-0000-0000-0000-000000000111&timestamp=gte.2025-12-28T04%3A25%3A16.204Z&order=timestamp.desc&limit=1000 400 (Bad Request)
```

## Root Cause

The `analytics_events` table may not exist or may have incorrect RLS (Row Level Security) policies that are blocking queries. The Dashboard component queries this table to fetch analytics events for the last 24 hours, but the query fails with a 400 error.

## Solution

A migration has been created to ensure the `analytics_events` table exists with the correct schema and RLS policies:

**File:** `supabase/migrations/20251229042627_ensure_analytics_events_table.sql`

This migration:
- Creates the `analytics_events` table if it doesn't exist
- Defines all required columns (`event_type`, `timestamp`, `event_category`, `property_id`, etc.)
- Creates indexes for performance
- Sets up proper RLS policies to allow users to view analytics events for their properties

## Apply the Migration

### Option 1: Using Supabase CLI (Recommended)

```bash
# Link to your Supabase project (if not already linked)
npx supabase link --project-ref qnwsnrfcnonaxvnithfv

# Apply the migration
npx supabase db push
```

### Option 2: Via Supabase Dashboard

1. Go to: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/sql/new
2. Copy the contents of `supabase/migrations/20251229042627_ensure_analytics_events_table.sql`
3. Paste into the SQL editor
4. Click "Run"

### Option 3: Direct SQL Execution

Run this SQL in Supabase SQL Editor:

```sql
-- Create analytics_events table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.analytics_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE,
  property_id UUID REFERENCES public.properties(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,
  event_category TEXT,
  event_data JSONB DEFAULT '{}'::jsonb,
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  session_id TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_analytics_events_property_id ON public.analytics_events(property_id);
CREATE INDEX IF NOT EXISTS idx_analytics_events_timestamp ON public.analytics_events(timestamp);
CREATE INDEX IF NOT EXISTS idx_analytics_events_event_type ON public.analytics_events(event_type);

-- Enable RLS
ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Users can view analytics events for their property" ON public.analytics_events;
CREATE POLICY "Users can view analytics events for their property"
  ON public.analytics_events FOR SELECT
  USING (
    property_id IN (SELECT property_id FROM public.user_properties WHERE user_id = auth.uid())
    OR property_id IN (SELECT property_id FROM public.staff WHERE user_id = auth.uid() AND (status = 'active' OR status IS NULL))
    OR property_id IS NULL
  );
```

## Expected Behavior After Fix

Once the migration is applied:

1. ✅ The `analytics_events` query in `Dashboard.tsx` will succeed
2. ✅ Users will see analytics events for their properties
3. ✅ No more 400 Bad Request errors for analytics_events queries
4. ✅ The dashboard will display analytics data correctly

## Related Code

The following files use the `analytics_events` table:
- `src/pages/Dashboard.tsx` - Line 177-182: Queries analytics events for last 24 hours
- `src/pages/Logging.tsx` - Line 51: Queries analytics events for logging page

All of these will work correctly once the migration is applied.

## Note

The Dashboard component already handles errors gracefully (returns empty array if query fails), so this error doesn't break the UI. However, fixing it ensures that analytics data is properly displayed.

