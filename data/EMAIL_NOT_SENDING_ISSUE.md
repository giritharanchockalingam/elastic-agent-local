# Email Not Sending Issue

## Problem
Communications show status "sent" in the queue, but guests haven't received any emails.

## Root Cause
The system is marking communications as "sent" even when the email service fails. This happens when:
1. No email provider is configured (no Resend API key, no integrations)
2. Email service returns an error but the HTTP response is still 200
3. The function doesn't properly check if emails were actually sent

## Diagnosis

### Step 1: Check Email Service Configuration

Run this SQL to check if email integrations are configured:

```sql
-- Check email integrations
SELECT 
  id,
  integration_name,
  provider,
  integration_type,
  is_enabled,
  status,
  property_id,
  CASE 
    WHEN credentials IS NULL THEN '❌ No credentials'
    WHEN credentials::text = '{}' THEN '❌ Empty credentials'
    WHEN credentials::text = 'null' THEN '❌ Null credentials'
    ELSE '✅ Has credentials'
  END as credentials_status
FROM third_party_integrations
WHERE integration_type = 'email'
ORDER BY created_at DESC;
```

### Step 2: Check Edge Function Logs

1. Go to Supabase Dashboard → Edge Functions → `send-guest-communication`
2. Click on "Logs" tab
3. Look for errors like:
   - "No email integrations found"
   - "RESEND_API_KEY environment variable not set"
   - "All email providers failed"

### Step 3: Check Email Logs

```sql
-- Check if emails were actually logged
SELECT 
  id,
  recipient_email,
  subject,
  status,
  provider,
  provider_message_id,
  sent_at,
  error_message
FROM email_log
ORDER BY created_at DESC
LIMIT 20;
```

If `email_log` table doesn't exist or is empty, emails are NOT being sent.

## Solutions

### Solution 1: Configure Resend API Key (Recommended)

1. **Get Resend API Key:**
   - Sign up at https://resend.com
   - Go to API Keys section
   - Create a new API key
   - Copy the key

2. **Set as Supabase Secret:**
   - Go to Supabase Dashboard → Project Settings → Edge Functions
   - Click "Secrets"
   - Add secret: `RESEND_API_KEY` = `your_resend_api_key`

3. **Verify:**
   ```bash
   # Test the function
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

### Solution 2: Configure Email Integration in Database

```sql
-- Insert Resend integration
INSERT INTO third_party_integrations (
  integration_name,
  integration_type,
  provider,
  is_enabled,
  status,
  credentials,
  configuration
) VALUES (
  'Resend Email Service',
  'email',
  'resend',
  true,
  'active',
  '{"api_key": "your_resend_api_key_here"}'::jsonb,
  '{"from_email": "noreply@yourdomain.com", "from_name": "Hotel Name"}'::jsonb
);
```

### Solution 3: Check Function Response

The issue might be that `process-communication-queue` is checking HTTP status instead of the actual result. Let's verify:

```sql
-- Check recent communication queue items for errors
SELECT 
  id,
  reservation_id,
  communication_type,
  status,
  error_message,
  attempts,
  processed_at
FROM communication_queue
WHERE status = 'sent'
  AND processed_at IS NOT NULL
ORDER BY processed_at DESC
LIMIT 10;
```

If `error_message` is NULL but emails weren't sent, the function is incorrectly marking them as sent.

## Fix the Function

The `process-communication-queue` function needs to check the actual response from `send-guest-communication`:

```typescript
// Current (WRONG):
if (!response.ok) {
  throw new Error('Failed to send communication');
}
// Mark as sent even if email service failed

// Should be (CORRECT):
const responseData = await response.json();
if (!response.ok || !responseData.success) {
  throw new Error(responseData.error || 'Failed to send communication');
}
// Only mark as sent if responseData.success === true
```

## Quick Test

Test email sending directly:

```sql
-- Get a guest email
SELECT id, email, first_name, last_name
FROM guests
WHERE email IS NOT NULL
LIMIT 1;
```

Then call the function with that guest_id to see if it actually sends.

## Verification

After configuring email service:

1. **Check email_log table:**
   ```sql
   SELECT COUNT(*) as sent_emails
   FROM email_log
   WHERE status = 'sent'
     AND created_at >= NOW() - INTERVAL '1 hour';
   ```

2. **Check Resend dashboard:**
   - Go to https://resend.com/emails
   - Verify emails are being sent

3. **Check guest inbox:**
   - Check spam folder
   - Verify sender email is correct

## Common Issues

### Issue 1: Using Resend Default Domain
Resend's default domain (`onboarding@resend.dev`) only works for testing. For production:
- Verify your domain in Resend
- Update `from_email` in configuration

### Issue 2: Emails Going to Spam
- Use verified domain
- Set up SPF/DKIM records
- Use proper from_email format: `name@yourdomain.com`

### Issue 3: Function Returns Success But No Email
- Check `email_log` table - if empty, emails aren't being sent
- Check Edge Function logs for errors
- Verify API key is set correctly

