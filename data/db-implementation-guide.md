# Database Implementation Guide

This guide walks you through implementing the enterprise database changes according to `DB_IMPLEMENTATION_PLAN.md`.

---

## 🎯 Overview

The implementation is broken down into 6 phases plus post-implementation constraints:

1. **Phase 1:** Critical Enterprise Tables (Security & Audit, Guest & Booking, Loyalty, Revenue)
2. **Phase 2:** Communication & Notifications
3. **Phase 3:** Reports & Analytics
4. **Phase 4:** Constraints & Enhancements (Post-Implementation)
5. **Phase 5:** Test Data Generation (Optional)
6. **Phase 6:** Data Integrity Validation

---

## 📋 Pre-Implementation Checklist

- [ ] Backup current database
- [ ] Review all SQL scripts
- [ ] Test in development environment first
- [ ] Verify sufficient disk space
- [ ] Schedule maintenance window
- [ ] Notify stakeholders

---

## 🚀 Implementation Methods

### Method 1: Supabase SQL Editor (Recommended)

**Best for:** Production, safety, visibility

**Steps:**

1. Go to https://app.supabase.com
2. Select your project
3. Navigate to **SQL Editor**
4. Copy and paste the SQL for each phase
5. Review the SQL carefully
6. Click **Run** or press `Cmd+Enter` (Mac) / `Ctrl+Enter` (Windows)

**Phase Files:**
- Phase 1: `db-implementation-phase-phase1.sql`
- Phase 2: `db-implementation-phase-phase2.sql`
- Phase 3: `db-implementation-phase-phase3.sql`
- Phase 4: `db-implementation-phase-phase4.sql`
- Phase 5: `db-implementation-phase-phase5.sql`
- Phase 6: `db-implementation-phase-phase6.sql`
- Post-Implementation: `db-implementation-phase-post.sql`

### Method 2: Automated Script (Experimental)

**Best for:** Development, testing

**Prerequisites:**
```bash
# Set environment variables
export SUPABASE_URL="your_supabase_url"
export SUPABASE_SERVICE_ROLE_KEY="your_service_role_key"
```

**Usage:**
```bash
# Run all phases
node scripts/execute-db-implementation.cjs all

# Run specific phase
node scripts/execute-db-implementation.cjs phase1
```

**Note:** This method may have limitations. Use SQL Editor for production.

---

## 📊 Phase-by-Phase Implementation

### Phase 1: Critical Enterprise Tables

**Duration:** 3-5 days  
**Priority:** 🔴 CRITICAL

#### Day 1-2: Security & Audit Foundation

**Tables to Create:**
- `audit_logs`
- `user_sessions`
- `login_history`
- `rate_limits`
- `security_alerts`

**SQL Location:** Lines 20-165 in `DB_ENTERPRISE_IMPLEMENTATION.sql`

**Validation:**
```sql
-- Verify tables created
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('audit_logs', 'user_sessions', 'login_history', 'rate_limits', 'security_alerts');

-- Verify indexes
SELECT indexname 
FROM pg_indexes 
WHERE tablename IN ('audit_logs', 'user_sessions', 'login_history');
```

#### Day 3: Guest & Booking Enhancements

**Tables to Create:**
- `guest_preferences`
- `guest_documents`
- `reservation_history`
- `room_rate_history`
- `cancellation_policies`

**SQL Location:** Lines 167-303 in `DB_ENTERPRISE_IMPLEMENTATION.sql`

**Validation:**
```sql
SELECT COUNT(*) FROM public.guest_preferences;
SELECT COUNT(*) FROM public.reservation_history;
```

#### Day 4: Loyalty Program

**Tables to Create:**
- `loyalty_tiers`
- `loyalty_transactions`

**SQL Location:** Lines 305-367 in `DB_ENTERPRISE_IMPLEMENTATION.sql`

**Sample Data:**
```sql
INSERT INTO public.loyalty_tiers (property_id, tier_name, tier_level, min_points, max_points, discount_percentage) VALUES
(NULL, 'Bronze', 1, 0, 999, 5),
(NULL, 'Silver', 2, 1000, 2999, 10),
(NULL, 'Gold', 3, 3000, 9999, 15),
(NULL, 'Platinum', 4, 10000, NULL, 20);
```

#### Day 5: Revenue Management

**Tables to Create:**
- `revenue_centers`
- `revenue_transactions`
- `promotions`

**SQL Location:** Lines 369-472 in `DB_ENTERPRISE_IMPLEMENTATION.sql`

**Sample Revenue Centers:**
```sql
INSERT INTO public.revenue_centers (property_id, center_name, center_code, category) VALUES
(NULL, 'Room Revenue', 'ROOM', 'rooms'),
(NULL, 'Food Revenue', 'FOOD', 'food'),
(NULL, 'Beverage Revenue', 'BEV', 'beverage'),
(NULL, 'Spa Revenue', 'SPA', 'spa'),
(NULL, 'Laundry Revenue', 'LAUN', 'laundry');
```

