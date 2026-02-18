# How to Process Communication Queue

## Problem
You have pending communications in the queue that need to be processed, but the scheduled job may not be running or you want to process them immediately.

## Solution Options

### Method 1: Supabase Dashboard (Easiest - No Keys Needed) ⭐ RECOMMENDED

1. **Go to Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/functions

2. **Find the Function:**
   - Look for `process-communication-queue` in the list

3. **Invoke the Function:**
   - Click on `process-communication-queue`
   - Click the **"Invoke"** button (usually in the top right)
   - In the request body, enter: `{}`
   - Click **"Invoke Function"**

4. **Check Results:**
   - View the response to see how many items were processed
   - Check the communication_queue table to verify status changed

### Method 2: Using curl with Service Role Key

#### Step 1: Get Your Service Role Key

1. Go to: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/settings/api
2. Scroll to **"Project API keys"** section
3. Find **"service_role"** key (NOT the anon key)
4. Click **"Reveal"** to show it
5. Copy the entire key (it's very long, starts with `eyJ...`)

#### Step 2: Add to .env file

Create or update `.env` file in project root:

```bash
SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

#### Step 3: Run the script

```bash
./scripts/process-communication-queue-now.sh
```

Or use curl directly:

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{}' \
  "https://qnwsnrfcnonaxvnithfv.supabase.co/functions/v1/process-communication-queue"
```

### Method 3: Check Scheduled Job

The queue should be processed automatically every 5 minutes. Check if it's running:

```sql
-- Check scheduled job status
SELECT 
  job_name,
  job_type,
  schedule_cron,
  is_enabled,
  last_run_at,
  next_run_at,
  last_status,
  error_message
FROM scheduled_jobs
WHERE job_name LIKE '%communication%'
   OR job_name LIKE '%queue%';
```

If the job is not enabled or not running, you can enable it:

```sql
-- Enable the scheduled job
UPDATE scheduled_jobs
SET is_enabled = true,
    next_run_at = NOW()
WHERE job_name = 'process-communication-queue';
```

## Verify Processing

### Check Queue Status

```sql
-- Count pending items
SELECT COUNT(*) as pending_count
FROM communication_queue
WHERE status = 'pending';

-- View pending items
SELECT 
  id,
  reservation_id,
  communication_type,
  status,
  attempts,
  created_at
FROM communication_queue
WHERE status = 'pending'
ORDER BY created_at ASC
LIMIT 10;
```

### Check Processing Results

```sql
-- View recently processed items
SELECT 
  id,
  reservation_id,
  communication_type,
  status,
  attempts,
  error_message,
  processed_at
FROM communication_queue
WHERE status IN ('sent', 'failed')
ORDER BY processed_at DESC
LIMIT 10;
```

## Troubleshooting

### Issue: Function returns 401 Unauthorized

**Solution:** You need the service role key, not the anon key. Use Method 1 (Dashboard) or get your service role key (Method 2).

### Issue: Function returns but no items processed

**Possible causes:**
1. All items have exceeded max attempts
2. Items are scheduled for future
3. Items are missing required data (guest email, template, etc.)

**Check:**
```sql
-- Check for items that can't be processed
SELECT 
  id,
  reservation_id,
  communication_type,
  status,
  attempts,
  max_attempts,
  error_message
FROM communication_queue
WHERE status = 'pending'
  AND (attempts >= max_attempts OR scheduled_at > NOW());
```

### Issue: Items stuck in "processing" status

These are items that started processing but never completed. Reset them:

```sql
-- Reset stuck processing items
UPDATE communication_queue
SET status = 'pending',
    updated_at = NOW()
WHERE status = 'processing'
  AND updated_at < NOW() - INTERVAL '5 minutes';
```

### Issue: All items failing

Check error messages:

```sql
SELECT 
  id,
  reservation_id,
  communication_type,
  status,
  attempts,
  error_message
FROM communication_queue
WHERE status = 'failed'
ORDER BY updated_at DESC
LIMIT 10;
```

Common errors:
- Missing email template
- Invalid guest email
- Missing property_id
- Template variable errors

## Quick Reference

| Method | Difficulty | Requirements |
|--------|-----------|--------------|
| Supabase Dashboard | ⭐ Easy | None |
| curl script | ⭐⭐ Medium | Service role key |
| Scheduled job | ⭐⭐⭐ Hard | Job must be configured |

## Recommended Approach

For immediate processing: **Use Method 1 (Supabase Dashboard)** - it's the easiest and doesn't require any keys or configuration.

For automated processing: **Ensure the scheduled job is running** (Method 3).

