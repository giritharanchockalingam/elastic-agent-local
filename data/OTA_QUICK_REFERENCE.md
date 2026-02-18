# OTA Integration Quick Reference Card

## 🚀 Essential URLs

### Edge Function Endpoints
```
Expedia API:         https://YOUR_PROJECT.supabase.co/functions/v1/expedia-api
Expedia Webhook:     https://YOUR_PROJECT.supabase.co/functions/v1/expedia-webhook
Booking.com API:     https://YOUR_PROJECT.supabase.co/functions/v1/bookingcom-api
Booking.com Webhook: https://YOUR_PROJECT.supabase.co/functions/v1/bookingcom-webhook
```

---

## 📋 Quick Setup Commands

### Deploy Database
```bash
supabase db push
```

### Deploy Functions
```bash
supabase functions deploy expedia-api
supabase functions deploy expedia-webhook
supabase functions deploy bookingcom-api
supabase functions deploy bookingcom-webhook
```

---

## 🔑 Configuration Templates

### Expedia Configuration (SQL)
```sql
INSERT INTO ota_configurations (
    property_id, provider, integration_name,
    credentials, configuration,
    is_active, is_test_mode, status
) VALUES (
    'PROPERTY_UUID', 'expedia', 'Expedia Partner Solutions',
    jsonb_build_object(
        'api_key', 'YOUR_KEY',
        'api_secret', 'YOUR_SECRET',
        'ean_hotel_id', 'YOUR_HOTEL_ID'
    ),
    jsonb_build_object('test_mode', true, 'sync_enabled', true),
    true, true, 'active'
);
```

### Booking.com Configuration (SQL)
```sql
INSERT INTO ota_configurations (
    property_id, provider, integration_name,
    credentials, configuration,
    is_active, is_test_mode, status
) VALUES (
    'PROPERTY_UUID', 'booking_com', 'Booking.com Connectivity',
    jsonb_build_object(
        'api_key', 'YOUR_KEY',
        'hotel_id', 'YOUR_HOTEL_ID',
        'username', 'YOUR_USERNAME',
        'password', 'YOUR_PASSWORD'
    ),
    jsonb_build_object('test_mode', true, 'sync_enabled', true),
    true, true, 'active'
);
```

---

## 🧪 Quick Test Commands

### Test Expedia API
```bash
curl -X POST 'https://YOUR_PROJECT.supabase.co/functions/v1/expedia-api' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "checkAvailability",
    "property_id": "UUID",
    "params": {
      "start_date": "2025-01-15",
      "end_date": "2025-01-17"
    }
  }'
```

### Test Webhook
```bash
curl -X POST 'https://YOUR_PROJECT.supabase.co/functions/v1/expedia-webhook' \
  -H 'Content-Type: application/json' \
  -d '{
    "event_type": "booking.created",
    "hotel_id": "YOUR_HOTEL_ID",
    "booking": {
      "booking_id": "TEST-001",
      "check_in": "2025-01-15",
      "check_out": "2025-01-17",
      "guest": {"first_name": "John", "last_name": "Doe"},
      "total_amount": 450
    }
  }'
```

---

## 📊 Monitoring Queries

### Check Recent Bookings
```sql
SELECT 
    provider, external_booking_id, guest_name,
    check_in_date, total_amount, booking_status
FROM ota_bookings
ORDER BY created_at DESC
LIMIT 10;
```

### Check Sync Status
```sql
SELECT 
    provider, sync_type, status,
    records_processed, started_at
FROM ota_sync_logs
ORDER BY started_at DESC
LIMIT 10;
```

### Check Webhook Logs
```sql
SELECT 
    provider, event_type, processing_status,
    received_at, processing_error
FROM ota_webhooks
ORDER BY received_at DESC
LIMIT 10;
```

---

## 🔧 Common Troubleshooting

### Webhook Not Working?
1. Check webhook URL is correct
2. Verify it's configured in OTA dashboard
3. Check logs: `supabase functions logs expedia-webhook`
4. Test manually with curl

### Rates Not Syncing?
1. Check rate mappings exist
2. Verify credentials are correct
3. Check sync logs for errors
4. Try manual push

### Bookings Not Appearing?
1. Check webhook logs
2. Verify property mapping
3. Check OTA configuration is active
4. Test with manual webhook POST

---

## 📚 Documentation Index

| Document | Purpose | Audience |
|----------|---------|----------|
| `OTA_IMPLEMENTATION_COMPLETE_SUMMARY.md` | Overview & summary | All |
| `OTA_PORTAL_ACTIVATION_STEP_BY_STEP.md` | Implementation roadmap | Developers |
| `OTA_DEPLOYMENT_TESTING_GUIDE.md` | Deploy & test | DevOps |
| `EXPEDIA_SETUP_GUIDE.md` | Setup Expedia | Property Owners |
| `BOOKINGCOM_SETUP_GUIDE.md` | Setup Booking.com | Property Owners |
| `OTA_QUICK_REFERENCE.md` | Quick reference | All (this doc) |

---

## ⚡ Sync Settings

| Setting | Default | Recommended |
|---------|---------|-------------|
| Rate Sync | 15 min | 15-30 min |
| Inventory Sync | 5 min | 5-10 min |
| Booking Sync | Webhook | Webhook (instant) |
| Content Sync | Daily | Daily/Weekly |

---

## 📞 Support Contacts

**Expedia**: lxapi@expedia.com  
**Booking.com**: connectivity@booking.com  
**Supabase**: https://supabase.com/support

---

**Version**: 1.0 | **Updated**: Dec 26, 2024
