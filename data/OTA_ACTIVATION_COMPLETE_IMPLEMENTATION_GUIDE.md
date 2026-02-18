# OTA Integration - Complete Activation Guide

## 🎯 Overview

This guide provides **step-by-step instructions** to activate Expedia and Booking.com integrations in your HMS portal, allowing tenants/properties to leverage these popular OTAs for bookings.

**What You'll Accomplish:**
- ✅ Deploy Expedia and Booking.com API Edge Functions
- ✅ Configure OTA credentials in the database
- ✅ Enable portal UI for OTA management
- ✅ Test and validate OTA connections
- ✅ Enable automatic booking synchronization

**Time Required:** 2-3 hours  
**Prerequisites:** Supabase CLI, Node.js, HMS Portal access

---

## 📚 Table of Contents

1. [Phase 1: Deploy Edge Functions](#phase-1-deploy-edge-functions)
2. [Phase 2: Configure OTA Credentials](#phase-2-configure-ota-credentials)
3. [Phase 3: Enable Portal Features](#phase-3-enable-portal-features)
4. [Phase 4: Test Connections](#phase-4-test-connections)
5. [Phase 5: Enable Webhooks](#phase-5-enable-webhooks)
6. [Phase 6: Production Activation](#phase-6-production-activation)

---

## Phase 1: Deploy Edge Functions

### Step 1.1: Verify Function Files Exist

```bash
# Navigate to your project root
cd /Users/giritharanchockalingam/Desktop/GitHub/hms-gcp-refactor

# Verify the OTA functions exist
ls -la supabase/functions/expedia-api/
ls -la supabase/functions/bookingcom-api/
```

**Expected Output:**
```
supabase/functions/expedia-api/index.ts ✅
supabase/functions/bookingcom-api/index.ts ✅
```

### Step 1.2: Deploy Expedia API Function

```bash
# Deploy to Supabase
npx supabase functions deploy expedia-api --no-verify-jwt

# Verify deployment
npx supabase functions list
```

**Expected Output:**
```
✅ expedia-api deployed successfully
```

### Step 1.3: Deploy Booking.com API Function

```bash
# Deploy to Supabase
npx supabase functions deploy bookingcom-api --no-verify-jwt

# Verify deployment
npx supabase functions list
```

**Expected Output:**
```
✅ bookingcom-api deployed successfully
```

### Step 1.4: Verify All Functions Are Running

```bash
# List all deployed functions
npx supabase functions list

# Should show:
# - expedia-api (active)
# - bookingcom-api (active)
# - channel-manager-api (active)
# - booking-engine-api (active)
# ...and other existing functions
```

---

## Phase 2: Configure OTA Credentials

### Step 2.1: Get Your OTA Credentials

#### For Expedia:
1. Go to https://developers.expediagroup.com/
2. Create an account or sign in
3. Navigate to "My Applications"
4. Create a new application
5. **Save these credentials:**
   - API Key
   - API Secret
   - EAN Hotel ID

#### For Booking.com:
1. Go to https://developers.booking.com/
2. Sign in to your partner account
3. Navigate to "Connectivity" → "API Settings"
4. **Save these credentials:**
   - Partner ID
   - Hotel ID
   - Username
   - Password
   - API Key

### Step 2.2: Insert Credentials into Database

```sql
-- Connect to your Supabase database
-- You can run this from Supabase Dashboard → SQL Editor

-- ===================================
-- EXPEDIA CONFIGURATION
-- ===================================
INSERT INTO ota_configurations (
  property_id,
  provider,
  credentials,
  configuration,
  is_active,
  last_synced_at
) VALUES (
  'your-property-uuid-here', -- Replace with actual property_id
  'expedia',
  jsonb_build_object(
    'api_key', 'YOUR_EXPEDIA_API_KEY',
    'api_secret', 'YOUR_EXPEDIA_API_SECRET',
    'ean_hotel_id', 'YOUR_EXPEDIA_HOTEL_ID'
  ),
  jsonb_build_object(
    'test_mode', true,  -- Set to false for production
    'property_id', 'your-property-uuid-here',
    'sync_interval_minutes', 15,
    'auto_accept_bookings', true
  ),
  true,  -- is_active
  NOW()
);

-- ===================================
-- BOOKING.COM CONFIGURATION
-- ===================================
INSERT INTO ota_configurations (
  property_id,
  provider,
  credentials,
  configuration,
  is_active,
  last_synced_at
) VALUES (
  'your-property-uuid-here', -- Same property_id as above
  'booking_com',
  jsonb_build_object(
    'api_key', 'YOUR_BOOKING_COM_API_KEY',
    'partner_id', 'YOUR_PARTNER_ID',
    'hotel_id', 'YOUR_HOTEL_ID',
    'username', 'YOUR_USERNAME',
    'password', 'YOUR_PASSWORD'
  ),
  jsonb_build_object(
    'test_mode', true,  -- Set to false for production
    'property_id', 'your-property-uuid-here',
    'sync_interval_minutes', 15,
    'auto_accept_bookings', true
  ),
  true,  -- is_active
  NOW()
);
```

### Step 2.3: Verify Credentials Are Stored

```sql
-- Run this query to verify
SELECT 
  id,
  property_id,
  provider,
  is_active,
  created_at
FROM ota_configurations
WHERE property_id = 'your-property-uuid-here';
```

**Expected Output:**
```
id | property_id | provider    | is_active | created_at
1  | uuid-123... | expedia     | true      | 2024-12-26...
2  | uuid-123... | booking_com | true      | 2024-12-26...
```

---

## Phase 3: Enable Portal Features

### Step 3.1: Create OTA Management Page

Create this file if it doesn't exist:  
`src/pages/OTAManagement.tsx`

```tsx
import { useEffect, useState } from 'react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { useToast } from '@/hooks/use-toast';
import { supabase } from '@/lib/supabase';

interface OTAConfig {
  id: string;
  provider: string;
  is_active: boolean;
  last_synced_at: string;
}

export default function OTAManagement() {
  const [configs, setConfigs] = useState<OTAConfig[]>([]);
  const [loading, setLoading] = useState(true);
  const { toast } = useToast();

  useEffect(() => {
    fetchConfigs();
  }, []);

  const fetchConfigs = async () => {
    const { data, error } = await supabase
      .from('ota_configurations')
      .select('id, provider, is_active, last_synced_at')
      .order('provider');

    if (error) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    } else {
      setConfigs(data || []);
    }
    setLoading(false);
  };

  const toggleOTA = async (id: string, currentStatus: boolean) => {
    const { error } = await supabase
      .from('ota_configurations')
      .update({ is_active: !currentStatus })
      .eq('id', id);

    if (error) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    } else {
      toast({
        title: "Success",
        description: `OTA ${!currentStatus ? 'enabled' : 'disabled'}`,
      });
      fetchConfigs();
    }
  };

  const syncOTA = async (provider: string) => {
    toast({
      title: "Syncing...",
      description: `Starting sync for ${provider}`,
    });

    // Call the appropriate Edge Function
    const functionName = provider === 'expedia' ? 'expedia-api' : 'bookingcom-api';
    
    const { data: { session } } = await supabase.auth.getSession();
    
    const response = await fetch(
      `${supabase.supabaseUrl}/functions/v1/${functionName}`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${session?.access_token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          action: 'getBookings',
          params: {
            start_date: new Date().toISOString().split('T')[0],
            end_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
          },
          property_id: 'your-property-uuid', // Get from context
        }),
      }
    );

    const result = await response.json();

    if (result.success) {
      toast({
        title: "Success",
        description: `${provider} synced successfully`,
      });
      fetchConfigs();
    } else {
      toast({
        title: "Error",
        description: result.error,
        variant: "destructive",
      });
    }
  };

  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold mb-6">OTA Integrations</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {configs.map((config) => (
          <Card key={config.id} className="p-6">
            <div className="flex justify-between items-start mb-4">
              <div>
                <h3 className="text-xl font-semibold capitalize">
                  {config.provider.replace('_', '.')}
                </h3>
                <p className="text-sm text-gray-500">
                  Last synced: {new Date(config.last_synced_at).toLocaleString()}
                </p>
              </div>
              <Badge variant={config.is_active ? "success" : "secondary"}>
                {config.is_active ? "Active" : "Inactive"}
              </Badge>
            </div>

            <div className="space-y-3">
              <Button
                onClick={() => toggleOTA(config.id, config.is_active)}
                variant={config.is_active ? "destructive" : "default"}
                className="w-full"
              >
                {config.is_active ? "Disable" : "Enable"}
              </Button>

              {config.is_active && (
                <Button
                  onClick={() => syncOTA(config.provider)}
                  variant="outline"
                  className="w-full"
                >
                  Sync Now
                </Button>
              )}
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
```

### Step 3.2: Add Route to Navigation

Update `src/App.tsx` or your routing file:

```tsx
import OTAManagement from './pages/OTAManagement';

// Add to your routes:
<Route path="/ota-management" element={<OTAManagement />} />
```

### Step 3.3: Add Menu Item

Update your sidebar navigation to include:

```tsx
{
  name: 'OTA Management',
  href: '/ota-management',
  icon: GlobeIcon,
}
```

---

## Phase 4: Test Connections

### Step 4.1: Test Expedia Connection

```bash
# Create a test file: test-expedia.js
cat > test-expedia.js << 'EOF'
const fetch = require('node-fetch');

async function testExpedia() {
  const response = await fetch(
    'YOUR_SUPABASE_URL/functions/v1/expedia-api',
    {
      method: 'POST',
      headers: {
        'Authorization': 'Bearer YOUR_SUPABASE_ANON_KEY',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        action: 'checkAvailability',
        params: {
          start_date: '2025-01-01',
          end_date: '2025-01-07',
        },
        property_id: 'your-property-uuid',
      }),
    }
  );

  const result = await response.json();
  console.log('Expedia Test Result:', JSON.stringify(result, null, 2));
}

testExpedia();
EOF

# Run the test
node test-expedia.js
```

**Expected Output:**
```json
{
  "success": true,
  "data": {
    "availability": [...]
  }
}
```

### Step 4.2: Test Booking.com Connection

```bash
# Create a test file: test-bookingcom.js
cat > test-bookingcom.js << 'EOF'
const fetch = require('node-fetch');

async function testBookingCom() {
  const response = await fetch(
    'YOUR_SUPABASE_URL/functions/v1/bookingcom-api',
    {
      method: 'POST',
      headers: {
        'Authorization': 'Bearer YOUR_SUPABASE_ANON_KEY',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        action: 'checkAvailability',
        params: {
          start_date: '2025-01-01',
          end_date: '2025-01-07',
        },
        property_id: 'your-property-uuid',
      }),
    }
  );

  const result = await response.json();
  console.log('Booking.com Test Result:', JSON.stringify(result, null, 2));
}

testBookingCom();
EOF

# Run the test
node test-bookingcom.js
```

### Step 4.3: Verify Sync Logs

```sql
-- Check if API calls are being logged
SELECT 
  provider,
  sync_type,
  status,
  records_processed,
  created_at
FROM ota_sync_logs
ORDER BY created_at DESC
LIMIT 10;
```

---

## Phase 5: Enable Webhooks

### Step 5.1: Create Webhook Handler

Create `supabase/functions/ota-webhook/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    const { provider, event_type, data } = await req.json();

    console.log(`Webhook received from ${provider}: ${event_type}`);

    // Handle based on event type
    switch (event_type) {
      case 'booking.created':
        await handleNewBooking(supabaseClient, provider, data);
        break;
      case 'booking.modified':
        await handleModifiedBooking(supabaseClient, provider, data);
        break;
      case 'booking.cancelled':
        await handleCancelledBooking(supabaseClient, provider, data);
        break;
      default:
        console.log(`Unknown event type: ${event_type}`);
    }

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error: any) {
    console.error('Webhook Error:', error);
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    );
  }
});

async function handleNewBooking(client: any, provider: string, data: any) {
  await client.from('ota_bookings').insert({
    provider,
    external_booking_id: data.booking_id || data.reservation_id,
    booking_status: 'confirmed',
    booking_data: data,
    guest_name: data.guest?.name,
    guest_email: data.guest?.email,
    check_in_date: data.check_in,
    check_out_date: data.check_out,
    total_amount: data.total_amount,
    currency_code: data.currency || 'USD',
  });
}

async function handleModifiedBooking(client: any, provider: string, data: any) {
  await client
    .from('ota_bookings')
    .update({
      booking_data: data,
      updated_at: new Date().toISOString(),
    })
    .eq('external_booking_id', data.booking_id || data.reservation_id)
    .eq('provider', provider);
}

async function handleCancelledBooking(client: any, provider: string, data: any) {
  await client
    .from('ota_bookings')
    .update({
      booking_status: 'cancelled',
      cancellation_date: new Date().toISOString(),
      booking_data: data,
    })
    .eq('external_booking_id', data.booking_id || data.reservation_id)
    .eq('provider', provider);
}
```

### Step 5.2: Deploy Webhook Handler

```bash
npx supabase functions deploy ota-webhook --no-verify-jwt
```

### Step 5.3: Configure Webhooks in OTA Portals

#### Expedia:
1. Go to https://developers.expediagroup.com/
2. Navigate to your application
3. Add webhook URL: `YOUR_SUPABASE_URL/functions/v1/ota-webhook`
4. Subscribe to events:
   - Booking Created
   - Booking Modified
   - Booking Cancelled

#### Booking.com:
1. Go to https://admin.booking.com/
2. Navigate to Connectivity → Webhooks
3. Add webhook URL: `YOUR_SUPABASE_URL/functions/v1/ota-webhook`
4. Subscribe to events:
   - New Reservation
   - Reservation Modified
   - Reservation Cancelled

---

## Phase 6: Production Activation

### Step 6.1: Switch to Production Credentials

```sql
-- Update Expedia to use production credentials
UPDATE ota_configurations
SET 
  credentials = jsonb_build_object(
    'api_key', 'YOUR_PRODUCTION_API_KEY',
    'api_secret', 'YOUR_PRODUCTION_API_SECRET',
    'ean_hotel_id', 'YOUR_PRODUCTION_HOTEL_ID'
  ),
  configuration = jsonb_set(configuration, '{test_mode}', 'false'::jsonb)
WHERE provider = 'expedia';

-- Update Booking.com to use production credentials
UPDATE ota_configurations
SET 
  credentials = jsonb_build_object(
    'api_key', 'YOUR_PRODUCTION_API_KEY',
    'partner_id', 'YOUR_PRODUCTION_PARTNER_ID',
    'hotel_id', 'YOUR_PRODUCTION_HOTEL_ID',
    'username', 'YOUR_PRODUCTION_USERNAME',
    'password', 'YOUR_PRODUCTION_PASSWORD'
  ),
  configuration = jsonb_set(configuration, '{test_mode}', 'false'::jsonb)
WHERE provider = 'booking_com';
```

### Step 6.2: Enable Scheduled Sync Jobs

Create a scheduled job to sync bookings automatically:

```sql
-- This requires pg_cron extension
SELECT cron.schedule(
  'sync-ota-bookings',
  '*/15 * * * *',  -- Every 15 minutes
  $$
  SELECT net.http_post(
    url := 'YOUR_SUPABASE_URL/functions/v1/expedia-api',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer YOUR_SERVICE_ROLE_KEY"}'::jsonb,
    body := '{"action": "getBookings", "params": {"start_date": "' || CURRENT_DATE || '", "end_date": "' || (CURRENT_DATE + 30) || '"}}'::jsonb
  );
  $$
);

SELECT cron.schedule(
  'sync-bookingcom-bookings',
  '*/15 * * * *',  -- Every 15 minutes
  $$
  SELECT net.http_post(
    url := 'YOUR_SUPABASE_URL/functions/v1/bookingcom-api',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer YOUR_SERVICE_ROLE_KEY"}'::jsonb,
    body := '{"action": "getReservations", "params": {"start_date": "' || CURRENT_DATE || '", "end_date": "' || (CURRENT_DATE + 30) || '"}}'::jsonb
  );
  $$
);
```

### Step 6.3: Monitor Production

```sql
-- Create monitoring dashboard query
SELECT 
  provider,
  COUNT(*) as total_bookings,
  SUM(CASE WHEN booking_status = 'confirmed' THEN 1 ELSE 0 END) as confirmed,
  SUM(CASE WHEN booking_status = 'cancelled' THEN 1 ELSE 0 END) as cancelled,
  SUM(total_amount) as total_revenue,
  MAX(created_at) as last_booking
FROM ota_bookings
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY provider;
```

---

## ✅ Completion Checklist

- [ ] Phase 1: Edge Functions deployed
- [ ] Phase 2: OTA credentials configured
- [ ] Phase 3: Portal UI enabled
- [ ] Phase 4: Connections tested successfully
- [ ] Phase 5: Webhooks configured and working
- [ ] Phase 6: Production credentials activated
- [ ] Scheduled sync jobs running
- [ ] Monitoring dashboard set up
- [ ] Staff trained on new features

---

## 🆘 Troubleshooting

### Issue: "Integration not configured" Error

**Solution:**
```sql
-- Verify configuration exists
SELECT * FROM ota_configurations WHERE provider = 'expedia';

-- If missing, re-insert credentials (see Phase 2.2)
```

### Issue: API Call Returns 401 Unauthorized

**Solution:**
- Verify API credentials are correct
- Check if test_mode matches the credentials (sandbox vs production)
- Regenerate API keys from OTA portal if needed

### Issue: Webhooks Not Receiving Events

**Solution:**
- Verify webhook URL is publicly accessible
- Check webhook configuration in OTA portal
- Review webhook logs in Supabase Dashboard

---

## 📊 Success Metrics

After activation, track these metrics:

```sql
-- Daily OTA Performance
SELECT 
  DATE(created_at) as date,
  provider,
  COUNT(*) as bookings,
  SUM(total_amount) as revenue
FROM ota_bookings
WHERE created_at >= CURRENT_DATE - 30
GROUP BY DATE(created_at), provider
ORDER BY date DESC;
```

---

## 🎉 Next Steps

Once activated:
1. Train property managers on OTA management features
2. Set up rate and inventory sync schedules
3. Configure automatic booking confirmations
4. Enable revenue reporting and analytics
5. Monitor performance and optimize

---

**Document Version:** 1.0  
**Last Updated:** December 26, 2024  
**Questions?** Contact your HMS administrator
