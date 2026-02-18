# Fix 401 Error in Browser (API Works, Browser Doesn't)

## ✅ Confirmed Working

- ✅ API test shows SELECT works (HTTP 200)
- ✅ Anon key is valid
- ✅ RLS policies are correct
- ✅ Server-side connection works

## ❌ Browser Issue

The 401 error in browser means the **Supabase client isn't sending the anon key** in requests.

## Quick Fixes

### Fix 1: Clear Browser Auth State

The Supabase client might be trying to use a stale/invalid session token instead of the anon key.

**In browser console, run:**

```javascript
// Clear Supabase auth state
localStorage.removeItem('hms-supabase-auth-token');
localStorage.removeItem('sb-qnwsnrfcnonaxvnithfv-auth-token');
localStorage.clear();

// Reload page
location.reload();
```

### Fix 2: Verify Client Initialization

**In browser console, run:**

```javascript
// Check if client is initialized
import('/src/integrations/supabase/client.js').then(({ supabase }) => {
  console.log('✅ Supabase client loaded');
  
  // Check what key it's using
  const client = supabase;
  console.log('Client URL:', client.supabaseUrl);
  console.log('Has anon key:', !!client.supabaseKey);
  
  // Test direct query
  client.from('guests')
    .select('id')
    .limit(1)
    .then(({ data, error }) => {
      if (error) {
        console.error('❌ Error:', error.message, error.code);
      } else {
        console.log('✅ Query works!', data);
      }
    });
});
```

### Fix 3: Check Network Request Headers

1. Open DevTools → Network tab
2. Try booking flow
3. Find failed request to `/rest/v1/guests`
4. Click → Headers tab
5. Check:
   - `apikey` header → Should have anon key
   - `Authorization` header → Should have `Bearer <anon-key>`

**If headers are missing:**
- The client isn't initialized properly
- Environment variables aren't loading in browser

### Fix 4: Hard Refresh & Clear Cache

1. Open DevTools (F12)
2. Right-click refresh button → "Empty Cache and Hard Reload"
3. Or: Ctrl+Shift+R (Windows) / Cmd+Shift+R (Mac)

### Fix 5: Check for Auth Session Interference

The client might be trying to use an invalid session token. Check:

```javascript
// In browser console
import('/src/integrations/supabase/client.js').then(({ supabase }) => {
  supabase.auth.getSession().then(({ data: { session }, error }) => {
    console.log('Current session:', session);
    if (session) {
      console.log('⚠️  Has session - might be interfering');
      console.log('   Session user:', session.user?.email);
    } else {
      console.log('✅ No session - should use anon key');
    }
  });
});
```

If there's an invalid session, clear it:

```javascript
import('/src/integrations/supabase/client.js').then(({ supabase }) => {
  supabase.auth.signOut().then(() => {
    console.log('✅ Signed out, cleared session');
    location.reload();
  });
});
```

## Most Likely Solution

Since the API works but browser doesn't:

1. **Clear localStorage:**
   ```javascript
   localStorage.clear();
   location.reload();
   ```

2. **Hard refresh browser:**
   - Ctrl+Shift+R or Cmd+Shift+R

3. **Verify client is using anon key:**
   - Check browser console for initialization logs
   - Should see: `✅ Supabase client initialized`

4. **Check Network tab:**
   - Verify `apikey` header is present in requests

## If Still Not Working

The issue might be that the Supabase client is checking for a session first and failing before falling back to anon key. Try:

1. **Open in incognito/private window** (no cached state)
2. **Test booking flow there**
3. If it works in incognito → Browser cache/session issue
4. If it still fails → Client initialization issue
