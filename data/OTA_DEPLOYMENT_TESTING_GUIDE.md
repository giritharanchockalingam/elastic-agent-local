# OTA Portal Deployment & Testing Guide

## 🎯 Overview

This guide covers how to deploy the OTA integration components and test them thoroughly before going live with Expedia and Booking.com.

---

## 📋 Prerequisites

Before deployment, ensure you have:

- [ ] Supabase project created
- [ ] Database migrated with OTA schema
- [ ] Supabase CLI installed (`npm install -g supabase`)
- [ ] Git repository set up
- [ ] API credentials from Expedia (for testing)
- [ ] API credentials from Booking.com (for testing)

---

## 🚀 DEPLOYMENT STEPS

### STEP 1: Deploy Database Migration

#### 1.1: Connect to Supabase
```bash
# Initialize Supabase (if not already done)
cd /path/to/hms-gcp-refactor
supabase init

# Link to your Supabase project
supabase link --project-ref YOUR_PROJECT_REF
```

#### 1.2: Apply Migration
```bash
# Apply the OTA portal enablement migration
supabase db push

# Or manually run the SQL
# Copy contents of supabase/migrations/20251226_ota_portal_enablement.sql
# Paste into Supabase Dashboard → SQL Editor → Run
```

#### 1.3: Verify Tables Created
```sql
-- Run in Supabase SQL Editor
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name LIKE 'ota%';

-- Expected output:
-- ota_configurations
-- ota_bookings
-- ota_sync_logs
-- ota_property_content
-- ota_rate_mappings
-- ota_inventory_sync
-- ota_webhooks
```

---

### STEP 2: Deploy Edge Functions

#### 2.1: Deploy Expedia API Function
```bash
# Deploy the Expedia API edge function
supabase functions deploy expedia-api

# Expected output:
# ✓ Deployed function expedia-api
# URL: https://your-project.supabase.co/functions/v1/expedia-api
```

#### 2.2: Deploy Expedia Webhook Function
```bash
# Deploy the webhook handler
supabase functions deploy expedia-webhook

# URL: https://your-project.supabase.co/functions/v1/expedia-webhook
```

#### 2.3: Deploy Booking.com API Function
```bash
# Deploy the Booking.com API edge function
supabase functions deploy bookingcom-api

# URL: https://your-project.supabase.co/functions/v1/bookingcom-api
```

#### 2.4: Deploy Booking.com Webhook Function
```bash
# Deploy the webhook handler
supabase functions deploy bookingcom-webhook

# URL: https://your-project.supabase.co/functions/v1/bookingcom-webhook
```

#### 2.5: Verify Deployments
```bash
# List all deployed functions
supabase functions list

# Expected output:
# expedia-api
# expedia-webhook
# bookingcom-api
# bookingcom-webhook
```

---

### STEP 3: Set Environment Variables

#### 3.1: Required Environment Variables
```bash
# In Supabase Dashboard → Settings → Edge Functions

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

---

### STEP 4: Configure OTA Credentials

#### 4.1: Insert Expedia Configuration
```sql
-- Run in Supabase SQL Editor
-- Replace with your actual credentials

INSERT INTO ota_configurations (
    property_id,
    provider,
    integration_name,
    credentials,
    configuration,
    is_active,
    is_test_mode,
    status
) VALUES (
    'YOUR_PROPERTY_UUID',  -- Get from properties table
    'expedia',
    'Expedia Partner Solutions',
    jsonb_build_object(
        'api_key', 'YOUR_EXPEDIA_API_KEY',
        'api_secret', 'YOUR_EXPEDIA_API_SECRET',
        'ean_hotel_id', 'YOUR_EAN_HOTEL_ID'
    ),
    jsonb_build_object(
        'test_mode', true,
        'property_id', 'YOUR_PROPERTY_ID',
        'sync_enabled', true
    ),
    true,
    true,
    'active'
);
```

#### 4.2: Insert Booking.com Configuration
```sql
-- Run in Supabase SQL Editor
-- Replace with your actual credentials

