# Google OAuth - Publishing Consent Screen Guide

**Message:** "For Google Oauth - Publish or update your Lovable project for it to appear here."

This message appears when your OAuth consent screen is in **Testing** mode and needs to be configured or published.

---

## 🎯 Understanding the Message

This message typically appears in:
- Google Cloud Console → OAuth consent screen
- When your app is in "Testing" mode (External app type)

**What it means:**
- Your OAuth consent screen is configured but not published
- For testing, you don't need to publish (just add test users)
- For production, you need to publish (requires verification)

---

## ✅ Solution: For Testing/Development

**You don't need to publish for testing!** Just ensure:

### Step 1: Verify OAuth Consent Screen is Configured

1. **Go to Google Cloud Console:**
   - Visit: https://console.cloud.google.com/
   - Navigate to: **APIs & Services → OAuth consent screen**

2. **Check Status:**
   - Should show: "Testing" or "In production"
   - If it shows "Not configured", complete the setup first

### Step 2: Add Test Users (Required for Testing Mode)

1. **In OAuth Consent Screen:**
   - Scroll to **"Test users"** section
   - Click **"ADD USERS"**
   - Add your Gmail address (and any other test emails)
   - Click **"ADD"**
   - Click **"SAVE"**

2. **Important:**
   - Test users can sign in without publishing
   - Only test users can use the app in Testing mode
   - No publishing required for testing

### Step 3: Verify Configuration

Your OAuth consent screen should show:
- ✅ App information filled
- ✅ Scopes configured (email, profile)
- ✅ Test users added
- ⚠️ Status: "Testing" (this is OK for development)

---

## 🚀 Solution: For Production

If you need to publish for production use:

### Step 1: Complete All Required Fields

1. **App Information:**
   - App name: `Hotel Management System`
   - User support email: Your email
   - App logo: (Optional but recommended)
   - App domain: Your production domain
   - Developer contact: Your email

2. **Scopes:**
   - `.../auth/userinfo.email`
   - `.../auth/userinfo.profile`

3. **Test Users:**
   - Can be removed after publishing (optional)

### Step 2: Publish the App

1. **In OAuth Consent Screen:**
   - Scroll to bottom
   - Click **"PUBLISH APP"** button
   - Confirm the action

2. **Verification Process:**
   - Google may require verification for sensitive scopes
   - For basic scopes (email, profile), publishing is usually instant
   - You may see "Verification required" - this is normal

3. **After Publishing:**
   - Status changes to "In production"
   - Anyone can sign in (not just test users)
   - App appears in Google's OAuth consent screen

---

## 🔍 Troubleshooting

### Issue: "Publish or update your Lovable project"

**This message appears when:**
- OAuth consent screen is not fully configured
- App is in Testing mode but no test users added
- Some required fields are missing

**Solution:**
1. Complete all required fields in OAuth consent screen
2. Add at least one test user
3. Save all changes
4. The message should disappear

### Issue: Can't publish - Verification required

**For sensitive scopes:**
- Google requires verification for certain scopes
- Basic scopes (email, profile) usually don't need verification
- If verification is required, follow Google's verification process

**For testing:**
- You don't need to publish
- Just add test users
- Keep app in Testing mode

### Issue: Test users can't sign in

**Check:**
1. Test user email is added correctly
2. User is signing in with the exact email added
3. OAuth consent screen is saved
4. Client ID and Secret are correct in Supabase

---

## 📋 Quick Checklist

**For Testing (Recommended for Development):**
- [ ] OAuth consent screen configured
- [ ] App information filled
- [ ] Scopes added (email, profile)
- [ ] Test users added (your Gmail)
- [ ] Status: "Testing" (OK for dev)
- [ ] Client ID and Secret created
- [ ] Credentials added to Supabase
- [ ] **No publishing needed!**

**For Production:**
- [ ] All testing checklist items complete
- [ ] App domain added
- [ ] App logo uploaded (recommended)
- [ ] Privacy policy URL (if required)
- [ ] Terms of service URL (if required)
- [ ] Click "PUBLISH APP"
- [ ] Complete verification if required

---

## 🔗 Important Links

**Google Cloud Console:**
- OAuth Consent Screen: https://console.cloud.google.com/apis/credentials/consent
- Credentials: https://console.cloud.google.com/apis/credentials

**Supabase:**
- Auth Providers: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/auth/providers

---

## 💡 Recommendation

**For Development/Testing:**
- ✅ Keep app in **Testing** mode
- ✅ Add test users
- ✅ **Don't publish** (not needed)
- ✅ Works perfectly for development

**For Production:**
- ✅ Complete all fields
- ✅ Publish the app
- ✅ Complete verification if required
- ✅ Anyone can sign in

---

## ✅ Next Steps

1. **If testing:** Add test users and use without publishing
2. **If production:** Complete all fields and publish
3. **Verify:** Test OAuth login works
4. **Check:** Users can sign in successfully

---

**The message will disappear once you:**
- Complete OAuth consent screen configuration
- Add test users (for testing mode)
- Or publish the app (for production)

**For development, you don't need to publish - just add test users!**

