# RLS Error Troubleshooting - Guest Checkout

## If you're still getting RLS errors after running the migration:

### Step 1: Diagnose Current Policies

Run this in Supabase SQL Editor to see what policies are active:

```sql
-- Check current INSERT policies
SELECT 
    policyname,
    permissive,
    roles,
    cmd,
    with_check
FROM pg_policies 
WHERE tablename = 'guests' 
  AND schemaname = 'public'
  AND cmd = 'INSERT'
ORDER BY policyname;
```

**Expected Output:**
You should see at least:
- `"Allow public guest creation for bookings"` with `roles: {anon}`
- `"Allow authenticated guest creation for bookings"` with `roles: {authenticated}`

### Step 2: Manual Fix (If Migration Didn't Work)

If the migration didn't apply correctly, run this directly in Supabase SQL Editor:

```sql
-- Ensure RLS is enabled
ALTER TABLE public.guests ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Allow public guest creation for bookings" ON public.guests;
DROP POLICY IF EXISTS "Allow authenticated guest creation for bookings" ON public.guests;

-- Create anonymous user policy
-- NOTE: For INSERT policies, only WITH CHECK is allowed (not USING)
CREATE POLICY "Allow public guest creation for bookings"
ON public.guests 
FOR INSERT
TO anon
WITH CHECK (true);

-- Create authenticated user policy
CREATE POLICY "Allow authenticated guest creation for bookings"
ON public.guests 
FOR INSERT
TO authenticated
WITH CHECK (true);
```

### Step 3: Verify It Works

Test with a simple insert (as anonymous user):

```sql
-- This should work if policies are correct
-- (Run this in Supabase SQL Editor with anon role)
INSERT INTO public.guests (
  property_id,
  first_name,
  last_name,
  email,
  phone
) VALUES (
  '00000000-0000-0000-0000-000000000111', -- Replace with your property ID
  'Test',
  'Guest',
  'test@example.com',
  '+1234567890'
);
```

### Step 4: Check for Conflicting Policies

If you still have issues, check if there are restrictive policies blocking:

```sql
-- Check all policies
SELECT 
    policyname,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'guests' 
  AND schemaname = 'public'
ORDER BY cmd, policyname;
```

Look for policies that:
- Only allow specific roles (like `'super_admin', 'admin'`)
- Have restrictive `WITH CHECK` clauses
- Don't include `anon` in the roles array

### Step 5: Complete Reset (Nuclear Option)

If nothing works, use the comprehensive fix script:

```bash
# Run the comprehensive fix
cat db-scripts/fix-guests-rls-comprehensive.sql
```

Copy and paste the contents into Supabase SQL Editor and run it.

## Common Issues

### Issue 1: Migration Not Applied
**Symptom:** Policies don't exist after running migration  
**Fix:** Run the manual fix SQL above directly in Supabase SQL Editor

### Issue 2: Policy Exists But Still Blocking
**Symptom:** Policy exists but anonymous inserts still fail  
**Possible Causes:**
- Policy has restrictive `WITH CHECK` clause
- Another policy is more restrictive and blocking
- RLS is disabled

**Fix:** 
1. Check if RLS is enabled: `SELECT rowsecurity FROM pg_tables WHERE tablename = 'guests';`
2. Drop and recreate the policy with `WITH CHECK (true)` (INSERT policies don't use USING)

### Issue 3: Multiple Conflicting Policies
**Symptom:** Multiple INSERT policies exist with different rules  
**Fix:** PostgreSQL RLS uses OR logic, so multiple policies should work. But if one is very restrictive, it might cause issues. Drop all INSERT policies and recreate them cleanly.

## Verification Checklist

After applying the fix, verify:

- [ ] RLS is enabled on guests table
- [ ] Policy "Allow public guest creation for bookings" exists with `roles: {anon}`
- [ ] Policy "Allow authenticated guest creation for bookings" exists with `roles: {authenticated}`
- [ ] Test insert as anonymous user works
- [ ] Booking flow works without sign-in

## Still Having Issues?

1. **Check Supabase Dashboard:**
   - Go to Database → Policies
   - Find `guests` table
   - Check all INSERT policies

2. **Check Application Logs:**
   - Look for the exact RLS error message
   - Check if it's a permission error (42501) or policy error

3. **Test Directly:**
   - Try inserting via Supabase SQL Editor with anon role
   - If that works, the issue is in the application code
   - If that fails, the issue is with RLS policies

4. **Contact Support:**
   - Share the exact error message
   - Share the output of the diagnostic query
   - Share the current policies list
