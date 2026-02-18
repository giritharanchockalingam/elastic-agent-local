# Google OAuth - Testing Mode Setup (No Publishing Required)

**Quick Answer:** You don't need to publish your OAuth consent screen for testing! Just add test users.

---

## 🎯 The Message Explained

**"Publish or update your Lovable project for it to appear here"**

This message appears when:
- Your OAuth consent screen is in **Testing** mode
- No test users have been added yet
- The consent screen needs to be completed

**Good News:** For development/testing, you don't need to publish!

---

## ✅ Quick Fix (5 minutes)

### Step 1: Go to OAuth Consent Screen

1. Visit: https://console.cloud.google.com/apis/credentials/consent
2. Select your project
3. You should see the OAuth consent screen configuration

### Step 2: Complete Required Fields

**App Information:**
- App name: `Hotel Management System`
- User support email: Your email
- Developer contact: Your email
- Click "SAVE AND CONTINUE"

**Scopes:**
- Click "ADD OR REMOVE SCOPES"
- Select: `.../auth/userinfo.email`
- Select: `.../auth/userinfo.profile`
- Click "UPDATE" → "SAVE AND CONTINUE"

### Step 3: Add Test Users (IMPORTANT!)

1. **In "Test users" section:**
   - Click "ADD USERS"
   - Enter your Gmail address
   - Click "ADD"
   - Add any other test emails if needed

2. **Click "SAVE AND CONTINUE"**

3. **Review:**
   - Review the summary
   - Click "BACK TO DASHBOARD"

### Step 4: Verify

- Status should show: **"Testing"** ✅
- Test users should be listed ✅
- Message should disappear ✅

---

## 🔍 What This Means

**Testing Mode:**
- ✅ Works perfectly for development
- ✅ Only test users can sign in
- ✅ No publishing required
- ✅ No verification needed
- ✅ Can test OAuth immediately

**Production Mode:**
- Requires publishing
- Requires verification (may take time)
- Anyone can sign in
- Only needed when going live

---

## ✅ Verification Checklist

After completing the steps above:

- [ ] OAuth consent screen shows "Testing" status
- [ ] At least one test user added
- [ ] Scopes configured (email, profile)
- [ ] Client ID and Secret created
- [ ] Credentials added to Supabase
- [ ] Message should be gone

---

## 🚀 Test OAuth Login

1. **Start dev server:**
   ```bash
   npm run dev
   ```

2. **Visit:** http://localhost:5173/auth

3. **Click:** "Continue with Google"

4. **Sign in:** With your test user email

5. **Should work!** ✅

---

## 📝 Notes

- **Testing mode is perfect for development**
- **No publishing needed for testing**
- **Add test users = OAuth works**
- **Publish only when going to production**

---

**The message will disappear once you add test users!**

