# Diagnose Communication Queue Issue

## Problem
The function says "No pending communications" but you know there are items in the queue.

## Quick Diagnosis

Run this SQL in Supabase SQL Editor:

```sql
-- Check all queue items and their status
SELECT 
  id,
  reservation_id,
  communication_type,
  status,
  attempts,
  max_attempts,
  scheduled_at,
  created_at,
  updated_at,
  processed_at,
  error_message,
  CASE 
    WHEN status = 'pending' AND scheduled_at > NOW() THEN '⏰ Scheduled for future'
    WHEN status = 'pending' AND attempts >= COALESCE(max_attempts, 3) THEN '❌ Exceeded max attempts'
    WHEN status = 'pending' AND scheduled_at <= NOW() AND (attempts IS NULL OR attempts < COALESCE(max_attempts, 3)) THEN '✅ Ready to process'
    WHEN status = 'sent' THEN '✅ Already sent'
    WHEN status = 'processing' THEN '🔄 Currently processing'
    WHEN status = 'failed' THEN '❌ Failed'
    ELSE '❓ Unknown'
  END as processing_status
FROM communication_queue
ORDER BY created_at DESC
LIMIT 20;
```

## Common Issues and Solutions

### Issue 1: Items Already Processed
If status is 'sent' or 'processing', they were already handled.

**Solution:** Check if emails were actually sent by looking at the `processed_at` timestamp.

### Issue 2: Scheduled for Future
If `scheduled_at > NOW()`, items won't be processed until that time.

**Solution:** Either wait, or update them:
```sql
UPDATE communication_queue
SET scheduled_at = NOW()
WHERE status = 'pending'
  AND scheduled_at > NOW();
```

### Issue 3: Exceeded Max Attempts
If `attempts >= max_attempts`, items won't be processed.

**Solution:** Reset attempts if needed:
```sql
UPDATE communication_queue
SET attempts = 0,
    status = 'pending',
    error_message = NULL
WHERE status = 'pending'
  AND attempts >= COALESCE(max_attempts, 3);
```

### Issue 4: Status Not 'pending'
Items might be in 'processing' or 'failed' status.

**Solution:** Reset stuck items:
```sql
-- Reset stuck processing items
UPDATE communication_queue
SET status = 'pending',
    updated_at = NOW()
WHERE status = 'processing'
  AND updated_at < NOW() - INTERVAL '5 minutes';

-- Reset failed items (if you want to retry)
UPDATE communication_queue
SET status = 'pending',
    attempts = 0,
    error_message = NULL
WHERE status = 'failed'
  AND attempts < COALESCE(max_attempts, 3);
```

## Force Process All Pending Items

If you want to force process all pending items regardless of schedule:

```sql
-- Update all pending items to be ready now
UPDATE communication_queue
SET scheduled_at = NOW()
WHERE status = 'pending'
  AND scheduled_at > NOW();

-- Reset attempts for items that exceeded max
UPDATE communication_queue
SET attempts = 0
WHERE status = 'pending'
  AND attempts >= COALESCE(max_attempts, 3);
```

Then run the processing function again.

## Check Function Logs

In Supabase Dashboard:
1. Go to Edge Functions → `process-communication-queue`
2. Click on "Logs" tab
3. Check for any error messages

## Verify Email Templates

Make sure email templates exist:

```sql
SELECT 
  id,
  property_id,
  template_code,
  template_name,
  is_active
FROM email_templates
WHERE template_code = 'booking_confirmation'
  AND is_active = true;
```

## Verify Guest Emails

Check if guests have valid emails:

```sql
SELECT 
  cq.id as queue_id,
  cq.reservation_id,
  cq.status,
  g.email,
  g.first_name,
  g.last_name
FROM communication_queue cq
JOIN reservations r ON cq.reservation_id = r.id
JOIN guests g ON r.guest_id = g.id
WHERE cq.status = 'pending'
LIMIT 10;
```

