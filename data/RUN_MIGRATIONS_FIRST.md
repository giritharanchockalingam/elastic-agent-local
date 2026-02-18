# ⚠️ IMPORTANT: Run Migrations First!

**Error:** `Table "public.tenants" does not exist. Please run database migrations first.`

**Solution:** You must run database migrations BEFORE seeding data.

---

## ✅ Quick Fix: Run Migrations in Supabase Dashboard

### Step 1: Check Migration Status

1. **Go to Supabase Dashboard:**
   ```
   https://supabase.com/dashboard/project/YOUR_SUPABASE_PROJECT_ID
   ```

2. **Check Migrations:**
   - Go to: **Database** → **Migrations**
   - Or: **SQL Editor** → **Migrations**
   - See which migrations have been applied

### Step 2: Run Missing Migrations

**Option A: If Migrations Show as "Not Applied"**

1. Go to: **Database** → **Migrations**
2. Click on each migration that shows "Not Applied"
3. Click **Apply** or **Run**

**Option B: Run Migrations Manually via SQL Editor**

1. Go to: **SQL Editor** → **New Query**
2. Run migration files **in order** (by timestamp):

   **Critical migrations (run these first):**
   
   ```sql
   -- Migration 1: Core tables (guests, rooms, reservations)
   -- File: 20251112020704_7a1b120d-137f-4027-919f-0aaba912cfec.sql
   
   -- Migration 2: Tenants and Properties (REQUIRED for seeding!)
   -- File: 20251112032446_f22d40b7-cc9d-46e6-996a-92357a254322.sql
   ```

3. **Copy each migration file** from `supabase/migrations/`
4. **Paste into SQL Editor** and run
5. **Repeat for all migration files** in chronological order

---

## 🔍 Verify Tables Exist

After running migrations, verify tables exist:

```sql
-- Run this in SQL Editor
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN (
    'tenants', 'properties', 'room_types', 'rooms', 
    'guests', 'reservations', 'departments', 
    'menu_items', 'spa_services', 'payments', 
    'invoices', 'housekeeping_tasks', 'food_orders', 
    'maintenance_requests'
  )
ORDER BY table_name;
```

**Expected:** Should return all 14 table names

---

## 📋 Migration Files (in order)

Your project has **60+ migration files**. The most critical ones for seeding are:

1. ✅ `20251112020704_...` - Core tables (guests, rooms, reservations)
2. ✅ `20251112032446_...` - **Tenants and Properties** (REQUIRED!)
3. ✅ `20251112032554_...` - F&B and other features
4. ✅ ... (and 57+ more)

**All migrations should be run in chronological order** (by timestamp in filename).

---

## 🚀 Quick Solution

### If Migrations Are Already Applied in Supabase:

Sometimes Supabase applies migrations automatically. Check:

1. Go to: **Database** → **Migrations**
2. If migrations show as "Applied", but tables don't exist:
   - There may be an error in a migration
   - Check migration logs
   - Re-run failed migrations

### If Migrations Haven't Been Applied:

1. **Go to SQL Editor:**
   - https://supabase.com/dashboard/project/YOUR_SUPABASE_PROJECT_ID/sql/new

2. **Run the critical migration first:**
   - Open: `supabase/migrations/20251112032446_f22d40b7-cc9d-46e6-996a-92357a254322.sql`
   - Copy entire contents
   - Paste into SQL Editor
   - Click **Run**

3. **Then run other migrations in order**

4. **Finally, run seeding script:**
   - `scripts/seed-production-data.sql`

---

## 🔧 Alternative: Create Tables Manually

If migrations are too complex, you can create the essential tables manually:

```sql
-- Run this in SQL Editor to create essential tables for seeding

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create tenants table
CREATE TABLE IF NOT EXISTS public.tenants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  subscription_plan TEXT DEFAULT 'free',
  subscription_status TEXT DEFAULT 'active',
  max_properties INTEGER DEFAULT 1,
  max_users INTEGER DEFAULT 10,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create properties table
CREATE TABLE IF NOT EXISTS public.properties (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  address TEXT,
  city TEXT,
  state TEXT,
  country TEXT,
  postal_code TEXT,
  phone TEXT,
  email TEXT,
  property_type TEXT DEFAULT 'hotel',
  star_rating INTEGER,
  total_rooms INTEGER DEFAULT 0,
  check_in_time TIME DEFAULT '14:00',
  check_out_time TIME DEFAULT '11:00',
  currency TEXT DEFAULT 'USD',
  timezone TEXT DEFAULT 'UTC',
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(tenant_id, code)
);

-- (Add other essential tables as needed)
```

**Note:** This is a minimal setup. For full functionality, run all migrations.

---

## ✅ Checklist

- [ ] Checked migration status in Supabase Dashboard
- [ ] Ran critical migration: `20251112032446_...` (tenants, properties)
- [ ] Verified tables exist (ran verification query)
- [ ] All required tables present
- [ ] Ready to run seeding script

---

## 📝 Next Steps

Once migrations are applied and tables exist:

1. **Run seeding script:**
   - Go to: **SQL Editor** → **New Query**
   - Run: `scripts/seed-production-data.sql`

2. **Verify seeded data:**
   - Check the verification queries at the end of seeding script

3. **Enable OAuth:**
   - Follow: `scripts/enable-oauth-after-seeding.md`

---

**Run migrations first, then seed data!** 🚀


