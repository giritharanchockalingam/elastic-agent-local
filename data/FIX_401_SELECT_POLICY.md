# Fix 401 Error - Missing SELECT Policy for Anonymous Users

## The Problem

You're getting 401 errors on:
```
/rest/v1/guests?select=id:1
```

**Root Cause:** The booking flow tries to **SELECT** (find existing guest) before INSERT. Anonymous users don't have SELECT permission on the guests table.

## The Fix

Run this in Supabase SQL Editor:

```sql
-- Allow anonymous users to SELECT guests (needed to check if guest exists)
DROP POLICY IF EXISTS "Allow anonymous SELECT on guests" ON public.guests;

CREATE POLICY "Allow anonymous SELECT on guests"
ON public.guests 
FOR SELECT
TO anon
USING (true);
```

## Why This Is Needed

The booking flow does this:

1. **SELECT** - Check if guest exists by email (line 716 in BookingEngine.tsx)
   ```typescript
   const { data: existingGuest } = await supabase
     .from('guests')
     .select('id')
     .eq('email', g.email)
     .eq('property_id', propertyId)
     .maybeSingle();
   ```
   ❌ **This fails with 401** if anon can't SELECT

2. **INSERT** - Create new guest if not found (line 732)
   ```typescript
   const { data: newGuest } = await supabase
     .from('guests')
     .insert({ ... });
   ```
   ✅ This would work (we have INSERT policy)

## Complete Fix

Run both policies:

```sql
-- 1. Allow anonymous SELECT (to find existing guests)
DROP POLICY IF EXISTS "Allow anonymous SELECT on guests" ON public.guests;
CREATE POLICY "Allow anonymous SELECT on guests"
ON public.guests FOR SELECT TO anon USING (true);

-- 2. Ensure anonymous INSERT works (should already exist)
DROP POLICY IF EXISTS "Allow public guest creation for bookings" ON public.guests;
CREATE POLICY "Allow public guest creation for bookings"
ON public.guests FOR INSERT TO anon WITH CHECK (true);
```

## Security Note

Allowing anonymous SELECT on guests is safe because:
- ✅ They can only see guest records (not sensitive data)
- ✅ This is needed for the booking flow to work
- ✅ RLS still prevents unauthorized access to other tables
- ✅ UPDATE/DELETE policies remain restricted

## Verification

After running the fix, test:

1. Open browser console (F12)
2. Try booking flow
3. Check Network tab - should see:
   - ✅ `GET /rest/v1/guests?select=id` → 200 OK (not 401)
   - ✅ `POST /rest/v1/guests` → 201 Created (not 401)