INSERT INTO ota_configurations (
    property_id,
    provider,
    integration_name,
    credentials,
    configuration,
    is_active,
    is_test_mode,
    status
) VALUES (
    'YOUR_PROPERTY_UUID',  -- Same property or different
    'booking_com',
    'Booking.com Connectivity',
    jsonb_build_object(
        'api_key', 'YOUR_BOOKING_API_KEY',
        'partner_id', 'YOUR_PARTNER_ID',
        'hotel_id', 'YOUR_HOTEL_ID',
        'username', 'YOUR_USERNAME',
        'password', 'YOUR_PASSWORD'
    ),
    jsonb_build_object(
        'test_mode', true,
        'property_id', 'YOUR_PROPERTY_ID',
        'sync_enabled', true
    ),
    true,
    true,
    'active'
);
```

---

## 🧪 TESTING

### TEST 1: Database Connection

```sql
-- Verify configurations are stored
SELECT 
    id,
    provider,
    integration_name,
    is_active,
    is_test_mode,
    status
FROM ota_configurations;

-- Expected: 2 rows (Expedia and Booking.com)
```

---

### TEST 2: Test Expedia API Function

#### 2.1: Test Availability Check
```bash
# Using curl
curl -X POST 'https://your-project.supabase.co/functions/v1/expedia-api' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "checkAvailability",
    "property_id": "YOUR_PROPERTY_UUID",
    "params": {
      "start_date": "2025-01-15",
      "end_date": "2025-01-17"
    }
  }'

# Expected: JSON response with available rooms
```

#### 2.2: Test via Postman
```
POST https://your-project.supabase.co/functions/v1/expedia-api
Headers:
  Authorization: Bearer YOUR_ANON_KEY
  Content-Type: application/json
Body:
{
  "action": "checkAvailability",
  "property_id": "YOUR_PROPERTY_UUID",
  "params": {
    "start_date": "2025-01-15",
    "end_date": "2025-01-17"
  }
}
```

---

### TEST 3: Test Expedia Webhook

#### 3.1: Send Test Webhook
```bash
# Simulate Expedia webhook
curl -X POST 'https://your-project.supabase.co/functions/v1/expedia-webhook' \
  -H 'Content-Type: application/json' \
  -H 'x-expedia-signature: test-signature' \
  -d '{
    "event_type": "booking.created",
    "hotel_id": "YOUR_EAN_HOTEL_ID",
    "booking": {
      "booking_id": "TEST-BOOKING-001",
      "itinerary_id": "TEST-ITI-001",
      "status": "confirmed",
      "check_in": "2025-01-15",
      "check_out": "2025-01-17",
      "guest": {
        "first_name": "John",
        "last_name": "Doe",
        "email": "john.doe@example.com",
        "phone": "+1234567890"
      },
      "total_amount": 450.00,
      "currency": "USD"
    }
  }'

# Expected: { "success": true, "message": "Webhook processed successfully" }
```

#### 3.2: Verify Webhook Was Logged
```sql
-- Check webhook was received and processed
SELECT 
    event_type,
    processing_status,
    processed_at,
    payload
FROM ota_webhooks
WHERE provider = 'expedia'
ORDER BY received_at DESC
LIMIT 1;

-- Expected: 1 row with status 'processed'
```

#### 3.3: Verify Booking Was Created
```sql
-- Check booking was created from webhook
SELECT 
    external_booking_id,
    guest_name,
    check_in_date,
    check_out_date,
    total_amount,
    booking_status
FROM ota_bookings
WHERE provider = 'expedia'
AND external_booking_id = 'TEST-BOOKING-001';

-- Expected: 1 row with the test booking
```

---

### TEST 4: Test Booking.com API Function

```bash
# Test availability check
curl -X POST 'https://your-project.supabase.co/functions/v1/bookingcom-api' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "checkAvailability",
    "property_id": "YOUR_PROPERTY_UUID",
    "params": {
      "start_date": "2025-01-15",
      "end_date": "2025-01-17"
    }
  }'
```

---

### TEST 5: Test Booking.com Webhook

```bash
# Simulate Booking.com webhook
curl -X POST 'https://your-project.supabase.co/functions/v1/bookingcom-webhook' \
  -H 'Content-Type: application/json' \
  -d '{
    "event_type": "reservation.created",
    "hotel_id": "YOUR_HOTEL_ID",
    "reservation": {
      "reservation_id": "TEST-RES-001",
      "status": "confirmed",
      "check_in": "2025-01-15",
      "check_out": "2025-01-17",
      "guest": {
        "name": "Jane Smith",
        "email": "jane.smith@example.com"
      },
      "total_amount": 500.00,
      "currency": "EUR"
    }
  }'
