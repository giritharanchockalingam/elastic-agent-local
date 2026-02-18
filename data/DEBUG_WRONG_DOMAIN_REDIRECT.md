# 🔍 Debug: Wrong Domain Redirect After Login

## 🚨 Problem
Signing into `hms-aurora-portal-clean.vercel.app` redirects to `https://hms-gcp-refactor.vercel.app/grand-hospitality`

## 🔍 Root Cause Analysis

Since Supabase configuration is clean, the issue is likely:

1. **OAuth Provider Configuration (Google/GitHub)** - The OAuth providers have the wrong redirect URI
2. **Browser localStorage** - Stale `returnTo` value stored with wrong domain
3. **Supabase Site URL** - Even if redirect URLs are correct, the Site URL might be wrong

## ✅ Step-by-Step Debugging

### Step 1: Check Browser Console

1. Open browser DevTools (F12)
2. Go to **Console** tab
3. Sign in and watch for:
   - `[AuthCallback]` log messages
   - Any redirect errors
   - `returnTo` values

### Step 2: Check localStorage

1. Open browser DevTools (F12)
2. Go to **Application** tab → **Local Storage**
3. Look for key: `returnTo`
4. If it contains `hms-gcp-refactor` or any full URL, **delete it**

### Step 3: Check OAuth Provider Configuration

#### Google OAuth Console

1. **Go to:** https://console.cloud.google.com/apis/credentials
2. **Find your OAuth 2.0 Client ID** → Click to edit
3. **Check "Authorized redirect URIs":**
   - Should include: `https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback`
   - Should NOT include: `https://hms-gcp-refactor.vercel.app/auth/callback`
   - Should NOT include: `https://hms-aurora-portal-clean.vercel.app/auth/callback` (Supabase handles this)

4. **Check "Authorized JavaScript origins":**
   - Should include: `https://hms-aurora-portal-clean.vercel.app`
   - Can remove: `https://hms-gcp-refactor.vercel.app` (if not needed)

#### GitHub OAuth

1. **Go to:** https://github.com/settings/developers
2. **Click on your OAuth App**
3. **Check "Authorization callback URL":**
   - Should be: `https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback`
   - Should NOT be: `https://hms-gcp-refactor.vercel.app/auth/callback`

### Step 4: Verify Supabase Site URL

Even if redirect URLs are correct, **Site URL** is used as the default redirect target.

1. **Go to:** https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/url-configuration
2. **Check "Site URL":**
   - Should be: `https://hms-aurora-portal-clean.vercel.app`
   - If it's `https://hms-gcp-refactor.vercel.app`, **change it**

### Step 5: Clear All Browser Data

1. **Clear cookies** for `vercel.app` domains
2. **Clear localStorage** (or use incognito mode)
3. **Hard refresh** (Ctrl+Shift+R or Cmd+Shift+R)

## 🛠️ Code Safeguards Added

The code now:
- ✅ Clears stale `returnTo` values from localStorage
- ✅ Validates `returnTo` is a relative path (starts with `/`)
- ✅ Rejects any URL-like paths (containing `://`)
- ✅ Forces redirect to home if unsafe path detected

## 🧪 Test After Fixing

1. **Clear browser cache and cookies**
2. **Open incognito/private window**
3. **Visit:** `https://hms-aurora-portal-clean.vercel.app/auth`
4. **Sign in** (email/password or OAuth)
5. **Expected:** Should redirect to `https://hms-aurora-portal-clean.vercel.app/` (home page)
6. **Should NOT redirect to:** `hms-gcp-refactor.vercel.app` ❌

## 🔍 Debugging Commands

### Check localStorage

```javascript
// In browser console
console.log('returnTo:', localStorage.getItem('returnTo'));
console.log('All localStorage:', { ...localStorage });
```

### Clear localStorage

```javascript
// In browser console
localStorage.removeItem('returnTo');
localStorage.clear(); // Clear all (use with caution)
```

### Check current origin

```javascript
// In browser console
console.log('Current origin:', window.location.origin);
console.log('Current URL:', window.location.href);
```

## 📋 Checklist

- [ ] Checked browser console for errors
- [ ] Checked localStorage for stale `returnTo` values
- [ ] Verified Google OAuth redirect URIs
- [ ] Verified GitHub OAuth callback URL
- [ ] Verified Supabase Site URL is correct
- [ ] Cleared browser cache/cookies
- [ ] Tested in incognito mode
- [ ] Tested login flow - redirects to correct domain

## 🚨 Most Likely Causes

1. **OAuth Provider has wrong redirect URI** (most common)
   - Google/GitHub OAuth apps might have `hms-gcp-refactor.vercel.app` in their config
   - Fix: Update OAuth provider configuration

2. **Supabase Site URL is wrong** (even if redirect URLs are correct)
   - Site URL is used as default redirect target
   - Fix: Change Site URL to `https://hms-aurora-portal-clean.vercel.app`

3. **Stale localStorage value**
   - Old `returnTo` value stored in browser
   - Fix: Clear localStorage or use incognito mode

## 🔗 Direct Links

- **Supabase URL Config:** https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/url-configuration
- **Google OAuth Console:** https://console.cloud.google.com/apis/credentials
- **GitHub OAuth Apps:** https://github.com/settings/developers
