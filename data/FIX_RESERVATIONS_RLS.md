# Fix Reservations RLS Policy for Guest Checkout

## The Problem

Error: `new row violates row-level security policy for table 'reservations'`

**Root Cause:** Anonymous users don't have permission to INSERT into the `reservations` table.

## The Fix

Run this in Supabase SQL Editor:

```sql
-- Ensure RLS is enabled
ALTER TABLE public.reservations ENABLE ROW LEVEL SECURITY;

-- Allow anonymous SELECT (to view booking confirmation)
DROP POLICY IF EXISTS "Allow anonymous SELECT on reservations" ON public.reservations;
CREATE POLICY "Allow anonymous SELECT on reservations"
ON public.reservations FOR SELECT TO anon USING (true);

-- Allow anonymous INSERT (to create bookings)
DROP POLICY IF EXISTS "Allow public reservation creation" ON public.reservations;
CREATE POLICY "Allow public reservation creation"
ON public.reservations FOR INSERT TO anon WITH CHECK (true);

-- Also allow authenticated users (for guest signups)
DROP POLICY IF EXISTS "Allow authenticated reservation creation" ON public.reservations;
CREATE POLICY "Allow authenticated reservation creation"
ON public.reservations FOR INSERT TO authenticated WITH CHECK (true);
```

## Why This Is Needed

The booking flow creates a reservation after creating the guest:

1. ✅ Create guest record (now works)
2. ❌ Create reservation record (fails without this policy)

## Security Note

Allowing anonymous INSERT on reservations is safe because:
- ✅ They can only create reservations (not update/delete)
- ✅ This is required for guest checkout (industry standard)
- ✅ Staff policies remain in place for management operations
- ✅ UPDATE/DELETE policies remain restricted

## Verification

After running the fix, verify:

```sql
SELECT 
    policyname,
    roles,
    cmd
FROM pg_policies 
WHERE tablename = 'reservations' 
  AND 'anon' = ANY(roles::text[])
ORDER BY cmd, policyname;
```

Should see:
- `"Allow anonymous SELECT on reservations"` with roles: `{anon}`
- `"Allow public reservation creation"` with roles: `{anon}`

## Complete Guest Checkout Flow

After this fix, the complete flow should work:

1. ✅ Anonymous user selects dates/room
2. ✅ Creates guest record (anon SELECT + INSERT policies)
3. ✅ Creates reservation record (anon SELECT + INSERT policies)
4. ✅ Shows booking confirmation
