# Production Seeding and OAuth Enablement Guide

**Workflow:** Seed production data FIRST, then enable OAuth providers

---

## 🎯 Quick Start

### Option 1: Interactive Script (Recommended)

```bash
./scripts/seed-and-enable-oauth.sh
```

This script will guide you through:
1. Seeding production data
2. Enabling Google OAuth
3. Enabling GitHub OAuth
4. Configuring URLs

### Option 2: Manual Steps

Follow the detailed guide: `scripts/enable-oauth-after-seeding.md`

---

## 📋 What Gets Seeded

### Master Data:
- ✅ **Tenant:** Aurora Hotels Group
- ✅ **Property:** Aurora Grand Hotel (5-star, 150 rooms)
- ✅ **Room Types:** Standard, Deluxe, Suite, Presidential Suite
- ✅ **Rooms:** 50 rooms across different types and floors
- ✅ **Departments:** Front Desk, Housekeeping, F&B, Maintenance, etc.
- ✅ **Menu Items:** Sample F&B menu items
- ✅ **Spa Services:** Sample spa service offerings

### Transactional Data:
- ✅ **Guests:** 5 sample guest records
- ✅ **Reservations:** 15 sample reservations (various statuses)
- ✅ **Payments:** 12 payment records linked to reservations
- ✅ **Invoices:** 10 invoice records
- ✅ **Housekeeping Tasks:** 20 tasks across rooms
- ✅ **Food Orders:** 8 sample food orders
- ✅ **Maintenance Requests:** 10 maintenance requests

---

## 🚀 Step-by-Step Process

### Step 1: Seed Production Data

1. **Open Supabase SQL Editor:**
   - Go to: https://supabase.com/dashboard
   - Select your project
   - Navigate to: **SQL Editor** → **New Query**

2. **Run Seeding Script:**
   ```sql
   -- Copy and paste contents of:
   scripts/seed-production-data.sql
   ```

3. **Verify:**
   - Check the verification queries at the end
   - Should show counts for all tables

### Step 2: Enable Google OAuth

1. **Create Google OAuth App:**
   - Go to: https://console.cloud.google.com
   - Enable Google+ API
   - Configure OAuth Consent Screen
   - Create OAuth 2.0 Client ID
   - Get Client ID and Secret

2. **Enable in Supabase:**
   - Go to: **Authentication** → **Providers**
   - Enable **Google**
   - Enter Client ID and Secret
   - Save

### Step 3: Enable GitHub OAuth

1. **Create GitHub OAuth App:**
   - Go to: https://github.com/settings/developers
   - Create New OAuth App
   - Get Client ID and Secret

2. **Enable in Supabase:**
   - Go to: **Authentication** → **Providers**
   - Enable **GitHub**
   - Enter Client ID and Secret
   - Save

### Step 4: Configure URLs

1. **Set Site URL:**
   - Go to: **Authentication** → **URL Configuration**
   - Set Site URL: `http://localhost:8080` (or production URL)

2. **Add Redirect URLs:**
   - Add: `http://localhost:8080/**`
   - Add: `https://your-production-domain.com/**`

---

## ✅ Verification

### Check Seeded Data:

```sql
-- Run in Supabase SQL Editor
SELECT 'Tenants' as table_name, COUNT(*) as count FROM public.tenants
UNION ALL
SELECT 'Properties', COUNT(*) FROM public.properties
UNION ALL
SELECT 'Rooms', COUNT(*) FROM public.rooms
UNION ALL
SELECT 'Reservations', COUNT(*) FROM public.reservations;
```

### Test OAuth:

1. **Start application:**
   ```bash
   npm run dev
   ```

2. **Test Google OAuth:**
   - Visit: `http://localhost:8080/auth`
   - Click "Continue with Google"
   - Complete login
   - Verify user created in Supabase

3. **Test GitHub OAuth:**
   - Click "Continue with GitHub"
   - Complete authorization
   - Verify user created in Supabase

---

## 📁 Files

- **`scripts/seed-production-data.sql`** - Complete seeding script
- **`scripts/enable-oauth-after-seeding.md`** - Detailed OAuth setup guide
- **`scripts/seed-and-enable-oauth.sh`** - Interactive workflow script

---

## 🔍 Troubleshooting

### Seeding Issues:

**Problem:** Foreign key constraints fail
- **Solution:** Ensure all migrations are run first
- Check that tables exist before seeding

**Problem:** Duplicate key errors
- **Solution:** Script uses `ON CONFLICT DO NOTHING` - safe to re-run

### OAuth Issues:

**Problem:** "Provider is not enabled"
- **Solution:** Verify provider is toggled ON in Supabase
- Check Client ID and Secret are correct

**Problem:** "Redirect URI mismatch"
- **Solution:** Verify callback URL matches:
  ```
  https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback
  ```

---

## 📝 Important Notes

1. **Order Matters:** Always seed data BEFORE enabling OAuth
2. **Test Users:** Add test users to Google OAuth consent screen for development
3. **Production:** Publish OAuth consent screen for production use
4. **Security:** Never commit OAuth secrets to git
5. **Re-running:** Seeding script is idempotent - safe to run multiple times

---

## 🎯 Next Steps

After completing seeding and OAuth setup:

1. **Test the application:**
   ```bash
   npm run dev
   ```

2. **Verify OAuth login works:**
   - Test Google login
   - Test GitHub login
   - Check users in Supabase Auth

3. **Verify seeded data:**
   - Check properties, rooms, reservations
   - Verify data relationships

---

**Ready to seed and enable OAuth!** 🚀

Run: `./scripts/seed-and-enable-oauth.sh` to get started.

