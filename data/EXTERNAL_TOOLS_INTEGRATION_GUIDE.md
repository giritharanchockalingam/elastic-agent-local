# External Tools Integration Guide

## Overview

This guide documents the production-ready integrations for the External Tools category, including Booking Engine, Channel Manager, and Payment Gateway. All integrations support sandbox/test mode for safe testing and validation.

---

## 🎯 Booking Engine Integration

### Supported Providers
- **Booking.com** - Full API integration with sandbox support
- **Expedia** - Full API integration with sandbox support
- **Internal** - Default booking system

### Features
- ✅ Real-time availability checking
- ✅ Multi-provider booking creation
- ✅ Booking cancellation
- ✅ Sandbox/test mode support
- ✅ Secure API credential management

### API Services
- `src/services/booking-engine/booking-com-api.ts` - Booking.com API client
- `src/services/booking-engine/expedia-api.ts` - Expedia API client
- `src/services/booking-engine/index.ts` - Unified booking engine service

### Edge Function
- `supabase/functions/booking-engine-api/index.ts` - Secure backend API handler

### Configuration
Store credentials in `third_party_integrations` table:
```sql
{
  "integration_name": "Booking.com",
  "integration_type": "booking_engine",
  "provider": "booking.com",
  "credentials": {
    "api_key": "your_api_key",
    "api_secret": "your_api_secret"
  },
  "configuration": {
    "test_mode": true,
    "hotel_id": "your_hotel_id"
  },
  "is_enabled": true
}
```

### Usage Example
```typescript
import { BookingEngineService } from '@/services/booking-engine';
import { loadIntegrationConfigs } from '@/services/config/integration-config';

const configs = await loadIntegrationConfigs();
const bookingService = new BookingEngineService(configs.bookingEngine!);

// Get availability
const rooms = await bookingService.getAvailability({
  checkIn: '2024-01-15',
  checkOut: '2024-01-17',
  adults: 2,
  propertyId: 'hotel-123'
});

// Create booking
const booking = await bookingService.createBooking({
  provider: 'booking.com',
  roomId: 'room-123',
  checkIn: '2024-01-15',
  checkOut: '2024-01-17',
  guests: {
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com',
    phone: '+1234567890'
  },
  adults: 2
});
```

---

## 🔄 Channel Manager Integration

### Supported Providers
- **SiteMinder** - Full API integration with sandbox support
- **Cloudbeds** - Full API integration with sandbox support

### Features
- ✅ Inventory synchronization
- ✅ Rate management
- ✅ Booking synchronization from channels
- ✅ Real-time availability updates
- ✅ Sandbox/test mode support

### API Services
- `src/services/channel-manager/siteminder-api.ts` - SiteMinder API client
- `src/services/channel-manager/cloudbeds-api.ts` - Cloudbeds API client
- `src/services/channel-manager/index.ts` - Unified channel manager service

### Edge Function
- `supabase/functions/channel-manager-api/index.ts` - Secure backend API handler

### Configuration
```sql
{
  "integration_name": "SiteMinder Integration",
  "integration_type": "Channel Manager",
  "provider": "siteminder",
  "credentials": {
    "api_key": "your_api_key",
    "api_secret": "your_api_secret"
  },
  "configuration": {
    "test_mode": true,
    "property_id": "your_property_id"
  },
  "is_enabled": true
}
```

### Usage Example
```typescript
import { ChannelManagerService } from '@/services/channel-manager';
import { loadIntegrationConfigs } from '@/services/config/integration-config';

const configs = await loadIntegrationConfigs();
const channelService = new ChannelManagerService(configs.channelManager!);

// Sync inventory
const inventory = await channelService.syncInventory({
  propertyId: 'property-123',
  startDate: '2024-01-01',
  endDate: '2024-01-31'
});

// Get bookings from channels
const bookings = await channelService.getBookings(
  'property-123',
  '2024-01-01',
  '2024-01-31'
);

// Sync all data
const syncResult = await channelService.syncAll(
  'property-123',
  '2024-01-01',
  '2024-01-31'
);
```

---

## 💳 Payment Gateway Integration

### Supported Providers
- **Stripe** - Full integration (existing, enhanced)
- **Razorpay** - Full integration with sandbox support

### Features
- ✅ Payment processing
- ✅ Refund management
- ✅ Payment verification
- ✅ Transaction history
- ✅ Sandbox/test mode support
- ✅ Webhook handling

