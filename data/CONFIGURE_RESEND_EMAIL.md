# Configure Resend Email Service

## Current Status
✅ The system is correctly detecting email failures  
❌ Resend integration exists but credentials are missing/invalid

## Solution: Configure Resend API Key

You have two options:

### Option 1: Set as Supabase Secret (Recommended)

1. **Get Resend API Key:**
   - Go to https://resend.com
   - Sign up or log in
   - Go to API Keys section
   - Create a new API key
   - Copy the key (starts with `re_...`)

2. **Set as Supabase Secret:**
   - Go to Supabase Dashboard → Project Settings → Edge Functions
   - Click "Secrets" tab
   - Click "Add Secret"
   - Name: `RESEND_API_KEY`
   - Value: `your_resend_api_key_here`
   - Click "Save"

3. **Redeploy Edge Functions (if needed):**
   ```bash
   supabase functions deploy send-guest-communication
   ```

### Option 2: Update Database Integration

1. **Get Resend API Key** (same as above)

2. **Update Integration in Database:**
   ```sql
   -- Update existing Resend integration
   UPDATE third_party_integrations
   SET 
     credentials = '{"api_key": "your_resend_api_key_here"}'::jsonb,
     is_enabled = true,
     status = 'active',
     updated_at = NOW()
   WHERE integration_type = 'email'
     AND provider = 'resend';
   ```

   Or use the script: `scripts/fix-resend-integration.sql`

## After Configuration

### 1. Reset Failed Communications

```sql
-- Reset failed communications to retry
UPDATE communication_queue
SET status = 'pending',
    attempts = 0,
    error_message = NULL,
    processed_at = NULL
WHERE status = 'failed'
  AND error_message LIKE '%Resend%';
```

### 2. Process Queue Again

```bash
./scripts/process-communication-queue-now.sh
```

Or wait for the scheduled job (runs every 5 minutes).

### 3. Verify Emails Are Sending

```sql
-- Check email_log table (if it exists)
SELECT 
  COUNT(*) as sent_emails,
  MAX(created_at) as last_email_sent
FROM email_log
WHERE status = 'sent'
  AND created_at >= NOW() - INTERVAL '1 hour';
```

## Testing

### Test Email Sending Directly

You can test by calling the function directly:

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "property_id": "your-property-id",
    "guest_id": "your-guest-id",
    "message_type": "email",
    "subject": "Test Email",
    "message": "<h1>Test Email</h1><p>This is a test.</p>"
  }' \
  "https://YOUR_PROJECT.supabase.co/functions/v1/send-guest-communication"
```

## Resend Domain Setup

### For Testing (Default)
- Uses `onboarding@resend.dev` (works immediately, but emails may go to spam)

### For Production (Recommended)
1. **Verify Your Domain:**
   - Go to Resend Dashboard → Domains
   - Add your domain (e.g., `yourdomain.com`)
   - Add DNS records (SPF, DKIM) as shown
   - Wait for verification

2. **Update Configuration:**
   ```sql
   UPDATE third_party_integrations
   SET configuration = '{"from_email": "noreply@yourdomain.com", "from_name": "Your Hotel Name"}'::jsonb
   WHERE integration_type = 'email'
     AND provider = 'resend';
   ```

## Troubleshooting

### Issue: Still getting "All email providers failed"

1. **Check API Key:**
   ```sql
   SELECT 
     credentials::jsonb->>'api_key' as api_key_preview
   FROM third_party_integrations
   WHERE integration_type = 'email'
     AND provider = 'resend';
   ```
   - Should show your API key (masked)

2. **Check Edge Function Logs:**
   - Go to Supabase Dashboard → Edge Functions → `send-guest-communication`
   - Check "Logs" tab for specific errors

3. **Verify API Key is Valid:**
   - Test at https://resend.com/emails
   - Try sending a test email from Resend dashboard

### Issue: Emails Going to Spam

- Use verified domain (not `onboarding@resend.dev`)
- Set up SPF/DKIM records
- Use proper from_email format

### Issue: Rate Limits

Resend free tier: 100 emails/day, 3,000/month
- Check usage at Resend dashboard
- Upgrade if needed

## Quick Setup Checklist

- [ ] Sign up at Resend.com
- [ ] Get API key
- [ ] Set `RESEND_API_KEY` as Supabase secret OR update database integration
- [ ] Reset failed communications
- [ ] Process queue again
- [ ] Verify emails are sending
- [ ] (Optional) Verify domain for production

## Next Steps

After configuring:
1. Reset failed communications (SQL above)
2. Run queue processor again
3. Check `email_log` table to verify emails are being sent
4. Check guest inboxes (and spam folders)

