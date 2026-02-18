# Complete Email Fix Guide

## Current Status
- ✅ System correctly detects failures (not marking as "sent" when emails fail)
- ❌ All items are marked "failed" (need to be reset)
- ❌ Resend API key not accessible to Edge Function

## Complete Fix Steps

### Step 1: Set RESEND_API_KEY Secret (CRITICAL)

**This is the most important step:**

1. **Get Resend API Key:**
   - Go to https://resend.com/api-keys
   - Create a new API key if you don't have one
   - Copy the key (starts with `re_...`)

2. **Set as Supabase Secret:**
   - Go to Supabase Dashboard → Project Settings → Edge Functions
   - Click "Secrets" tab
   - Click "Add Secret" or "New Secret"
   - **Name:** `RESEND_API_KEY`
   - **Value:** Paste your Resend API key
   - Click "Save"

**Why this is critical:** The Edge Function needs this to actually send emails. Without it, all emails will fail.

### Step 2: Reset Failed Communications

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

Or use the script: `scripts/reset-all-failed-to-pending.sql`

### Step 3: Process Queue Again

After setting the secret and resetting:

```bash
./scripts/process-communication-queue-now.sh
```

### Step 4: Verify Emails Are Sent

#### Check Resend Dashboard
1. Go to https://resend.com/emails
2. You should see emails being sent
3. Check for any errors

#### Check Edge Function Logs
1. Go to Supabase Dashboard → Edge Functions → `send-guest-communication`
2. Click "Logs" tab
3. Look for: `[sendViaResend] ✓ Email sent successfully`

#### Check Guest Inboxes
- Check spam folders
- Verify email addresses are correct

## Troubleshooting

### Issue: Still "No pending communications"

**Cause:** Items weren't reset or are in wrong status

**Fix:**
```sql
-- Check current status
SELECT status, COUNT(*) FROM communication_queue GROUP BY status;

-- If all are "sent" or "failed", reset them
UPDATE communication_queue
SET status = 'pending', attempts = 0, error_message = NULL
WHERE status IN ('sent', 'failed');
```

### Issue: Still getting "All email providers failed"

**Cause:** RESEND_API_KEY secret not set or invalid

**Fix:**
1. Verify secret is set: Supabase Dashboard → Settings → Edge Functions → Secrets
2. Verify API key is valid: Test at https://resend.com/emails
3. Redeploy function: `supabase functions deploy send-guest-communication`

### Issue: Emails sent but not received

**Possible causes:**
1. Going to spam (check spam folder)
2. Wrong email address (verify guest emails)
3. Resend testing limitation (can only send to verified email on free tier)

**Fix:**
- Verify domain in Resend (for production)
- Use verified email for testing
- Check Resend dashboard for delivery status

## Verification Checklist

After completing all steps:

- [ ] RESEND_API_KEY secret is set in Supabase
- [ ] Failed communications are reset to pending
- [ ] Queue processor runs successfully
- [ ] Edge Function logs show "Email sent successfully"
- [ ] Resend dashboard shows sent emails
- [ ] Guests receive emails (check spam if not in inbox)

## Expected Results

After fix:
- ✅ Items are processed and marked "sent" only if email was actually sent
- ✅ Failed items are retried up to max_attempts
- ✅ Emails are actually delivered to guests
- ✅ Error messages are logged for debugging

## Quick Reference

| Step | Action | Location |
|------|--------|----------|
| 1 | Set RESEND_API_KEY | Supabase Dashboard → Settings → Edge Functions → Secrets |
| 2 | Reset failed items | Run SQL: `UPDATE communication_queue SET status = 'pending' WHERE status = 'failed'` |
| 3 | Process queue | Run: `./scripts/process-communication-queue-now.sh` |
| 4 | Verify | Check Resend dashboard and Edge Function logs |

## Most Common Issue

**"No pending communications" but no emails sent**

**Solution:**
1. Items are marked "failed" - reset them (Step 2)
2. RESEND_API_KEY not set - set it (Step 1)
3. Then process queue again (Step 3)