### API Services
- `src/services/payment-gateway/razorpay-api.ts` - Razorpay API client
- `src/services/payment-gateway/index.ts` - Unified payment gateway service

### Edge Function
- `supabase/functions/razorpay-api/index.ts` - Secure backend API handler

### Configuration
```sql
{
  "integration_name": "Razorpay",
  "integration_type": "payment_gateway",
  "provider": "razorpay",
  "credentials": {
    "key_id": "rzp_test_...",
    "key_secret": "your_key_secret",
    "webhook_secret": "your_webhook_secret"
  },
  "configuration": {
    "test_mode": true
  },
  "is_enabled": true
}
```

### Usage Example
```typescript
import { PaymentGatewayService } from '@/services/payment-gateway';
import { loadIntegrationConfigs } from '@/services/config/integration-config';

const configs = await loadIntegrationConfigs();
const paymentService = new PaymentGatewayService(configs.paymentGateway!);

// Create payment order (Razorpay)
const payment = await paymentService.createPayment({
  provider: 'razorpay',
  amount: 1000,
  currency: 'INR',
  description: 'Hotel booking',
  customer: {
    name: 'John Doe',
    email: 'john@example.com',
    phone: '+1234567890'
  }
});

// Create refund
const refund = await paymentService.createRefund({
  provider: 'razorpay',
  paymentId: 'pay_123',
  amount: 500,
  reason: 'Customer request'
});
```

---

## 🔐 Security Best Practices

1. **Never store API credentials in frontend code**
   - All credentials are stored in Supabase database
   - Edge Functions handle all API calls with credentials

2. **Use Edge Functions for API calls**
   - All external API calls go through Supabase Edge Functions
   - Credentials are never exposed to the client

3. **Sandbox Mode**
   - Always test in sandbox mode first
   - Use test API keys for development
   - Switch to production only after thorough testing

4. **Environment Variables**
   - Store sensitive keys in Supabase secrets
   - Use environment-specific configurations

---

## 📋 Setup Instructions

### 1. Database Setup

Ensure `third_party_integrations` table exists with proper schema:
- `integration_name` (text)
- `integration_type` (text)
- `provider` (text)
- `credentials` (jsonb)
- `configuration` (jsonb)
- `is_enabled` (boolean)
- `status` (text)

### 2. Configure Integrations

Use the UI pages to configure:
- **Booking Engine**: `/booking-engine` → Settings tab
- **Channel Manager**: `/channel-manager` → Add/Edit channel
- **Payment Gateway**: `/payment-gateway` → Configuration tab

### 3. Test in Sandbox Mode

1. Enable test mode in configuration
2. Use sandbox/test API keys
3. Verify all operations work correctly
4. Check logs for any errors

### 4. Switch to Production

1. Update API keys to production keys
2. Disable test mode
3. Update webhook URLs
4. Monitor for issues

---

## 🧪 Testing

### Sandbox Mode Features
- Mock data when API calls fail
- Safe testing environment
- No real transactions
- Full feature parity

### Test Scenarios
1. **Booking Engine**
   - Search availability
   - Create booking
   - Cancel booking

2. **Channel Manager**
   - Sync inventory
   - Update rates
   - Fetch bookings

3. **Payment Gateway**
   - Create payment
   - Process refund
   - Verify payment

---

## 📚 API Documentation Links

- **Booking.com**: https://developers.booking.com/
- **Expedia**: https://developers.expediagroup.com/
- **SiteMinder**: https://developers.siteminder.com/
- **Cloudbeds**: https://developers.cloudbeds.com/
- **Razorpay**: https://razorpay.com/docs/api/
- **Stripe**: https://stripe.com/docs/api

---

## 🐛 Troubleshooting

### Common Issues

1. **"Integration not configured"**
   - Check `third_party_integrations` table
   - Verify `is_enabled` is true
   - Ensure credentials are set

2. **"API call failed"**
   - Verify API keys are correct
   - Check sandbox vs production mode
   - Review Edge Function logs

3. **"Sandbox mode not working"**
   - Ensure `test_mode: true` in configuration
   - Use test API keys
   - Check mock data fallback

---

## ✅ Next Steps

1. Update UI pages to use new services
2. Add configuration UI for each integration
3. Implement webhook handlers
4. Add monitoring and logging
5. Create comprehensive test suite

---

**Status**: ✅ Core services and Edge Functions complete
**Next**: Update UI pages to integrate with services

