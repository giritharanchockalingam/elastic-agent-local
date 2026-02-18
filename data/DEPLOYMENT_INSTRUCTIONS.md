# Guest Communication Deployment Instructions

## Overview

This document provides step-by-step instructions to deploy all required database operations and edge functions for complete guest communication automation.

## Prerequisites

- Supabase project access
- Supabase CLI installed and configured
- Database admin access
- Edge function deployment permissions

## Step 1: Deploy Database Migrations

### 1.1 Communication Queue and Triggers

Execute the following migration file:

```bash
# Using Supabase CLI
supabase db push

# Or manually in Supabase SQL Editor
# Copy and execute: supabase/migrations/20251226_complete_communication_setup.sql
```

**What it creates:**
- `communication_queue` table
- Automated booking communication triggers
- Payment communication triggers
- Communication processor function
- RLS policies

### 1.2 Verify Deployment

Run these queries in Supabase SQL Editor:

```sql
-- Check if communication_queue exists
SELECT EXISTS (
  SELECT 1 FROM information_schema.tables 
  WHERE table_name = 'communication_queue'
);

-- Check if triggers exist
SELECT tgname FROM pg_trigger 
WHERE tgname IN (
  'trigger_send_booking_confirmation',
  'trigger_send_booking_update',
  'trigger_send_payment_communication'
);

-- Check if functions exist
SELECT proname FROM pg_proc 
WHERE proname IN (
  'send_automated_booking_communication',
  'send_payment_communication',
  'process_communication_queue'
);
```

## Step 2: Deploy Edge Functions

### 2.1 Deploy booking-operations Function

```bash
cd supabase/functions/booking-operations
supabase functions deploy booking-operations
```

**Verify deployment:**
```bash
supabase functions list
# Should show: booking-operations
```

### 2.2 Deploy process-communication-queue Function

```bash
cd supabase/functions/process-communication-queue
supabase functions deploy process-communication-queue
```

**Verify deployment:**
```bash
supabase functions list
# Should show: process-communication-queue
```

### 2.3 Update send-checkin-email Function

```bash
cd supabase/functions/send-checkin-email
supabase functions deploy send-checkin-email
```

**Verify deployment:**
```bash
supabase functions list
# Should show: send-checkin-email (updated)
```

### 2.4 Verify send-guest-communication Function

```bash
# Check if already deployed
supabase functions list | grep send-guest-communication

# If not deployed or needs update:
cd supabase/functions/send-guest-communication
supabase functions deploy send-guest-communication
```

## Step 3: Set Up Scheduled Jobs

### 3.1 Communication Queue Processor

Set up a cron job to process the communication queue every 5 minutes:

**Option A: Using Supabase Cron (pg_cron extension)**

```sql
-- Enable pg_cron extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule communication queue processor
SELECT cron.schedule(
  'process-communication-queue',
  '*/5 * * * *', -- Every 5 minutes
  $$
  SELECT public.process_communication_queue();
  $$
);
```

**Option B: Using External Cron Service**

Set up a cron job that calls:
```
POST https://YOUR_PROJECT.supabase.co/functions/v1/process-communication-queue
Authorization: Bearer YOUR_SERVICE_ROLE_KEY
```

### 3.2 Check-in Reminders

Schedule daily check-in reminders:

```sql
SELECT cron.schedule(
  'send-checkin-reminders',
  '0 10 * * *', -- Daily at 10 AM
  $$
  SELECT public.send_checkin_reminders();
  $$
);
```

**Note:** You'll need to create the `send_checkin_reminders()` function or use the `auto-checkin-reminder` edge function.

### 3.3 Check-out Reminders

Schedule daily check-out reminders:

```sql
SELECT cron.schedule(
  'send-checkout-reminders',
  '0 18 * * *', -- Daily at 6 PM
  $$
  SELECT public.send_checkout_reminders();
  $$
);
```

## Step 4: Create Missing Email Templates

### 4.1 Check-in/Check-out Templates

If templates don't exist, create them:

