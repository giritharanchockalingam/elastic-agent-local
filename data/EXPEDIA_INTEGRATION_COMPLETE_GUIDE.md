# Expedia Partner Solutions - Complete Integration Guide

## 🎯 Overview

This guide provides step-by-step instructions to integrate your HMS portal with **ALL** Expedia Partner Solutions APIs, enabling your hotel tenants to leverage Expedia's global distribution network.

## 📋 Table of Contents

1. [Getting Started](#getting-started)
2. [API Registration](#api-registration)
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
- ✅ Property listed on Expedia (or ready to list)
- ✅ Expedia partner account with API access
- ✅ HMS portal database access
- ✅ Technical contact email at Expedia
- ✅ HTTPS-enabled domain for webhooks

### Expedia API Ecosystem

Expedia provides several API products:
1. **Rapid API (Partner Solutions)** - For booking, availability, rates
2. **EAN Content API** - For property and room content
3. **Image API** - For property and room images
4. **Webhook API** - For real-time notifications
5. **Reporting API** - For performance metrics

---

## API Registration

### Step 1: Create Expedia Partner Account

1. **Visit Expedia Partner Central**
   ```
   URL: https://partner.expediagroup.com/
   ```

2. **Sign Up or Log In**
   - Use your property's official business email
   - Complete property details
   - Verify your property information

3. **Request API Access**
   - Navigate to "Developer Tools" or "API Access"
   - Submit request for Partner Solutions API access
   - Include intended use case (property management system)

### Step 2: Complete Partner Application

**Information Required**:
- Property details (name, address, contact)
- Business registration documents
- Tax identification number
- Bank account information (for payouts)
- Property images (high-resolution)
- Room type descriptions

**Timeline**: 5-10 business days for approval

### Step 3: Get API Credentials

Once approved, you'll receive:
```json
{
  "api_key": "your-expedia-api-key",
  "api_secret": "your-expedia-api-secret",
  "property_id": "12345",
  "ean_id": "67890",
  "sandbox_api_key": "sandbox-key",
  "sandbox_api_secret": "sandbox-secret"
}
```

**Security Note**: Store these credentials securely, never commit to git.

---

## Authentication Setup

### Step 1: Configure in HMS Database

Run this SQL in Supabase SQL Editor:

```sql
-- Insert Expedia integration configuration
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
  'Expedia Partner Solutions',
  'ota',
  'expedia',
  jsonb_build_object(
    'api_key', 'YOUR_SANDBOX_API_KEY',
    'api_secret', 'YOUR_SANDBOX_API_SECRET',
    'production_api_key', 'YOUR_PRODUCTION_API_KEY',
    'production_api_secret', 'YOUR_PRODUCTION_API_SECRET'
  ),
  jsonb_build_object(
    'test_mode', true,
    'property_id', 'YOUR_PROPERTY_ID',
    'ean_id', 'YOUR_EAN_ID',
    'region', 'NA', -- NA, EU, APAC
    'language', 'en-US',
    'currency', 'USD'
  ),
  true,
  'active',
  'YOUR_PROPERTY_UUID', -- Replace with actual UUID
  'https://your-domain.com/api/webhooks/expedia'
)
ON CONFLICT (provider, property_id) DO UPDATE SET
  credentials = EXCLUDED.credentials,
  configuration = EXCLUDED.configuration,
  updated_at = CURRENT_TIMESTAMP;
```

### Step 2: Set Environment Variables

Add to `.env.production`:

```env
# Expedia API Configuration
EXPEDIA_API_KEY=your_sandbox_api_key
EXPEDIA_API_SECRET=your_sandbox_api_secret
EXPEDIA_PROPERTY_ID=your_property_id
EXPEDIA_EAN_ID=your_ean_id
EXPEDIA_TEST_MODE=true

# Production credentials (comment out until ready)
# EXPEDIA_PROD_API_KEY=your_production_api_key
# EXPEDIA_PROD_API_SECRET=your_production_api_secret
```

### Step 3: Test Authentication

Create a test script to verify credentials:

```typescript
// scripts/test-expedia-auth.ts
import { ExpediaComprehensiveAPI } from '@/services/ota/expedia-comprehensive-api';

async function testExpediaAuth() {
  const expedia = new ExpediaComprehensiveAPI({
    apiKey: process.env.EXPEDIA_API_KEY!,
    apiSecret: process.env.EXPEDIA_API_SECRET!,
    environment: 'sandbox',
    propertyId: process.env.EXPEDIA_PROPERTY_ID!
  });

  try {
    // Test with a simple API call
    const property = await expedia.getProperty(process.env.EXPEDIA_PROPERTY_ID!);
    console.log('✅ Authentication successful!');
    console.log('Property:', property.name);
    return true;
  } catch (error) {
    console.error('❌ Authentication failed:', error);
    return false;
  }
}

testExpediaAuth();
```

Run the test:
```bash
npm run test:expedia-auth
```

---

## Property Configuration

### Step 1: Configure Property Details

```typescript
// Example: Configure property in Expedia
const propertyConfig = {
  propertyId: 'YOUR_PROPERTY_ID',
  name: 'Grand Hotel Downtown',
  address: {
    line1: '123 Main Street',
    city: 'New York',
    state: 'NY',
    postalCode: '10001',
    country: 'US'
  },
  contact: {
    phone: '+1-555-0100',
    email: 'info@grandhotel.com'
  },
  location: {
    latitude: 40.7128,
    longitude: -74.0060
  },
  checkInTime: '15:00',
  checkOutTime: '11:00',
  policies: {
    cancellation: {
      type: 'flexible',
      freeUntilHours: 24
    },
    pets: {
      allowed: true,
      fee: 50
    }
  },
  amenities: [
    'wifi',
    'parking',
    'pool',
    'fitness_center',
    'restaurant',
    'room_service',
    'concierge'
  ]
};

// Update property using API
await expedia.updateProperty(propertyConfig);
```

### Step 2: Configure Room Types

```typescript
// Define room types
const roomTypes = [
  {
    roomTypeId: 'RT001',
    name: 'Deluxe King Room',
    description: 'Spacious room with king bed, city view',
    maxOccupancy: 2,
    bedTypes: [
      { type: 'king', count: 1 }
    ],
    roomSize: {
      value: 350,
      unit: 'sqft'
    },
    amenities: [
      'wifi',
      'tv',
      'minibar',
      'safe',
      'coffee_maker'
    ],
    images: [
      {
        url: 'https://your-cdn.com/images/deluxe-king-1.jpg',
        caption: 'Deluxe King Room - Main View',
        isPrimary: true
      }
    ]
  },
  {
    roomTypeId: 'RT002',
    name: 'Executive Suite',
    description: 'Luxury suite with separate living area',
    maxOccupancy: 4,
    bedTypes: [
      { type: 'king', count: 1 },
      { type: 'sofa_bed', count: 1 }
    ],
    roomSize: {
      value: 600,
      unit: 'sqft'
    },
    amenities: [
      'wifi',
      'tv',
      'minibar',
      'safe',
      'coffee_maker',
      'living_room',
      'balcony'
    ],
    images: [
      {
        url: 'https://your-cdn.com/images/executive-suite-1.jpg',
        caption: 'Executive Suite - Living Area',
        isPrimary: true
      }
    ]
  }
];

// Create room types
for (const roomType of roomTypes) {
  await expedia.createRoomType(propertyConfig.propertyId, roomType);
}
```

### Step 3: Upload Images

```typescript
// Upload property images
const propertyImages = [
  {
    url: 'https://your-cdn.com/images/hotel-exterior.jpg',
    category: 'exterior',
    caption: 'Hotel Exterior',
    isPrimary: true
  },
  {
    url: 'https://your-cdn.com/images/hotel-lobby.jpg',
    category: 'lobby',
    caption: 'Hotel Lobby'
  },
  {
    url: 'https://your-cdn.com/images/pool.jpg',
    category: 'amenity',
    caption: 'Outdoor Pool'
  }
];

await expedia.uploadImages(propertyConfig.propertyId, propertyImages);
```

---

## API Implementation

### 1. Availability & Rates API

#### Get Availability with Rates
```typescript
// Fetch availability for date range
const availability = await expedia.getAvailabilityWithRates({
  propertyId: 'YOUR_PROPERTY_ID',
  checkIn: '2025-02-01',
  checkOut: '2025-02-05',
  adults: 2,
  children: 0,
  ratePlans: ['BAR', 'CORPORATE'] // Optional: filter by rate plans
});

console.log('Available rooms:', availability.rooms);
```

#### Update Rates
```typescript
// Update rates for a room type
await expedia.updateRates({
  propertyId: 'YOUR_PROPERTY_ID',
  roomTypeId: 'RT001',
  ratePlanId: 'BAR',
  rates: [
    {
      date: '2025-02-01',
      rate: 199.00,
      currency: 'USD'
    },
    {
      date: '2025-02-02',
      rate: 229.00,
      currency: 'USD'
    }
  ]
});
```

#### Bulk Rate Update
```typescript
// Update rates for multiple dates
await expedia.bulkUpdateRates({
  propertyId: 'YOUR_PROPERTY_ID',
  roomTypeId: 'RT001',
  ratePlanId: 'BAR',
  startDate: '2025-02-01',
  endDate: '2025-02-28',
  rate: 199.00,
  currency: 'USD',
  daysOfWeek: ['monday', 'tuesday', 'wednesday', 'thursday'] // Weekday rates
});

// Weekend rates
await expedia.bulkUpdateRates({
  propertyId: 'YOUR_PROPERTY_ID',
  roomTypeId: 'RT001',
  ratePlanId: 'BAR',
  startDate: '2025-02-01',
  endDate: '2025-02-28',
  rate: 249.00,
  currency: 'USD',
  daysOfWeek: ['friday', 'saturday', 'sunday'] // Weekend rates
});
```

#### Update Inventory
```typescript
// Update room availability
await expedia.updateInventory({
  propertyId: 'YOUR_PROPERTY_ID',
  roomTypeId: 'RT001',
  inventory: [
    {
      date: '2025-02-01',
      available: 10
    },
    {
      date: '2025-02-02',
      available: 8
    }
  ]
});
```

#### Set Restrictions
```typescript
// Set minimum length of stay
await expedia.updateRestrictions({
  propertyId: 'YOUR_PROPERTY_ID',
  roomTypeId: 'RT001',
  restrictions: [
    {
      date: '2025-02-14', // Valentine's Day
      minLengthOfStay: 2,
      closedToArrival: false,
      closedToDeparture: false
    }
  ]
});
```

### 2. Booking Management API

#### Create Booking
```typescript
// Create a new booking
const booking = await expedia.createBooking({
  propertyId: 'YOUR_PROPERTY_ID',
  roomTypeId: 'RT001',
  ratePlanId: 'BAR',
  checkIn: '2025-02-01',
  checkOut: '2025-02-05',
  guest: {
    firstName: 'John',
    lastName: 'Doe',
    email: 'john.doe@email.com',
    phone: '+1-555-0100'
  },
  adults: 2,
  children: 0,
  specialRequests: 'Late check-in expected around 10 PM'
});

console.log('Booking created:', booking.bookingId);
console.log('Confirmation:', booking.confirmationNumber);
```

#### Get Booking Details
```typescript
// Retrieve booking information
const bookingDetails = await expedia.getBooking('BOOKING_ID');

console.log('Guest:', bookingDetails.guest);
console.log('Status:', bookingDetails.status);
console.log('Total:', bookingDetails.totalAmount);
```

#### Modify Booking
```typescript
// Modify existing booking
const modified = await expedia.modifyBooking({
  bookingId: 'BOOKING_ID',
  modifications: {
    checkIn: '2025-02-02', // Changed check-in date
    checkOut: '2025-02-06', // Changed check-out date
    adults: 3 // Added one more guest
  }
});

console.log('Modified booking:', modified.bookingId);
console.log('Price difference:', modified.priceDifference);
```

#### Cancel Booking
```typescript
// Cancel booking
const cancellation = await expedia.cancelBooking({
  bookingId: 'BOOKING_ID',
  reason: 'Guest requested cancellation'
});

console.log('Cancellation status:', cancellation.status);
console.log('Refund amount:', cancellation.refundAmount);
```

### 3. Payment API

#### Process Payment
```typescript
// Process payment for booking
const payment = await expedia.processPayment({
  bookingId: 'BOOKING_ID',
  amount: 398.00,
  currency: 'USD',
  paymentMethod: {
    type: 'credit_card',
    cardNumber: '4111111111111111',
    expiryMonth: '12',
    expiryYear: '2025',
    cvv: '123',
    cardholderName: 'John Doe'
  }
});

console.log('Payment status:', payment.status);
console.log('Transaction ID:', payment.transactionId);
```

#### Process Refund
```typescript
// Process refund for cancellation
const refund = await expedia.processRefund({
  bookingId: 'BOOKING_ID',
  amount: 398.00,
  currency: 'USD',
  reason: 'Cancellation within free cancellation period'
});

console.log('Refund status:', refund.status);
console.log('Refund ID:', refund.refundId);
```

### 4. Content API

#### Update Property Description
```typescript
// Update property content
await expedia.updateContent({
  propertyId: 'YOUR_PROPERTY_ID',
  content: {
    description: {
      'en-US': 'Luxurious downtown hotel with modern amenities',
      'es-ES': 'Lujoso hotel en el centro con comodidades modernas'
    },
    policies: {
      'en-US': 'Check-in: 3 PM, Check-out: 11 AM. Free cancellation up to 24 hours before arrival.',
      'es-ES': 'Check-in: 15:00, Check-out: 11:00. Cancelación gratuita hasta 24 horas antes de la llegada.'
    }
  }
});
```

### 5. Reporting API

#### Get Booking Report
```typescript
// Generate booking report
const report = await expedia.getBookingReport({
  propertyId: 'YOUR_PROPERTY_ID',
  startDate: '2025-01-01',
  endDate: '2025-01-31',
  groupBy: 'day',
  metrics: ['bookings', 'revenue', 'occupancy']
});

console.log('Total bookings:', report.summary.totalBookings);
console.log('Total revenue:', report.summary.totalRevenue);
console.log('Average occupancy:', report.summary.averageOccupancy);
```

#### Get Revenue Report
```typescript
// Generate revenue report
const revenueReport = await expedia.getRevenueReport({
  propertyId: 'YOUR_PROPERTY_ID',
  startDate: '2025-01-01',
  endDate: '2025-01-31'
});

console.log('Gross revenue:', revenueReport.grossRevenue);
console.log('Commission:', revenueReport.commission);
console.log('Net revenue:', revenueReport.netRevenue);
```

---

## Testing & Validation

### Sandbox Testing

1. **Use Sandbox Credentials**
   ```typescript
   const expedia = new ExpediaComprehensiveAPI({
     apiKey: process.env.EXPEDIA_SANDBOX_API_KEY!,
     apiSecret: process.env.EXPEDIA_SANDBOX_API_SECRET!,
     environment: 'sandbox',
     propertyId: process.env.EXPEDIA_PROPERTY_ID!
   });
   ```

2. **Test Booking Flow**
   ```bash
   # Create test booking
   npm run test:expedia-booking-create
   
   # Retrieve booking
   npm run test:expedia-booking-get
   
   # Modify booking
   npm run test:expedia-booking-modify
   
   # Cancel booking
   npm run test:expedia-booking-cancel
   ```

3. **Test Rate Updates**
   ```bash
   # Update single rate
   npm run test:expedia-rate-update
   
   # Bulk rate update
   npm run test:expedia-rate-bulk-update
   ```

4. **Test Inventory Sync**
   ```bash
   # Update inventory
   npm run test:expedia-inventory-update
   
   # Get inventory status
   npm run test:expedia-inventory-get
   ```

### Validation Checklist

- [ ] Authentication works with sandbox credentials
- [ ] Can retrieve property details
- [ ] Can fetch availability
- [ ] Can create test booking
- [ ] Can retrieve booking details
- [ ] Can modify booking
- [ ] Can cancel booking
- [ ] Can update rates
- [ ] Can update inventory
- [ ] Can upload images
- [ ] Can update content
- [ ] Can process payment
- [ ] Can process refund
- [ ] Can generate reports
- [ ] Webhooks are received and processed

---

## Production Deployment

### Step 1: Switch to Production Credentials

Update `.env.production`:

```env
# Production Expedia Configuration
EXPEDIA_API_KEY=your_production_api_key
EXPEDIA_API_SECRET=your_production_api_secret
EXPEDIA_TEST_MODE=false
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
  credentials = jsonb_set(
    credentials,
    '{api_secret}',
    to_jsonb('YOUR_PRODUCTION_API_SECRET'::text)
  ),
  configuration = jsonb_set(
    configuration,
    '{test_mode}',
    'false'::jsonb
  )
WHERE provider = 'expedia';
```

### Step 2: Configure Webhook URL

1. **Get Your Webhook URL**
   ```
   https://your-domain.supabase.co/functions/v1/ota-webhook-handler
   ```

2. **Register in Expedia Partner Central**
   - Log in to Expedia Partner Central
   - Navigate to "API Settings" → "Webhooks"
   - Add webhook URL
   - Select events to receive:
     - New bookings
     - Booking modifications
     - Booking cancellations
     - Payment updates

3. **Verify Webhook**
   - Expedia will send a verification request
   - Your webhook handler should respond with 200 OK

### Step 3: Monitor Initial Bookings

```sql
-- Monitor bookings from Expedia
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
WHERE b.provider = 'expedia'
  AND b.created_at > NOW() - INTERVAL '24 hours'
ORDER BY b.created_at DESC;
```

### Step 4: Set Up Monitoring

Create alerts for:
- Failed API calls
- Webhook processing errors
- Sync failures
- Rate limit warnings
- High cancellation rates

---

## Troubleshooting

### Common Issues

#### 1. Authentication Errors

**Error**: `401 Unauthorized`

**Solutions**:
- Verify API key and secret are correct
- Check if credentials are for correct environment (sandbox vs production)
- Ensure credentials haven't expired
- Contact Expedia support if issue persists

#### 2. Invalid Property ID

**Error**: `400 Bad Request - Invalid property ID`

**Solutions**:
- Verify property ID matches your Expedia account
- Ensure property is active in Expedia system
- Check if using correct EAN ID

#### 3. Rate Limit Exceeded

**Error**: `429 Too Many Requests`

**Solutions**:
- Implement request queuing
- Add exponential backoff retry logic
- Reduce frequency of API calls
- Use bulk operations when possible

#### 4. Webhook Not Received

**Issue**: Not receiving booking notifications

**Solutions**:
- Verify webhook URL is correct and accessible
- Check if webhook endpoint returns 200 OK
- Review Expedia webhook logs in Partner Central
- Ensure firewall allows Expedia's IP ranges
- Test webhook endpoint manually

#### 5. Inventory Sync Issues

**Issue**: Inventory not updating on Expedia

**Solutions**:
- Check sync logs for errors
- Verify room type IDs match
- Ensure dates are in correct format
- Check if inventory update permissions are enabled

### Debug Mode

Enable debug logging:

```typescript
const expedia = new ExpediaComprehensiveAPI({
  apiKey: process.env.EXPEDIA_API_KEY!,
  apiSecret: process.env.EXPEDIA_API_SECRET!,
  environment: 'sandbox',
  propertyId: process.env.EXPEDIA_PROPERTY_ID!,
  debug: true // Enable debug logging
});
```

### Support Resources

- **Technical Documentation**: https://developers.expediagroup.com/docs
- **API Support Email**: apisupport@expediagroup.com
- **Partner Support**: 1-866-539-3526
- **Developer Forum**: https://community.expediapartnersolutions.com/

---

## Best Practices

### 1. Rate Management
- Update rates at least daily
- Use bulk updates for efficiency
- Set competitive rates based on market demand
- Implement dynamic pricing strategies

### 2. Inventory Management
- Keep inventory synchronized in real-time
- Use overbooking protection
- Monitor inventory levels daily
- Set inventory buffers for walk-ins

### 3. Booking Management
- Process bookings immediately
- Send confirmation emails promptly
- Handle modifications within 24 hours
- Process cancellations same-day

### 4. Content Management
- Use high-quality images (2000x1500px minimum)
- Write detailed, accurate descriptions
- Update content seasonally
- Translate content for international markets

### 5. Performance Monitoring
- Track conversion rates
- Monitor average daily rates (ADR)
- Analyze cancellation patterns
- Review guest feedback

---

## Next Steps

1. ✅ Complete Expedia registration
2. ✅ Configure property in HMS portal
3. ✅ Test in sandbox environment
4. ✅ Deploy to production
5. ✅ Monitor initial bookings
6. ⏭️ Implement Booking.com integration (see [Booking.com Guide](BOOKING_COM_INTEGRATION_COMPLETE_GUIDE.md))

---

**Document Version**: 1.0  
**Last Updated**: December 26, 2024  
**Next Review**: January 26, 2025
