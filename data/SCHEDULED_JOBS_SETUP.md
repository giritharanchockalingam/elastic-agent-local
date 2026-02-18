# Scheduled Jobs Setup Guide

## Overview

This guide explains how to set up scheduled jobs for guest communications. There are multiple options depending on your Supabase plan and available extensions.

## Option 1: Using Supabase Scheduled Functions (Recommended)

Supabase provides a built-in scheduled functions feature. Set up your scheduled jobs through the Supabase dashboard:

1. Go to **Database** → **Functions** → **Scheduled Functions**
2. Create new scheduled functions:

### Communication Queue Processor
- **Name**: `process-communication-queue`
- **Schedule**: `*/5 * * * *` (every 5 minutes)
- **Function**: `process-communication-queue`
- **Method**: POST
- **Body**: `{}`

### Check-in Reminders
- **Name**: `send-checkin-reminders`
- **Schedule**: `0 10 * * *` (daily at 10 AM)
- **Function**: `auto-checkin-reminder`
- **Method**: POST
- **Body**: `{"autoCheckin": false}`

### Check-out Reminders
- **Name**: `send-checkout-reminders`
- **Schedule**: `0 18 * * *` (daily at 6 PM)
- **Function**: `auto-checkout-overdue`
- **Method**: POST
- **Body**: `{}`

## Option 2: Using External Cron Service

If Supabase scheduled functions are not available, use an external cron service (e.g., GitHub Actions, cron-job.org, EasyCron):

### Communication Queue Processor (Every 5 minutes)

```bash
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/process-communication-queue \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json"
```

### Check-in Reminders (Daily at 10 AM)

```bash
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/auto-checkin-reminder \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{"autoCheckin": false}'
```

### Check-out Reminders (Daily at 6 PM)

```bash
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/auto-checkout-overdue \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json"
```

## Option 3: Using pg_cron Extension (If Available)

If you have access to pg_cron extension (requires Supabase Pro plan or self-hosted):

1. Execute the migration: `supabase/migrations/20251226_setup_scheduled_jobs.sql`
2. The script will automatically set up pg_cron jobs if available

## Option 4: Using scheduled_jobs Table

The migration script also creates entries in the `scheduled_jobs` table. You can process these with a custom scheduler:

1. Execute: `supabase/migrations/20251226_setup_scheduled_jobs.sql`
2. Set up a cron job that reads from `scheduled_jobs` table and executes the jobs

## Verification

After setting up scheduled jobs, verify they're working:

```sql
-- Check scheduled_jobs table
SELECT 
  job_name,
  schedule_cron,
  is_enabled,
  last_run_at,
  next_run_at,
  last_status
FROM public.scheduled_jobs
WHERE job_name IN (
  'Process Communication Queue',
  'Send Check-in Reminders',
  'Send Check-out Reminders'
);

-- Check pg_cron jobs (if available)
SELECT jobname, schedule, active
FROM cron.job
WHERE jobname IN (
  'process-communication-queue',
  'send-checkin-reminders',
  'send-checkout-reminders'
);
```

## Testing

Test the communication queue processor manually:

```bash
# Test queue processor
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/process-communication-queue \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY"

# Check queue status
SELECT 
  status,
  communication_type,
  COUNT(*) as count
FROM public.communication_queue
GROUP BY status, communication_type;
```

## Troubleshooting

### Jobs Not Running

1. **Check if jobs are enabled:**
   ```sql
   SELECT job_name, is_enabled FROM public.scheduled_jobs;
   ```

2. **Check last run status:**
   ```sql
   SELECT job_name, last_run_at, last_status, error_message
   FROM public.scheduled_jobs
   WHERE last_status = 'failed';
   ```

3. **Manually trigger a job:**
   ```bash
   curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/process-communication-queue \
     -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY"
   ```

### Communication Queue Not Processing

1. **Check queue size:**
   ```sql
   SELECT COUNT(*) FROM public.communication_queue WHERE status = 'pending';
   ```

2. **Check for errors:**
   ```sql
   SELECT * FROM public.communication_queue 
   WHERE status = 'failed' 
   ORDER BY created_at DESC 
   LIMIT 10;
   ```

3. **Manually process queue:**
   ```sql
   SELECT * FROM public.process_communication_queue();
   ```

## Next Steps

After setting up scheduled jobs:

1. Monitor the `communication_queue` table for pending items
2. Check `scheduled_jobs` table for job execution status
3. Review logs in Supabase dashboard for any errors
4. Test with a sample booking to verify end-to-end flow

