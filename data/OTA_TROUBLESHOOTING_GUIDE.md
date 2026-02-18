# OTA Integration Troubleshooting Guide

## 🎯 Overview

This guide provides solutions to common issues encountered when integrating with Expedia and Booking.com OTA platforms.

## 📋 Table of Contents

1. [Authentication Issues](#authentication-issues)
2. [API Connection Problems](#api-connection-problems)
3. [Rate Sync Issues](#rate-sync-issues)
4. [Inventory Sync Issues](#inventory-sync-issues)
5. [Webhook Problems](#webhook-problems)
6. [Booking Issues](#booking-issues)
7. [Performance Issues](#performance-issues)
8. [Common Error Codes](#common-error-codes)

---

## Authentication Issues

### Problem: 401 Unauthorized Error

**Symptoms**:
```
Error: 401 Unauthorized
Message: Invalid API credentials
```

**Solutions**:

1. **Verify API Credentials**
   ```sql
   -- Check stored credentials
   SELECT 
     provider,
     credentials,
     configuration
   FROM third_party_integrations
   WHERE provider IN ('expedia', 'booking.com');
   ```

2. **Check Environment**
   - Ensure using correct environment (sandbox vs production)
   - Verify credentials match environment

3. **Test Credentials**
   ```bash
   # Test Expedia
   curl -X GET \
     https://api.expediapartnercentral.com/v2/properties \
     -H "Authorization: Bearer YOUR_API_KEY"

   # Test Booking.com
   curl -X GET \
     https://supply-xml.booking.com/hotels/xml/auth \
     -H "X-Booking-API-Key: YOUR_API_KEY"
   ```

4. **Regenerate Credentials**
   - Log in to partner portal
   - Generate new API keys
   - Update in database and environment variables

### Problem: API Key Expired

**Symptoms**:
```
Error: 403 Forbidden
Message: API key has expired
```

**Solutions**:

1. **Check Expiration Date**
   ```sql
   SELECT 
     provider,
     created_at,
     DATE_PART('day', NOW() - created_at) as days_old
   FROM third_party_integrations
   WHERE provider IN ('expedia', 'booking.com');
   ```

2. **Rotate Credentials**
   ```typescript
   // Use credential rotation script
   npm run rotate-ota-credentials
   ```

---

## API Connection Problems

### Problem: Connection Timeout

**Symptoms**:
```
Error: ETIMEDOUT
Message: Connection timed out after 30000ms
```

**Solutions**:

1. **Check Network Connectivity**
   ```bash
   # Ping OTA APIs
   ping api.expediapartnercentral.com
   ping supply-xml.booking.com
   ```

2. **Verify Firewall Rules**
   - Ensure outbound HTTPS (443) is allowed
   - Check if OTA IP ranges are whitelisted

3. **Increase Timeout**
   ```typescript
   const expedia = new ExpediaComprehensiveAPI({
     // ...config
     timeout: 60000 // Increase to 60 seconds
   });
   ```

4. **Implement Retry Logic**
   ```typescript
   async function withRetry<T>(
     fn: () => Promise<T>,
     maxRetries = 3
   ): Promise<T> {
     for (let i = 0; i < maxRetries; i++) {
       try {
         return await fn();
       } catch (error) {
         if (i === maxRetries - 1) throw error;
         await sleep(1000 * Math.pow(2, i)); // Exponential backoff
       }
     }
     throw new Error('Max retries exceeded');
   }
   ```

### Problem: SSL Certificate Error

**Symptoms**:
```
Error: CERT_HAS_EXPIRED
Message: SSL certificate problem
```

**Solutions**:

1. **Update System Certificates**
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install ca-certificates

   # macOS
   brew update
   brew upgrade openssl
   ```

2. **Use Valid Certificate**
   - Ensure your webhook endpoint has valid SSL
   - Use Let's Encrypt for free SSL

---

## Rate Sync Issues

### Problem: Rates Not Updating on OTA

**Symptoms**:
- Rates updated in HMS but not on Expedia/Booking.com
- No error messages in logs

**Solutions**:

1. **Check Sync Logs**
   ```sql
   SELECT *
   FROM ota_sync_logs
   WHERE sync_type = 'rate'
     AND created_at > NOW() - INTERVAL '1 hour'
   ORDER BY created_at DESC
   LIMIT 50;
   ```

2. **Verify Property Mapping**
   ```sql
   SELECT 
     rt.name,
     opm.provider,
     opm.external_room_id
   FROM ota_property_mappings opm
   JOIN room_types rt ON rt.id = opm.internal_room_type_id
   WHERE opm.property_id = 'YOUR_PROPERTY_ID';
   ```

3. **Manual Rate Update**
   ```typescript
   // Force rate sync
   const rateSyncService = new RateSyncService();
   await rateSyncService.syncRateUpdate(
     propertyId,
     roomTypeId,
     ratePlanId,
     date,
     rate
   );
   ```

4. **Check OTA Rate Plan Status**
   - Verify rate plan is active in OTA portal
   - Check if rate plan has restrictions

### Problem: Rate Mismatch Between Channels

**Symptoms**:
- Different rates showing on Expedia vs Booking.com
- Rates don't match HMS

**Solutions**:

1. **Audit All Rates**
   ```sql
   -- Compare rates across channels
   WITH hms_rates AS (
     SELECT date, room_type_id, rate as hms_rate
     FROM room_rates
     WHERE property_id = 'YOUR_PROPERTY_ID'
   ),
   ota_rates AS (
     SELECT 
       check_in as date,
       provider,
       (booking_data->>'rate')::decimal as ota_rate
     FROM ota_bookings
     WHERE property_id = 'YOUR_PROPERTY_ID'
   )
   SELECT 
     hr.date,
     hr.hms_rate,
     or_exp.ota_rate as expedia_rate,
     or_bdc.ota_rate as booking_com_rate
   FROM hms_rates hr
   LEFT JOIN ota_rates or_exp ON or_exp.date = hr.date AND or_exp.provider = 'expedia'
   LEFT JOIN ota_rates or_bdc ON or_bdc.date = hr.date AND or_bdc.provider = 'booking.com'
   WHERE hr.hms_rate != or_exp.ota_rate 
      OR hr.hms_rate != or_bdc.ota_rate;
   ```

2. **Force Rate Parity**
   ```typescript
   await enforceRateParity(propertyId, date);
   ```

3. **Check Currency Conversion**
   - Ensure all rates use same currency
   - Verify exchange rate if multi-currency

---

## Inventory Sync Issues

### Problem: Inventory Not Syncing

**Symptoms**:
- Availability updated in HMS but not on OTAs
- Rooms showing as sold out when available

**Solutions**:

1. **Check Sync Status**
   ```sql
   SELECT *
   FROM ota_inventory_allocation
   WHERE property_id = 'YOUR_PROPERTY_ID'
     AND date >= CURRENT_DATE
   ORDER BY date;
   ```

2. **Verify Allocation**
   ```typescript
   // Check current allocation
   const allocation = await inventorySyncService.getInventoryAllocation(
     propertyId,
     roomTypeId,
     date
   );
   console.log('Allocation:', allocation);
   ```

3. **Manual Inventory Sync**
   ```typescript
   await inventorySyncService.syncInventoryUpdate(
     propertyId,
     roomTypeId,
     date,
     availability
   );
   ```

4. **Check OTA Inventory Limits**
   - Verify minimum inventory requirements
   - Check if inventory restrictions are set

### Problem: Overbooking Occurring

**Symptoms**:
- More bookings than available rooms
- Double bookings across channels

**Solutions**:

1. **Enable Overbooking Protection**
   ```typescript
   const isOverbooked = await inventorySyncService.checkOverbooking(
     propertyId,
     roomTypeId,
     date
   );

   if (isOverbooked) {
     await inventorySyncService.handleOverbooking(
       propertyId,
       roomTypeId,
       date
     );
   }
   ```

2. **Reduce Allocation Percentages**
   ```sql
   UPDATE inventory_allocation_config
   SET 
     expedia_percentage = 0.35,
     booking_com_percentage = 0.35,
     direct_percentage = 0.30
   WHERE property_id = 'YOUR_PROPERTY_ID';
   ```

3. **Implement Buffer**
   ```typescript
   const safeAllocation = {
     total: totalRooms,
     buffer: 2, // Keep 2 rooms as buffer
     allocatable: totalRooms - 2
   };
   ```

---

## Webhook Problems

### Problem: Not Receiving Webhooks

**Symptoms**:
- No booking notifications
- Webhooks table is empty

**Solutions**:

1. **Verify Webhook URL**
   ```bash
   # Test webhook endpoint
   curl -X POST https://your-domain.supabase.co/functions/v1/ota-webhook-handler \
     -H "Content-Type: application/json" \
     -d '{"test": true}'
   ```

2. **Check Webhook Configuration**
   - Log in to Expedia Partner Central
   - Verify webhook URL is correct
   - Check if webhooks are enabled

3. **Review Webhook Logs**
   - Check OTA portal for delivery logs
   - Look for failed delivery attempts
   - Verify response codes

4. **Test Webhook Handler**
   ```typescript
   // Run webhook handler locally
   deno run --allow-net --allow-env \
     supabase/functions/ota-webhook-handler/index.ts
   ```

### Problem: Webhook Signature Validation Failing

**Symptoms**:
```
Error: Invalid webhook signature
Status: 401 Unauthorized
```

**Solutions**:

1. **Verify Webhook Secret**
   ```typescript
   // Check if secret matches
   const secret = Deno.env.get('EXPEDIA_WEBHOOK_SECRET');
   console.log('Secret:', secret);
   ```

2. **Update Signature Verification**
   ```typescript
   // Use correct algorithm for provider
   if (provider === 'expedia') {
     // HMAC-SHA256
   } else if (provider === 'booking.com') {
     // Check Booking.com documentation
   }
   ```

3. **Log Signature Comparison**
   ```typescript
   console.log('Received signature:', receivedSignature);
   console.log('Expected signature:', expectedSignature);
   ```

---

## Booking Issues

### Problem: Bookings Not Creating in HMS

**Symptoms**:
- Webhook received but booking not in database
- OTA shows booking but HMS doesn't

**Solutions**:

1. **Check Webhook Processing**
   ```sql
   SELECT 
     event_type,
     status,
     payload,
     error_message
   FROM ota_webhooks
   WHERE status = 'failed'
   ORDER BY received_at DESC
   LIMIT 10;
   ```

2. **Verify Property Mapping**
   ```sql
   -- Ensure property exists
   SELECT id, name
   FROM properties
   WHERE id IN (
     SELECT property_id
     FROM third_party_integrations
     WHERE provider IN ('expedia', 'booking.com')
   );
   ```

3. **Manual Booking Creation**
   ```typescript
   await processWebhookEvent({
     provider: 'expedia',
     eventType: 'reservation.created',
     eventId: 'BOOKING_ID',
     data: webhookPayload
   });
   ```

### Problem: Booking Status Not Updating

**Symptoms**:
- Cancellations not reflecting in HMS
- Modifications not updating

**Solutions**:

1. **Check Status Sync**
   ```sql
   SELECT 
     external_booking_id,
     booking_status,
     updated_at
   FROM ota_bookings
   WHERE updated_at < NOW() - INTERVAL '1 hour'
     AND booking_status = 'confirmed';
   ```

2. **Force Status Update**
   ```typescript
   await bookingSyncService.syncBookingStatus(
     'BOOKING_ID',
     'cancelled'
   );
   ```

---

## Performance Issues

### Problem: Slow API Responses

**Symptoms**:
- API calls taking > 10 seconds
- Timeout errors

**Solutions**:

1. **Enable Response Caching**
   ```typescript
   const cache = new Map();
   const cacheKey = `${provider}:${endpoint}:${params}`;
   
   if (cache.has(cacheKey)) {
     return cache.get(cacheKey);
   }
   
   const response = await apiCall();
   cache.set(cacheKey, response);
   return response;
   ```

2. **Use Bulk Operations**
   ```typescript
   // Instead of:
   for (const date of dates) {
     await updateRate(date);
   }

   // Use:
   await bulkUpdateRates(dates);
   ```

3. **Implement Connection Pooling**
   ```typescript
   const pool = new ConnectionPool({
     maxConnections: 10,
     keepAlive: true
   });
   ```

### Problem: Rate Limit Exceeded

**Symptoms**:
```
Error: 429 Too Many Requests
Message: Rate limit exceeded
```

**Solutions**:

1. **Implement Rate Limiting**
   ```typescript
   const rateLimiter = new RateLimiter({
     maxRequests: 100,
     perMinute: 1
   });

   await rateLimiter.add(() => apiCall());
   ```

2. **Use Request Queue**
   ```typescript
   const queue = new RequestQueue({
     concurrency: 5,
     interval: 1000 // 1 request per second
   });
   ```

---

## Common Error Codes

### Expedia Error Codes

| Code | Message | Solution |
|------|---------|----------|
| 400 | Invalid request | Check request parameters |
| 401 | Unauthorized | Verify API credentials |
| 403 | Forbidden | Check API permissions |
| 404 | Not found | Verify property/room ID |
| 429 | Rate limit | Implement rate limiting |
| 500 | Server error | Retry with backoff |

### Booking.com Error Codes

| Code | Message | Solution |
|------|---------|----------|
| 1001 | Invalid hotel ID | Check hotel ID mapping |
| 1002 | Invalid room ID | Verify room mapping |
| 1003 | Invalid rate | Check rate value |
| 2001 | Authentication failed | Regenerate API key |
| 3001 | Rate limit | Reduce request frequency |

---

## Debug Checklist

When troubleshooting OTA issues, go through this checklist:

- [ ] Verify API credentials are correct
- [ ] Check environment (sandbox vs production)
- [ ] Review sync logs for errors
- [ ] Verify property and room mappings
- [ ] Check webhook configuration
- [ ] Test API connectivity
- [ ] Review rate and inventory allocation
- [ ] Check for overbooking
- [ ] Verify SSL certificates
- [ ] Review firewall rules
- [ ] Check OTA portal for alerts
- [ ] Test with sample data

---

## Getting Help

### Internal Resources
- Documentation: `docs/` folder
- Code examples: `src/services/ota/`
- Test scripts: `scripts/test-ota-*.ts`

### External Support
- **Expedia Support**: apisupport@expediagroup.com
- **Booking.com Support**: connectivity@booking.com
- **Supabase Support**: https://supabase.com/support

### Community
- GitHub Issues: Report bugs and feature requests
- Discord: Real-time help from community

---

**Document Version**: 1.0  
**Last Updated**: December 26, 2024  
**Next Review**: January 26, 2025
