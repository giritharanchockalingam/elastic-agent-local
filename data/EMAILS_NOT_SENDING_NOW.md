# Emails Not Sending Now - Complete Fix

## Problem
- ✅ Emails were working 3 hours ago (old emails in Resend dashboard)
- ❌ No new emails being sent now
- ❌ Queue processor says "No pending communications"
- ❌ All items are stuck in "failed" status

## Root Cause
Items were marked as "failed" during earlier attempts and haven't been reset to "pending" for retry.

## Complete Fix Steps

### Step 1: Verify RESEND_API_KEY is Set

1. Go to Supabase Dashboard → Project Settings → Edge Functions → Secrets
2. Check if `RESEND_API_KEY` exists
3. If not, add it:
   - Get API key from https://resend.com/api-keys
   - Add secret: `RESEND_API_KEY` = `your_key`

### Step 2: Reset Failed Items

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

Or use: `scripts/fix-and-process-emails.sql`

### Step 3: Process Queue

After resetting:

```bash
./scripts/process-communication-queue-now.sh
```

### Step 4: Verify New Emails

1. **Check Resend Dashboard:** https://resend.com/emails
   - Should see NEW emails (not just the old ones from 3 hours ago)

2. **Check Edge Function Logs:**
   - Supabase Dashboard → Edge Functions → `process-communication-queue` → Logs
   - Should see successful processing

3. **Check Queue Status:**
   ```sql
   SELECT status, COUNT(*) 
   FROM communication_queue 
   GROUP BY status;
   ```
   - Should show items moving from "pending" → "sent"

## Why This Happens

1. Items fail (e.g., API key not set)
2. Items marked as "failed"
3. Queue processor skips "failed" items
4. Items stay "failed" until manually reset

## Prevention

The system should automatically retry failed items, but:
- Items that exceed `max_attempts` stay "failed"
- Items need to be reset manually if API key was missing

## Quick Fix (All-in-One)

Run this complete fix:

```sql
-- 1. Reset all failed items
UPDATE communication_queue
SET status = 'pending', attempts = 0, error_message = NULL, processed_at = NULL
WHERE status = 'failed';

-- 2. Verify
SELECT status, COUNT(*) FROM communication_queue GROUP BY status;
```

Then process queue:
```bash
./scripts/process-communication-queue-now.sh
```

## Expected Results

After fix:
- ✅ Failed items reset to "pending"
- ✅ Queue processor finds pending items
- ✅ Emails are sent successfully
- ✅ New emails appear in Resend dashboard
- ✅ Items marked as "sent" (not "failed")

## If Still Not Working

1. **Check RESEND_API_KEY is set:** Supabase Dashboard → Settings → Edge Functions → Secrets
2. **Check Edge Function logs:** Look for specific error messages
3. **Verify API key is valid:** Test at https://resend.com/emails
4. **Check guest emails:** Make sure guests have valid email addresses

