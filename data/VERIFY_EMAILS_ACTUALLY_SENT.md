# Verify if Emails Are Actually Being Sent

## Problem
80 communications show status "sent" but no emails are being received. Need to verify if emails are actually being sent or just marked as "sent".

## Diagnosis

### Step 1: Run Diagnostic Script

Run `scripts/verify-emails-actually-sent.sql` in Supabase SQL Editor.

This will show:
- If `email_log` table exists (logs actual email sends)
- Recent email activity from email_log
- Discrepancy between queue "sent" vs actual emails sent
- Recent "sent" items and whether they have corresponding email_log entries

### Step 2: Check Edge Function Logs

1. Go to Supabase Dashboard → Edge Functions → `send-guest-communication`
2. Click "Logs" tab
3. Look for:
   - `[sendEmail] Success with provider: resend` - Email actually sent
   - `[sendEmail] All providers failed` - Email NOT sent
   - `[sendViaResend] ✓ Email sent successfully` - Confirmation

### Step 3: Check Resend Dashboard

1. Go to https://resend.com/emails
2. Check if emails are actually being sent
3. Look for:
   - Sent emails count
   - Failed emails
   - Rate limits

## Expected Results

### If Emails Are Actually Being Sent:
- ✅ `email_log` table has entries with `status = 'sent'`
- ✅ Edge Function logs show "Email sent successfully"
- ✅ Resend dashboard shows sent emails
- ✅ Discrepancy = 0 (queue matches email_log)

### If Emails Are NOT Being Sent:
- ❌ `email_log` table is empty or has no recent entries
- ❌ Edge Function logs show "All providers failed"
- ❌ Resend dashboard shows no sent emails
- ❌ Discrepancy > 0 (queue has more "sent" than email_log)

## Solutions

### If Emails Are NOT Actually Being Sent:

1. **Check Resend API Key:**
   - Verify it's set correctly in Supabase Secrets
   - Test it in Resend dashboard

2. **Check Edge Function Response:**
   - The function might be returning `success: true` even when email fails
   - Check logs for actual error messages

3. **Reset and Retry:**
   ```sql
   -- Reset all "sent" items that don't have email_log entries
   UPDATE communication_queue
   SET 
     status = 'pending',
     attempts = 0,
     error_message = NULL,
     processed_at = NULL
   WHERE status = 'sent'
     AND processed_at IS NOT NULL
     AND NOT EXISTS (
       SELECT 1 FROM email_log el
       JOIN guests g ON el.recipient_email = g.email
       WHERE g.id = communication_queue.guest_id
       AND el.created_at >= communication_queue.processed_at - INTERVAL '1 minute'
     );
   ```

4. **Fix the Function:**
   - The `send-guest-communication` function should only return `success: true` if email was actually sent
   - Check if it's logging to `email_log` table correctly

## Quick Test

Test email sending directly:

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "property_id": "your-property-id",
    "guest_id": "your-guest-id",
    "message_type": "email",
    "subject": "Test Email",
    "message": "<h1>Test</h1>"
  }' \
  "https://YOUR_PROJECT.supabase.co/functions/v1/send-guest-communication"
```

Check the response - if `success: true` but no email arrives, the function is incorrectly reporting success.

## Next Steps

1. Run `scripts/verify-emails-actually-sent.sql`
2. Check Edge Function logs
3. Check Resend dashboard
4. Based on results, either:
   - Fix the function if it's incorrectly reporting success
   - Fix Resend configuration if emails are failing
   - Reset items and retry if they were incorrectly marked as sent

