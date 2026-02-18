# 🔧 Fix: Wrong Domain Redirect After Login

## 🚨 Problem
Signing into `hms-aurora-portal-clean.vercel.app` redirects to `https://hms-gcp-refactor.vercel.app/grand-hospitality`

## 🎯 Root Cause
**Supabase Authentication URL Configuration** is pointing to the wrong domain (`hms-gcp-refactor.vercel.app` instead of `hms-aurora-portal-clean.vercel.app`).

## ✅ Solution: Update Supabase Configuration

### Step 1: Update Supabase Site URL

1. **Go to Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/url-configuration
   - Or: Dashboard → Authentication → URL Configuration

2. **Update Site URL:**
   - **Current (WRONG):** `https://hms-gcp-refactor.vercel.app`
   - **Change to:** `https://hms-aurora-portal-clean.vercel.app`
   - ⚠️ **This is the PRIMARY fix** - Supabase uses this as the default redirect target

3. **Update Redirect URLs:**
   Make sure these are ALL added (one per line):
   ```
   http://localhost:5173/**
   http://localhost:3000/**
   http://localhost:8080/**
   https://hms-aurora-portal-clean.vercel.app/**
   ```
   
   **Remove any old domains:**
   - ❌ Remove: `https://hms-gcp-refactor.vercel.app/**`
   - ❌ Remove: `https://hms-gcp-cursor.vercel.app/**`
   
   **Keep only:**
   - ✅ `https://hms-aurora-portal-clean.vercel.app/**` (your current domain)

4. **Click "SAVE"**

---

### Step 2: Verify OAuth Provider Redirects (if using OAuth)

If you're using Google/GitHub OAuth, also update:

#### Google OAuth Console

1. **Go to:** https://console.cloud.google.com/apis/credentials
2. **Find your OAuth 2.0 Client ID** → Click to edit
3. **Update Authorized JavaScript origins:**
   - ❌ Remove: `https://hms-gcp-refactor.vercel.app`
   - ✅ Add: `https://hms-aurora-portal-clean.vercel.app`
   
   Should include:
   ```
   http://localhost:5173
   http://localhost:3000
   http://localhost:8080
   https://hms-aurora-portal-clean.vercel.app
   ```

4. **Click "SAVE"**

#### GitHub OAuth (if using)

1. **Go to:** https://github.com/settings/developers
2. **Click on your OAuth App**
3. **Update Homepage URL:**
   - Change to: `https://hms-aurora-portal-clean.vercel.app`
4. **Click "Update application"**

---

## 🧪 Test After Fixing

1. **Clear browser cache and cookies** (important!)
2. **Visit:** `https://hms-aurora-portal-clean.vercel.app/auth`
3. **Sign in** (email/password or OAuth)
4. **Expected:** Should redirect to `https://hms-aurora-portal-clean.vercel.app/` (home page)
5. **Should NOT redirect to:** `hms-gcp-refactor.vercel.app` ❌

---

## 🔍 Why This Happens

Supabase's **Site URL** setting is used as the default redirect target after authentication. If it's set to the wrong domain, all logins will redirect there.

The code in this repo uses `window.location.origin` for redirects, which is correct. The issue is purely in Supabase configuration.

---

## 📝 Quick Checklist

- [ ] Updated Supabase Site URL to `https://hms-aurora-portal-clean.vercel.app`
- [ ] Updated Supabase Redirect URLs (removed old domains)
- [ ] Updated Google OAuth origins (if using Google)
- [ ] Updated GitHub OAuth homepage (if using GitHub)
- [ ] Cleared browser cache/cookies
- [ ] Tested login flow

---

## 🚨 Important Notes

1. **Site URL is the key setting** - This is what Supabase uses as the default redirect
2. **Changes take effect immediately** - No need to redeploy code
3. **Clear browser cache** - Old redirects might be cached
4. **Check all OAuth providers** - Each provider needs to be updated separately

---

## 🔗 Direct Links

- **Supabase URL Config:** https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/url-configuration
- **Google OAuth Console:** https://console.cloud.google.com/apis/credentials
- **GitHub OAuth Apps:** https://github.com/settings/developers
