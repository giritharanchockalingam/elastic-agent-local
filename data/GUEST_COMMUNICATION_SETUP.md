# Guest Communication Setup Guide

This guide explains how to configure and use the Guest Communication system with 3rd party providers for Email, SMS, and WhatsApp.

## Overview

The Guest Communication system supports multiple providers for each communication channel:

- **Email**: SendGrid, Resend, AWS SES
- **SMS**: Twilio, AWS SNS, MSG91
- **WhatsApp**: Twilio WhatsApp API

## Quick Start

### 1. Configure Providers

Navigate to **Third-Party Integrations** (`/third-party-integrations`) and click the appropriate button:
- **Email** - Configure email providers
- **SMS** - Configure SMS providers
- **WhatsApp** - Configure WhatsApp providers

### 2. Send Messages

Go to **Guest Communication** (`/guest-communication`) and:
1. Click "Send Message"
2. Select a guest
3. Choose message type (Email, SMS, or WhatsApp)
4. Enter subject (for email) and message
5. Click "Send Message"

## Provider Configuration

### Email Providers

#### Resend

**⚠️ Important Limitations:**
- **Free/Testing Tier**: Can only send emails to the account owner's email address
- **Production Use**: Requires domain verification to send to any recipient
- **Domain Verification**: Go to https://resend.com/domains to verify your domain

**Setup Steps:**

