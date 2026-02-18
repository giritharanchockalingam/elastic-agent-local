# OTA Sandbox Integration - Complete Implementation Guide

## 🎯 Executive Summary

This implementation enables your HMS portal to connect with **Expedia and Booking.com sandbox APIs**, allowing properties/tenants to test all OTA functionality before going live. The system includes comprehensive database schema, API integrations, UI portal, and activation workflows.

## ✅ Implementation Status

### ✓ Completed Components

1. **Database Schema** ✅
   - `ota_configurations` - Store API credentials and settings
   - `ota_bookings` - Track all OTA reservations
   - `ota_property_content` - Cache synced property data
   - `ota_sync_logs` - Audit trail for synchronization
   - `ota_rate_plans` - Rate plan mappings
   - `ota_inventory` - Availability tracking
   - `ota_webhook_events` - Incoming webhook handling
   - All tables include RLS policies and proper indexes

2. **Supabase Edge Functions** ✅
   - `expedia-api` - Complete Expedia Partner Solutions integration
   - `bookingcom-api` - Complete Booking.com Connectivity integration
   - Both support sandbox and production environments
   - Comprehensive error handling and logging

3. **Frontend Portal** ✅
   - `OTAPortalConfiguration` component - Main configuration UI
   - Expedia configuration panel with credentials management
   - Booking.com configuration panel with credentials management
   - Real-time statistics and analytics
   - Connection testing and data synchronization
   - Integrated documentation tab

4. **Routing** ✅
   - `/ota-portal` route configured in App.tsx
   - Accessible from the main navigation

## 📋 Files Created/Modified

### New Files Created

```
supabase/migrations/
└── 20251226_create_ota_tables.sql          # Complete OTA database schema

src/components/ota/
└── OTAPortalConfiguration.tsx              # Main OTA configuration component

src/pages/
└── OTAPortal.tsx                           # OTA Portal page with tabs

docs/
└── OTA_SANDBOX_INTEGRATION_COMPLETE.md     # This document
```

### Modified Files

```
src/App.tsx                                  # Added OTA Portal route and import
```

### Existing Files (Already Implemented)

```
supabase/functions/expedia-api/index.ts     # Expedia API edge function
supabase/functions/bookingcom-api/index.ts  # Booking.com API edge function
```

## 🚀 Deployment Instructions

### Step 1: Database Migration

```bash
# Apply the OTA tables migration to your Supabase instance
cd /path/to/hms-gcp-refactor
supabase db push supabase/migrations/20251226_create_ota_tables.sql
```

Or manually execute the SQL in Supabase Dashboard:
1. Go to Supabase Dashboard → SQL Editor
2. Open `supabase/migrations/20251226_create_ota_tables.sql`
3. Execute the entire script

### Step 2: Verify Edge Functions

The edge functions are already deployed. Verify they're active:

```bash
supabase functions list
```

Should show:
- `expedia-api`
- `bookingcom-api`

If not deployed, deploy them:

```bash
supabase functions deploy expedia-api
supabase functions deploy bookingcom-api
```

### Step 3: Build and Deploy Frontend

```bash
# Install dependencies (if not already done)
npm install

# Build the application
npm run build

# Deploy to Vercel or your hosting platform
npm run deploy:github
```

### Step 4: Verify OTA Portal Access

1. Log in to the HMS portal
2. Navigate to `/ota-portal`
3. Verify the page loads with Expedia and Booking.com tabs
4. The portal should be accessible to users with Manager roles

## 🔧 Configuration Guide for Tenants

### Setting Up Expedia Integration

#### 1. Obtain Sandbox Credentials

1. Visit https://developers.expediagroup.com/
2. Sign up for a Partner account
3. Request sandbox access from your account manager
4. You'll receive:
   - API Key
   - API Secret
   - EAN Hotel ID (test property ID)

#### 2. Configure in HMS Portal

1. Go to OTA Portal → Configuration → Expedia tab
2. Enter your credentials:
   - **API Key**: Your Expedia API key
   - **API Secret**: Your Expedia API secret
   - **EAN Hotel ID**: Your test hotel ID
3. Ensure **Sandbox Mode** is enabled
4. Click "Save Configuration"
5. Click "Test Connection" to verify
6. Toggle "Enable Expedia Integration" to activate

#### 3. Sync Data

1. Click "Sync Data" to pull test bookings and property content
2. Monitor the Statistics cards for updates
3. Check sync logs in the backend for any errors

### Setting Up Booking.com Integration

#### 1. Obtain Sandbox Credentials

1. Visit https://developers.booking.com/
2. Join the Connectivity Program
3. Request sandbox access via Partner Hub
4. You'll receive:
   - Username
   - Password
   - Hotel ID (test property ID)
   - Partner ID

#### 2. Configure in HMS Portal

