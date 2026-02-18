# RLS Final Fix - Guest Checkout

## Current Status

Your policies look correct:
- ✅ `"Allow public guest creation for bookings"` with `{anon}` role exists
- ✅ `"Allow authenticated guest creation for bookings"` with `{authenticated}` role exists
- ✅ `"guests_insert_policy"` with `{public}` role exists (includes anon)

## If You're Still Getting Errors

### 1. Check Policy Conditions

Run this to see if any policies have restrictive conditions:

```sql
SELECT 
    policyname,
    roles,
    with_check
FROM pg_policies 
WHERE tablename = 'guests' 
  AND schemaname = 'public'
  AND cmd = 'INSERT';
```

Look for policies where `with_check` is NOT `true` or NULL - these might be blocking.

### 2. Verify Anon Policy is Active

```sql
-- Check if anon policy exists
SELECT 
    policyname,
    roles,
    cmd
FROM pg_policies 
WHERE tablename = 'guests' 
  AND 'anon' = ANY(roles::text[])
  AND cmd = 'INSERT';
```

Should return at least one policy.

### 3. Test Direct Insert

Try inserting directly as anon user in Supabase SQL Editor:

```sql
-- This should work if policies are correct
INSERT INTO public.guests (
  property_id,
  first_name,
  last_name,
  email,
  phone
) VALUES (
  '00000000-0000-0000-0000-000000000111', -- Your property ID
  'Test',
  'Guest',
  'test@example.com',
  '+1234567890'
);
```

### 4. Check Application Code

The error might be in how the Supabase client is initialized. Verify:

1. **Anonymous requests use anon key:**
   ```typescript
   // Should use VITE_SUPABASE_ANON_KEY for anonymous users
   const supabase = createClient(
     VITE_SUPABASE_URL,
     VITE_SUPABASE_ANON_KEY  // ✅ Anon key for anonymous users
   );
   ```

2. **Check if session is being checked:**
   ```typescript
   // For anonymous users, this should be null
   const { data: { session } } = await supabase.auth.getSession();
   // session should be null for anonymous users
   ```

### 5. Common Issues

#### Issue: Property ID Missing
**Symptom:** Error about required field  
**Fix:** Ensure `property_id` is included in the insert:
```typescript
.insert({
  property_id: propertyId,  // ✅ Required
  first_name: ...,
  // ...
})
```

#### Issue: Wrong Supabase Client
**Symptom:** Using service role key instead of anon key  
**Fix:** Use anon key for client-side operations

#### Issue: Policy Not Applied
**Symptom:** Policy exists but doesn't work  
**Fix:** Drop and recreate the policy:
```sql
DROP POLICY IF EXISTS "Allow public guest creation for bookings" ON public.guests;
CREATE POLICY "Allow public guest creation for bookings"
ON public.guests FOR INSERT TO anon WITH CHECK (true);
```

## Quick Diagnostic

Run this complete diagnostic:

```sql
-- 1. Check policies
SELECT policyname, roles, cmd, with_check
FROM pg_policies 
WHERE tablename = 'guests' AND cmd = 'INSERT';

-- 2. Check RLS is enabled
SELECT rowsecurity FROM pg_tables WHERE tablename = 'guests';

-- 3. Check required columns
SELECT column_name, is_nullable 
FROM information_schema.columns
WHERE table_name = 'guests' 
  AND column_name IN ('property_id', 'first_name', 'last_name', 'email');
```

## Still Not Working?

Share:
1. The exact error message
2. Output of the diagnostic queries above
3. The code path where the insert happens (which file/function)
