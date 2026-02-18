# Fix: All Items Marked "Sent" But No Emails

## Current Status
- 80 items marked as "sent"
- But no new emails being sent (last emails were 3+ hours ago)
- Likely incorrectly marked before the fix

## Diagnosis

Run this SQL to check:

```sql
-- Check if "sent" items have errors or are old
SELECT 
  COUNT(*) as total_sent,
  COUNT(CASE WHEN error_message IS NOT NULL THEN 1 END) as sent_with_errors,
  COUNT(CASE WHEN processed_at < NOW() - INTERVAL '3 hours' THEN 1 END) as old_sent_items,
  MAX(processed_at) as last_processed
FROM communication_queue
WHERE status = 'sent';
```

## Solution

### Option 1: Reset Old "Sent" Items (Recommended)

Reset items that were processed more than 3 hours ago (likely incorrectly marked):

```sql
-- Reset old "sent" items to pending
UPDATE communication_queue
SET 
  status = 'pending',
  attempts = 0,
  error_message = NULL,
  processed_at = NULL
WHERE status = 'sent'
  AND processed_at < NOW() - INTERVAL '3 hours';
```

### Option 2: Reset All "Sent" Items

If you want to reprocess everything:

```sql
-- Reset ALL "sent" items to pending
UPDATE communication_queue
SET 
  status = 'pending',
  attempts = 0,
  error_message = NULL,
  processed_at = NULL
WHERE status = 'sent';
```

### Option 3: Reset Only Items With Errors

If some have errors:

```sql
-- Reset "sent" items that have errors
UPDATE communication_queue
SET 
  status = 'pending',
  attempts = 0,
  error_message = NULL,
  processed_at = NULL
WHERE status = 'sent'
  AND error_message IS NOT NULL;
```

## After Resetting

1. **Process queue:**
   ```bash
   ./scripts/process-communication-queue-now.sh
   ```

2. **Verify:**
   - Check Resend dashboard for NEW emails
   - Check queue status - items should move to "sent" with recent timestamps

## Recommended Approach

Since last emails were 3+ hours ago, reset all "sent" items processed more than 3 hours ago:

```sql
UPDATE communication_queue
SET status = 'pending', attempts = 0, error_message = NULL, processed_at = NULL
WHERE status = 'sent'
  AND processed_at < NOW() - INTERVAL '3 hours';
```

Then process the queue again. This will ensure:
- Old incorrectly marked items are reprocessed
- New emails are actually sent
- Items are marked "sent" only when emails are really sent