---

### Phase 2: Communication & Notifications

**Duration:** 2-3 days  
**Priority:** 🟡 HIGH

**Tables to Create:**
- `email_templates`
- `email_log`
- `sms_log`
- `notifications`

**SQL Location:** Lines 474-595 in `DB_ENTERPRISE_IMPLEMENTATION.sql`

**Sample Email Templates:**
```sql
INSERT INTO public.email_templates (template_code, template_name, subject, body_html, variables, category) VALUES
('BOOKING_CONFIRMATION', 'Booking Confirmation', 
 'Your Reservation is Confirmed - {{reservation_number}}',
 '<h1>Booking Confirmed</h1><p>Dear {{guest_name}},</p><p>Your reservation {{reservation_number}} is confirmed...</p>',
 '["guest_name", "reservation_number", "check_in_date", "check_out_date", "room_type"]'::jsonb,
 'reservation');
```

---

### Phase 3: Reports & Analytics

**Duration:** 1-2 days  
**Priority:** 🟢 MEDIUM

**Tables to Create:**
- `saved_reports`
- `report_executions`

**SQL Location:** Lines 597-649 in `DB_ENTERPRISE_IMPLEMENTATION.sql`

---

### Phase 4: Constraints & Enhancements

**Duration:** 1 day  
**Priority:** 🔴 CRITICAL  
**Risk:** MEDIUM (may affect existing data)

**⚠️ IMPORTANT:** Run this in a transaction and test thoroughly!

**SQL Location:** Lines 657-719 in `DB_ENTERPRISE_IMPLEMENTATION.sql`

**What it does:**
- Adds CHECK constraints to reservations
- Adds CHECK constraints to payments
- Enhances rooms, invoices, guests, menu_items tables with new columns

**Testing:**
```sql
BEGIN;
-- Add constraints
-- ... (from SQL file)

-- Test constraints
SELECT * FROM public.reservations WHERE check_out_date <= check_in_date;
-- If no results, constraints are good

COMMIT; -- or ROLLBACK if issues found
```

---

## ✅ Post-Implementation Validation

### 1. Verify Tables Created

```sql
SELECT 
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
AND table_name IN (
  'audit_logs', 'user_sessions', 'login_history', 'rate_limits', 'security_alerts',
  'guest_preferences', 'guest_documents', 'reservation_history', 'room_rate_history', 'cancellation_policies',
  'loyalty_tiers', 'loyalty_transactions',
  'revenue_centers', 'revenue_transactions', 'promotions',
  'email_templates', 'email_log', 'sms_log', 'notifications',
  'saved_reports', 'report_executions'
)
ORDER BY table_name;
```

### 2. Verify Indexes

```sql
SELECT 
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
AND tablename IN (
  'audit_logs', 'user_sessions', 'login_history', 'rate_limits', 'security_alerts'
)
ORDER BY tablename, indexname;
```

### 3. Verify Constraints

```sql
SELECT 
  conname as constraint_name,
  conrelid::regclass as table_name,
  contype as constraint_type
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
AND conrelid::regclass::text IN (
  'reservations', 'payments', 'guests'
)
ORDER BY table_name, constraint_name;
```

### 4. Run Integrity Validation

```bash
# Run the integrity validation script
psql -h your-host -U postgres -d postgres < /path/to/DB_INTEGRITY_VALIDATION.sql
```

Or in Supabase SQL Editor, copy and paste the contents of `DB_INTEGRITY_VALIDATION.sql`.

---

## 🚨 Rollback Procedures

If issues occur:

### Option 1: Database Backup Restore

```bash
# Restore from backup
psql -h your-host -U postgres -d postgres < backup_before_implementation.sql
```

### Option 2: Drop New Tables

```sql
BEGIN;
  -- Drop new tables (in reverse order)
  DROP TABLE IF EXISTS public.report_executions CASCADE;
  DROP TABLE IF EXISTS public.saved_reports CASCADE;
  DROP TABLE IF EXISTS public.notifications CASCADE;
  DROP TABLE IF EXISTS public.sms_log CASCADE;
  DROP TABLE IF EXISTS public.email_log CASCADE;
  DROP TABLE IF EXISTS public.email_templates CASCADE;
  -- ... continue for all new tables
COMMIT;
```

---

## 📈 Success Metrics

After implementation, verify:

- ✅ All 27 new enterprise tables created
- ✅ All indexes created
- ✅ All constraints added
- ✅ Zero orphaned records
- ✅ Zero referential integrity violations
- ✅ RLS policies active

---

## 📞 Support

If you encounter issues:

1. Check error messages in Supabase SQL Editor
2. Review the SQL syntax
3. Verify foreign key references exist
4. Check for existing data conflicts
5. Review `DB_INTEGRITY_VALIDATION.sql` for validation queries

---

**Ready to implement!** Start with Phase 1 in Supabase SQL Editor.

