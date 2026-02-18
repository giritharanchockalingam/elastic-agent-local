# OAuth Provider Configuration - Setup Guide

**Status:** ✅ Application Code Ready - Manual Configuration Required

---

## 🎯 Current Status

✅ **Application Code:** OAuth buttons and handlers are already implemented in `src/pages/Auth.tsx`  
⏳ **Provider Configuration:** Needs to be configured in Google Cloud Console, GitHub, and Supabase

---

## 📋 Quick Setup Checklist

Follow these steps to complete OAuth configuration:

### Google OAuth Setup

- [ ] **Step 1:** Create Google Cloud Project
- [ ] **Step 2:** Enable Google+ API
- [ ] **Step 3:** Configure OAuth Consent Screen
- [ ] **Step 4:** Create OAuth 2.0 Client ID
- [ ] **Step 5:** Add credentials to Supabase

### GitHub OAuth Setup

- [ ] **Step 1:** Create GitHub OAuth App
- [ ] **Step 2:** Generate Client Secret
- [ ] **Step 3:** Add credentials to Supabase

### Supabase Configuration

- [ ] **Step 1:** Enable Google provider
- [ ] **Step 2:** Enable GitHub provider
- [ ] **Step 3:** Configure Site URL
- [ ] **Step 4:** Add redirect URLs

### Testing

- [ ] **Step 1:** Test Google login
- [ ] **Step 2:** Test GitHub login
- [ ] **Step 3:** Verify user creation

---

## 📖 Detailed Instructions

### For Google OAuth: See `scripts/setup-oauth-providers.md`
### For GitHub OAuth: See `scripts/setup-oauth-providers.md`
### Quick Reference: See `OAuth/files/OAUTH_QUICK_START.md`

---

## 🔗 Important URLs

**Supabase:**
- Dashboard: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv
- Auth Providers: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers
- URL Configuration: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/url-configuration

**OAuth Providers:**
- Google Cloud Console: https://console.cloud.google.com/
- GitHub OAuth Apps: https://github.com/settings/developers

**Application:**
- Local Dev: http://localhost:5173/auth
- Auth Page: http://localhost:8080/auth

---

## ⚙️ Configuration Details

### Redirect URI (Required for both providers):
```
https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback
```

### Authorized JavaScript Origins (Google):
```
http://localhost:5173
http://localhost:3000
http://localhost:8080
```

### Site URL (Supabase):
```
http://localhost:5173
```

---

## ✅ Verification

After configuration, verify:

1. **Supabase Providers:**
   - Go to: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers
   - Both Google and GitHub should show as **Enabled**

2. **Test Login:**
   - Start dev server: `npm run dev`
   - Visit: http://localhost:5173/auth
   - Click "Continue with Google" → Should redirect to Google
   - Click "Continue with GitHub" → Should redirect to GitHub

3. **User Creation:**
   - After OAuth login, check: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/users
   - User should appear with provider badge

---

## 📚 Documentation Files

1. **`OAuth/files/OAUTH_QUICK_START.md`** - Quick reference guide
2. **`OAuth/files/OAUTH_CONFIGURATION_GUIDE.md`** - Detailed configuration guide
3. **`scripts/setup-oauth-providers.md`** - Step-by-step setup instructions
4. **`OAuth/files/test-oauth.sh`** - Test script

---

## 🚀 Next Steps

1. **Read the detailed guide:** `scripts/setup-oauth-providers.md`
2. **Follow step-by-step instructions** for Google and GitHub
3. **Test OAuth login** after configuration
4. **Verify user creation** in Supabase

---

**Ready to configure!** Follow `scripts/setup-oauth-providers.md` for detailed instructions.

