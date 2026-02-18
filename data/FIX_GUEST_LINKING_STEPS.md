# Fix Guest Linking - Step by Step

## The Problem

Bookings made anonymously don't appear in "My Account" after signing in because:
1. RLS policies block regular guests from UPDATE operations
2. Only staff roles can UPDATE guest records
3. Anonymous guest records can't be linked to user accounts

## Solution

Run these migrations in order in Supabase SQL Editor:

### Step 1: Run Migration `20251230000003_fix_guest_update_for_linking.sql`

This allows regular guests (without staff roles) to update anonymous guest records with matching emails.

**Go to:** https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/sql/new

**Copy and paste the contents of:**
`supabase/migrations/20251230000003_fix_guest_update_for_linking.sql`

**Click "Run"**

### Step 2: Verify Policies

Run this to check if policies are correct:

```sql
SELECT 
    policyname,
    roles,
    cmd,
    qual as "USING clause"
FROM pg_policies 
WHERE tablename = 'guests' 
  AND cmd = 'UPDATE'
ORDER BY policyname;
```

You should see:
- `"guests_update_policy"` - Allows staff AND guests to update
- `"Guests can update own record"` - Allows guests to update their own records

### Step 3: Test the Linking

1. **Check browser console** (F12 → Console tab)
   - Look for logs starting with `[getGuestBookings]`
   - Should see: "Found anonymous guest" and "Successfully linked"

2. **If you see errors**, check:
   - Error code (should be visible in console)
   - Error message
   - Whether the anonymous guest was found

### Step 4: Manual Test Query

Replace `'your-email@example.com'` with the email you used for booking:

```sql
-- Check if anonymous guest exists
SELECT 
    id,
    email,
    first_name,
    last_name,
    user_id,
    created_at
FROM public.guests
WHERE email = 'your-email@example.com'
  AND user_id IS NULL;

-- Check reservations for that guest
SELECT 
    r.id,
    r.reservation_number,
    r.check_in_date,
    r.check_out_date,
    g.email,
    g.user_id
FROM public.reservations r
JOIN public.guests g ON r.guest_id = g.id
WHERE g.email = 'your-email@example.com';
```

### Step 5: If Still Not Working

1. **Check RLS is enabled:**
   ```sql
   SELECT tablename, rowsecurity 
   FROM pg_tables 
   WHERE tablename = 'guests';
   ```
   Should show `rowsecurity = true`

2. **Check if SELECT is blocked:**
   The code needs to SELECT anonymous guests to find them. Make sure this policy exists:
   ```sql
   SELECT policyname, roles, cmd
   FROM pg_policies 
   WHERE tablename = 'guests' 
     AND cmd = 'SELECT'
     AND 'anon' = ANY(roles::text[]);
   ```

3. **Check browser console for detailed errors**
   - Open DevTools (F12)
   - Go to Console tab
   - Look for `[getGuestBookings]` logs
   - Share any error messages

## Expected Behavior After Fix

1. User books anonymously → guest record with `user_id = null`
2. User signs in → visits "My Account"
3. System finds anonymous guest by email
4. System links guest record (`UPDATE guests SET user_id = ...`)
5. Bookings appear in "My Account"

## Debugging

If linking still fails, check:
- ✅ Migration was run successfully
- ✅ Policies allow UPDATE for guests
- ✅ Anonymous guest exists with matching email
- ✅ Browser console shows linking attempt
- ✅ No RLS errors in console
