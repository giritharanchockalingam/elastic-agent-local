# Next Steps: OTA Integration Implementation

## ✅ Completed
- Database schema created (7 tables)
- Comprehensive Expedia API service
- Comprehensive Booking.com API service
- Documentation

## 🎯 Immediate Next Steps (Priority Order)

### Step 1: Get API Credentials (Required)

#### Expedia Partner Solutions
1. **Register**: Go to https://developers.expediagroup.com/
2. **Contact**: Email lxapi@expedia.com to initiate scoping
3. **Get Credentials**:
   - API Key
   - API Secret
   - Property ID (EAN ID)
   - Sandbox credentials for testing

#### Booking.com Connectivity
1. **Register**: Go to https://developers.booking.com/
2. **Complete Certification**: Follow their certification process
3. **Get Credentials**:
   - API Key
   - API Secret
   - Hotel ID
   - Partner ID
   - Sandbox credentials for testing

### Step 2: Configure Integrations in Database

Run this SQL in Supabase SQL Editor:

```sql
-- Expedia Integration
INSERT INTO third_party_integrations (
  integration_name,
  integration_type,
  provider,
  credentials,
  configuration,
  is_enabled,
  status,
  property_id
) VALUES (
  'Expedia Partner Solutions',
  'ota',
  'expedia',
  jsonb_build_object(
    'api_key', 'YOUR_EXPEDIA_API_KEY',
    'api_secret', 'YOUR_EXPEDIA_API_SECRET'
  ),
  jsonb_build_object(
    'test_mode', true,
    'property_id', 'YOUR_PROPERTY_ID',
    'ean_id', 'YOUR_EAN_ID'
  ),
  true,
  'active',
  'YOUR_PROPERTY_UUID' -- Replace with actual property UUID
)
ON CONFLICT DO NOTHING;

-- Booking.com Integration
INSERT INTO third_party_integrations (
  integration_name,
  integration_type,
  provider,
  credentials,
  configuration,
  is_enabled,
  status,
  property_id
) VALUES (
  'Booking.com Connectivity',
  'ota',
  'booking.com',
  jsonb_build_object(
    'api_key', 'YOUR_BOOKING_COM_API_KEY',
    'api_secret', 'YOUR_BOOKING_COM_API_SECRET'
  ),
  jsonb_build_object(
    'test_mode', true,
    'hotel_id', 'YOUR_HOTEL_ID',
    'partner_id', 'YOUR_PARTNER_ID'
  ),
  true,
  'active',
  'YOUR_PROPERTY_UUID' -- Replace with actual property UUID
)
ON CONFLICT DO NOTHING;
```

### Step 3: Test API Connections

Create a test script to verify credentials work:

```typescript
// Test script: src/scripts/test-ota-connections.ts
import { ExpediaComprehensiveAPI } from '@/services/ota/expedia-comprehensive-api';
import { BookingComComprehensiveAPI } from '@/services/ota/booking-com-comprehensive-api';

// Test Expedia
const expedia = new ExpediaComprehensiveAPI({
  apiKey: 'your_key',
  apiSecret: 'your_secret',
  environment: 'sandbox',
  propertyId: 'your_property_id'
});

try {
  const rooms = await expedia.getAvailabilityWithRates({
    propertyId: 'your_property_id',
    checkIn: '2025-01-15',
    checkOut: '2025-01-17',
    adults: 2
  });
  console.log('✅ Expedia connection successful:', rooms);
} catch (error) {
  console.error('❌ Expedia connection failed:', error);
}

// Test Booking.com
const bookingCom = new BookingComComprehensiveAPI({
  apiKey: 'your_key',
  apiSecret: 'your_secret',
  environment: 'sandbox',
  hotelId: 'your_hotel_id'
});

try {
  const rooms = await bookingCom.getAvailabilityWithRates({
    hotelId: 'your_hotel_id',
    checkIn: '2025-01-15',
    checkOut: '2025-01-17',
    adults: 2
  });
  console.log('✅ Booking.com connection successful:', rooms);
} catch (error) {
  console.error('❌ Booking.com connection failed:', error);
}
```

### Step 4: Implement Core Integration Services

#### 4.1: Unified OTA Service
Create `src/services/ota/index.ts` - A unified interface for both providers

