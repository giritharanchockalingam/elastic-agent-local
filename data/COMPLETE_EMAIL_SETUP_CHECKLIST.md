# Complete Email Setup Checklist

## Current Status
- ❌ Emails not sending (last sent 3+ hours ago)
- ❌ Items stuck in "failed" status
- ❌ JSON parsing error (now fixed)
- ✅ Resend integration exists in database

## Complete Fix Checklist

### ✅ Step 1: Set RESEND_API_KEY Secret

**Location:** Supabase Dashboard → Project Settings → Edge Functions → Secrets

1. Go to https://resend.com/api-keys
2. Get or create your API key
3. In Supabase Dashboard:
   - Go to Settings → Edge Functions → Secrets
   - Click "Add Secret" or "New Secret"
   - Name: `RESEND_API_KEY`
   - Value: Your Resend API key
   - Save

**Status:** [ ] Done

### ✅ Step 2: Deploy Fixed Functions

Run these commands:

```bash
supabase functions deploy send-guest-communication
supabase functions deploy process-communication-queue
```

**Status:** [ ] Done

### ✅ Step 3: Reset Failed Items

Run this SQL in Supabase SQL Editor:

```sql
UPDATE communication_queue
SET 
  status = 'pending',
  attempts = 0,
  error_message = NULL,
  processed_at = NULL
WHERE status = 'failed';
```

**Status:** [ ] Done

### ✅ Step 4: Process Queue

Run:

```bash
./scripts/process-communication-queue-now.sh
```

Or use the interactive script:

```bash
./scripts/complete-email-setup.sh
```

**Status:** [ ] Done

### ✅ Step 5: Verify

1. **Check Resend Dashboard:**
   - Go to https://resend.com/emails
   - Should see NEW emails (recent timestamps)

2. **Check Queue Status:**
   ```sql
   SELECT status, COUNT(*) 
   FROM communication_queue 
   GROUP BY status;
   ```
   - Should show items moved from "pending" → "sent"

3. **Check Edge Function Logs:**
   - Supabase Dashboard → Edge Functions → `process-communication-queue` → Logs
   - Should see successful processing (no errors)

**Status:** [ ] Done

## Quick Reference

| Step | Action | How |
|------|--------|-----|
| 1 | Set API Key | Supabase Dashboard → Settings → Edge Functions → Secrets |
| 2 | Deploy Functions | `supabase functions deploy send-guest-communication && supabase functions deploy process-communication-queue` |
| 3 | Reset Items | SQL: `UPDATE communication_queue SET status = 'pending' WHERE status = 'failed';` |
| 4 | Process Queue | `./scripts/process-communication-queue-now.sh` |
| 5 | Verify | Check Resend dashboard and queue status |

## Or Use Interactive Script

```bash
./scripts/complete-email-setup.sh
```

This walks you through all steps interactively.

## Expected Results

After completing all steps:
- ✅ New emails appear in Resend dashboard
- ✅ Items are marked "sent" (not "failed")
- ✅ Guests receive emails
- ✅ No JSON parsing errors
- ✅ No "All email providers failed" errors

## Troubleshooting

### Still getting "All email providers failed"
- Verify RESEND_API_KEY is set correctly
- Check API key is valid at https://resend.com/emails
- Redeploy functions after setting secret

### Still "No pending communications"
- Items might still be "failed" - reset them again
- Check queue status: `SELECT status, COUNT(*) FROM communication_queue GROUP BY status;`

### JSON parsing errors
- Functions need to be deployed with the fix
- Run: `supabase functions deploy send-guest-communication`

