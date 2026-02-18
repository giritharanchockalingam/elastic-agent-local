# Fix: Resend API Key Not Accessible

## Problem
All emails are failing with: "All email providers failed. Found 1 integration(s): Resend (resend). Please check provider credentials in Third-Party Integrations or set RESEND_API_KEY environment variable."

This means the Edge Function can't access the Resend API key.

## Root Cause
The API key exists in the database, but:
1. The key might be invalid/expired
2. The key format might be wrong
3. The Edge Function can't read it properly from the database
4. The `RESEND_API_KEY` environment variable is not set

## Solution: Set RESEND_API_KEY as Supabase Secret (Recommended)

This is the most reliable method:

### Step 1: Get Your Resend API Key

1. Go to https://resend.com/api-keys
2. If you don't have one, create a new API key
3. Copy the key (starts with `re_...`)

### Step 2: Set as Supabase Secret

1. Go to Supabase Dashboard → Project Settings → Edge Functions
2. Click "Secrets" tab
3. Click "Add Secret"
4. Name: `RESEND_API_KEY`
5. Value: `your_resend_api_key_here` (paste the key)
6. Click "Save"

### Step 3: Redeploy Edge Functions

After setting the secret, redeploy the function:

```bash
supabase functions deploy send-guest-communication
```

Or it will pick up the secret automatically on next invocation.

### Step 4: Test

After setting the secret, test email sending:

```bash
./scripts/process-communication-queue-now.sh
```

## Alternative: Fix Database Credentials

If you prefer to use database credentials:

### Step 1: Check Current Credentials

Run `scripts/check-resend-credentials.sql` to see what's in the database.

### Step 2: Update Credentials

```sql
-- Update Resend integration with valid API key
UPDATE third_party_integrations
SET 
  credentials = '{"api_key": "your_resend_api_key_here"}'::jsonb,
  is_enabled = true,
  status = 'active',
  updated_at = NOW()
WHERE integration_type = 'email'
  AND provider = 'resend';
```

**Important:** Replace `your_resend_api_key_here` with your actual Resend API key.

## Verify API Key is Working

### Check Resend Dashboard

1. Go to https://resend.com/emails
2. Try sending a test email from the dashboard
3. If it works, the API key is valid

### Test via Edge Function

After setting the secret, check Edge Function logs:
- Go to Supabase Dashboard → Edge Functions → `send-guest-communication` → Logs
- Look for: `[sendViaResend] ✓ Email sent successfully`

## Common Issues

### Issue: "API key not found"

**Cause:** Credentials structure is wrong or key is missing

**Fix:** 
- Set `RESEND_API_KEY` as Supabase secret (recommended)
- Or update database credentials with correct structure: `{"api_key": "re_..."}`

### Issue: "domain is not verified"

**Cause:** Using a custom domain that's not verified in Resend

**Fix:**
- Verify domain at https://resend.com/domains
- Or use default `onboarding@resend.dev` for testing

### Issue: "only send testing emails to your own email address"

**Cause:** Resend free tier limitation

**Fix:**
- Verify a domain in Resend
- Or upgrade Resend plan
- For testing, send to your own email address

## Quick Fix

**Fastest solution:** Set `RESEND_API_KEY` as Supabase secret:

1. Get API key from https://resend.com/api-keys
2. Supabase Dashboard → Settings → Edge Functions → Secrets
3. Add: `RESEND_API_KEY` = `your_key`
4. Test again

This bypasses database credential issues and is more reliable.

