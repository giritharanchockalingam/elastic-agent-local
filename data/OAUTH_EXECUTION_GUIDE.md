# OAuth Configuration - Execution Guide

**Status:** Ready to Execute  
**Time Required:** 15-20 minutes

---

## 🚀 Quick Start

You have **3 options** to configure OAuth:

### Option 1: Interactive Wizard (Recommended)
```bash
node scripts/configure-oauth-interactive.cjs
```
This will guide you step-by-step through the entire process.

### Option 2: Follow Checklist
Use the checklist: `OAUTH_EXECUTION_CHECKLIST.md`
- Print or open the checklist
- Follow each step
- Check off items as you complete them

### Option 3: Follow Detailed Guide
Read: `scripts/setup-oauth-providers.md`
- Comprehensive step-by-step instructions
- Screenshots and detailed explanations

---

## 📋 What You'll Need

Before starting, ensure you have:

- [ ] Access to Google Cloud Console (https://console.cloud.google.com/)
- [ ] Google account with project creation permissions
- [ ] GitHub account
- [ ] Access to Supabase Dashboard (https://app.supabase.com)
- [ ] About 20 minutes of time

---

## 🎯 Execution Steps Summary

### Google OAuth (5 steps, ~10 minutes)
1. Create Google Cloud Project
2. Enable Google+ API
3. Configure OAuth Consent Screen
4. Create OAuth 2.0 Client ID
5. Add credentials to Supabase

### GitHub OAuth (2 steps, ~5 minutes)
1. Create GitHub OAuth App
2. Add credentials to Supabase

### Supabase Configuration (1 step, ~2 minutes)
1. Configure Site URL and redirect URLs

### Testing (1 step, ~3 minutes)
1. Test both OAuth providers

**Total Time:** ~20 minutes

---

## 🔗 Important URLs

**Supabase Dashboard:**
- Auth Providers: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers
- URL Configuration: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/url-configuration

**OAuth Providers:**
- Google Cloud Console: https://console.cloud.google.com/
- GitHub OAuth Apps: https://github.com/settings/developers

**Application:**
- Local Dev: http://localhost:5173/auth

---

## ⚙️ Configuration Details

**Redirect URI (Required for both):**
```
https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback
```

**Authorized JavaScript Origins (Google):**
```
http://localhost:5173
http://localhost:3000
http://localhost:8080
```

**Site URL (Supabase):**
```
http://localhost:5173
```

---

## ✅ Success Criteria

You'll know it's working when:

1. ✅ Both providers show as "Enabled" in Supabase
2. ✅ Clicking "Continue with Google" redirects to Google login
3. ✅ Clicking "Continue with GitHub" redirects to GitHub login
4. ✅ After login, user is redirected to `/admin`
5. ✅ User appears in Supabase users table with provider badge

---

## 🚨 Common Issues

### "Invalid redirect_uri"
- Verify redirect URI is EXACTLY: `https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback`
- Check for typos in project ID

### "Access denied"
- **Google:** Add your email as test user in OAuth consent screen
- **GitHub:** Verify OAuth app is active

### "CORS error"
- Add `http://localhost:5173` to Google Console → Authorized JavaScript origins
- Verify Supabase Site URL is set correctly

---

## 📚 Documentation Files

1. **`scripts/configure-oauth-interactive.cjs`** - Interactive wizard
2. **`OAUTH_EXECUTION_CHECKLIST.md`** - Printable checklist
3. **`scripts/setup-oauth-providers.md`** - Detailed guide
4. **`OAuth/files/OAUTH_QUICK_START.md`** - Quick reference

---

## 🎬 Ready to Start?

**Run the interactive wizard:**
```bash
node scripts/configure-oauth-interactive.cjs
```

**Or follow the checklist:**
Open `OAUTH_EXECUTION_CHECKLIST.md` and follow step-by-step.

---

**Good luck! The process is straightforward and should take about 20 minutes.**

