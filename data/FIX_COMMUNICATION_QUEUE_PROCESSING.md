# Fix Communication Queue Processing

## Problem
Booking confirmations were being queued correctly, but they were stuck in "pending" status and not being processed.

## Root Cause
The `process-communication-queue` Edge Function had a query issue:
- It was trying to use `.lt('attempts', 'max_attempts')` which compares two columns
- Supabase doesn't support column-to-column comparisons in query filters
- This caused the query to fail silently or return incorrect results

## Solution

### 1. Fixed Query Filter
Removed the invalid column comparison from the Supabase query and moved the filtering to JavaScript:

```typescript
// Before (invalid):
.lt('attempts', 'max_attempts')

// After (valid):
// Filter in JavaScript after fetching
const validQueueItems = queueItems.filter(item => 
  (item.attempts || 0) < (item.max_attempts || 3)
);
```

### 2. Created Manual Processing Script
Created `scripts/process-communication-queue-now.sh` to manually trigger queue processing:

```bash
./scripts/process-communication-queue-now.sh
```

### 3. Created Status Check Script
Created `scripts/check-communication-queue-status.sql` to diagnose queue issues:

```sql
-- Run in Supabase SQL Editor
\i scripts/check-communication-queue-status.sql
```

## How to Process Pending Communications

### Option 1: Manual Script (Recommended for Testing)
```bash
./scripts/process-communication-queue-now.sh
```

### Option 2: Direct Edge Function Call
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  "https://YOUR_PROJECT.supabase.co/functions/v1/process-communication-queue"
```

### Option 3: Via Supabase Dashboard
1. Go to Supabase Dashboard → Edge Functions
2. Find `process-communication-queue`
3. Click "Invoke" button
4. Use empty body `{}`

## Verify Queue Processing

### Check Queue Status
```sql
-- Count pending items
SELECT COUNT(*) FROM communication_queue WHERE status = 'pending';

-- View pending items
SELECT * FROM communication_queue 
WHERE status = 'pending' 
ORDER BY created_at ASC 
LIMIT 10;
```

### Check Processing Results
```sql
-- View recently processed items
SELECT * FROM communication_queue 
WHERE status IN ('sent', 'failed')
ORDER BY processed_at DESC 
LIMIT 10;
```

## Scheduled Processing

The queue should be processed automatically every 5 minutes via:
- **pg_cron** (if available): `SELECT cron.schedule(...)`
- **scheduled_jobs table**: Check `scheduled_jobs` for `process-communication-queue` job

### Verify Scheduled Job
```sql
SELECT * FROM scheduled_jobs 
WHERE job_name LIKE '%communication%' 
   OR job_name LIKE '%queue%';
```

## Troubleshooting

### Issue: Queue items stuck in "pending"
1. Check if scheduled job is running:
   ```sql
   SELECT * FROM scheduled_jobs WHERE job_name = 'process-communication-queue';
   ```
2. Manually trigger processing (see Option 1 above)
3. Check Edge Function logs in Supabase Dashboard

### Issue: Queue items stuck in "processing"
These are items that started processing but never completed. Reset them:
```sql
UPDATE communication_queue
SET status = 'pending',
    updated_at = NOW()
WHERE status = 'processing'
  AND updated_at < NOW() - INTERVAL '5 minutes';
```

### Issue: All items failing
1. Check error messages:
   ```sql
   SELECT id, error_message, attempts 
   FROM communication_queue 
   WHERE status = 'failed' 
   ORDER BY updated_at DESC 
   LIMIT 10;
   ```
2. Verify email templates exist:
   ```sql
   SELECT * FROM email_templates 
   WHERE template_code = 'booking_confirmation' 
     AND is_active = true;
   ```
3. Check guest emails are valid:
   ```sql
   SELECT r.id, g.email 
   FROM reservations r
   JOIN guests g ON r.guest_id = g.id
   WHERE r.id IN (
     SELECT reservation_id FROM communication_queue WHERE status = 'failed'
   );
   ```

## Files Changed

1. `supabase/functions/process-communication-queue/index.ts`
   - Fixed query filter issue
   - Added JavaScript-based filtering for max attempts

2. `scripts/process-communication-queue-now.sh` (new)
   - Manual queue processing script

3. `scripts/check-communication-queue-status.sql` (new)
   - Diagnostic queries for queue status

## Next Steps

1. **Deploy the fixed function:**
   ```bash
   supabase functions deploy process-communication-queue
   ```

2. **Process existing pending items:**
   ```bash
   ./scripts/process-communication-queue-now.sh
   ```

3. **Verify scheduled job is running:**
   - Check `scheduled_jobs` table
   - Verify pg_cron jobs (if using)

4. **Monitor queue processing:**
   - Set up alerts for failed communications
   - Monitor queue size regularly

## Expected Behavior

After the fix:
- ✅ Queue items are processed correctly
- ✅ Communications are sent to guests
- ✅ Status updates from "pending" → "processing" → "sent"
- ✅ Failed items are retried up to max_attempts
- ✅ Error messages are logged for debugging