1. Go to OTA Portal → Configuration → Booking.com tab
2. Enter your credentials:
   - **Username**: Your Booking.com username
   - **Password**: Your Booking.com password
   - **Hotel ID**: Your test hotel ID
   - **Partner ID**: Your partner ID
3. Ensure **Sandbox Mode** is enabled
4. Click "Save Configuration"
5. Click "Test Connection" to verify
6. Toggle "Enable Booking.com Integration" to activate

#### 3. Sync Data

1. Click "Sync Data" to pull test reservations
2. Monitor the Statistics cards for updates
3. Check sync logs for synchronization status

## 📊 Available Features

### Expedia Integration

**Supported Actions:**
- ✅ Get Bookings (`getBookings`)
- ✅ Get Booking Details (`getBookingDetails`)
- ✅ Create Booking (`createBooking`)
- ✅ Modify Booking (`modifyBooking`)
- ✅ Cancel Booking (`cancelBooking`)
- ✅ Check Availability (`checkAvailability`)
- ✅ Update Rates (`updateRates`)
- ✅ Update Inventory (`updateInventory`)
- ✅ Sync Content (`syncContent`)

### Booking.com Integration

**Supported Actions:**
- ✅ Get Reservations (`getReservations`)
- ✅ Get Reservation Details (`getReservationDetails`)
- ✅ Create Reservation (`createReservation`)
- ✅ Modify Reservation (`modifyReservation`)
- ✅ Cancel Reservation (`cancelReservation`)
- ✅ Check Availability (`checkAvailability`)
- ✅ Update Rates (`updateRates`)
- ✅ Update Availability (`updateAvailability`)
- ✅ Sync Property Info (`syncPropertyInfo`)

## 🔐 Security & Access Control

### RBAC Permissions

The OTA Portal is accessible to users with the following roles:
- Property Manager
- General Manager
- Admin
- Super Admin

Row Level Security (RLS) policies ensure users can only access OTA data for properties they're assigned to.

### Credentials Storage

- All API credentials are stored encrypted in the `ota_configurations` table
- Credentials are transmitted securely over HTTPS
- Sensitive fields are displayed as password inputs in the UI

## 📈 Monitoring & Analytics

### Statistics Dashboard

Each OTA provider shows:
- **Total Bookings**: All-time booking count
- **Active Bookings**: Currently confirmed/checked-in
- **Total Revenue**: Cumulative revenue from OTA bookings
- **Last Sync**: Timestamp of most recent synchronization

### Sync Logs

All API operations are logged in `ota_sync_logs`:
- Action performed
- Status (pending/completed/failed)
- Records processed
- Error details (if any)
- Timestamps

### Database Queries

```sql
-- View all OTA configurations
SELECT * FROM ota_configurations WHERE property_id = 'your-property-id';

-- View recent bookings
SELECT * FROM ota_bookings 
WHERE property_id = 'your-property-id' 
ORDER BY created_at DESC LIMIT 10;

-- View sync logs
SELECT * FROM ota_sync_logs 
WHERE property_id = 'your-property-id' 
ORDER BY created_at DESC LIMIT 20;

-- Check sync errors
SELECT * FROM ota_sync_logs 
WHERE status = 'failed' 
ORDER BY created_at DESC;
```

## 🧪 Testing Checklist

### Pre-Deployment Tests

- [ ] Database migration executes without errors
- [ ] All OTA tables are created with proper indexes
- [ ] RLS policies are active and working
- [ ] Edge functions deploy successfully

### Post-Deployment Tests

- [ ] OTA Portal page loads at `/ota-portal`
- [ ] Both Expedia and Booking.com tabs render
- [ ] Configuration forms accept input
- [ ] Save Configuration updates database
- [ ] Test Connection calls the correct edge function
- [ ] Statistics display correctly
- [ ] Sync Data triggers synchronization
- [ ] Error handling works (test with invalid credentials)

### Integration Tests

#### Expedia Tests
1. Configure with test credentials
2. Test connection - should succeed with valid credentials
3. Sync data - should retrieve test bookings
4. Check `ota_bookings` table for new records
5. Verify statistics update

#### Booking.com Tests
1. Configure with test credentials
2. Test connection - should succeed with valid credentials
3. Sync data - should retrieve test reservations
4. Check `ota_bookings` table for new records
5. Verify statistics update

## 🚨 Troubleshooting

### Common Issues

#### "Integration not configured" Error

**Cause**: No configuration record in database
**Solution**: 
1. Complete the configuration form
2. Click "Save Configuration"
3. Verify record exists in `ota_configurations` table

#### Connection Test Fails

**Cause**: Invalid credentials or network issues
**Solution**:
1. Double-check all credentials
2. Verify sandbox mode is enabled
3. Check edge function logs for detailed errors
4. Ensure Supabase has network access to OTA APIs

