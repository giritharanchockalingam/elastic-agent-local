# Seeding Instructions - IMPORTANT

## ⚠️ Prerequisites

**You MUST run database migrations BEFORE running the seeding script!**

The seeding script requires these tables to exist:
- `public.tenants`
- `public.properties`
- `public.room_types`
- `public.rooms`
- `public.guests`
- `public.reservations`
- `public.departments`
- `public.menu_items`
- `public.spa_services`
- And other related tables

---

## ✅ Step 1: Run Database Migrations

### Option A: Supabase Dashboard (Recommended)

1. **Go to Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard
   - Select your project

2. **Navigate to Migrations:**
   - Go to: **SQL Editor** → **Migrations**
   - Or: **Database** → **Migrations**

3. **Run All Migrations:**
   - Supabase should automatically run migrations
   - Or manually run each migration file in order

### Option B: Supabase CLI

```bash
# If you have Supabase CLI installed
supabase db reset
# Or
supabase migration up
```

### Option C: Manual Migration

1. **Go to SQL Editor:**
   - Visit: https://supabase.com/dashboard
   - Select your project
   - Navigate to: **SQL Editor** → **New Query**

2. **Run Migration Files:**
   - Run all files in `supabase/migrations/` directory
   - Run them in chronological order (by timestamp)

---

## ✅ Step 2: Verify Tables Exist

Run this query in Supabase SQL Editor to verify tables exist:

```sql
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

## ✅ Step 3: Run Seeding Script

1. **Go to SQL Editor:**
   - Visit: https://supabase.com/dashboard
   - Select your project
   - Navigate to: **SQL Editor** → **New Query**

2. **Copy and Paste:**
   - Open: `scripts/seed-production-data.sql`
   - Copy entire contents
   - Paste into SQL Editor

3. **Run Script:**
   - Click **Run** (or press Cmd/Ctrl + Enter)
   - The script will:
     - ✅ Check if tables exist (will error if missing)
     - ✅ Insert master data
     - ✅ Insert transactional data
     - ✅ Show verification counts

---

## 🔍 Verification

After running the seeding script, you should see a table with counts:

```
table_name              | count
------------------------|------
Tenants                 | 1
Properties              | 1
Room Types              | 4
Rooms                   | 50
Departments             | 8
Guests                  | 5
Reservations            | 15
Payments                | 12
Invoices                | 10
Housekeeping Tasks      | 20
Food Orders             | 8
Maintenance Requests    | 10
```

---

## 🚨 Common Errors

### Error: "relation does not exist"

**Cause:** Migrations haven't been run

**Solution:**
1. Run all migrations first (see Step 1)
2. Verify tables exist (see Step 2)
3. Then run seeding script

### Error: "ON CONFLICT constraint does not exist"

**Cause:** Table structure doesn't match expected schema

**Solution:**
1. Check migration files match your database
2. Re-run migrations if needed
3. Verify table constraints exist

### Error: "Foreign key constraint violation"

**Cause:** Referenced data doesn't exist

**Solution:**
1. Ensure migrations created all tables
2. Check foreign key relationships
3. Run seeding script in order (master data first)

---

## 📝 Notes

- **Idempotent:** Script is safe to run multiple times (uses `ON CONFLICT DO NOTHING`)
- **Order Matters:** Master data is inserted before transactional data
- **Validation:** Script checks for table existence before inserting
- **Data Integrity:** All foreign key relationships are maintained

---

## ✅ Quick Checklist

- [ ] All migrations have been run
- [ ] Tables exist (verified with query)
- [ ] Seeding script copied to SQL Editor
- [ ] Script executed successfully
- [ ] Verification counts look correct

---

**Once seeding is complete, proceed to enable OAuth providers!** 🚀

