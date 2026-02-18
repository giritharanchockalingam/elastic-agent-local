# Booking Engine Provider Selection - Quick Guide

## ✅ What Was Added

The BookingEngine page now includes:

1. **Provider Selection UI** - Appears at the top of Step 1
2. **External Provider Support** - Booking.com and Expedia integration
3. **Configuration Dialog** - Link to configure providers
4. **External Room Fetching** - Fetches rooms from external providers
5. **Sandbox Mode** - Mock data fallback for testing

## 🎯 How to Use

### Step 1: Navigate to Booking Engine
```
http://localhost:5173/booking-engine
```

### Step 2: Select a Provider
At the top of the page, you'll see:
- **Internal System** (default) - Uses your internal booking system
- **Booking.com** - Books through Booking.com API
- **Expedia** - Books through Expedia API

### Step 3: Configure External Providers (if needed)
1. Select an external provider (Booking.com or Expedia)
2. Click "Configure" button
3. You'll be directed to Channel Manager to add API credentials
4. Or configure directly in Supabase Dashboard

### Step 4: Select Dates and Search
1. Choose check-in and check-out dates
2. Select number of adults/children
3. Available rooms will load:
   - **Internal**: From your database
   - **External**: From the selected provider's API (or mock data in sandbox)

### Step 5: Complete Booking
1. Select a room
2. Fill in guest details
3. Complete payment
4. Booking confirmation will show

## 🔧 Configuration

### Configure Booking.com
In Supabase Dashboard → SQL Editor:
```sql
INSERT INTO third_party_integrations (
  integration_name,
  integration_type,
  provider,
  credentials,
  configuration,
  is_enabled,
  status
) VALUES (
  'Booking.com',
  'booking_engine',
  'booking.com',
  '{"api_key": "your_sandbox_api_key", "api_secret": "your_sandbox_api_secret"}'::jsonb,
  '{"test_mode": true, "hotel_id": "your_hotel_id"}'::jsonb,
  true,
  'active'
);
```

### Configure Expedia
```sql
INSERT INTO third_party_integrations (
  integration_name,
  integration_type,
  provider,
  credentials,
  configuration,
  is_enabled,
  status
) VALUES (
  'Expedia',
  'booking_engine',
  'expedia',
  '{"api_key": "your_sandbox_api_key", "api_secret": "your_sandbox_api_secret"}'::jsonb,
  '{"test_mode": true, "property_id": "your_property_id"}'::jsonb,
  true,
  'active'
);
```

## 🧪 Testing

### Test Internal System
1. Select "Internal System"
2. Choose dates
3. Select a room
4. Complete booking
5. Should work as before

### Test External Providers (Sandbox)
1. Select "Booking.com" or "Expedia"
2. Choose dates
3. You'll see mock rooms (sandbox mode)
4. Select a room
5. Complete booking
6. Booking will be created via Edge Function

## 📋 Features

- ✅ Provider selection dropdown
- ✅ External provider room fetching
- ✅ Configuration dialog
- ✅ Sandbox mode with mock data
- ✅ Seamless fallback to internal system
- ✅ External booking creation via Edge Functions

## 🐛 Troubleshooting

### Provider selection not showing
- Clear browser cache
- Check browser console for errors
- Verify the page loaded correctly

### External rooms not loading
- Check if provider is configured in database
- Verify Edge Function is deployed
- Check browser console for API errors
- In sandbox mode, mock data should appear

### Configuration button not working
- Ensure you're logged in
- Check if Channel Manager page exists
- Verify navigation permissions

---

**Status**: ✅ Provider selection UI added and functional
**Next**: Test with real API credentials when ready

