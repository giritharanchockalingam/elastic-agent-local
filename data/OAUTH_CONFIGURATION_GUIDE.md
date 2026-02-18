# 🔐 OAuth Configuration Guide - Google & GitHub

## Project Information
- **Supabase Project ID:** qnwsnrfcnonaxvnithfv
- **Supabase URL:** https://qnwsnrfcnonaxvnithfv.supabase.co
- **Dashboard:** https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv

---

## 📋 **STEP 1: Configure Google OAuth**

### **1.1 Create Google OAuth Credentials**

1. **Go to Google Cloud Console:**
   - Visit: https://console.cloud.google.com/
   - Sign in with your Gmail account

2. **Create/Select Project:**
   - Click "Select a Project" → "NEW PROJECT"
   - Project Name: `HMS OAuth` or use existing project
   - Click "CREATE"

3. **Enable Google+ API:**
   - Go to: APIs & Services → Library
   - Search for "Google+ API"
   - Click "ENABLE"

4. **Configure OAuth Consent Screen:**
   - Go to: APIs & Services → OAuth consent screen
   - User Type: **External** (for testing) or **Internal** (for organization)
   - Click "CREATE"
   
   **Fill in required fields:**
   - App name: `Hotel Management System`
   - User support email: `your-email@gmail.com`
   - Developer contact: `your-email@gmail.com`
   - Click "SAVE AND CONTINUE"

   **Scopes (Step 2):**
   - Click "ADD OR REMOVE SCOPES"
   - Select: `.../auth/userinfo.email`
   - Select: `.../auth/userinfo.profile`
   - Click "UPDATE" → "SAVE AND CONTINUE"

   **Test users (if External):**
   - Add your Gmail address as test user
   - Click "SAVE AND CONTINUE"

5. **Create OAuth 2.0 Credentials:**
   - Go to: APIs & Services → Credentials
   - Click "+ CREATE CREDENTIALS" → "OAuth 2.0 Client ID"
   - Application type: **Web application**
   - Name: `HMS Web Client`

   **Authorized JavaScript origins:**
   ```
   http://localhost:5173
   http://localhost:3000
   https://your-production-domain.com
   ```

   **Authorized redirect URIs:**
   ```
   https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback
   http://localhost:5173/auth/callback
   ```

   - Click "CREATE"
   - **Copy:** Client ID and Client Secret

### **1.2 Configure in Supabase**

1. **Go to Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers

2. **Enable Google Provider:**
   - Find "Google" in the list
   - Toggle "Enable" to ON

3. **Add Credentials:**
   - **Client ID:** Paste from Google Console
   - **Client Secret:** Paste from Google Console
   - Click "SAVE"

4. **Configure Site URL:**
   - Go to: Authentication → URL Configuration
   - **Site URL:** `http://localhost:5173` (development) or your production URL
   - **Redirect URLs:** Add:
     ```
     http://localhost:5173/**
     https://your-production-domain.com/**
     ```
   - Click "SAVE"

---

## 🐙 **STEP 2: Configure GitHub OAuth**

### **2.1 Create GitHub OAuth App**

1. **Go to GitHub Settings:**
   - Visit: https://github.com/settings/developers
   - Click "OAuth Apps" → "New OAuth App"

2. **Fill in Application Details:**
   - **Application name:** `HMS - Hotel Management System`
   - **Homepage URL:** `http://localhost:5173` (or production URL)
   - **Application description:** `OAuth authentication for HMS`
   - **Authorization callback URL:** 
     ```
     https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback
     ```
   - Click "Register application"

3. **Get Credentials:**
   - **Copy:** Client ID (shown immediately)
   - Click "Generate a new client secret"
   - **Copy:** Client Secret (shown once only - save it!)

### **2.2 Configure in Supabase**

1. **Go to Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers

2. **Enable GitHub Provider:**
   - Find "GitHub" in the list
   - Toggle "Enable" to ON

3. **Add Credentials:**
   - **Client ID:** Paste from GitHub
   - **Client Secret:** Paste from GitHub
   - Click "SAVE"

---

## ✅ **STEP 3: Test OAuth Configuration**

### **3.1 Test Google OAuth**

1. Start your development server:
   ```bash
   cd ~/Desktop/GitHub/hms-gcp-refactor
   npm run dev
   ```

2. Open browser: `http://localhost:5173`

3. Click "Continue with Google" button

4. **Expected Flow:**
   - Redirects to Google login
   - Shows consent screen
   - Redirects back to your app
   - User is logged in

5. **Check Success:**
   - Should redirect to `/admin`
   - User session should be active
   - Check browser DevTools → Application → Local Storage → `sb-qnwsnrfcnonaxvnithfv-auth-token`

### **3.2 Test GitHub OAuth**

1. On the same auth page, click "GitHub" button