#### 4.2: Booking Sync Service
Create `src/services/ota/booking-sync-service.ts` - Sync bookings from OTAs to internal system

#### 4.3: Rate Sync Service
Create `src/services/ota/rate-sync-service.ts` - Sync rates from internal to OTAs

#### 4.4: Inventory Sync Service
Create `src/services/ota/inventory-sync-service.ts` - Sync inventory bidirectionally

### Step 5: Create Edge Functions

#### 5.1: Enhanced Booking Engine API
Update `supabase/functions/booking-engine-api/index.ts` to use comprehensive APIs

#### 5.2: Webhook Handler
Create `supabase/functions/ota-webhook-handler/index.ts` for real-time notifications

#### 5.3: Rate Sync API
Create `supabase/functions/rate-sync-api/index.ts` for rate synchronization

#### 5.4: Inventory Sync API
Create `supabase/functions/inventory-sync-api/index.ts` for inventory synchronization

### Step 6: Set Up Scheduled Jobs

Configure scheduled functions for:
- **Rate Sync**: Every 15 minutes
- **Inventory Sync**: Every 5 minutes
- **Booking Sync**: Every 10 minutes
- **Content Sync**: Daily at 2 AM

### Step 7: Configure Webhooks

1. Get webhook URL: `https://your-project.supabase.co/functions/v1/ota-webhook-handler`
2. Configure in Expedia dashboard
3. Configure in Booking.com dashboard
4. Test webhook delivery

### Step 8: Create Frontend Pages

1. **OTA Bookings Page** (`src/pages/OTABookings.tsx`)
2. **Rate Management Page** (`src/pages/OTARateManagement.tsx`)
3. **Inventory Management Page** (`src/pages/OTAInventoryManagement.tsx`)
4. **Content Management Page** (`src/pages/OTAContentManagement.tsx`)
5. **OTA Reports Page** (`src/pages/OTAReports.tsx`)

## 🚀 Quick Start (If You Have Credentials)

If you already have API credentials, you can start testing immediately:

1. **Configure integrations** (Step 2 above)
2. **Test connections** (Step 3 above)
3. **Start with booking sync** - Most critical feature

## 📋 Testing Checklist

### Basic Functionality
- [ ] API authentication works
- [ ] Can fetch availability
- [ ] Can create test booking
- [ ] Can retrieve booking
- [ ] Can cancel booking

### Advanced Features
- [ ] Rate synchronization works
- [ ] Inventory synchronization works
- [ ] Webhooks are received
- [ ] Scheduled jobs run successfully
- [ ] Error handling works
- [ ] Retry logic works

## 🔧 Development Tips

1. **Start with Sandbox**: Always test in sandbox mode first
2. **Use Mock Data**: The APIs return mock data in sandbox mode
3. **Test Incrementally**: Test one feature at a time
4. **Monitor Logs**: Check Supabase function logs for errors
5. **Rate Limits**: Be aware of API rate limits

## 📚 Documentation

- **Implementation Guide**: `docs/OTA_INTEGRATION_IMPLEMENTATION_GUIDE.md`
- **API Coverage**: `docs/COMPREHENSIVE_EXPEDIA_BOOKING_API_INTEGRATION.md`
- **Expedia Docs**: https://developers.expediagroup.com/
- **Booking.com Docs**: https://developers.booking.com/

## ⚠️ Important Notes

1. **API Credentials**: Never commit credentials to git
2. **Sandbox First**: Always test in sandbox before production
3. **Rate Limits**: Respect API rate limits
4. **Error Handling**: Implement robust error handling
5. **Webhook Security**: Verify webhook signatures

## 🎯 Recommended Order

1. ✅ Database schema (DONE)
2. ⏭️ Get API credentials
3. ⏭️ Configure integrations
4. ⏭️ Test basic API calls
5. ⏭️ Implement booking sync
6. ⏭️ Implement rate sync
7. ⏭️ Implement inventory sync
8. ⏭️ Set up webhooks
9. ⏭️ Create frontend pages
10. ⏭️ Set up scheduled jobs

## 💡 Need Help?

- Check the implementation guide for detailed steps
- Review API documentation from Expedia/Booking.com
- Test in sandbox mode first
- Check Supabase function logs for errors


