# Complete Database Migration Guide
## From: crumfjyjvofleoqfpwzm → To: qnwsnrfcnonaxvnithfv

## Overview
This guide will help you migrate your entire HMS database from the old Supabase project to the new one with:
- ✅ Complete schema (all tables, columns, constraints)
- ✅ All data migrated
- ✅ Row Level Security (RLS) policies
- ✅ Indexes and performance optimizations
- ✅ Foreign key relationships
- ✅ Proper data integrity

## Migration Strategy

### Phase 1: Schema Export & Analysis
### Phase 2: Schema Creation in New Project
### Phase 3: Data Migration
### Phase 4: RLS & Security Hardening
### Phase 5: Validation & Testing

---

## Phase 1: Export Schema from Old Project

### Step 1.1: Export Schema via Supabase Dashboard

**Old Project**: https://supabase.com/dashboard/project/crumfjyjvofleoqfpwzm/database/tables

1. **Export Schema SQL**:
   - Go to: Settings → Database → Connection String
   - Use the connection pooler URI
   - Run this command in your terminal:

```bash
# Install PostgreSQL client if needed
# Mac: brew install postgresql
# Ubuntu: sudo apt-get install postgresql-client

# Export schema only (no data)
pg_dump "postgresql://postgres.[PASSWORD]@db.crumfjyjvofleoqfpwzm.supabase.co:5432/postgres" \
  --schema-only \
  --no-owner \
  --no-acl \
  --schema=public \
  --file=old_schema.sql
```

### Step 1.2: Export Data

```bash
# Export data only
pg_dump "postgresql://postgres.[PASSWORD]@db.crumfjyjvofleoqfpwzm.supabase.co:5432/postgres" \
  --data-only \
  --no-owner \
  --no-acl \
  --schema=public \
  --file=old_data.sql
```

### Step 1.3: Alternative - Use Supabase SQL Editor

If you don't have pg_dump, use this SQL in the old project's SQL Editor:

```sql
-- Get all table structures
SELECT 
  'CREATE TABLE ' || table_schema || '.' || table_name || ' (' ||
  string_agg(
    column_name || ' ' || data_type || 
    CASE WHEN character_maximum_length IS NOT NULL 
      THEN '(' || character_maximum_length || ')' 
      ELSE '' 
    END ||
    CASE WHEN is_nullable = 'NO' THEN ' NOT NULL' ELSE '' END,
    ', '
  ) || ');' AS create_statement
FROM information_schema.columns
WHERE table_schema = 'public'
GROUP BY table_schema, table_name
ORDER BY table_name;
```

---

## Phase 2: Automated Migration Script

Since manual export can be complex, I'll create an automated migration script that:
1. Connects to both databases
2. Copies schema
3. Copies data
4. Sets up RLS
5. Validates everything

### Step 2.1: Prepare Credentials

You'll need:
- **Old Project Password**: From crumfjyjvofleoqfpwzm
- **New Project Password**: From qnwsnrfcnonaxvnithfv

Get passwords from:
- Settings → Database → Database Password (Reset if needed)

---

## Phase 3: Quick Migration (Recommended)

### Option A: Use Supabase CLI (Easiest)

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to old project
supabase link --project-ref crumfjyjvofleoqfpwzm

# Generate migration from old project
supabase db dump -f old_project_dump.sql

# Switch to new project
supabase link --project-ref qnwsnrfcnonaxvnithfv --password [NEW_PASSWORD]

# Apply dump to new project
supabase db reset
psql [NEW_PROJECT_CONNECTION_STRING] < old_project_dump.sql
```

### Option B: Manual SQL Script Approach

I'll create SQL scripts that you can run directly in the new project's SQL Editor.

---

## Critical Tables to Migrate

Based on your errors, these are the priority tables:

### Core Tables (Existing in new project):
✅ properties
✅ rooms
✅ room_types
✅ staff

### Missing Tables (Need to create):
❌ languages
❌ scheduled_jobs
❌ system_settings
❌ user_activity_logs
❌ reservations (exists but has issues)
❌ guests (exists but has issues)

### Additional HMS Tables:
- audit_logs
- bar_orders
- cancellation_policies
- demand_analytics
- email_log
- email_templates
- expenses
- food_orders
- frro_submissions
- guest_feedback
- housekeeping_tasks
- incidents
- invoices
- loyalty_tiers
- loyalty_transactions
- maintenance_work_orders
- marketing_analytics
- menu_items
- notifications
- payments
- pricing_rules
- promotions
- rate_plans
- revenue_centers
- revenue_transactions
- saved_reports
- sms_log
- staff_attendance
- yield_optimization_logs

---

## Next Steps

**Choose your migration method:**

1. **Quick & Automated** (Recommended):
   - I'll create a Node.js script that handles everything
   - Requires: Node.js, database passwords
   - Time: ~10 minutes

2. **Manual SQL Scripts**:
   - I'll create SQL files you can run one by one
   - No additional tools needed
   - Time: ~30 minutes

3. **Supabase CLI**:
   - Official Supabase method
   - Cleanest approach
   - Requires: Supabase CLI installed

**Which method do you prefer?**

Also, please confirm:
- Do you want to migrate ALL data, or just the schema?
- Should I preserve existing data in the new project (like your 40 rooms)?
- Do you have access to the database passwords for both projects?