2. **Expected Flow:**
   - Redirects to GitHub login
   - Shows authorization screen
   - Redirects back to your app
   - User is logged in

3. **Check Success:**
   - Should redirect to `/admin`
   - User session should be active

---

## 🔧 **STEP 4: Update Environment Variables**

Update your `.env` file to use the new Supabase project:

```env
VITE_SUPABASE_PROJECT_ID="qnwsnrfcnonaxvnithfv"
VITE_SUPABASE_URL="https://qnwsnrfcnonaxvnithfv.supabase.co"
VITE_SUPABASE_PUBLISHABLE_KEY="<your-new-anon-key>"
```

Get the anon key from:
https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/settings/api

---

## 🐛 **TROUBLESHOOTING**

### **Issue: "Invalid redirect_uri"**

**Solution:**
- Check that redirect URI in Google Console exactly matches:
  ```
  https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback
  ```
- No trailing slashes
- Check for typos in project ID

### **Issue: "OAuth callback URL mismatch" (GitHub)**

**Solution:**
- Go to GitHub OAuth App settings
- Ensure callback URL is:
  ```
  https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback
  ```
- Update and save

### **Issue: "Access denied" or "Error 400"**

**Solution:**
- Check that you've added your email as a test user (Google)
- Ensure OAuth consent screen is published (Google)
- Verify Client ID and Secret are correct in Supabase

### **Issue: User not redirected after login**

**Solution:**
- Check Site URL in Supabase matches your app URL
- Verify redirect URLs include your domain
- Check browser console for errors

### **Issue: CORS errors**

**Solution:**
- Add your domain to "Authorized JavaScript origins" (Google)
- Ensure Site URL in Supabase is correct
- Check that redirect URLs in Supabase include all your domains

---

## 📊 **VERIFICATION CHECKLIST**

### **Google OAuth:**
- [ ] Google Cloud Console project created
- [ ] OAuth consent screen configured
- [ ] OAuth 2.0 credentials created
- [ ] Client ID and Secret copied
- [ ] Supabase Google provider enabled
- [ ] Credentials added to Supabase
- [ ] Redirect URIs match exactly
- [ ] Test user added (if External app)
- [ ] Successfully tested login

### **GitHub OAuth:**
- [ ] GitHub OAuth App created
- [ ] Client ID copied
- [ ] Client Secret generated and copied
- [ ] Supabase GitHub provider enabled
- [ ] Credentials added to Supabase
- [ ] Callback URL matches exactly
- [ ] Successfully tested login

### **Supabase Configuration:**
- [ ] Site URL configured
- [ ] Redirect URLs added
- [ ] Both providers show "Enabled" status
- [ ] Environment variables updated
- [ ] Application rebuilt and tested

---

## 🔐 **SECURITY BEST PRACTICES**

1. **Keep Secrets Safe:**
   - Never commit `.env` to git
   - Store secrets in environment variables
   - Use different credentials for production

2. **Restrict Domains:**
   - Limit authorized origins to your domains
   - Remove localhost from production config
   - Use environment-specific credentials

3. **Monitor Usage:**
   - Check Supabase Auth logs regularly
   - Monitor OAuth provider dashboards
   - Set up alerts for suspicious activity

4. **User Data:**
   - Only request necessary scopes
   - Comply with OAuth provider terms
   - Handle user data responsibly

---

## 📝 **PRODUCTION DEPLOYMENT**

When deploying to production:

1. **Update Google Console:**
   - Add production domain to authorized origins
   - Add production redirect URI
   - Publish OAuth consent screen

2. **Update GitHub OAuth:**
   - Add production callback URL
   - Update homepage URL

3. **Update Supabase:**
   - Set Site URL to production domain
   - Add production redirect URLs
   - Consider enabling email confirmations

4. **Environment Variables:**
   - Use production Supabase credentials
   - Secure environment variable storage
   - Never expose secrets in frontend code

---

## 🎉 **NEXT STEPS**

After configuration:

1. **Test Both Providers:**
   - Google login
   - GitHub login
   - Sign out and sign in again

2. **Check User Creation:**
   - Go to Supabase → Authentication → Users
   - Verify users are created with OAuth
   - Check profiles table is populated

3. **Test User Roles:**
   - Verify RBAC works with OAuth users
   - Assign roles to OAuth users
   - Test permissions

4. **Production Readiness:**
   - Test on staging environment
   - Monitor logs for errors
   - Prepare rollback plan

---

## 📞 **SUPPORT RESOURCES**

- **Google OAuth:** https://developers.google.com/identity/protocols/oauth2
- **GitHub OAuth:** https://docs.github.com/en/developers/apps/building-oauth-apps
- **Supabase Auth:** https://supabase.com/docs/guides/auth
- **HMS Documentation:** See project README.md

---

**Document Version:** 1.0  
**Last Updated:** December 17, 2025  
**Status:** Ready for Configuration