```

---

### TEST 6: End-to-End Booking Flow

#### 6.1: Create Test Booking in Expedia
1. Use Expedia Partner Central test mode
2. Create a test reservation
3. Wait 5 seconds
4. Check HMS for booking

#### 6.2: Verify in Database
```sql
SELECT 
    COUNT(*) as total_bookings,
    SUM(total_amount) as total_revenue,
    provider
FROM ota_bookings
GROUP BY provider;
```

---

### TEST 7: Test Rate Sync

```bash
# Update rates in HMS and push to Expedia
curl -X POST 'https://your-project.supabase.co/functions/v1/expedia-api' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "updateRates",
    "property_id": "YOUR_PROPERTY_UUID",
    "params": {
      "rates": [
        {
          "room_type_id": "ROOM_TYPE_ID",
          "rate_plan_id": "RATE_PLAN_ID",
          "start_date": "2025-01-15",
          "end_date": "2025-01-31",
          "base_rate": 199.99,
          "currency": "USD"
        }
      ]
    }
  }'
```

---

### TEST 8: Test Inventory Sync

```bash
# Update inventory
curl -X POST 'https://your-project.supabase.co/functions/v1/expedia-api' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "updateInventory",
    "property_id": "YOUR_PROPERTY_UUID",
    "params": {
      "inventory": [
        {
          "room_type_id": "ROOM_TYPE_ID",
          "date": "2025-01-15",
          "available_rooms": 10
        }
      ]
    }
  }'
```

---

## 📊 Monitoring & Verification

### Check Edge Function Logs

```bash
# View real-time logs for Expedia webhook
supabase functions logs expedia-webhook --follow

# View logs for all functions
supabase functions logs
```

### Monitor Sync Status

```sql
-- Check recent sync operations
SELECT 
    provider,
    sync_type,
    status,
    records_processed,
    started_at,
    completed_at,
    error_message
FROM ota_sync_logs
ORDER BY started_at DESC
LIMIT 20;
```

### Check Webhook Delivery

```sql
-- Monitor webhook processing
SELECT 
    provider,
    event_type,
    processing_status,
    received_at,
    processed_at,
    retry_count
FROM ota_webhooks
ORDER BY received_at DESC
LIMIT 10;
```

---

## ✅ Deployment Checklist

Before going live:

### Infrastructure
- [ ] Database migration applied successfully
- [ ] All edge functions deployed
- [ ] Environment variables configured
- [ ] OTA configurations inserted in database

### Expedia
- [ ] API function deployed and tested
- [ ] Webhook handler deployed and tested
- [ ] Test booking flow completed
- [ ] Webhook configured in Expedia Partner Central
- [ ] Rate sync tested
- [ ] Inventory sync tested

### Booking.com
- [ ] API function deployed and tested
- [ ] Webhook handler deployed and tested
- [ ] Test reservation flow completed
- [ ] Webhook configured in Booking.com Extranet
- [ ] Rate sync tested
- [ ] Availability sync tested

### Monitoring
- [ ] Logging is working
- [ ] Webhook logs are being created
- [ ] Sync logs are being created
- [ ] Error handling is working

---

## 🔧 Troubleshooting

### Edge Function Not Responding
```bash
# Check function status
supabase functions list

# View recent logs
supabase functions logs FUNCTION_NAME

# Redeploy if needed
supabase functions deploy FUNCTION_NAME --no-verify-jwt
```

### Database Connection Issues
```sql
-- Test database connection
SELECT NOW();

-- Check RLS policies
SELECT tablename, policyname, cmd, qual 
FROM pg_policies 
WHERE tablename LIKE 'ota%';
```

### Webhook Not Processing
- Verify webhook URL is correct
- Check function logs for errors
- Ensure payload format matches expected structure
- Verify database permissions (use service role key)

---

## 🎯 Next Steps

After successful deployment and testing:

1. **Switch to Production**
   - Update credentials to production
   - Change `is_test_mode` to `false`
   - Update webhook URLs in OTA dashboards

2. **Monitor Initial Bookings**
   - Watch for first real bookings
   - Verify data accuracy
   - Check sync performance

3. **Enable Automation**
   - Schedule rate sync jobs
   - Schedule inventory sync jobs
   - Set up alerts for failed syncs

4. **Train Staff**
   - Show how to view OTA bookings
   - Explain how to update rates/inventory
   - Train on troubleshooting common issues

---

**Deployment Complete!** 🎉

Your OTA integrations are now live and ready to receive bookings from Expedia and Booking.com.

---

**Document Version**: 1.0  
**Last Updated**: December 26, 2024
