# Quick Fix: "No Pending Communications"

## Problem
Queue processor says "No pending communications" but emails aren't being sent.

## Cause
All items are stuck in "failed" status from earlier attempts. They need to be reset to "pending" before they can be processed.

## Quick Fix (2 Steps)

### Step 1: Reset Failed Items

Run this SQL in Supabase SQL Editor:

```sql
-- Reset all failed items to pending
UPDATE communication_queue
SET 
  status = 'pending',
  attempts = 0,
  error_message = NULL,
  processed_at = NULL
WHERE status = 'failed';
```

**Expected:** Should update rows (e.g., 30+ items)

Or use the script: `scripts/check-and-reset-queue.sql`

### Step 2: Process Queue Again

After resetting:

```bash
./scripts/process-communication-queue-now.sh
```

## Verify It Worked

### Check Queue Status
```sql
SELECT status, COUNT(*) 
FROM communication_queue 
GROUP BY status;
```

**Expected:**
- Should see items in "pending" status
- Then after processing, items move to "sent"

### Check Processing Results
After running the queue processor, you should see:
```json
{
  "success": true,
  "processed": 30,  // Should be > 0
  "failed": 0,
  "total": 30
}
```

## Why This Happens

1. Items fail (e.g., API key missing)
2. Items marked as "failed"
3. Queue processor skips "failed" items
4. Items stay "failed" until manually reset

## Prevention

Once RESEND_API_KEY is set and functions are deployed, items should process successfully and won't get stuck in "failed" status.

## Quick Checklist

- [ ] Reset failed items (SQL above)
- [ ] Verify RESEND_API_KEY is set
- [ ] Deploy fixed functions (if not done)
- [ ] Process queue again
- [ ] Check Resend dashboard for new emails

That's it! Reset → Process → Done.

