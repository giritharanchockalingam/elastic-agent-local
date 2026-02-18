# Fix 401 Error - Guest Checkout

## The Problem

You're seeing:
```
Failed to load resource: the server responded with a status of 401
qnwsnrfcnonaxvnithfv.supabase.co/rest/v1/guests?select=id:1
```

**This is NOT an RLS issue** - it's an **authentication issue**. The Supabase client is not sending a valid anon key.

## Root Cause

The 401 error means:
- ❌ The `Authorization` header is missing
- ❌ The anon key is invalid/expired
- ❌ The environment variable is not set correctly

## Fix Steps

### Step 1: Check Browser Console

Open browser console (F12) and look for:
```
✅ Supabase client initialized: { url: '...', hasKey: true, keyLength: 200+ }
```

If you see:
- `hasKey: false` → Environment variable not loaded
- `keyLength: 0` → Key is empty
- `❌ VITE_SUPABASE_ANON_KEY appears to be invalid` → Key format is wrong

### Step 2: Verify Local Environment File

Check your `.env.local` file (in project root):

```bash
# Should exist and have:
VITE_SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... (200+ chars)
```

**Common Issues:**
- ❌ File doesn't exist → Create it
- ❌ Key is truncated → Copy full key
- ❌ Extra spaces → Remove them
- ❌ Using service_role key → Must use anon key

### Step 3: Get Fresh Anon Key from Supabase

1. Go to: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/settings/api

2. Find **"anon"** key (NOT service_role)

3. Click **"Reveal"**

4. Copy the **ENTIRE key** (starts with `eyJ...`, 200+ characters)

### Step 4: Update .env.local

```bash
# .env.local
VITE_SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... (paste full key here)
```

**Important:**
- ✅ No quotes around values
- ✅ No spaces before/after
- ✅ Full key (not truncated)
- ✅ Must start with `eyJ`

### Step 5: Restart Dev Server

**Environment variables are loaded at startup:**

```bash
# Stop the dev server (Ctrl+C)
# Then restart:
npm run dev
```

### Step 6: Verify in Browser

1. Open browser console (F12)
2. Check for: `✅ Supabase client initialized`
3. Try booking again
4. Check Network tab → Look at the request headers:
   - Should see: `apikey: eyJ...`
   - Should see: `Authorization: Bearer eyJ...`

## Quick Diagnostic Script

Add this to your browser console to check:

```javascript
// Run in browser console
const checkSupabase = async () => {
  console.log('🔍 Checking Supabase Configuration...');
  
  // Check if client exists
  if (typeof window !== 'undefined' && window.supabase) {
    const { data, error } = await window.supabase
      .from('guests')
      .select('id')
      .limit(1);
    
    if (error) {
      console.error('❌ Error:', error.message, error.code);
      if (error.code === 'PGRST301' || error.message.includes('JWT')) {
        console.error('🔑 API Key issue - check VITE_SUPABASE_ANON_KEY');
      }
    } else {
      console.log('✅ Supabase connection works!');
    }
  } else {
    console.error('❌ Supabase client not found');
  }
};

checkSupabase();
```

## Still Not Working?

### Check 1: Environment Variable Loading

Vite only loads `.env.local` in development. Verify:

```bash
# Check if file exists
ls -la .env.local

# Check contents (first few chars only for security)
head -c 100 .env.local
```

### Check 2: Browser Cache

Clear browser cache and hard refresh:
- Chrome: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
- Or: DevTools → Network tab → "Disable cache" checkbox

### Check 3: Network Request Headers

In browser DevTools → Network tab:
1. Find the failed request to `/rest/v1/guests`
2. Click on it
3. Check "Headers" tab
4. Look for:
   - `apikey` header → Should have your anon key
   - `Authorization` header → Should have `Bearer <anon-key>`

If these are missing or wrong, the environment variable isn't loading.

## Common Mistakes

1. **Using service_role key** → Must use anon key
2. **Key truncated** → Copy full key (200+ chars)
3. **Not restarting dev server** → Env vars load at startup
4. **Wrong file** → Must be `.env.local` (not `.env`)
5. **Quotes around values** → Don't use quotes in .env files

## Success Indicators

After fixing, you should see:
- ✅ No 401 errors in console
- ✅ `✅ Supabase client initialized` in console
- ✅ Booking flow completes successfully
- ✅ Guest record created in database
