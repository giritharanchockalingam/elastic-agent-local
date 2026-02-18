# Enable OAuth After Production Data Seeding

**Workflow:** Seed production data FIRST, then enable OAuth providers

---

## ✅ Step 1: Seed Production Data

### Option A: Using Supabase SQL Editor (Recommended)

1. **Go to Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard
   - Select your project

2. **Open SQL Editor:**
   - Navigate to: **SQL Editor** → **New Query**

3. **Run Seeding Script:**
   - Copy contents of `scripts/seed-production-data.sql`
   - Paste into SQL Editor
   - Click **Run** (or press Cmd/Ctrl + Enter)

4. **Verify Data:**
   - Check the verification queries at the end of the script
   - Should show counts for all seeded tables

### Option B: Using Supabase CLI

```bash
# If you have Supabase CLI installed
supabase db reset --db-url "your-connection-string"
psql "your-connection-string" < scripts/seed-production-data.sql
```

---

## ✅ Step 2: Enable Google OAuth

### 2.1 Create Google Cloud Project (if not done)

1. **Go to Google Cloud Console:**
   - Visit: https://console.cloud.google.com
   - Create or select a project

2. **Enable Google+ API:**
   - Navigate to: **APIs & Services** → **Library**
   - Search for "Google+ API"
   - Click **Enable**

3. **Configure OAuth Consent Screen:**
   - Go to: **APIs & Services** → **OAuth consent screen**
   - Select **External** (or Internal for G Suite)
   - Fill in required information:
     - App name: "Aurora Hotel Management System"
     - User support email: your email
     - Developer contact: your email
   - Add scopes: `email`, `profile`, `openid`
   - Add test users (for development):
     - Click **Add Users**
     - Add email addresses that will test OAuth

4. **Create OAuth 2.0 Client ID:**
   - Go to: **APIs & Services** → **Credentials**
   - Click **Create Credentials** → **OAuth 2.0 Client ID**
   - Application type: **Web application**
   - Name: "Aurora HMS Web Client"
   - Authorized redirect URIs:
     ```
     https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback
     ```
   - Copy **Client ID** and **Client Secret**

### 2.2 Add Google OAuth to Supabase

1. **Go to Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard
   - Select your project

2. **Navigate to Auth Providers:**
   - Go to: **Authentication** → **Providers**
   - Or: **Settings** → **Auth** → **Providers**

3. **Enable Google Provider:**
   - Find **Google** in the list
   - Toggle to **ON** (Enable)
   - Enter:
     - **Client ID:** (from Google Cloud Console)
     - **Client Secret:** (from Google Cloud Console)
   - Click **Save**

---

## ✅ Step 3: Enable GitHub OAuth

### 3.1 Create GitHub OAuth App

1. **Go to GitHub Settings:**
   - Visit: https://github.com/settings/developers
   - Or: Your Profile → **Settings** → **Developer settings** → **OAuth Apps**

2. **Create New OAuth App:**
   - Click **New OAuth App**
   - Fill in:
     - **Application name:** "Aurora Hotel Management System"
     - **Homepage URL:** `https://YOUR_PROJECT_ID.supabase.co`
     - **Authorization callback URL:**
       ```
       https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback
       ```
   - Click **Register application**

3. **Get Credentials:**
   - Copy **Client ID**
   - Click **Generate a new client secret**
   - Copy **Client Secret** (save it - won't be shown again!)

### 3.2 Add GitHub OAuth to Supabase

1. **Go to Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard
   - Select your project

2. **Navigate to Auth Providers:**
   - Go to: **Authentication** → **Providers**
   - Or: **Settings** → **Auth** → **Providers**

3. **Enable GitHub Provider:**
   - Find **GitHub** in the list
   - Toggle to **ON** (Enable)
   - Enter:
     - **Client ID:** (from GitHub)
     - **Client Secret:** (from GitHub)
   - Click **Save**

---

## ✅ Step 4: Configure Site URL and Redirect URLs

1. **Go to Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard
   - Select your project

2. **Navigate to URL Configuration:**
   - Go to: **Authentication** → **URL Configuration**
   - Or: **Settings** → **Auth** → **URL Configuration**

3. **Set Site URL:**
   - **Site URL:** `http://localhost:8080` (for local development)
   - Or: `https://your-production-domain.com` (for production)

4. **Add Redirect URLs:**
   - Add: `http://localhost:8080/**`
   - Add: `https://your-production-domain.com/**`
   - Click **Save**

---

## ✅ Step 5: Verify OAuth Setup

### Test Google OAuth:

1. **Start your application:**
   ```bash
   npm run dev
   ```

2. **Navigate to login page:**
   - Visit: `http://localhost:8080/auth`

3. **Click "Continue with Google":**
   - Should redirect to Google login
   - After login, should redirect back to app
   - User should be created in Supabase

### Test GitHub OAuth:

1. **On login page:**
   - Click "Continue with GitHub"
   - Should redirect to GitHub login
   - After authorization, should redirect back to app
   - User should be created in Supabase

---

## 🔍 Verification Checklist

- [ ] Production data seeded (tenants, properties, rooms, etc.)
- [ ] Google OAuth app created in Google Cloud Console
- [ ] Google OAuth enabled in Supabase
- [ ] GitHub OAuth app created
- [ ] GitHub OAuth enabled in Supabase
- [ ] Site URL configured in Supabase
- [ ] Redirect URLs configured in Supabase
- [ ] Google OAuth login tested successfully
- [ ] GitHub OAuth login tested successfully
- [ ] New OAuth users appear in Supabase Auth → Users

---

## 🚨 Troubleshooting

### Issue: "Provider is not enabled"

**Solution:**
- Verify provider is toggled ON in Supabase
- Check Client ID and Secret are correct
- Wait a few minutes after enabling

### Issue: "Redirect URI mismatch"

**Solution:**
- Verify callback URL in OAuth provider matches:
  ```
  https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback
  ```
- Check Site URL and Redirect URLs in Supabase

### Issue: "OAuth users not created"

**Solution:**
- Check Supabase Auth logs
- Verify OAuth consent screen is published (or test users added)
- Check Site URL configuration

---

## 📝 Notes

- **Order matters:** Seed data FIRST, then enable OAuth
- **Test users:** Add test users to Google OAuth consent screen for development
- **Production:** Publish OAuth consent screen for production use
- **Security:** Keep Client Secrets secure, never commit to git

---

**After completing these steps, OAuth will be enabled and users can sign in with Google or GitHub!** 🚀

