# Diagnose: No Emails Received

## Problem
Queue processor says "No pending communications" but no emails were received.

## Possible Causes

1. **Items are still marked as "failed"** (not reset to pending)
2. **Items were processed but emails failed silently**
3. **Emails are being sent but going to spam**
4. **Email service not configured correctly**

## Diagnosis Steps

### Step 1: Check Queue Status

Run this SQL in Supabase SQL Editor:

```sql
-- Check communication queue status
SELECT 
  status,
  COUNT(*) as count
FROM communication_queue
GROUP BY status;
```

**Expected:** Should see items in "pending" or "failed" status.

**If all are "sent":** They were processed but emails might have failed.

**If all are "failed":** Need to reset them to pending.

### Step 2: Check Email Logs

```sql
-- Check if emails were actually sent
SELECT 
  COUNT(*) as total_emails,
  COUNT(CASE WHEN status = 'sent' THEN 1 END) as sent_count,
  COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_count
FROM email_log
WHERE created_at >= NOW() - INTERVAL '24 hours';
```

**If email_log is empty:** Emails are NOT being sent (email service not working).

**If email_log has entries:** Check the status and error messages.

### Step 3: Check Resend Configuration

```sql
-- Check Resend integration
SELECT 
  is_enabled,
  status,
  CASE 
    WHEN credentials::jsonb ? 'api_key' 
      AND (credentials::jsonb->>'api_key') IS NOT NULL 
      AND (credentials::jsonb->>'api_key') != ''
    THEN '✅ API key configured'
    ELSE '❌ API key missing or invalid'
  END as api_key_status
FROM third_party_integrations
WHERE integration_type = 'email'
  AND provider = 'resend';
```

## Solutions

### Solution 1: Reset Failed Communications

If items are marked "failed", reset them:

```sql
-- Reset failed communications
UPDATE communication_queue
SET status = 'pending',
    attempts = 0,
    error_message = NULL,
    processed_at = NULL
WHERE status = 'failed'
  AND attempts < COALESCE(max_attempts, 3);
```

### Solution 2: Verify Resend API Key

1. **Check if API key is set:**
   ```sql
   SELECT 
     credentials::jsonb->>'api_key' as api_key_preview
   FROM third_party_integrations
   WHERE integration_type = 'email'
     AND provider = 'resend';
   ```

2. **If missing, set it:**
   - Option A: Supabase Secret (recommended)
     - Dashboard → Settings → Edge Functions → Secrets
     - Add: `RESEND_API_KEY` = `your_key`
   
   - Option B: Database
     ```sql
     UPDATE third_party_integrations
     SET credentials = '{"api_key": "your_resend_api_key"}'::jsonb
     WHERE integration_type = 'email'
       AND provider = 'resend';
     ```

### Solution 3: Check Edge Function Logs

1. Go to Supabase Dashboard → Edge Functions → `send-guest-communication`
2. Click "Logs" tab
3. Look for errors like:
   - "API key not found"
   - "Invalid API key"
   - "Rate limit exceeded"

### Solution 4: Test Email Sending Directly

Test if Resend is working:

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "property_id": "your-property-id",
    "guest_id": "your-guest-id",
    "message_type": "email",
    "subject": "Test Email",
    "message": "<h1>Test</h1><p>This is a test email.</p>"
  }' \
  "https://YOUR_PROJECT.supabase.co/functions/v1/send-guest-communication"
```

Check the response - should have `"success": true` if email was sent.

### Solution 5: Check Resend Dashboard

1. Go to https://resend.com/emails
2. Check if emails are being sent
3. Check for any errors or rate limits

## Quick Fix Script

Run this to reset and retry:

```sql
-- 1. Reset failed communications
UPDATE communication_queue
SET status = 'pending',
    attempts = 0,
    error_message = NULL,
    processed_at = NULL
WHERE status = 'failed'
  AND attempts < COALESCE(max_attempts, 3);

-- 2. Verify Resend is configured
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM third_party_integrations
      WHERE integration_type = 'email'
        AND provider = 'resend'
        AND is_enabled = true
        AND credentials::jsonb ? 'api_key'
        AND (credentials::jsonb->>'api_key') IS NOT NULL
        AND (credentials::jsonb->>'api_key') != ''
    ) THEN '✅ Resend configured'
    WHEN EXISTS (
      SELECT 1 FROM pg_settings 
      WHERE name = 'resend_api_key'
    ) THEN '✅ Resend API key in environment'
    ELSE '❌ Resend NOT configured - need to set API key'
  END as resend_status;
```

Then process the queue again.

## Common Issues

### Issue: "No pending communications" but items exist

**Cause:** Items might be:
- Scheduled for future (`scheduled_at > NOW()`)
- Exceeded max attempts
- In wrong status

**Fix:**
```sql
-- Check why items aren't pending
SELECT 
  id,
  status,
  scheduled_at,
  attempts,
  max_attempts,
  CASE 
    WHEN scheduled_at > NOW() THEN 'Scheduled for future'
    WHEN attempts >= COALESCE(max_attempts, 3) THEN 'Exceeded max attempts'
    WHEN status != 'pending' THEN 'Wrong status: ' || status
    ELSE 'Should be processable'
  END as issue
FROM communication_queue
WHERE status IN ('pending', 'failed')
LIMIT 10;
```

### Issue: Emails sent but not received

**Possible causes:**
1. Going to spam folder
2. Wrong email address
3. Email service issue

**Check:**
```sql
-- Verify guest emails
SELECT 
  g.email,
  g.first_name,
  g.last_name,
  COUNT(*) as communication_count
FROM communication_queue cq
JOIN guests g ON cq.guest_id = g.id
WHERE cq.status = 'sent'
GROUP BY g.email, g.first_name, g.last_name;
```

## Next Steps

1. Run `scripts/check-email-status.sql` to diagnose
2. Fix any issues found
3. Reset failed communications
4. Process queue again
5. Check email_log table to verify emails are being sent
6. Check Resend dashboard to confirm delivery

