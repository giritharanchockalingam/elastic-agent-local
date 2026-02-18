# Simple Email Fix - Step by Step

## Problem
Emails stopped working. Last emails were sent 3 hours ago. Queue processor says "No pending communications" because all items are stuck in "failed" status.

## Simple 3-Step Fix

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

**Expected:** Should update 30+ rows

### Step 2: Verify RESEND_API_KEY

1. Go to Supabase Dashboard → Project Settings → Edge Functions → Secrets
2. Check if `RESEND_API_KEY` exists
3. **If missing:** 
   - Get key from https://resend.com/api-keys
   - Add secret: `RESEND_API_KEY` = `your_key`

### Step 3: Process Queue

Run this command:

```bash
./scripts/process-communication-queue-now.sh
```

Or use the interactive script:

```bash
./scripts/complete-email-fix.sh
```

## Verify It Worked

### Check Resend Dashboard
1. Go to https://resend.com/emails
2. Should see NEW emails (timestamp should be recent, not 3+ hours ago)

### Check Queue Status
```sql
SELECT status, COUNT(*) 
FROM communication_queue 
GROUP BY status;
```
- Should show items moved from "pending" → "sent"

## If Still Not Working

1. **Check Edge Function Logs:**
   - Supabase Dashboard → Edge Functions → `process-communication-queue` → Logs
   - Look for error messages

2. **Check if API key is valid:**
   - Test sending an email from Resend dashboard
   - If it works there, the key is valid

3. **Check guest emails:**
   ```sql
   SELECT DISTINCT g.email
   FROM communication_queue cq
   JOIN guests g ON cq.guest_id = g.id
   WHERE cq.status = 'pending'
   LIMIT 10;
   ```
   - Verify emails are valid

## Quick Reference

| Step | Action | SQL/Command |
|------|--------|-------------|
| 1 | Reset failed items | `UPDATE communication_queue SET status = 'pending', attempts = 0 WHERE status = 'failed';` |
| 2 | Set API key | Supabase Dashboard → Settings → Edge Functions → Secrets |
| 3 | Process queue | `./scripts/process-communication-queue-now.sh` |

That's it! Simple 3-step fix.

