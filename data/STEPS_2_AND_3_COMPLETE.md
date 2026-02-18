# Steps 2 & 3 Completion Guide

## Step 2: Set Up Scheduled Jobs ✅

### Quick Setup (Recommended)

**Execute in Supabase SQL Editor:**

```sql
-- Run the scheduled jobs migration
-- File: supabase/migrations/20251226_setup_scheduled_jobs.sql
```

This will:
- ✅ Try to set up pg_cron jobs (if available)
- ✅ Create entries in `scheduled_jobs` table
- ✅ Provide fallback options

### Alternative: Manual Setup via Supabase Dashboard

1. Go to **Database** → **Functions** → **Scheduled Functions**
2. Create three scheduled functions:

   **1. Process Communication Queue**
   - Schedule: `*/5 * * * *` (every 5 minutes)
   - Function: `process-communication-queue`
   - Method: POST

   **2. Check-in Reminders**
   - Schedule: `0 10 * * *` (daily 10 AM)
   - Function: `auto-checkin-reminder`
   - Method: POST
   - Body: `{"autoCheckin": false}`

   **3. Check-out Reminders**
   - Schedule: `0 18 * * *` (daily 6 PM)
   - Function: `auto-checkout-overdue`
   - Method: POST

### Alternative: External Cron Service

If Supabase scheduled functions aren't available, use an external cron service:

**Communication Queue Processor (every 5 minutes):**
```bash
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/process-communication-queue \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY"
```

**Check-in Reminders (daily 10 AM):**
```bash
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/auto-checkin-reminder \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{"autoCheckin": false}'
```

**Check-out Reminders (daily 6 PM):**
```bash
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/auto-checkout-overdue \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY"
```

## Step 3: Run Validation Script ✅

### Execute Validation Script

**In Supabase SQL Editor, run:**

```sql
-- File: scripts/validate-guest-communications.sql
-- Copy and paste the entire file contents
```

Or execute via command line:

```bash
# If you have psql access
psql $DATABASE_URL -f scripts/validate-guest-communications.sql
```

### What the Validation Checks

The script validates:
- ✅ All required tables exist
- ✅ All triggers are created and enabled
- ✅ All functions exist
- ✅ Email templates exist
- ✅ Indexes are created
- ✅ RLS policies are set up

### Expected Output

You should see:
```
✓ communication_queue table exists
✓ guest_communication table exists
✓ email_templates table exists
✓ Booking confirmation trigger exists and enabled
✓ Booking update trigger exists and enabled
✓ Payment communication triggers created
✓ All functions exist
✓ Templates exist
```

### If Validation Fails

1. **Missing tables:** Run `supabase/migrations/20251226_complete_communication_setup.sql`
2. **Missing triggers:** Check if migration executed successfully
3. **Missing templates:** Create templates (see Step 4 in DEPLOYMENT_INSTRUCTIONS.md)

## Quick Reference

### Files to Execute

1. **Database Migration:**
   - `supabase/migrations/20251226_complete_communication_setup.sql` ✅ (Already done)

2. **Scheduled Jobs:**
   - `supabase/migrations/20251226_setup_scheduled_jobs.sql` ⚠️ (Do this now)

3. **Validation:**
   - `scripts/validate-guest-communications.sql` ⚠️ (Do this now)

### Verification Queries

After setup, run these to verify:

```sql
-- Check scheduled jobs
SELECT job_name, schedule_cron, is_enabled, last_run_at
FROM public.scheduled_jobs
WHERE job_name IN (
  'Process Communication Queue',
  'Send Check-in Reminders',
  'Send Check-out Reminders'
);

-- Check communication queue
SELECT 
  status,
  communication_type,
  COUNT(*) as count
FROM public.communication_queue
GROUP BY status, communication_type;

-- Check triggers
SELECT tgname, tgenabled 
FROM pg_trigger 
WHERE tgname LIKE '%communication%';
```

## Next: Step 4 - Testing

After completing steps 2 and 3, proceed to step 4:
- Create a test booking
- Check `communication_queue` table
- Verify email is sent

See `docs/DEPLOYMENT_INSTRUCTIONS.md` for detailed testing instructions.

