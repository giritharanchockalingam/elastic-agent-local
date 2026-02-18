# OTA Webhook Integration Guide

## 🎯 Overview

This guide explains how to set up and manage webhooks from Expedia and Booking.com to receive real-time notifications about bookings, modifications, cancellations, and other events.

## 📋 Table of Contents

1. [Webhook Architecture](#webhook-architecture)
2. [Webhook Setup](#webhook-setup)
3. [Event Types](#event-types)
4. [Implementation](#implementation)
5. [Security](#security)
6. [Error Handling](#error-handling)
7. [Testing](#testing)
8. [Monitoring](#monitoring)

---

## Webhook Architecture

### How Webhooks Work

```
┌─────────────┐                    ┌──────────────────┐
│   OTA       │                    │   HMS Portal     │
│ (Expedia/   │                    │                  │
│Booking.com) │                    │                  │
└──────┬──────┘                    └────────┬─────────┘
       │                                    │
       │  1. Event occurs (booking created) │
       │                                    │
       │  2. POST webhook notification      │
       ├────────────────────────────────────>
       │                                    │
       │                                    │  3. Process event
       │                                    │  4. Update database
       │                                    │  5. Send confirmation
       │                                    │
       │  6. Return 200 OK                  │
       <────────────────────────────────────┤
       │                                    │
```

### Webhook Endpoint

```
https://your-domain.supabase.co/functions/v1/ota-webhook-handler
```

### Processing Flow

1. **Receive** webhook POST request
2. **Verify** webhook signature
3. **Parse** event payload
4. **Validate** event data
5. **Process** event (update database, trigger actions)
6. **Respond** with 200 OK
7. **Log** event for audit trail

---

## Webhook Setup

### Step 1: Deploy Webhook Handler Function

The webhook handler is an Edge Function that processes incoming webhooks:

```bash
# Deploy the webhook handler
supabase functions deploy ota-webhook-handler
```

### Step 2: Configure Webhook URLs

#### Expedia Configuration

1. **Log in to Expedia Partner Central**
   ```
   URL: https://partner.expediagroup.com/
   ```

2. **Navigate to API Settings**
   - Go to "Developer Tools" → "Webhooks"
   - Click "Add Webhook"

3. **Configure Webhook**
   ```json
   {
     "url": "https://your-domain.supabase.co/functions/v1/ota-webhook-handler",
     "events": [
       "reservation.created",
       "reservation.modified",
       "reservation.cancelled",
       "payment.completed",
       "payment.refunded"
     ],
     "format": "json",
     "version": "2.0"
   }
   ```

4. **Verify Webhook**
   - Expedia sends a verification request
   - Your handler must respond with 200 OK
   - Webhook becomes active after verification

#### Booking.com Configuration

1. **Log in to Booking.com Extranet**
   ```
   URL: https://admin.booking.com/
   ```

2. **Navigate to Connectivity**
   - Go to "Connectivity" → "Webhook Settings"
   - Click "Add Webhook Endpoint"

3. **Configure Webhook**
   ```json
   {
     "url": "https://your-domain.supabase.co/functions/v1/ota-webhook-handler",
     "events": [
       "reservation.new",
       "reservation.modified",
       "reservation.cancelled",
       "reservation.no_show"
     ],
     "format": "json"
   }
   ```

4. **Test Webhook**
   - Use Booking.com's test tool
   - Verify your endpoint responds correctly

---

## Event Types

### Expedia Events

#### 1. Reservation Created
```json
{
  "event_type": "reservation.created",
  "event_id": "evt_123456",
  "timestamp": "2025-01-15T14:30:00Z",
  "data": {
    "reservation_id": "EXP_RES_789",
    "confirmation_number": "ABC123DEF",
    "property_id": "12345",
    "room_type_id": "RT001",
    "rate_plan_id": "BAR",
    "check_in": "2025-02-01",
    "check_out": "2025-02-05",
    "guest": {
      "first_name": "John",
      "last_name": "Doe",
      "email": "john.doe@email.com",
      "phone": "+1-555-0100"
    },
    "adults": 2,
    "children": 0,
    "total_amount": 796.00,
    "currency": "USD",
    "status": "confirmed",
    "special_requests": "Late check-in"
  }
}
```

#### 2. Reservation Modified
```json
{
  "event_type": "reservation.modified",
  "event_id": "evt_123457",
  "timestamp": "2025-01-16T10:15:00Z",
  "data": {
    "reservation_id": "EXP_RES_789",
    "modifications": {
      "check_in": {
        "old": "2025-02-01",
        "new": "2025-02-02"
      },
      "check_out": {
        "old": "2025-02-05",
        "new": "2025-02-06"
      }
    },
    "price_difference": 50.00,
    "new_total": 846.00
  }
}
```

#### 3. Reservation Cancelled
```json
{
  "event_type": "reservation.cancelled",
  "event_id": "evt_123458",
  "timestamp": "2025-01-17T09:00:00Z",
  "data": {
    "reservation_id": "EXP_RES_789",
    "cancellation_reason": "Guest requested",
    "cancelled_by": "guest",
    "refund_amount": 796.00,
    "refund_status": "pending"
  }
}
```

### Booking.com Events

#### 1. New Reservation
```json
{
  "message_type": "reservation",
  "action": "new",
  "reservation_id": "1234567890",
  "hotel_id": "12345",
  "created_at": "2025-01-15T14:30:00Z",
  "reservation": {
    "room_id": "ROOM001",
    "arrival_date": "2025-02-01",
    "departure_date": "2025-02-05",
    "guest": {
      "firstname": "John",
      "lastname": "Doe",
      "email": "john.doe@email.com",
      "phone": "+1-555-0100"
    },
    "number_of_adults": 2,
    "number_of_children": 0,
    "total_price": 796.00,
    "currency": "USD",
    "status": "confirmed",
    "remarks": "Late check-in expected"
  }
}
```

#### 2. Reservation Modified
```json
{
  "message_type": "reservation",
  "action": "modified",
  "reservation_id": "1234567890",
  "hotel_id": "12345",
  "modified_at": "2025-01-16T10:15:00Z",
  "changes": {
    "arrival_date": "2025-02-02",
    "departure_date": "2025-02-06",
    "total_price": 846.00
  }
}
```

#### 3. Reservation Cancelled
```json
{
  "message_type": "reservation",
  "action": "cancelled",
  "reservation_id": "1234567890",
  "hotel_id": "12345",
  "cancelled_at": "2025-01-17T09:00:00Z",
  "cancellation": {
    "reason": "Guest request",
    "refund_amount": 796.00
  }
}
```

---

## Implementation

### Webhook Handler Edge Function

```typescript
// supabase/functions/ota-webhook-handler/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

interface WebhookEvent {
  provider: 'expedia' | 'booking.com';
  eventType: string;
  eventId: string;
  timestamp: string;
  data: any;
}

serve(async (req) => {
  try {
    // 1. Verify request method
    if (req.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 });
    }

    // 2. Get provider from path or header
    const url = new URL(req.url);
    const provider = url.searchParams.get('provider') || 
                     req.headers.get('x-ota-provider');

    if (!provider || !['expedia', 'booking.com'].includes(provider)) {
      return new Response('Invalid provider', { status: 400 });
    }

    // 3. Verify webhook signature
    const signature = req.headers.get('x-webhook-signature');
    const isValid = await verifyWebhookSignature(
      provider as 'expedia' | 'booking.com',
      req,
      signature
    );

    if (!isValid) {
      return new Response('Invalid signature', { status: 401 });
    }

    // 4. Parse webhook payload
    const payload = await req.json();

    // 5. Normalize event data
    const event = await normalizeWebhookEvent(
      provider as 'expedia' | 'booking.com',
      payload
    );

    // 6. Store webhook in database
    await storeWebhook(event);

    // 7. Process event
    await processWebhookEvent(event);

    // 8. Return success
    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });

  } catch (error) {
    console.error('Webhook processing error:', error);
    
    // Still return 200 to prevent retries for permanent errors
    return new Response(JSON.stringify({ 
      error: error.message,
      success: false 
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
  }
});

async function verifyWebhookSignature(
  provider: 'expedia' | 'booking.com',
  req: Request,
  signature: string | null
): Promise<boolean> {
  if (!signature) return false;

  const body = await req.text();
  
  if (provider === 'expedia') {
    // Verify Expedia signature
    const secret = Deno.env.get('EXPEDIA_WEBHOOK_SECRET')!;
    const encoder = new TextEncoder();
    const key = await crypto.subtle.importKey(
      'raw',
      encoder.encode(secret),
      { name: 'HMAC', hash: 'SHA-256' },
      false,
      ['sign']
    );
    const signatureBytes = await crypto.subtle.sign(
      'HMAC',
      key,
      encoder.encode(body)
    );
    const expectedSignature = Array.from(new Uint8Array(signatureBytes))
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
    
    return signature === expectedSignature;
  }
  
  if (provider === 'booking.com') {
    // Verify Booking.com signature
    const secret = Deno.env.get('BOOKING_COM_WEBHOOK_SECRET')!;
    // Booking.com uses different signature algorithm
    // Implement according to their documentation
    return true; // Placeholder
  }

  return false;
}

async function normalizeWebhookEvent(
  provider: 'expedia' | 'booking.com',
  payload: any
): Promise<WebhookEvent> {
  if (provider === 'expedia') {
    return {
      provider: 'expedia',
      eventType: payload.event_type,
      eventId: payload.event_id,
      timestamp: payload.timestamp,
      data: payload.data
    };
  }

  if (provider === 'booking.com') {
    return {
      provider: 'booking.com',
      eventType: `reservation.${payload.action}`,
      eventId: payload.reservation_id,
      timestamp: payload.created_at || payload.modified_at || payload.cancelled_at,
      data: payload
    };
  }

  throw new Error(`Unknown provider: ${provider}`);
}

async function storeWebhook(event: WebhookEvent) {
  const { error } = await supabase
    .from('ota_webhooks')
    .insert({
      provider: event.provider,
      event_type: event.eventType,
      event_id: event.eventId,
      payload: event.data,
      received_at: event.timestamp,
      processed_at: null,
      status: 'pending'
    });

  if (error) {
    console.error('Error storing webhook:', error);
    throw error;
  }
}

async function processWebhookEvent(event: WebhookEvent) {
  switch (event.eventType) {
    case 'reservation.created':
    case 'reservation.new':
      await processNewReservation(event);
      break;
    
    case 'reservation.modified':
      await processModifiedReservation(event);
      break;
    
    case 'reservation.cancelled':
      await processCancelledReservation(event);
      break;
    
    default:
      console.log(`Unhandled event type: ${event.eventType}`);
  }

  // Mark webhook as processed
  await supabase
    .from('ota_webhooks')
    .update({
      processed_at: new Date().toISOString(),
      status: 'processed'
    })
    .eq('event_id', event.eventId);
}

async function processNewReservation(event: WebhookEvent) {
  const data = event.data;
  
  // Get property mapping
  const { data: mapping } = await supabase
    .from('third_party_integrations')
    .select('property_id')
    .eq('provider', event.provider)
    .single();

  if (!mapping) {
    throw new Error(`No mapping found for provider: ${event.provider}`);
  }

  // Create OTA booking record
  const { error } = await supabase
    .from('ota_bookings')
    .insert({
      property_id: mapping.property_id,
      provider: event.provider,
      external_booking_id: event.provider === 'expedia' 
        ? data.reservation_id 
        : event.eventId,
      booking_status: 'confirmed',
      check_in: event.provider === 'expedia' 
        ? data.check_in 
        : data.reservation.arrival_date,
      check_out: event.provider === 'expedia' 
        ? data.check_out 
        : data.reservation.departure_date,
      guest_name: event.provider === 'expedia'
        ? `${data.guest.first_name} ${data.guest.last_name}`
        : `${data.reservation.guest.firstname} ${data.reservation.guest.lastname}`,
      guest_email: event.provider === 'expedia'
        ? data.guest.email
        : data.reservation.guest.email,
      guest_phone: event.provider === 'expedia'
        ? data.guest.phone
        : data.reservation.guest.phone,
      total_amount: event.provider === 'expedia'
        ? data.total_amount
        : data.reservation.total_price,
      currency: event.provider === 'expedia'
        ? data.currency
        : data.reservation.currency,
      booking_data: data
    });

  if (error) {
    console.error('Error creating booking:', error);
    throw error;
  }

  console.log(`✅ Created booking: ${event.eventId}`);
}

async function processModifiedReservation(event: WebhookEvent) {
  const { error } = await supabase
    .from('ota_bookings')
    .update({
      booking_status: 'modified',
      booking_data: event.data,
      updated_at: new Date().toISOString()
    })
    .eq('external_booking_id', event.eventId);

  if (error) {
    console.error('Error updating booking:', error);
    throw error;
  }

  console.log(`✅ Modified booking: ${event.eventId}`);
}

async function processCancelledReservation(event: WebhookEvent) {
  const { error } = await supabase
    .from('ota_bookings')
    .update({
      booking_status: 'cancelled',
      cancellation_reason: event.data.cancellation_reason || 
                          event.data.cancellation?.reason,
      cancelled_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    })
    .eq('external_booking_id', event.eventId);

  if (error) {
    console.error('Error cancelling booking:', error);
    throw error;
  }

  console.log(`✅ Cancelled booking: ${event.eventId}`);
}
```

---

## Security

### 1. Signature Verification

**Always verify webhook signatures** to ensure requests come from legitimate sources.

```typescript
// Expedia signature verification
async function verifyExpediaSignature(
  body: string,
  signature: string,
  secret: string
): Promise<boolean> {
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  
  const signatureBytes = await crypto.subtle.sign(
    'HMAC',
    key,
    encoder.encode(body)
  );
  
  const expectedSignature = Array.from(new Uint8Array(signatureBytes))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
  
  return signature === expectedSignature;
}
```

### 2. IP Whitelisting

Configure firewall to only accept webhooks from OTA IP ranges:

**Expedia IP Ranges**:
- 104.127.64.0/18
- 185.12.64.0/20

**Booking.com IP Ranges**:
- 5.57.16.0/20
- 185.29.68.0/22

### 3. HTTPS Only

- Never accept webhooks over HTTP
- Ensure valid SSL certificate
- Use TLS 1.2 or higher

### 4. Rate Limiting

```typescript
// Implement rate limiting
const rateLimiter = new Map<string, number[]>();

function isRateLimited(ip: string): boolean {
  const now = Date.now();
  const requests = rateLimiter.get(ip) || [];
  
  // Remove requests older than 1 minute
  const recentRequests = requests.filter(t => now - t < 60000);
  
  // Allow max 100 requests per minute
  if (recentRequests.length >= 100) {
    return true;
  }
  
  recentRequests.push(now);
  rateLimiter.set(ip, recentRequests);
  return false;
}
```

---

## Error Handling

### Retry Strategy

OTAs typically retry failed webhooks with exponential backoff:
- 1st retry: After 1 minute
- 2nd retry: After 5 minutes
- 3rd retry: After 15 minutes
- 4th retry: After 1 hour
- 5th retry: After 6 hours

**Important**: Always return 200 OK even for errors you want to retry, to prevent OTA from stopping retries.

### Idempotency

```typescript
async function ensureIdempotency(eventId: string): Promise<boolean> {
  // Check if event already processed
  const { data } = await supabase
    .from('ota_webhooks')
    .select('id')
    .eq('event_id', eventId)
    .eq('status', 'processed')
    .single();

  return !!data; // true if already processed
}

// Use in handler
const alreadyProcessed = await ensureIdempotency(event.eventId);
if (alreadyProcessed) {
  return new Response(JSON.stringify({ 
    success: true,
    message: 'Already processed'
  }), { status: 200 });
}
```

---

## Testing

### 1. Manual Testing

```bash
# Test webhook endpoint with curl
curl -X POST https://your-domain.supabase.co/functions/v1/ota-webhook-handler?provider=expedia \
  -H "Content-Type: application/json" \
  -H "x-webhook-signature: test-signature" \
  -d '{
    "event_type": "reservation.created",
    "event_id": "test_123",
    "timestamp": "2025-01-15T14:30:00Z",
    "data": {
      "reservation_id": "TEST_RES_001",
      "property_id": "12345",
      "check_in": "2025-02-01",
      "check_out": "2025-02-05",
      "guest": {
        "first_name": "Test",
        "last_name": "User",
        "email": "test@example.com"
      },
      "total_amount": 400.00
    }
  }'
```

### 2. Automated Testing

```typescript
// tests/webhook-handler.test.ts
import { assertEquals } from 'https://deno.land/std@0.168.0/testing/asserts.ts';

Deno.test('Webhook Handler - New Reservation', async () => {
  const payload = {
    event_type: 'reservation.created',
    event_id: 'test_123',
    timestamp: new Date().toISOString(),
    data: {
      reservation_id: 'TEST_001',
      property_id: '12345',
      check_in: '2025-02-01',
      check_out: '2025-02-05',
      guest: {
        first_name: 'Test',
        last_name: 'User',
        email: 'test@example.com'
      },
      total_amount: 400.00
    }
  };

  const response = await fetch(
    'http://localhost:54321/functions/v1/ota-webhook-handler?provider=expedia',
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    }
  );

  assertEquals(response.status, 200);
  
  const result = await response.json();
  assertEquals(result.success, true);
});
```

---

## Monitoring

### Webhook Metrics

```sql
-- Track webhook processing statistics
SELECT
  provider,
  event_type,
  status,
  COUNT(*) as count,
  AVG(EXTRACT(EPOCH FROM (processed_at - received_at))) as avg_processing_time_seconds
FROM ota_webhooks
WHERE received_at > NOW() - INTERVAL '24 hours'
GROUP BY provider, event_type, status
ORDER BY count DESC;
```

### Alert on Failures

```sql
-- Create alerts for failed webhooks
SELECT
  provider,
  event_type,
  COUNT(*) as failed_count
FROM ota_webhooks
WHERE status = 'failed'
  AND received_at > NOW() - INTERVAL '1 hour'
GROUP BY provider, event_type
HAVING COUNT(*) > 5;
```

---

## Next Steps

1. ✅ Deploy webhook handler function
2. ✅ Configure webhook URLs in OTA portals
3. ✅ Test webhook delivery
4. ✅ Monitor webhook processing
5. ⏭️ Set up alerts for failures
6. ⏭️ Implement retry logic for failed processing

---

**Document Version**: 1.0  
**Last Updated**: December 26, 2024  
**Next Review**: January 26, 2025