1. Sign up at [resend.com](https://resend.com)
2. Get your API key from the dashboard
3. For **Testing**: The system automatically uses `onboarding@resend.dev` (only works for account owner's email)
4. For **Production**: 
   - Verify your domain at https://resend.com/domains
   - Configure in Third-Party Integrations:
     - **Provider**: Resend
     - **API Key**: Your Resend API key
     - **From Email**: Your verified domain email (e.g., `noreply@yourdomain.com`)
     - **From Name**: Display name (e.g., "Hotel Management")

**Note**: If you're on the free tier and need to send to guests immediately, use **SMS or WhatsApp** instead (they don't have this limitation).

#### SendGrid
1. Sign up at [sendgrid.com](https://sendgrid.com)
2. Create an API key with "Mail Send" permissions
3. Configure in Third-Party Integrations:
   - **Provider**: SendGrid
   - **API Key**: Your SendGrid API key
   - **From Email**: Verified sender email
   - **From Name**: Display name

#### AWS SES
1. Set up AWS SES in your AWS account
2. Verify your sender email/domain
3. Create IAM credentials with SES permissions
4. Configure in Third-Party Integrations:
   - **Provider**: AWS SES
   - **Access Key ID**: AWS access key
   - **Secret Access Key**: AWS secret key
   - **Region**: AWS region (e.g., `us-east-1`)

### SMS Providers

#### Twilio
1. Sign up at [twilio.com](https://twilio.com)
2. Get your Account SID and Auth Token from the dashboard
3. Purchase a phone number or use a trial number
4. Configure in Third-Party Integrations:
   - **Provider**: Twilio
   - **Account SID**: Your Twilio Account SID
   - **Auth Token**: Your Twilio Auth Token
   - **Phone Number**: Your Twilio phone number (e.g., `+1234567890`)

#### MSG91 (India)
1. Sign up at [msg91.com](https://msg91.com)
2. Get your API key from the dashboard
3. Configure in Third-Party Integrations:
   - **Provider**: MSG91
   - **API Key**: Your MSG91 API key
   - **Sender ID**: Your registered sender ID (e.g., `HOTEL`)
   - **Template ID**: Template ID if using DLT (optional)

#### AWS SNS
1. Set up AWS SNS in your AWS account
2. Configure in Third-Party Integrations:
   - **Provider**: AWS SNS
   - **Access Key ID**: AWS access key
   - **Secret Access Key**: AWS secret key
   - **Region**: AWS region

### WhatsApp Providers

#### Twilio WhatsApp API
1. Sign up at [twilio.com](https://twilio.com)
2. Get your Account SID and Auth Token
3. Enable WhatsApp in Twilio Console
4. Use Twilio's sandbox number or get your WhatsApp Business number approved
5. Configure in Third-Party Integrations:
   - **Provider**: Twilio
   - **Account SID**: Your Twilio Account SID
   - **Auth Token**: Your Twilio Auth Token
   - **WhatsApp Number**: `whatsapp:+14155238886` (sandbox) or your approved number

**Note**: Twilio WhatsApp sandbox allows testing with pre-approved numbers. For production, you need to get your WhatsApp Business number approved by Twilio.

## Environment Variables / Secrets

### Setting Secrets for Edge Functions

Edge Function secrets are set using the **Supabase CLI**, not through the dashboard. Here's how:

#### Step 1: Install Supabase CLI (if not already installed)

```bash
npm install -g supabase
# or use npx (no global install needed)
npx supabase --version
```

#### Step 2: Login to Supabase

```bash
npx supabase login
```

This will open your browser to authenticate.

#### Step 3: Link Your Project

```bash
# Navigate to your project root
cd /Users/giritharanchockalingam/Desktop/GitHub/hms-gcp-refactor

# Link to your Supabase project (your project ref is: qnwsnrfcnonaxvnithfv)
npx supabase link --project-ref qnwsnrfcnonaxvnithfv
```

#### Step 4: Set the Service Role Key Secret (REQUIRED)

This is required for the Edge Function to log communications:

```bash
# Get your Service Role Key from:
# Dashboard → Settings → API → service_role key (click "Reveal")

# Set it as a secret for Edge Functions
# Note: Supabase CLI doesn't allow secrets starting with SUPABASE_, so we use SERVICE_ROLE_KEY
npx supabase secrets set SERVICE_ROLE_KEY=your-service-role-key-here
```

**Important:** 
- Replace `your-service-role-key-here` with your actual service role key from:
  1. Go to [Supabase Dashboard](https://app.supabase.com)
  2. Select your project
  3. Go to **Settings** → **API**
  4. Find **"service_role"** key (⚠️ Keep this secret!)
  5. Click **"Reveal"** to show it
  6. Copy the entire key (starts with `eyJ...`)
- **Note:** Supabase CLI doesn't allow environment variable names starting with `SUPABASE_`, so we use `SERVICE_ROLE_KEY` instead

#### Step 5: Set Provider Secrets (Optional - Fallback Only)

These are optional and only used if no integrations are configured in the database:

```bash
# Email (Resend fallback)
npx supabase secrets set RESEND_API_KEY=your-resend-api-key

# SMS (Twilio fallback)
npx supabase secrets set TWILIO_ACCOUNT_SID=your-account-sid
npx supabase secrets set TWILIO_AUTH_TOKEN=your-auth-token
npx supabase secrets set TWILIO_PHONE_NUMBER=+1234567890

# WhatsApp (Twilio fallback)
npx supabase secrets set TWILIO_WHATSAPP_NUMBER=whatsapp:+14155238886
```

#### Step 6: Verify Secrets

```bash
# List all secrets (values are hidden for security)
npx supabase secrets list
```

#### Step 7: Redeploy the Edge Function

After setting secrets, redeploy the function:

```bash
npx supabase functions deploy send-guest-communication
```

**Note:** The CLI method (`supabase secrets set`) is the standard and most reliable way to set Edge Function secrets. The Supabase dashboard does not have a UI for setting Edge Function secrets - they must be set via CLI.

## How It Works

1. **Message Sending**: When you send a message from Guest Communication:
   - The frontend calls the `send-guest-communication` Edge Function
   - The function looks up configured providers for the message type
   - It tries providers in order until one succeeds
   - If database providers fail, it falls back to environment variables

2. **Logging**: All communications are logged in:
   - `guest_communication` table - General communication log
   - `email_log` table - Email-specific logs (for email messages)
   - `sms_log` table - SMS/WhatsApp logs (for SMS and WhatsApp messages)

3. **Status Tracking**: Messages are tracked with statuses:
   - `sent` - Successfully sent to provider
   - `delivered` - Delivered to recipient (if provider supports tracking)
   - `read` - Read by recipient (if provider supports tracking)
   - `failed` - Failed to send

## Testing

### Test Email
1. Configure Resend or SendGrid
2. Go to Guest Communication
3. Select a guest with a valid email
4. Choose "Email" as message type
5. Enter subject and message
6. Click "Send Message"

### Test SMS
1. Configure Twilio
2. Go to Guest Communication
3. Select a guest with a valid phone number
4. Choose "SMS" as message type
5. Enter message (no subject needed)
6. Click "Send Message"

### Test WhatsApp
1. Configure Twilio WhatsApp
2. Add your phone number to Twilio WhatsApp sandbox (send `join <code>` to the sandbox number)
3. Go to Guest Communication
4. Select a guest with a valid phone number
5. Choose "WhatsApp" as message type
6. Enter message
7. Click "Send Message"

## Troubleshooting

### Messages Not Sending

1. **Check Provider Configuration**:
   - Go to Third-Party Integrations
   - Verify the provider is enabled (`is_enabled = true`)
   - Check credentials are correct

2. **Check Edge Function Logs**:
   - Go to Supabase Dashboard → Edge Functions → Logs
   - Look for `send-guest-communication` function logs
   - Check for error messages

3. **Check Guest Information**:
   - For email: Guest must have a valid email address
   - For SMS/WhatsApp: Guest must have a valid phone number

4. **Check Provider Limits**:
   - Twilio trial accounts have limits
   - Resend free tier has limits
   - Check your provider dashboard for quota/limits

### Common Errors

- **"Provider not configured"**: Add the provider in Third-Party Integrations
- **"Guest phone number not found"**: Ensure guest has a phone number
- **"All providers failed"**: Check provider credentials and network connectivity
- **"Invalid phone number format"**: Ensure phone numbers include country code (e.g., `+1234567890`)

## Best Practices

1. **Use Test Mode**: Enable "Test Mode" when configuring new providers to avoid sending real messages
2. **Verify Credentials**: Test each provider after configuration
3. **Monitor Logs**: Regularly check communication logs for failures
4. **Provider Redundancy**: Configure multiple providers for the same type for failover
5. **Rate Limiting**: Be aware of provider rate limits and implement queuing if needed
6. **Compliance**: Ensure you comply with SMS/WhatsApp regulations (opt-in, opt-out, etc.)

## API Usage

You can also send communications programmatically:

```typescript
const { data, error } = await supabase.functions.invoke('send-guest-communication', {
  body: {
    property_id: 'your-property-id',
    guest_id: 'guest-uuid',
    message_type: 'email', // or 'sms' or 'whatsapp'
    subject: 'Welcome to our hotel', // required for email
    message: 'Your message here',
    priority: 'normal', // or 'high' or 'urgent'
  },
});
```

## Support

For issues or questions:
1. Check the Edge Function logs in Supabase Dashboard
2. Verify provider credentials
3. Test with a simple message first
4. Check provider status pages for outages

