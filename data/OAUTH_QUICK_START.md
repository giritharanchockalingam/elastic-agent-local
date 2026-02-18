# ⚡ OAuth Quick Start Checklist

**Time Required:** 15-20 minutes  
**Difficulty:** Medium

---

## 🎯 **Quick Setup (TL;DR)**

1. ✅ Enable providers in Supabase
2. ✅ Get credentials from Google/GitHub
3. ✅ Add credentials to Supabase
4. ✅ Test login
5. ✅ Done!

---

## 📝 **GOOGLE OAUTH (5 Steps)**

### ✅ Step 1: Google Cloud Console Setup (5 min)

Visit: https://console.cloud.google.com/

```
1. Create project: "HMS OAuth"
2. Enable "Google+ API"
3. Configure OAuth consent screen:
   - App name: Hotel Management System
   - Add your email
   - Scopes: email, profile
4. Create OAuth 2.0 Client ID:
   - Type: Web application
   - Redirect URI: https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback
5. Copy Client ID and Secret
```

### ✅ Step 2: Supabase Configuration (2 min)

Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers

```
1. Find "Google"
2. Toggle ON
3. Paste Client ID
4. Paste Client Secret
5. Click SAVE
```

### ✅ Step 3: Test (1 min)

```bash
npm run dev
# Open http://localhost:5173
# Click "Continue with Google"
# Should work! ✅
```

---

## 🐙 **GITHUB OAUTH (4 Steps)**

### ✅ Step 1: GitHub OAuth App (3 min)

Visit: https://github.com/settings/developers

```
1. Click "OAuth Apps" → "New OAuth App"
2. Fill in:
   - Name: HMS - Hotel Management System
   - Homepage: http://localhost:5173
   - Callback: https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback
3. Register application
4. Generate client secret
5. Copy Client ID and Secret
```

### ✅ Step 2: Supabase Configuration (2 min)

Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers

```
1. Find "GitHub"
2. Toggle ON
3. Paste Client ID
4. Paste Client Secret
5. Click SAVE
```

### ✅ Step 3: Test (1 min)

```bash
# Already running from Google test
# Click "Continue with GitHub"
# Should work! ✅
```

---

## 🔍 **VERIFICATION STEPS**

### ✅ Check Supabase Providers

```bash
# Visit dashboard
https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers

# Should see:
✅ Google: Enabled
✅ GitHub: Enabled
```

### ✅ Check User Creation

```bash
# After login, visit:
https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/users

# Should see your user with OAuth provider badge
```

### ✅ Test Both Methods

```
1. Sign in with Google → Works ✅
2. Sign out
3. Sign in with GitHub → Works ✅
4. Sign out
5. Sign in with email/password → Works ✅
```

---

## ❌ **COMMON ISSUES & FIXES**

### Issue: "Invalid redirect_uri"

**Fix:**
```
Redirect URI must be EXACTLY:
https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback

No extra slashes, no typos in project ID
```

### Issue: "Access denied"

**Fix:**
```
Google: Add your email as test user in OAuth consent screen
GitHub: Make sure OAuth app is active
```

### Issue: "CORS error"

**Fix:**
```
Add to Google Console → Authorized JavaScript origins:
http://localhost:5173
https://your-domain.com
```

### Issue: User not redirected

**Fix:**
```
Supabase → Settings → Authentication → Site URL
Set to: http://localhost:5173
```

---

## 🎉 **SUCCESS INDICATORS**

You know it's working when:

✅ Click "Continue with Google" → Redirects to Google  
✅ Login with Google → Redirects back to app  
✅ User appears in Supabase users table  
✅ User is logged in (redirected to /admin)  
✅ Same for GitHub  

---

## 📊 **VERIFICATION CHECKLIST**

Copy this to verify your setup:

```
□ Google Cloud Console: Project created
□ Google: OAuth consent screen configured
□ Google: OAuth credentials created
□ Google: Client ID and Secret copied
□ Supabase: Google provider enabled
□ Supabase: Google credentials saved
□ Test: Google login works

□ GitHub: OAuth App created
□ GitHub: Client ID and Secret copied
□ Supabase: GitHub provider enabled
□ Supabase: GitHub credentials saved
□ Test: GitHub login works

□ User appears in Supabase users table
□ User can access protected routes
□ Sign out works
□ Can sign back in
```

---

## 🚀 **PRODUCTION DEPLOYMENT**

Before going live:

1. **Update OAuth Providers:**
   ```
   Google Console:
   - Add production domain to authorized origins
   - Add production redirect URI
   
   GitHub:
   - Add production callback URL
   ```

2. **Update Supabase:**
   ```
   - Set Site URL to production domain
   - Add production redirect URLs
   ```

3. **Publish OAuth Consent:**
   ```
   Google: Publish consent screen (or keep Internal)
   ```

4. **Test in Production:**
   ```
   - Test Google login on production
   - Test GitHub login on production
   - Monitor for errors
   ```

---

## 🔗 **QUICK LINKS**

**Supabase:**
- Dashboard: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv
- Auth Providers: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers
- Users: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/users

**OAuth Providers:**
- Google Console: https://console.cloud.google.com/
- GitHub OAuth: https://github.com/settings/developers

**Documentation:**
- See: OAUTH_CONFIGURATION_GUIDE.md (detailed)

---

## ⏱️ **TIME BREAKDOWN**

- Google setup: 7 minutes
- GitHub setup: 6 minutes
- Testing: 2 minutes
- **Total: ~15 minutes** ⚡

---

## 📞 **NEED HELP?**

1. Review detailed guide: `OAUTH_CONFIGURATION_GUIDE.md`
2. Run test script: `./test-oauth.sh`
3. Check Supabase logs for errors
4. Test in incognito/private mode

---

**Status:** Ready to Configure  
**Last Updated:** December 17, 2025  
**Next Action:** Start with Google OAuth ↗️
