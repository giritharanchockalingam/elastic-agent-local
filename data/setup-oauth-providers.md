# OAuth Provider Setup Guide

This guide walks you through configuring Google and GitHub OAuth providers for the HMS application.

---

## 🎯 Quick Overview

**Project Details:**
- **Supabase Project ID:** `qnwsnrfcnonaxvnithfv`
- **Supabase URL:** `https://qnwsnrfcnonaxvnithfv.supabase.co`
- **Redirect URI:** `https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback`
- **Local Dev URL:** `http://localhost:5173`

---

## 📋 Prerequisites

- [ ] Access to Google Cloud Console (https://console.cloud.google.com/)
- [ ] GitHub account with developer access
- [ ] Access to Supabase Dashboard (https://app.supabase.com)
- [ ] Project: `qnwsnrfcnonaxvnithfv`

---

## 🔵 STEP 1: Configure Google OAuth

### 1.1 Create Google Cloud Project

1. **Go to Google Cloud Console:**
   - Visit: https://console.cloud.google.com/
   - Sign in with your Google account

2. **Create New Project:**
   - Click "Select a Project" → "NEW PROJECT"
   - **Project Name:** `HMS OAuth` (or any name you prefer)
   - Click "CREATE"
   - Wait for project creation (may take a minute)

3. **Select the Project:**
   - Make sure your new project is selected in the top bar

### 1.2 Enable Google+ API

1. **Navigate to APIs & Services:**
   - Go to: APIs & Services → Library
   - Or visit: https://console.cloud.google.com/apis/library

2. **Enable Google+ API:**
   - Search for "Google+ API"
   - Click on it
   - Click "ENABLE" button
   - Wait for API to be enabled

### 1.3 Configure OAuth Consent Screen

1. **Go to OAuth Consent Screen:**
   - Navigate to: APIs & Services → OAuth consent screen
   - Or visit: https://console.cloud.google.com/apis/credentials/consent

2. **Choose User Type:**
   - **For Testing:** Select "External"
   - **For Organization:** Select "Internal" (if you have Google Workspace)
   - Click "CREATE"

3. **Fill in App Information:**
   - **App name:** `Hotel Management System`
   - **User support email:** Your email address
   - **App logo:** (Optional) Upload a logo
   - **App domain:** (Optional)
   - **Developer contact:** Your email address
   - Click "SAVE AND CONTINUE"

4. **Configure Scopes:**
   - Click "ADD OR REMOVE SCOPES"
   - Select:
     - `.../auth/userinfo.email`
     - `.../auth/userinfo.profile`
   - Click "UPDATE"
   - Click "SAVE AND CONTINUE"

5. **Add Test Users (if External):**
   - Click "ADD USERS"
   - Add your Gmail address
   - Click "ADD"
   - Click "SAVE AND CONTINUE"

6. **Review and Publish:**
   - Review the summary
   - Click "BACK TO DASHBOARD"

### 1.4 Create OAuth 2.0 Credentials

1. **Go to Credentials:**
   - Navigate to: APIs & Services → Credentials
   - Or visit: https://console.cloud.google.com/apis/credentials

2. **Create OAuth Client ID:**
   - Click "+ CREATE CREDENTIALS" → "OAuth 2.0 Client ID"

3. **Configure Application:**
   - **Application type:** Web application
   - **Name:** `HMS Web Client`

4. **Authorized JavaScript origins:**
   Add these URLs (one per line):
   ```
   http://localhost:5173
   http://localhost:3000
   http://localhost:8080
   ```

5. **Authorized redirect URIs:**
   Add these URIs (one per line):
   ```
   https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback
   http://localhost:5173/auth/callback
   ```

6. **Create:**
   - Click "CREATE"
   - **IMPORTANT:** Copy the **Client ID** and **Client Secret** immediately
   - Store them securely (you'll need them for Supabase)

### 1.5 Configure in Supabase

1. **Go to Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers
   - Or: Dashboard → Authentication → Providers

2. **Enable Google Provider:**
   - Find "Google" in the provider list
   - Toggle the switch to **ON** (Enable)

3. **Add Credentials:**
   - **Client ID (for OAuth):** Paste your Google Client ID
   - **Client Secret (for OAuth):** Paste your Google Client Secret
   - Click "SAVE"

4. **Verify Configuration:**
   - Make sure the toggle shows "Enabled"
   - Status should be green/active

---

## 🐙 STEP 2: Configure GitHub OAuth

### 2.1 Create GitHub OAuth App

1. **Go to GitHub Developer Settings:**
   - Visit: https://github.com/settings/developers
   - Sign in to GitHub

2. **Create New OAuth App:**
   - Click "OAuth Apps" in the left sidebar
   - Click "New OAuth App" button

3. **Fill in Application Details:**
   - **Application name:** `HMS - Hotel Management System`
   - **Homepage URL:** `http://localhost:5173`
   - **Authorization callback URL:** `https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback`
   - **Application description:** (Optional) `OAuth for Hotel Management System`

4. **Register Application:**
   - Click "Register application"
   - You'll be redirected to the app settings page

5. **Generate Client Secret:**
   - On the app settings page, click "Generate a new client secret"
   - **IMPORTANT:** Copy the **Client ID** and **Client Secret** immediately
   - The secret will only be shown once!

### 2.2 Configure in Supabase

1. **Go to Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers
   - Or: Dashboard → Authentication → Providers

2. **Enable GitHub Provider:**
   - Find "GitHub" in the provider list
   - Toggle the switch to **ON** (Enable)

3. **Add Credentials:**
   - **Client ID (for OAuth):** Paste your GitHub Client ID
   - **Client Secret (for OAuth):** Paste your GitHub Client Secret
   - Click "SAVE"

4. **Verify Configuration:**
   - Make sure the toggle shows "Enabled"
   - Status should be green/active

---

## ⚙️ STEP 3: Configure Supabase Site URL

1. **Go to Authentication Settings:**
   - Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/url-configuration
   - Or: Dashboard → Authentication → URL Configuration

2. **Set Site URL:**
   - **Site URL:** `http://localhost:5173` (for development)
   - For production, update to your production domain

3. **Add Redirect URLs:**
   Add these URLs (one per line):
   ```
   http://localhost:5173/**
   http://localhost:3000/**
   http://localhost:8080/**
   ```

4. **Save:**
   - Click "SAVE" button

---

## ✅ STEP 4: Verification

### 4.1 Check Provider Status

1. **Verify in Supabase:**
   - Go to: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers
   - Verify both Google and GitHub show as **Enabled**

### 4.2 Test OAuth Login

1. **Start Development Server:**
   ```bash
   npm run dev
   ```

2. **Open Application:**
   - Visit: http://localhost:5173/auth
   - Or: http://localhost:8080/auth

3. **Test Google Login:**
   - Click "Continue with Google" button
   - Should redirect to Google login
   - After login, should redirect back to app
   - User should be logged in

4. **Test GitHub Login:**
   - Sign out first
   - Click "Continue with GitHub" button
   - Should redirect to GitHub login
   - After login, should redirect back to app
   - User should be logged in

5. **Verify User Creation:**
   - Go to: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/users
   - You should see your OAuth user with provider badge (Google/GitHub icon)

---

## 🚨 Troubleshooting

### Issue: "Invalid redirect_uri"

**Solution:**
- Verify redirect URI is EXACTLY: `https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback`
- Check for typos in project ID
- Ensure no extra slashes or spaces

### Issue: "Access denied" or "Error 400"

**Solution:**
- **Google:** Add your email as test user in OAuth consent screen
- **GitHub:** Verify OAuth app is active and not suspended
- Check that credentials are correctly pasted in Supabase

### Issue: "CORS error"

**Solution:**
- Add `http://localhost:5173` to Google Console → Authorized JavaScript origins
- Verify Supabase Site URL is set correctly

### Issue: User not redirected after login

**Solution:**
- Check Supabase → Authentication → URL Configuration
- Verify Site URL is set to `http://localhost:5173`
- Add redirect URLs to allowed list

### Issue: "Provider not enabled"

**Solution:**
- Go to Supabase → Authentication → Providers
- Verify Google/GitHub toggle is ON
- Check that credentials are saved

---

## 📊 Verification Checklist

Use this checklist to verify your setup:

```
Google OAuth:
□ Google Cloud project created
□ Google+ API enabled
□ OAuth consent screen configured
□ OAuth 2.0 Client ID created
□ Client ID and Secret copied
□ Authorized redirect URI added
□ Supabase: Google provider enabled
□ Supabase: Google credentials saved
□ Test: Google login works

GitHub OAuth:
□ GitHub OAuth App created
□ Client ID and Secret copied
□ Callback URL configured
□ Supabase: GitHub provider enabled
□ Supabase: GitHub credentials saved
□ Test: GitHub login works

Supabase Configuration:
□ Site URL configured
□ Redirect URLs added
□ Both providers show as enabled

Testing:
□ Google login redirects correctly
□ GitHub login redirects correctly
□ Users created in Supabase
□ Users can access protected routes
□ Sign out works
```

---

## 🔗 Quick Links

**Supabase:**
- Dashboard: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv
- Auth Providers: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers
- URL Configuration: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/url-configuration
- Users: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/users

**OAuth Providers:**
- Google Cloud Console: https://console.cloud.google.com/
- GitHub OAuth Apps: https://github.com/settings/developers

---

## 🚀 Production Deployment

Before deploying to production:

1. **Update Google OAuth:**
   - Add production domain to Authorized JavaScript origins
   - Add production redirect URI

2. **Update GitHub OAuth:**
   - Update Homepage URL to production domain
   - Update Callback URL (if needed)

3. **Update Supabase:**
   - Set Site URL to production domain
   - Add production redirect URLs

4. **Publish OAuth Consent:**
   - Google: Publish consent screen (or keep Internal)
   - GitHub: OAuth app is already active

---

**Status:** Ready to Configure  
**Estimated Time:** 15-20 minutes  
**Next Action:** Start with Google OAuth setup

