# GitHub OAuth Error Fix

**Error:** `{"code":400,"error_code":"validation_failed","msg":"Unsupported provider: provider is not enabled"}`

**Cause:** GitHub OAuth provider is not enabled in Supabase.

---

## ✅ Quick Fix (2 minutes)

### Step 1: Enable GitHub Provider in Supabase

1. **Go to Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers
   - Or: Dashboard → Authentication → Providers

2. **Find GitHub Provider:**
   - Scroll to find "GitHub" in the provider list
   - You should see a toggle switch

3. **Enable GitHub:**
   - Toggle the switch to **ON** (Enable)
   - The switch should turn green/active

4. **Add Credentials (if not already added):**
   - **Client ID (for OAuth):** Your GitHub OAuth App Client ID
   - **Client Secret (for OAuth):** Your GitHub OAuth App Client Secret
   - Click **"SAVE"**

5. **Verify:**
   - Status should show "Enabled" ✅
   - Toggle should be ON ✅

---

## 🔍 If You Don't Have GitHub OAuth Credentials

If you haven't created a GitHub OAuth App yet:

### Step 1: Create GitHub OAuth App

1. **Go to GitHub:**
   - Visit: https://github.com/settings/developers
   - Sign in to GitHub

2. **Create OAuth App:**
   - Click **"OAuth Apps"** in left sidebar
   - Click **"New OAuth App"** button

3. **Fill in Details:**
   - **Application name:** `HMS - Hotel Management System`
   - **Homepage URL:** `http://localhost:5173`
   - **Authorization callback URL:** 
     ```
     https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback
     ```
   - **Application description:** (Optional) `OAuth for Hotel Management System`

4. **Register:**
   - Click **"Register application"**
   - You'll be redirected to the app settings page

5. **Get Credentials:**
   - **Client ID:** Shown immediately (copy it)
   - **Client Secret:** Click **"Generate a new client secret"**
   - **⚠️ Copy the secret immediately** (it's only shown once!)

### Step 2: Add to Supabase

1. **Go to Supabase:**
   - Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers

2. **Enable GitHub:**
   - Find "GitHub" provider
   - Toggle to **ON**

3. **Add Credentials:**
   - Paste **Client ID**
   - Paste **Client Secret**
   - Click **"SAVE"**

---

## ✅ Verification

After enabling:

1. **Check Status:**
   - Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers
   - GitHub should show as **"Enabled"** ✅

2. **Test Login:**
   ```bash
   npm run dev
   ```
   - Visit: http://localhost:5173/auth
   - Click "Continue with GitHub"
   - Should redirect to GitHub (not show error)

---

## 🚨 Common Issues

### Issue: "Provider is not enabled"

**Solution:**
- Go to Supabase → Authentication → Providers
- Find GitHub
- Toggle to ON
- Save credentials if prompted

### Issue: "Invalid credentials"

**Solution:**
- Verify Client ID is correct
- Regenerate Client Secret if needed
- Make sure callback URL matches exactly:
  ```
  https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback
  ```

### Issue: "Redirect URI mismatch"

**Solution:**
- Check GitHub OAuth App settings
- Callback URL must be EXACTLY:
  ```
  https://qnwsnrfcnonaxvnithfv.supabase.co/auth/v1/callback
  ```
- No trailing slashes, no typos

---

## 📋 Quick Checklist

- [ ] GitHub OAuth App created
- [ ] Client ID copied
- [ ] Client Secret generated and copied
- [ ] Callback URL configured correctly
- [ ] Supabase: GitHub provider enabled
- [ ] Supabase: Client ID added
- [ ] Supabase: Client Secret added
- [ ] Supabase: Changes saved
- [ ] Test: GitHub login works

---

## 🔗 Quick Links

**Supabase:**
- Auth Providers: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers

**GitHub:**
- OAuth Apps: https://github.com/settings/developers

---

## ✅ After Fixing

The error should disappear and GitHub OAuth should work!

**Test it:**
1. Start dev server: `npm run dev`
2. Visit: http://localhost:5173/auth
3. Click "Continue with GitHub"
4. Should redirect to GitHub login ✅

---

**The fix is simple: Enable GitHub provider in Supabase Dashboard!**

