# OAuth Configuration - Execution Checklist

**Project:** HMS - Hotel Management System  
**Supabase Project ID:** `qnwsnrfcnonaxvnithfv`  
**Date:** _______________

---

## 🔵 GOOGLE OAUTH CONFIGURATION

### Step 1: Create Google Cloud Project
- [ ] Visit: https://console.cloud.google.com/
- [ ] Click "Select a Project" → "NEW PROJECT"
- [ ] Project Name: `HMS OAuth`
- [ ] Click "CREATE"
- [ ] Wait for project creation
- [ ] Select the project in top bar

**Status:** ⬜ Not Started / ⬜ In Progress / ⬜ Complete

---

### Step 2: Enable Google+ API
- [ ] Go to: APIs & Services → Library
- [ ] Search for "Google+ API"
- [ ] Click "ENABLE"
- [ ] Wait for API to be enabled

**Status:** ⬜ Not Started / ⬜ In Progress / ⬜ Complete

---

### Step 3: Configure OAuth Consent Screen
- [ ] Go to: APIs & Services → OAuth consent screen
- [ ] User Type: Select "External"
- [ ] App name: `Hotel Management System`
- [ ] User support email: _______________
- [ ] Developer contact: _______________
- [ ] Click "SAVE AND CONTINUE"
- [ ] Scopes: Add `email` and `profile`
- [ ] Click "UPDATE" → "SAVE AND CONTINUE"
- [ ] Test users: Add your Gmail address
- [ ] Click "SAVE AND CONTINUE" → "BACK TO DASHBOARD"

**Status:** ⬜ Not Started / ⬜ In Progress / ⬜ Complete

---

### Step 4: Create OAuth 2.0 Client ID
- [ ] Go to: APIs & Services → Credentials
- [ ] Click "+ CREATE CREDENTIALS" → "OAuth 2.0 Client ID"
- [ ] Application type: **Web application**
- [ ] Name: `HMS Web Client`

**Authorized JavaScript origins:**
- [ ] `http://localhost:5173`
- [ ] `http://localhost:3000`
- [ ] `http://localhost:8080`

**Authorized redirect URIs:**
- [ ] `https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback`
- [ ] `http://localhost:5173/auth/callback`

- [ ] Click "CREATE"
- [ ] **COPY Client ID:** _______________
- [ ] **COPY Client Secret:** _______________

**Status:** ⬜ Not Started / ⬜ In Progress / ⬜ Complete

---

### Step 5: Configure in Supabase
- [ ] Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers
- [ ] Find "Google" provider
- [ ] Toggle "Enable" to **ON**
- [ ] Paste Client ID
- [ ] Paste Client Secret
- [ ] Click "SAVE"
- [ ] Verify status shows "Enabled"

**Status:** ⬜ Not Started / ⬜ In Progress / ⬜ Complete

---

## 🐙 GITHUB OAUTH CONFIGURATION

### Step 1: Create GitHub OAuth App
- [ ] Visit: https://github.com/settings/developers
- [ ] Click "OAuth Apps" → "New OAuth App"
- [ ] Application name: `HMS - Hotel Management System`
- [ ] Homepage URL: `http://localhost:5173`
- [ ] Authorization callback URL: `https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback`
- [ ] Click "Register application"
- [ ] Click "Generate a new client secret"
- [ ] **COPY Client ID:** _______________
- [ ] **COPY Client Secret:** _______________

**Status:** ⬜ Not Started / ⬜ In Progress / ⬜ Complete

---

### Step 2: Configure in Supabase
- [ ] Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers
- [ ] Find "GitHub" provider
- [ ] Toggle "Enable" to **ON**
- [ ] Paste Client ID
- [ ] Paste Client Secret
- [ ] Click "SAVE"
- [ ] Verify status shows "Enabled"

**Status:** ⬜ Not Started / ⬜ In Progress / ⬜ Complete

---

## ⚙️ SUPABASE CONFIGURATION

### Step 1: Configure Site URL and Redirect URLs
- [ ] Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/url-configuration
- [ ] Site URL: `http://localhost:5173`
- [ ] Redirect URLs: Add these (one per line):
  - [ ] `http://localhost:5173/**`
  - [ ] `http://localhost:3000/**`
  - [ ] `http://localhost:8080/**`
- [ ] Click "SAVE"

**Status:** ⬜ Not Started / ⬜ In Progress / ⬜ Complete

---

## ✅ VERIFICATION

### Step 1: Verify Provider Status
- [ ] Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers
- [ ] Google shows as "Enabled" ✅
- [ ] GitHub shows as "Enabled" ✅

**Status:** ⬜ Not Verified / ⬜ Verified

---

### Step 2: Test OAuth Login
- [ ] Start dev server: `npm run dev`
- [ ] Visit: http://localhost:5173/auth
- [ ] Click "Continue with Google"
- [ ] Complete Google login
- [ ] Verify redirect to `/admin`
- [ ] User appears in Supabase users table
- [ ] Sign out
- [ ] Click "Continue with GitHub"
- [ ] Complete GitHub login
- [ ] Verify redirect to `/admin`
- [ ] User appears in Supabase users table

**Status:** ⬜ Not Tested / ⬜ Google Works / ⬜ GitHub Works / ⬜ Both Work

---

## 📊 CONFIGURATION SUMMARY

**Google OAuth:**
- Client ID: _______________
- Client Secret: _______________ (stored securely)
- Status: ⬜ Not Configured / ⬜ Configured / ⬜ Tested

**GitHub OAuth:**
- Client ID: _______________
- Client Secret: _______________ (stored securely)
- Status: ⬜ Not Configured / ⬜ Configured / ⬜ Tested

**Supabase:**
- Site URL: ⬜ Configured
- Redirect URLs: ⬜ Configured
- Google Provider: ⬜ Enabled
- GitHub Provider: ⬜ Enabled

---

## 🎯 OVERALL STATUS

**Configuration:** ⬜ Not Started / ⬜ In Progress / ⬜ Complete  
**Testing:** ⬜ Not Started / ⬜ In Progress / ⬜ Complete  
**Production Ready:** ⬜ No / ⬜ Yes

---

## 📝 NOTES

_Use this space to record any issues, errors, or additional configuration needed:_




---

## 🔗 QUICK LINKS

**Supabase:**
- Dashboard: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv
- Auth Providers: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers
- URL Configuration: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/url-configuration
- Users: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/users

**OAuth Providers:**
- Google Cloud Console: https://console.cloud.google.com/
- GitHub OAuth Apps: https://github.com/settings/developers

---

**Completed By:** _______________  
**Date Completed:** _______________