```sql
-- For each property, insert check-in and check-out templates
INSERT INTO public.email_templates (
  property_id,
  template_code,
  template_name,
  subject,
  body_html,
  category,
  is_active,
  variables
) VALUES
(
  'YOUR_PROPERTY_ID',
  'checkin_confirmation',
  'Check-in Confirmation',
  'Check-in Confirmation - {{booking_number}}',
  '<!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
      <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
        <h1 style="color: #ffffff; margin: 0;">Welcome to {{hotel_name}}!</h1>
      </div>
      <div style="background-color: #ffffff; padding: 30px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 10px 10px;">
        <p>Dear {{guest_name}},</p>
        <p>Thank you for checking in. Here are your reservation details:</p>
        <div style="background-color: #f9fafb; padding: 25px; border-radius: 8px; margin: 25px 0;">
          <p><strong>Reservation Number:</strong> {{booking_number}}</p>
          <p><strong>Room:</strong> {{room_number}} ({{room_type}})</p>
          <p><strong>Check-In:</strong> {{check_in_date}}</p>
          <p><strong>Check-Out:</strong> {{check_out_date}}</p>
          <p><strong>Key Card Number:</strong> {{key_card_number}}</p>
        </div>
        <p>We hope you enjoy your stay with us!</p>
        <p>Best regards,<br><strong>{{hotel_name}} Team</strong></p>
      </div>
    </body>
  </html>',
  'booking',
  true,
  '["guest_name", "booking_number", "room_number", "room_type", "check_in_date", "check_out_date", "key_card_number", "hotel_name"]'::jsonb
),
(
  'YOUR_PROPERTY_ID',
  'checkout_confirmation',
  'Check-out Confirmation',
  'Check-out Confirmation - {{booking_number}}',
  '<!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
      <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
        <h1 style="color: #ffffff; margin: 0;">Thank You for Staying With Us!</h1>
      </div>
      <div style="background-color: #ffffff; padding: 30px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 10px 10px;">
        <p>Dear {{guest_name}},</p>
        <p>We hope you enjoyed your stay. Here is your check-out confirmation:</p>
        <div style="background-color: #f9fafb; padding: 25px; border-radius: 8px; margin: 25px 0;">
          <p><strong>Reservation Number:</strong> {{booking_number}}</p>
          <p><strong>Room:</strong> {{room_number}} ({{room_type}})</p>
          <p><strong>Check-Out Date:</strong> {{check_out_date}}</p>
        </div>
        <p>We look forward to welcoming you again!</p>
        <p>Best regards,<br><strong>{{hotel_name}} Team</strong></p>
      </div>
    </body>
  </html>',
  'booking',
  true,
  '["guest_name", "booking_number", "room_number", "room_type", "check_out_date", "hotel_name"]'::jsonb
)
ON CONFLICT (property_id, template_code, language) DO UPDATE
SET body_html = EXCLUDED.body_html,
    subject = EXCLUDED.subject,
    updated_at = NOW();
```

### 4.2 Payment Templates

Ensure payment templates exist:

```sql
-- Verify payment templates exist
SELECT template_code, template_name, is_active
FROM public.email_templates
WHERE template_code IN ('payment_received', 'payment_failed', 'refund_confirmation')
AND property_id = 'YOUR_PROPERTY_ID';
```

If missing, use the seed data from `docs/sql-fixes/SEED_EMAIL_TEMPLATES_COMPLETE.sql`

## Step 5: Test the System

### 5.1 Test Booking Creation

1. Create a test booking
2. Check `communication_queue` table for a new entry
3. Verify email is sent

```sql
-- Check communication queue
SELECT * FROM public.communication_queue
ORDER BY created_at DESC
LIMIT 10;

-- Check guest_communication log
SELECT * FROM public.guest_communication
ORDER BY sent_at DESC
LIMIT 10;
```

### 5.2 Test Payment Communication

1. Create a test payment
2. Update payment status to 'completed'
3. Check communication queue

```sql
-- Check payment communication
SELECT * FROM public.communication_queue
WHERE communication_type = 'payment_received'
ORDER BY created_at DESC
LIMIT 5;
```

### 5.3 Test Manual Queue Processing

```bash
# Call the queue processor manually
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/process-communication-queue \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json"
```

## Step 6: Monitor and Maintain

### 6.1 Monitor Communication Queue

```sql
-- Check queue status
SELECT 
  status,
  communication_type,
  COUNT(*) as count,
  MAX(created_at) as latest
FROM public.communication_queue
GROUP BY status, communication_type
ORDER BY latest DESC;
```

### 6.2 Check Failed Communications

```sql
-- Find failed communications
SELECT 
  id,
  communication_type,
  error_message,
  attempts,
  created_at
FROM public.communication_queue
WHERE status = 'failed'
ORDER BY created_at DESC
LIMIT 20;
```

### 6.3 Retry Failed Communications

```sql
-- Reset failed communications for retry (if needed)
UPDATE public.communication_queue
SET status = 'pending',
    attempts = 0,
    error_message = NULL,
    updated_at = NOW()
WHERE status = 'failed'
  AND attempts < max_attempts
  AND created_at > NOW() - INTERVAL '7 days';
```

## Troubleshooting

### Issue: Triggers not firing

**Solution:**
```sql
-- Check if triggers are enabled
SELECT tgname, tgenabled FROM pg_trigger 
WHERE tgname LIKE '%communication%';

-- Re-enable if disabled
ALTER TABLE public.reservations ENABLE TRIGGER trigger_send_booking_confirmation;
ALTER TABLE public.reservations ENABLE TRIGGER trigger_send_booking_update;
ALTER TABLE public.payments ENABLE TRIGGER trigger_send_payment_communication;
```

### Issue: Communication queue not processing

**Solution:**
- Verify `process-communication-queue` function is deployed
- Check scheduled job is running
- Manually trigger: `SELECT public.process_communication_queue();`

### Issue: Templates not found

**Solution:**
- Verify templates exist for your property_id
- Check template_code matches exactly
- Ensure `is_active = true`

## Validation Checklist

After deployment, verify:

- [ ] `communication_queue` table exists
- [ ] All triggers are created and enabled
- [ ] All edge functions are deployed
- [ ] Scheduled jobs are configured
- [ ] Email templates exist for all communication types
- [ ] Test booking creates queue entry
- [ ] Test payment creates queue entry
- [ ] Queue processor sends emails successfully
- [ ] Failed communications are logged properly

## Next Steps

1. Monitor communication queue for 24-48 hours
2. Review failed communications and fix issues
3. Adjust scheduled job frequency if needed
4. Set up alerts for high failure rates
5. Document any custom templates or configurations