#### No Bookings After Sync

**Cause**: Empty test data or date range issues
**Solution**:
1. Sandbox environments may have limited test data
2. Adjust date range in sync parameters
3. Check sync logs for specific errors
4. Verify test property ID is correct

#### RLS Policy Blocking Access

**Cause**: User not assigned to property
**Solution**:
1. Verify user exists in `user_properties` table
2. Check user's role in `user_roles` table
3. Ensure user has appropriate manager role

### Debugging

Enable detailed logging:

```javascript
// In edge function
console.log('OTA Request:', { action, params, property_id });
console.log('OTA Response:', result);
```

View logs in Supabase Dashboard:
1. Go to Edge Functions → Select function
2. View Logs tab
3. Filter by timestamp

## 📚 API Endpoints

### Expedia API

**Base URL (Sandbox)**: `https://test.ean.com/v3`

Key endpoints:
- Bookings: `/v3/bookings`
- Availability: `/v3/properties/availability`
- Content: `/v3/properties/content`
- Rates: `/v3/properties/rates`

### Booking.com API

**Base URL (Sandbox)**: `https://distribution-xml.booking.com/2.4/json`

Key endpoints:
- Reservations: `/2.4/json/reservations`
- Availability: `/2.4/json/availability`
- Rates: `/2.4/json/rateplans`
- Properties: `/2.4/json/properties`

## 🔄 Going to Production

When ready to switch from sandbox to production:

### 1. Obtain Production Credentials

Contact your OTA account managers to:
- Request production API access
- Complete any required certifications
- Sign necessary agreements

### 2. Update Configuration

1. Go to OTA Portal → Configuration
2. Enter production credentials
3. **Disable Sandbox Mode**
4. Test connection with production API
5. Monitor initial sync closely

### 3. Production Checklist

- [ ] Production credentials obtained
- [ ] Sandbox mode disabled
- [ ] Test connection successful
- [ ] Initial sync completed
- [ ] Bookings flowing correctly
- [ ] Staff trained on OTA workflow
- [ ] Monitoring alerts configured
- [ ] Support contact information updated

## 📞 Support

### For HMS System Issues

- Check system logs and sync logs
- Review this documentation
- Contact HMS development team

### For OTA API Issues

**Expedia:**
- Developer Portal: https://developers.expediagroup.com/
- Support: partner.support@expediagroup.com
- Documentation: https://developers.expediagroup.com/docs/

**Booking.com:**
- Partner Hub: https://admin.booking.com/
- Support: connectivity@booking.com
- Documentation: https://developers.booking.com/api/

## 🎓 Additional Resources

### Documentation Files

In the `docs/` directory:
- `OTA_PORTAL_ENABLEMENT_MASTER_GUIDE.md` - Comprehensive overview
- `EXPEDIA_INTEGRATION_COMPLETE_GUIDE.md` - Expedia-specific guide
- `BOOKING_COM_INTEGRATION_COMPLETE_GUIDE.md` - Booking.com-specific guide
- `OTA_IMPLEMENTATION_COMPLETE_SUMMARY.md` - Implementation summary

### Related Pages

- Channel Manager (`/channel-manager`) - Multi-channel distribution
- Booking Engine (`/booking-engine`) - Direct bookings
- Reservations (`/reservations`) - All reservations management

## ✨ Features for Future Enhancement

### Planned Features

1. **Automated Webhooks**
   - Real-time booking notifications
   - Automatic inventory updates
   - Price change alerts

2. **Advanced Analytics**
   - Channel performance comparison
   - Revenue optimization suggestions
   - Booking trends and forecasting

3. **Bulk Operations**
   - Mass rate updates
   - Inventory bulk sync
   - Property content updates

4. **Additional OTAs**
   - Airbnb integration
   - Agoda support
   - TripAdvisor connectivity

5. **Rate Management**
   - Dynamic pricing rules
   - Seasonal rate automation
   - Competitor rate monitoring

## 🎉 Summary

Your HMS portal now has complete OTA sandbox integration capabilities:

✅ **Database**: Comprehensive schema with 7 tables and full RLS
✅ **APIs**: Edge functions for both Expedia and Booking.com
✅ **UI**: Beautiful configuration portal with real-time stats
✅ **Security**: RBAC-protected with encrypted credentials
✅ **Documentation**: Complete guides for setup and troubleshooting
✅ **Monitoring**: Detailed logging and sync tracking

**Next Steps:**
1. Apply database migrations
2. Deploy frontend changes
3. Test with sandbox credentials
4. Train staff on OTA workflow
5. Go live when ready!

---

**Document Version**: 1.0  
**Last Updated**: December 26, 2024  
**Branch**: feature/ota-sandbox-integration
