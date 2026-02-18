# Debug 401 Error After Policies Are Set

## ✅ Policies Are Correct

You have:
- ✅ `"Allow anonymous SELECT on guests"` with `{anon}` role
- ✅ `"Allow public guest creation for bookings"` with `{anon}` role

But still getting 401 errors. This means the **Supabase client isn't sending the anon key** in the request.

## Diagnostic Steps

### Step 1: Check Browser Console

Open browser console (F12) and look for:

```
✅ Supabase client initialized: { url: '...', hasKey: true, keyLength: 208 }
```

If you see:
- `hasKey: false` → Environment variable not loaded
- `keyLength: 0` → Key is empty
- No log at all → Client not initializing

### Step 2: Check Network Request Headers

1. Open DevTools → Network tab
2. Try the booking flow
3. Find the failed request to `/rest/v1/guests`
4. Click on it → Headers tab
5. Look for:
   - `apikey` header → Should have your anon key
   - `Authorization` header → Should have `Bearer <anon-key>`

**If these headers are missing or wrong:**
- The environment variable isn't being loaded
- The dev server needs to be restarted

### Step 3: Verify Environment Variable in Browser

Run this in browser console:

```javascript
// Check if env vars are accessible
console.log('URL:', import.meta.env.VITE_SUPABASE_URL);
console.log('Has Key:', !!import.meta.env.VITE_SUPABASE_ANON_KEY);
console.log('Key Length:', import.meta.env.VITE_SUPABASE_ANON_KEY?.length || 0);
console.log('Key Preview:', import.meta.env.VITE_SUPABASE_ANON_KEY?.substring(0, 20) + '...');
```

**Expected:**
- URL: `https://qnwsnrfcnonaxvnithfv.supabase.co`
- Has Key: `true`
- Key Length: `208` (or similar)
- Key Preview: `eyJhbGciOiJIUzI1NiIs...`

### Step 4: Test Supabase Client Directly

Run this in browser console:

```javascript
// Import supabase client (adjust path if needed)
const { supabase } = await import('/src/integrations/supabase/client.ts');

// Test SELECT
const { data, error } = await supabase
  .from('guests')
  .select('id')
  .limit(1);

if (error) {
  console.error('❌ Error:', error.message, error.code);
  if (error.code === 'PGRST301' || error.message.includes('JWT')) {
    console.error('🔑 API Key issue - check VITE_SUPABASE_ANON_KEY');
  }
} else {
  console.log('✅ SELECT works!', data);
}

// Test INSERT (with test data)
const { data: insertData, error: insertError } = await supabase
  .from('guests')
  .insert({
    property_id: '00000000-0000-0000-0000-000000000111', // Your property ID
    first_name: 'Test',
    last_name: 'Guest',
    email: 'test' + Date.now() + '@example.com',
    phone: '+1234567890'
  })
  .select('id')
  .single();

if (insertError) {
  console.error('❌ INSERT Error:', insertError.message, insertError.code);
} else {
  console.log('✅ INSERT works!', insertData);
}
```

## Common Issues & Fixes

### Issue 1: Environment Variable Not Loading

**Symptom:** `hasKey: false` in console

**Fix:**
1. Verify `.env.local` exists and has correct values
2. **Restart dev server** (env vars load at startup)
3. Clear browser cache and hard refresh

### Issue 2: Wrong Key Being Used

**Symptom:** Key exists but requests still fail with 401

**Fix:**
1. Get fresh anon key from Supabase dashboard
2. Update `.env.local`
3. Restart dev server
4. Hard refresh browser

### Issue 3: Service Role Key Instead of Anon Key

**Symptom:** Key is 500+ characters (service_role is longer)

**Fix:**
- Use the **anon** key (200-300 chars), not service_role

### Issue 4: Browser Cache

**Symptom:** Policies are correct but still getting 401

**Fix:**
1. Hard refresh: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
2. Or: DevTools → Network tab → "Disable cache" checkbox
3. Clear localStorage: `localStorage.clear()`

## Quick Fix Checklist

- [ ] Policies exist (you confirmed ✅)
- [ ] `.env.local` has correct anon key
- [ ] Dev server restarted after updating `.env.local`
- [ ] Browser cache cleared
- [ ] Network request shows `apikey` header
- [ ] Console shows `✅ Supabase client initialized`

## Still Not Working?

If policies are correct but still getting 401:

1. **Check the actual request:**
   - Open Network tab
   - Find the failed request
   - Check Request Headers
   - Verify `apikey` header exists and has correct value

2. **Check Supabase Dashboard:**
   - Go to Settings → API
   - Verify the anon key matches what's in `.env.local`
   - If different, update `.env.local` and restart

3. **Try direct API call:**
   ```bash
   curl -X GET "https://qnwsnrfcnonaxvnithfv.supabase.co/rest/v1/guests?select=id&limit=1" \
     -H "apikey: YOUR_ANON_KEY" \
     -H "Authorization: Bearer YOUR_ANON_KEY"
   ```
   
   Replace `YOUR_ANON_KEY` with your actual anon key. If this works, the issue is in the client code.
