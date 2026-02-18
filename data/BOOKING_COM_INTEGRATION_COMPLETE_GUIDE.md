# Booking.com Connectivity - Complete Integration Guide

## 🎯 Overview

This guide provides comprehensive instructions to integrate your HMS portal with **ALL** Booking.com Connectivity APIs, enabling your hotel tenants to leverage Booking.com's extensive global reach.

## 📋 Table of Contents

1. [Getting Started](#getting-started)
2. [Connectivity Certification](#connectivity-certification)
3. [Authentication Setup](#authentication-setup)
4. [Property Configuration](#property-configuration)
5. [API Implementation](#api-implementation)
6. [Testing & Validation](#testing--validation)
7. [Production Deployment](#production-deployment)
8. [Troubleshooting](#troubleshooting)

---

## Getting Started

### Prerequisites

Before starting, ensure you have:
- ✅ Property listed on Booking.com (or ready to list)
- ✅ Booking.com extranet account
- ✅ Completed Connectivity Provider certification
- ✅ HMS portal database access
- ✅ HTTPS-enabled domain for webhooks

### Booking.com API Ecosystem

Booking.com provides several API categories:
1. **Availability & Rates API** - Manage inventory and pricing
2. **Reservations API** - Handle bookings and modifications
3. **Content API** - Property and room descriptions
4. **Rate Management API** - Dynamic pricing and rate plans
5. **Payment API** - Payment processing and refunds
6. **Reporting API** - Performance analytics

---

## Connectivity Certification

### Step 1: Register as Connectivity Provider

1. **Visit Booking.com Connectivity Program**
   ```
   URL: https://developers.booking.com/
   ```

2. **Apply for Connectivity Provider Status**
   - Submit company information
   - Describe your HMS platform
   - Provide technical capabilities
   - Submit test property details

3. **Complete Certification Requirements**
   - Technical integration checklist
   - Security compliance verification
   - Test environment setup
   - Sample integration demonstration

**Timeline**: 4-8 weeks for certification approval

### Step 2: Certification Testing

**Required Tests**:
- [ ] Availability updates (single and bulk)
- [ ] Rate updates (single and bulk)
- [ ] Reservation creation
- [ ] Reservation modification
- [ ] Reservation cancellation
- [ ] Content synchronization
- [ ] Error handling
- [ ] Webhook processing

### Step 3: Production Access

Once certified, Booking.com will provide:
```json
{
  "api_key": "your-booking-com-api-key",
  "partner_id": "your-partner-id",
  "hotel_id": "12345678",
  "sandbox_api_key": "sandbox-key",
  "sandbox_hotel_id": "test-12345"
}
```

---

## Authentication Setup

### Step 1: Configure in HMS Database

Run this SQL in Supabase SQL Editor:

```sql
-- Insert Booking.com integration configuration
INSERT INTO third_party_integrations (
  integration_name,
  integration_type,
  provider,
  credentials,
  configuration,
  is_enabled,
  status,
  property_id,
  webhook_url
) VALUES (
  'Booking.com Connectivity',
  'ota',
  'booking.com',
  jsonb_build_object(
    'api_key', 'YOUR_SANDBOX_API_KEY',
    'partner_id', 'YOUR_PARTNER_ID',
    'production_api_key', 'YOUR_PRODUCTION_API_KEY'
  ),
  jsonb_build_object(
    'test_mode', true,
    'hotel_id', 'YOUR_SANDBOX_HOTEL_ID',
    'production_hotel_id', 'YOUR_PRODUCTION_HOTEL_ID',
    'region', 'global',
    'language', 'en',
    'currency', 'USD',
    'max_advance_booking_days', 365
  ),
  true,
  'active',
  'YOUR_PROPERTY_UUID', -- Replace with actual UUID
  'https://your-domain.com/api/webhooks/booking-com'
)
ON CONFLICT (provider, property_id) DO UPDATE SET
  credentials = EXCLUDED.credentials,
  configuration = EXCLUDED.configuration,
  updated_at = CURRENT_TIMESTAMP;
```

### Step 2: Set Environment Variables

Add to `.env.production`:

```env
# Booking.com API Configuration
BOOKING_COM_API_KEY=your_sandbox_api_key
BOOKING_COM_PARTNER_ID=your_partner_id
BOOKING_COM_HOTEL_ID=your_sandbox_hotel_id
BOOKING_COM_TEST_MODE=true

# Production credentials (comment out until ready)
# BOOKING_COM_PROD_API_KEY=your_production_api_key
# BOOKING_COM_PROD_HOTEL_ID=your_production_hotel_id
```

### Step 3: Test Authentication

Create a test script:

```typescript
// scripts/test-booking-com-auth.ts
import { BookingComComprehensiveAPI } from '@/services/ota/booking-com-comprehensive-api';

async function testBookingComAuth() {
  const bookingCom = new BookingComComprehensiveAPI({
    apiKey: process.env.BOOKING_COM_API_KEY!,
    partnerId: process.env.BOOKING_COM_PARTNER_ID!,
    environment: 'sandbox',
    hotelId: process.env.BOOKING_COM_HOTEL_ID!
  });

  try {
    // Test with a simple API call
    const hotel = await bookingCom.getHotelInfo(process.env.BOOKING_COM_HOTEL_ID!);
    console.log('✅ Authentication successful!');
    console.log('Hotel:', hotel.name);
    return true;
  } catch (error) {
    console.error('❌ Authentication failed:', error);
    return false;
  }
}

testBookingComAuth();
```

Run the test:
```bash
npm run test:booking-com-auth
```

---

## Property Configuration

### Step 1: Configure Property Details

```typescript
// Example: Configure property in Booking.com
const propertyConfig = {
  hotelId: 'YOUR_HOTEL_ID',
  name: 'Grand Hotel Downtown',
  address: {
    street: '123 Main Street',
    city: 'New York',
    state: 'NY',
    postalCode: '10001',
    country: 'US'
  },
  contact: {
    phone: '+1-555-0100',
    email: 'info@grandhotel.com',
    website: 'https://grandhotel.com'
  },
  coordinates: {
    latitude: 40.7128,
    longitude: -74.0060
  },
  checkIn: {
    from: '15:00',
    until: '23:00'
  },
  checkOut: {
    from: '07:00',
    until: '11:00'
  },
  starRating: 4,
  propertyType: 'hotel',
  facilities: [
    {
      id: 'wifi',
      type: 'internet',
      description: 'Free WiFi throughout property'
    },
    {
      id: 'parking',
      type: 'parking',
      description: 'On-site parking available',
      feeAmount: 25,
      currency: 'USD',
      period: 'per_day'
    },
    {
      id: 'pool',
      type: 'wellness',
      description: 'Outdoor swimming pool'
    },
    {
      id: 'fitness',
      type: 'wellness',
      description: '24-hour fitness center'
    }
  ],
  policies: {
    cancellation: {
      type: 'flexible',
      deadlineHours: 24,
      penaltyPercentage: 0
    },
    payment: {
      methods: ['credit_card', 'debit_card'],
      acceptedCards: ['visa', 'mastercard', 'amex'],
      depositRequired: false
    },
    children: {
      allowed: true,
      maxAge: 17,
      freeUnderAge: 3
    },
    pets: {
      allowed: true,
      maxWeight: 20,
      fee: 50,
      currency: 'USD'
    }
  }
};

// Update property using API
await bookingCom.updateHotelInfo(propertyConfig);
```

### Step 2: Configure Room Types

```typescript
// Define room types
const roomTypes = [
  {
    roomId: 'ROOM001',
    name: 'Deluxe King Room',
    description: 'Spacious room with king-size bed and city view. Features modern amenities and elegant decor.',
    maxOccupancy: 2,
    beds: [
      {
        type: 'king',
        count: 1,
        size: 'king'
      }
    ],
    size: {
      value: 350,
      unit: 'sqft'
    },
    facilities: [
      'air_conditioning',
      'flat_screen_tv',
      'minibar',
      'safe',
      'coffee_machine',
      'desk',
      'wifi'
    ],
    view: 'city',
    smokingAllowed: false,
    photos: [
      {
        url: 'https://your-cdn.com/images/deluxe-king-main.jpg',
        caption: 'Deluxe King Room',
        sortOrder: 1
      },
      {
        url: 'https://your-cdn.com/images/deluxe-king-bathroom.jpg',
        caption: 'Bathroom',
        sortOrder: 2
      }
    ]
  },
  {
    roomId: 'ROOM002',
    name: 'Executive Suite',
    description: 'Luxurious suite with separate living area, dining space, and premium amenities.',
    maxOccupancy: 4,
    beds: [
      {
        type: 'king',
        count: 1,
        size: 'king'
      },
      {
        type: 'sofa_bed',
        count: 1,
        size: 'double'
      }
    ],
    size: {
      value: 600,
      unit: 'sqft'
    },
    facilities: [
      'air_conditioning',
      'flat_screen_tv',
      'minibar',
      'safe',
      'coffee_machine',
      'desk',
      'wifi',
      'living_room',
      'balcony',
      'bathrobe',
      'slippers'
    ],
    view: 'city',
    smokingAllowed: false,
    photos: [
      {
        url: 'https://your-cdn.com/images/executive-suite-living.jpg',
        caption: 'Living Area',
        sortOrder: 1
      },
      {
        url: 'https://your-cdn.com/images/executive-suite-bedroom.jpg',
        caption: 'Bedroom',
        sortOrder: 2
      },
      {
        url: 'https://your-cdn.com/images/executive-suite-bathroom.jpg',
        caption: 'Bathroom',
        sortOrder: 3
      }
    ]
  }
];

// Create room types
for (const roomType of roomTypes) {
  await bookingCom.createRoom(propertyConfig.hotelId, roomType);
}
```

### Step 3: Configure Rate Plans

```typescript
// Define rate plans
const ratePlans = [
  {
    ratePlanId: 'BAR',
    name: 'Best Available Rate',
    description: 'Our standard flexible rate with free cancellation',
    roomId: 'ROOM001',
    cancellationPolicy: {
      type: 'flexible',
      deadlineHours: 24,
      penaltyPercentage: 0
    },
    mealPlan: 'room_only',
    minLengthOfStay: 1,
    maxLengthOfStay: 30,
    advanceBookingDays: 365
  },
  {
    ratePlanId: 'NREF',
    name: 'Non-Refundable Rate',
    description: 'Best price with no refunds',
    roomId: 'ROOM001',
    cancellationPolicy: {
      type: 'non_refundable',
      deadlineHours: 0,
      penaltyPercentage: 100
    },
    mealPlan: 'room_only',
    minLengthOfStay: 1,
    maxLengthOfStay: 30,
    advanceBookingDays: 365,
    discount: {
      type: 'percentage',
      value: 15 // 15% off BAR rate
    }
  },
  {
    ratePlanId: 'BB',
    name: 'Bed & Breakfast',
    description: 'Includes complimentary breakfast',
    roomId: 'ROOM001',
    cancellationPolicy: {
      type: 'flexible',
      deadlineHours: 24,
      penaltyPercentage: 0
    },
    mealPlan: 'breakfast',
    minLengthOfStay: 1,
    maxLengthOfStay: 30,
    advanceBookingDays: 365
  }
];

// Create rate plans
for (const ratePlan of ratePlans) {
  await bookingCom.createRatePlan(propertyConfig.hotelId, ratePlan);
}
```

---

## API Implementation

### 1. Availability & Rates API

#### Get Availability
```typescript
// Fetch availability for date range
const availability = await bookingCom.getAvailabilityWithRates({
  hotelId: 'YOUR_HOTEL_ID',
  checkIn: '2025-02-01',
  checkOut: '2025-02-05',
  adults: 2,
  children: 0
});

console.log('Available rooms:', availability.rooms);
```

#### Update Single Rate
```typescript
// Update rate for a specific date
await bookingCom.updateRate({
  hotelId: 'YOUR_HOTEL_ID',
  roomId: 'ROOM001',
  ratePlanId: 'BAR',
  date: '2025-02-01',
  rate: 199.00,
  currency: 'USD',
  availability: 10
});
```

#### Bulk Rate Update
```typescript
// Update rates for multiple dates
await bookingCom.bulkUpdateRates({
  hotelId: 'YOUR_HOTEL_ID',
  roomId: 'ROOM001',
  ratePlanId: 'BAR',
  updates: [
    {
      date: '2025-02-01',
      rate: 199.00,
      currency: 'USD',
      availability: 10
    },
    {
      date: '2025-02-02',
      rate: 199.00,
      currency: 'USD',
      availability: 10
    },
    {
      date: '2025-02-03',
      rate: 229.00,
      currency: 'USD',
      availability: 8
    }
  ]
});
```

#### Update Inventory
```typescript
// Update room availability
await bookingCom.updateInventory({
  hotelId: 'YOUR_HOTEL_ID',
  roomId: 'ROOM001',
  date: '2025-02-01',
  availability: 10
});
```

#### Bulk Inventory Update
```typescript
// Update inventory for multiple dates
await bookingCom.bulkUpdateInventory({
  hotelId: 'YOUR_HOTEL_ID',
  roomId: 'ROOM001',
  updates: [
    { date: '2025-02-01', availability: 10 },
    { date: '2025-02-02', availability: 10 },
    { date: '2025-02-03', availability: 8 },
    { date: '2025-02-04', availability: 8 },
    { date: '2025-02-05', availability: 10 }
  ]
});
```

### 2. Reservation Management API

#### Get Reservation
```typescript
// Retrieve reservation details
const reservation = await bookingCom.getReservation('RESERVATION_ID');

console.log('Guest:', reservation.guest);
console.log('Status:', reservation.status);
console.log('Total:', reservation.totalPrice);
```

#### Confirm Reservation
```typescript
// Confirm a new reservation
await bookingCom.confirmReservation({
  reservationId: 'RESERVATION_ID',
  confirmationNumber: 'HMS-12345'
});
```

#### Modify Reservation
```typescript
// Modify existing reservation
const modified = await bookingCom.modifyReservation({
  reservationId: 'RESERVATION_ID',
  modifications: {
    checkIn: '2025-02-02',
    checkOut: '2025-02-06',
    adults: 3,
    specialRequests: 'Late check-in requested'
  }
});

console.log('Modified reservation:', modified.reservationId);
```

#### Cancel Reservation
```typescript
// Cancel reservation
const cancellation = await bookingCom.cancelReservation({
  reservationId: 'RESERVATION_ID',
  reason: 'Guest requested cancellation',
  waiveFee: false // Apply cancellation fee per policy
});

console.log('Cancellation status:', cancellation.status);
console.log('Refund amount:', cancellation.refundAmount);
```

### 3. Rate Management API

#### Create Dynamic Pricing Rule
```typescript
// Create dynamic pricing based on occupancy
await bookingCom.createPricingRule({
  hotelId: 'YOUR_HOTEL_ID',
  roomId: 'ROOM001',
  ratePlanId: 'BAR',
  rule: {
    type: 'occupancy_based',
    conditions: [
      {
        occupancyPercentage: { min: 0, max: 50 },
        adjustment: { type: 'percentage', value: -10 } // 10% discount
      },
      {
        occupancyPercentage: { min: 80, max: 100 },
        adjustment: { type: 'percentage', value: 20 } // 20% premium
      }
    ]
  }
});
```

#### Set Promotional Rate
```typescript
// Create promotional rate for special event
await bookingCom.createPromotion({
  hotelId: 'YOUR_HOTEL_ID',
  roomId: 'ROOM001',
  promotion: {
    name: 'Valentine\'s Special',
    startDate: '2025-02-13',
    endDate: '2025-02-15',
    discount: {
      type: 'percentage',
      value: 20
    },
    minLengthOfStay: 2,
    earlyBookingDays: 14
  }
});
```

### 4. Content Management API

#### Update Room Description
```typescript
// Update room content
await bookingCom.updateRoomContent({
  hotelId: 'YOUR_HOTEL_ID',
  roomId: 'ROOM001',
  content: {
    name: {
      'en': 'Deluxe King Room',
      'es': 'Habitación Deluxe King',
      'fr': 'Chambre Deluxe King'
    },
    description: {
      'en': 'Spacious room with king-size bed and city view',
      'es': 'Habitación espaciosa con cama king size y vista a la ciudad',
      'fr': 'Chambre spacieuse avec lit king size et vue sur la ville'
    }
  }
});
```

#### Upload Room Photos
```typescript
// Upload room images
await bookingCom.uploadRoomPhotos({
  hotelId: 'YOUR_HOTEL_ID',
  roomId: 'ROOM001',
  photos: [
    {
      url: 'https://your-cdn.com/images/room-main.jpg',
      caption: 'Main room view',
      sortOrder: 1,
      photoType: 'room'
    },
    {
      url: 'https://your-cdn.com/images/room-bathroom.jpg',
      caption: 'Bathroom',
      sortOrder: 2,
      photoType: 'bathroom'
    }
  ]
});
```

### 5. Payment API

#### Get Payment Details
```typescript
// Retrieve payment information
const payment = await bookingCom.getPaymentDetails('RESERVATION_ID');

console.log('Payment method:', payment.method);
console.log('Amount:', payment.amount);
console.log('Status:', payment.status);
```

#### Process Payment
```typescript
// Process guest payment
const paymentResult = await bookingCom.processPayment({
  reservationId: 'RESERVATION_ID',
  amount: 398.00,
  currency: 'USD',
  method: 'credit_card'
});

console.log('Payment successful:', paymentResult.success);
console.log('Transaction ID:', paymentResult.transactionId);
```

#### Process Refund
```typescript
// Process refund for cancellation
const refund = await bookingCom.processRefund({
  reservationId: 'RESERVATION_ID',
  amount: 398.00,
  currency: 'USD',
  reason: 'Cancellation per guest request'
});

console.log('Refund status:', refund.status);
console.log('Refund ID:', refund.refundId);
```

---

## Testing & Validation

### Sandbox Testing

1. **Use Sandbox Credentials**
   ```typescript
   const bookingCom = new BookingComComprehensiveAPI({
     apiKey: process.env.BOOKING_COM_SANDBOX_API_KEY!,
     partnerId: process.env.BOOKING_COM_PARTNER_ID!,
     environment: 'sandbox',
     hotelId: process.env.BOOKING_COM_SANDBOX_HOTEL_ID!
   });
   ```

2. **Test Reservation Flow**
   ```bash
   # Get reservation
   npm run test:booking-com-reservation-get
   
   # Confirm reservation
   npm run test:booking-com-reservation-confirm
   
   # Modify reservation
   npm run test:booking-com-reservation-modify
   
   # Cancel reservation
   npm run test:booking-com-reservation-cancel
   ```

3. **Test Rate Updates**
   ```bash
   # Single rate update
   npm run test:booking-com-rate-update
   
   # Bulk rate update
   npm run test:booking-com-rate-bulk-update
   ```

4. **Test Inventory Sync**
   ```bash
   # Single inventory update
   npm run test:booking-com-inventory-update
   
   # Bulk inventory update
   npm run test:booking-com-inventory-bulk-update
   ```

### Certification Testing Checklist

- [ ] Authentication works with sandbox credentials
- [ ] Can retrieve hotel information
- [ ] Can fetch availability
- [ ] Can retrieve reservation
- [ ] Can confirm reservation
- [ ] Can modify reservation
- [ ] Can cancel reservation
- [ ] Can update single rate
- [ ] Can update bulk rates
- [ ] Can update single inventory
- [ ] Can update bulk inventory
- [ ] Can upload photos
- [ ] Can update content
- [ ] Can process payment
- [ ] Can process refund
- [ ] Webhooks are received and processed
- [ ] Error handling works correctly
- [ ] Rate limiting is respected

---

## Production Deployment

### Step 1: Complete Certification

Ensure all certification tests pass:
```bash
npm run test:booking-com-certification
```

### Step 2: Switch to Production Credentials

Update `.env.production`:

```env
# Production Booking.com Configuration
BOOKING_COM_API_KEY=your_production_api_key
BOOKING_COM_HOTEL_ID=your_production_hotel_id
BOOKING_COM_TEST_MODE=false
```

Update database:

```sql
UPDATE third_party_integrations
SET 
  credentials = jsonb_set(
    credentials,
    '{api_key}',
    to_jsonb('YOUR_PRODUCTION_API_KEY'::text)
  ),
  configuration = jsonb_set(
    configuration,
    '{hotel_id}',
    to_jsonb('YOUR_PRODUCTION_HOTEL_ID'::text)
  ),
  configuration = jsonb_set(
    configuration,
    '{test_mode}',
    'false'::jsonb
  )
WHERE provider = 'booking.com';
```

### Step 3: Configure Production Webhooks

1. **Register Webhook URL**
   ```
   https://your-domain.supabase.co/functions/v1/ota-webhook-handler
   ```

2. **Configure in Booking.com Extranet**
   - Log in to Booking.com Extranet
   - Navigate to "Connectivity" → "Webhook Configuration"
   - Add webhook URL
   - Select notification types:
     - New reservations
     - Reservation modifications
     - Reservation cancellations
     - No-shows
     - Payment updates

3. **Test Webhook Delivery**
   - Booking.com sends test notification
   - Verify your handler responds with 200 OK
   - Check webhook logs in Extranet

### Step 4: Monitor Initial Reservations

```sql
-- Monitor reservations from Booking.com
SELECT 
  b.id,
  b.external_booking_id,
  b.booking_status,
  b.check_in,
  b.check_out,
  b.guest_name,
  b.total_amount,
  b.created_at
FROM ota_bookings b
WHERE b.provider = 'booking.com'
  AND b.created_at > NOW() - INTERVAL '24 hours'
ORDER BY b.created_at DESC;
```

---

## Troubleshooting

### Common Issues

#### 1. Authentication Errors

**Error**: `401 Unauthorized`

**Solutions**:
- Verify API key is correct
- Check partner ID matches
- Ensure hotel ID is correct
- Verify credentials are for correct environment
- Contact Booking.com support

#### 2. Invalid Hotel ID

**Error**: `400 Bad Request - Invalid hotel ID`

**Solutions**:
- Verify hotel ID in Extranet
- Ensure hotel is active
- Check if certification is complete
- Confirm using correct environment

#### 3. Rate Limit Exceeded

**Error**: `429 Too Many Requests`

**Solutions**:
- Implement request throttling
- Use bulk operations
- Add retry logic with exponential backoff
- Monitor API usage in Extranet

#### 4. Webhook Not Received

**Issue**: Not receiving reservation notifications

**Solutions**:
- Verify webhook URL is accessible
- Check SSL certificate is valid
- Review webhook logs in Extranet
- Test webhook endpoint manually
- Ensure endpoint returns 200 OK

#### 5. Inventory Not Updating

**Issue**: Availability not showing on Booking.com

**Solutions**:
- Check sync logs for errors
- Verify room ID matches
- Ensure dates are in correct format (YYYY-MM-DD)
- Check if minimum advance booking is set
- Review rate plan restrictions

### Debug Mode

Enable detailed logging:

```typescript
const bookingCom = new BookingComComprehensiveAPI({
  apiKey: process.env.BOOKING_COM_API_KEY!,
  partnerId: process.env.BOOKING_COM_PARTNER_ID!,
  environment: 'sandbox',
  hotelId: process.env.BOOKING_COM_HOTEL_ID!,
  debug: true, // Enable debug logging
  logLevel: 'verbose'
});
```

### Support Resources

- **Developer Documentation**: https://developers.booking.com/docs
- **Extranet Support**: https://admin.booking.com/
- **Technical Support Email**: connectivity@booking.com
- **Partner Support**: +31 20 702 4321
- **Status Page**: https://status.booking.com/

---

## Best Practices

### 1. Rate Management
- Update rates at least twice daily (morning and evening)
- Use bulk updates for efficiency
- Implement competitive pricing strategies
- Set rate plans for different market segments

### 2. Inventory Management
- Synchronize inventory in real-time
- Use bulk updates for multiple dates
- Set appropriate inventory buffers
- Monitor overbooking protection

### 3. Reservation Management
- Confirm reservations within 5 minutes
- Send confirmation emails immediately
- Update reservation status promptly
- Process modifications same-day

### 4. Content Management
- Use high-quality images (minimum 1024x768)
- Provide detailed room descriptions
- Translate content for all major markets
- Update seasonal information regularly

### 5. Performance Optimization
- Track Genius program participation
- Monitor review scores
- Maintain high acceptance rate (>95%)
- Respond to reviews within 24 hours

---

## Next Steps

1. ✅ Complete Booking.com certification
2. ✅ Configure property in HMS portal
3. ✅ Test in sandbox environment
4. ✅ Deploy to production
5. ✅ Monitor initial reservations
6. ⏭️ Implement rate synchronization automation
7. ⏭️ Set up reporting dashboards

---

**Document Version**: 1.0  
**Last Updated**: December 26, 2024  
**Next Review**: January 26, 2025
