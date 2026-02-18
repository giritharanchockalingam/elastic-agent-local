# 🚀 OTA Integration - Execution Playbook

**STOP! READ THIS FIRST**

This is your **STEP-BY-STEP EXECUTION GUIDE** to activate Expedia and Booking.com integrations in your HMS portal. Follow each step in order. Do not skip steps.

**Estimated Time:** 4-6 hours (can be split over multiple sessions)  
**Prerequisites:** Terminal access, Supabase CLI, OTA account credentials

---

## 📍 Where You Are Now

✅ **OTA Schema:** Database tables exist  
✅ **Documentation:** Complete guides available  
✅ **Edge Functions:** Code files created  
⏭️ **Next Step:** Deploy and activate

---

## 🎯 What You're About to Do

You will:
1. Deploy 2 Edge Functions (Expedia + Booking.com APIs)
2. Insert your OTA credentials into the database
3. Test the connections
4. Enable the portal UI
5. Go live!

---

## 🏁 START HERE - SESSION 1 (2 hours)

### Step 1: Open Terminal (2 minutes)

```bash
# Navigate to your project
cd /Users/giritharanchockalingam/Desktop/GitHub/hms-gcp-refactor

# Verify you're in the right place
ls -la supabase/functions/
```

**✅ Expected:** You should see `expedia-api/` and `bookingcom-api/` directories

---

### Step 2: Deploy Expedia API (5 minutes)

```bash
# Deploy the function
npx supabase functions deploy expedia-api --no-verify-jwt

# Wait for deployment to complete...
```

**✅ Expected Output:**
```
✓ expedia-api deployed successfully
Function URL: https://your-project.supabase.co/functions/v1/expedia-api
```

**❌ If Error:** 
- Check your Supabase CLI is logged in: `npx supabase login`
- Verify you're linked to your project: `npx supabase link`

---

### Step 3: Deploy Booking.com API (5 minutes)

```bash
# Deploy the function
npx supabase functions deploy bookingcom-api --no-verify-jwt

# Wait for deployment to complete...
```

**✅ Expected Output:**
```
✓ bookingcom-api deployed successfully
Function URL: https://your-project.supabase.co/functions/v1/bookingcom-api
```

---

### Step 4: Verify Deployments (3 minutes)

```bash
# List all deployed functions
npx supabase functions list
```

**✅ Expected:** You should see:
- ✅ expedia-api (active)
- ✅ bookingcom-api (active)
- Plus all your other existing functions

**🎉 Checkpoint:** Edge Functions are now deployed!

---

### Step 5: Get Your Property UUID (5 minutes)

```bash
# Open Supabase SQL Editor or use psql
# Run this query to find your property ID:
```

```sql
SELECT id, name, address 
FROM properties 
LIMIT 10;
```

**📝 SAVE THIS:** Copy your property UUID - you'll need it in the next steps!

Example: `123e4567-e89b-12d3-a456-426614174000`

---

### Step 6: Get Your OTA Credentials (30 minutes)

#### For Expedia:
1. Go to https://developers.expediagroup.com/
2. Sign in or create account
3. Create new application
4. **COPY AND SAVE:**
   - ✅ API Key: `_______________________`
   - ✅ API Secret: `_______________________`
   - ✅ EAN Hotel ID: `_______________________`

#### For Booking.com:
1. Go to https://admin.booking.com/
2. Navigate to Connectivity → API Settings
3. **COPY AND SAVE:**
   - ✅ API Key: `_______________________`
   - ✅ Partner ID: `_______________________`
   - ✅ Hotel ID: `_______________________`
   - ✅ Username: `_______________________`
   - ✅ Password: `_______________________`

**🎉 Checkpoint:** You now have all credentials!

---

### Step 7: Insert Credentials into Database (15 minutes)

```bash
# Open Supabase SQL Editor
# Copy and paste this template, REPLACING THE PLACEHOLDERS:
```

```sql
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
  'YOUR_PROPERTY_UUID_HERE',  -- ← REPLACE THIS
  'expedia',
  jsonb_build_object(
    'api_key', 'YOUR_EXPEDIA_API_KEY',      -- ← REPLACE THIS
    'api_secret', 'YOUR_EXPEDIA_SECRET',    -- ← REPLACE THIS
    'ean_hotel_id', 'YOUR_EXPEDIA_HOTEL_ID' -- ← REPLACE THIS
  ),
  jsonb_build_object(
    'test_mode', true,  -- Set to false for production later
    'property_id', 'YOUR_PROPERTY_UUID_HERE',  -- ← REPLACE THIS
    'sync_interval_minutes', 15,
    'auto_accept_bookings', true
  ),
  true,
  NOW()
)
ON CONFLICT (property_id, provider) DO UPDATE
SET 
  credentials = EXCLUDED.credentials,
  configuration = EXCLUDED.configuration,
  updated_at = NOW();

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
  'YOUR_PROPERTY_UUID_HERE',  -- ← REPLACE THIS (same as above)
  'booking_com',
  jsonb_build_object(
    'api_key', 'YOUR_BOOKING_API_KEY',       -- ← REPLACE THIS
    'partner_id', 'YOUR_PARTNER_ID',         -- ← REPLACE THIS
    'hotel_id', 'YOUR_BOOKING_HOTEL_ID',     -- ← REPLACE THIS
    'username', 'YOUR_USERNAME',             -- ← REPLACE THIS
    'password', 'YOUR_PASSWORD'              -- ← REPLACE THIS
  ),
  jsonb_build_object(
    'test_mode', true,  -- Set to false for production later
    'property_id', 'YOUR_PROPERTY_UUID_HERE',  -- ← REPLACE THIS
    'sync_interval_minutes', 15,
    'auto_accept_bookings', true
  ),
  true,
  NOW()
)
ON CONFLICT (property_id, provider) DO UPDATE
SET 
  credentials = EXCLUDED.credentials,
  configuration = EXCLUDED.configuration,
  updated_at = NOW();
```

**Execute the query!**

**✅ Expected:** 2 rows inserted (or updated)

---

### Step 8: Verify Credentials Are Stored (2 minutes)

```sql
-- Run this query:
SELECT 
  id,
  provider,
  is_active,
  (configuration->>'test_mode')::boolean as test_mode,
  created_at
FROM ota_configurations
WHERE property_id = 'YOUR_PROPERTY_UUID_HERE';  -- ← REPLACE THIS
```

**✅ Expected Output:**
```
provider     | is_active | test_mode | created_at
-------------|-----------|-----------|-------------
expedia      | true      | true      | 2024-12-26...
booking_com  | true      | true      | 2024-12-26...
```

**🎉 Checkpoint:** Credentials are securely stored!

---

## ⏸️ BREAK - Take 15 Minutes

You've completed the critical setup! Take a break before testing.

---

## 🧪 SESSION 2: Testing (1-2 hours)

### Step 9: Test Expedia Connection (10 minutes)

Create a test file:

```bash
cat > test-expedia.js << 'EOF'
const fetch = require('node-fetch');

const SUPABASE_URL = 'YOUR_SUPABASE_URL';  // ← REPLACE
const SUPABASE_KEY = 'YOUR_SUPABASE_ANON_KEY';  // ← REPLACE
const PROPERTY_ID = 'YOUR_PROPERTY_UUID';  // ← REPLACE

async function testExpedia() {
  console.log('Testing Expedia API connection...');
  
  const response = await fetch(
    `${SUPABASE_URL}/functions/v1/expedia-api`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        action: 'checkAvailability',
        property_id: PROPERTY_ID,
        params: {
          start_date: '2025-01-01',
          end_date: '2025-01-07',
        },
      }),
    }
  );

  const result = await response.json();
  console.log('Result:', JSON.stringify(result, null, 2));
  
  if (result.success) {
    console.log('✅ Expedia connection SUCCESSFUL!');
  } else {
    console.log('❌ Expedia connection FAILED:', result.error);
  }
}

testExpedia().catch(console.error);
EOF

# Run the test
node test-expedia.js
```

**✅ Expected:** `Expedia connection SUCCESSFUL!`

**❌ If Error:**
- Check credentials are correct
- Verify `test_mode: true` matches sandbox credentials
- Check Expedia API status

---

### Step 10: Test Booking.com Connection (10 minutes)

Create a test file:

```bash
cat > test-bookingcom.js << 'EOF'
const fetch = require('node-fetch');

const SUPABASE_URL = 'YOUR_SUPABASE_URL';  // ← REPLACE
const SUPABASE_KEY = 'YOUR_SUPABASE_ANON_KEY';  // ← REPLACE
const PROPERTY_ID = 'YOUR_PROPERTY_UUID';  // ← REPLACE

async function testBookingCom() {
  console.log('Testing Booking.com API connection...');
  
  const response = await fetch(
    `${SUPABASE_URL}/functions/v1/bookingcom-api`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        action: 'checkAvailability',
        property_id: PROPERTY_ID,
        params: {
          start_date: '2025-01-01',
          end_date: '2025-01-07',
        },
      }),
    }
  );

  const result = await response.json();
  console.log('Result:', JSON.stringify(result, null, 2));
  
  if (result.success) {
    console.log('✅ Booking.com connection SUCCESSFUL!');
  } else {
    console.log('❌ Booking.com connection FAILED:', result.error);
  }
}

testBookingCom().catch(console.error);
EOF

# Run the test
node test-bookingcom.js
```

**✅ Expected:** `Booking.com connection SUCCESSFUL!`

---

### Step 11: Check Sync Logs (5 minutes)

```sql
-- Verify API calls are being logged
SELECT 
  provider,
  sync_type,
  status,
  records_processed,
  created_at,
  error_message
FROM ota_sync_logs
ORDER BY created_at DESC
LIMIT 20;
```

**✅ Expected:** You should see log entries for your tests

**🎉 Checkpoint:** Both OTA connections are working!

---

## 🎨 SESSION 3: Enable Portal UI (1 hour)

### Step 12: Add OTA Management Page (30 minutes)

The complete React component code is in:  
`docs/OTA_ACTIVATION_COMPLETE_IMPLEMENTATION_GUIDE.md` - Phase 3

**Quick version:**

1. Create file: `src/pages/OTAManagement.tsx`
2. Copy component code from guide
3. Add route to `src/App.tsx`
4. Add menu item to sidebar navigation

---

### Step 13: Test Portal UI (15 minutes)

1. Start your dev server: `npm run dev`
2. Navigate to `/ota-management`
3. You should see:
   - ✅ Expedia card (Active badge)
   - ✅ Booking.com card (Active badge)
   - ✅ "Disable" and "Sync Now" buttons

4. Click "Sync Now" on each OTA
5. Verify success toasts appear

**🎉 Checkpoint:** Portal UI is working!

---

## 🚀 FINAL SESSION: Go Live (30 minutes)

### Step 14: Switch to Production Credentials (15 minutes)

**⚠️ IMPORTANT:** Only do this when ready for live bookings!

```sql
-- Update Expedia to production
UPDATE ota_configurations
SET 
  credentials = jsonb_build_object(
    'api_key', 'YOUR_PRODUCTION_API_KEY',        -- ← PRODUCTION KEY
    'api_secret', 'YOUR_PRODUCTION_API_SECRET',  -- ← PRODUCTION SECRET
    'ean_hotel_id', 'YOUR_PRODUCTION_HOTEL_ID'   -- ← PRODUCTION ID
  ),
  configuration = jsonb_set(configuration, '{test_mode}', 'false'::jsonb)
WHERE provider = 'expedia' 
  AND property_id = 'YOUR_PROPERTY_UUID';

-- Update Booking.com to production
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
WHERE provider = 'booking_com'
  AND property_id = 'YOUR_PROPERTY_UUID';
```

---

### Step 15: Set Up Monitoring (15 minutes)

Create a simple monitoring dashboard query:

```sql
-- Save this as a view or run daily
CREATE OR REPLACE VIEW ota_daily_stats AS
SELECT 
  DATE(created_at) as booking_date,
  provider,
  COUNT(*) as total_bookings,
  SUM(total_amount) as total_revenue,
  COUNT(CASE WHEN booking_status = 'confirmed' THEN 1 END) as confirmed,
  COUNT(CASE WHEN booking_status = 'cancelled' THEN 1 END) as cancelled
FROM ota_bookings
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(created_at), provider
ORDER BY booking_date DESC;

-- Test it
SELECT * FROM ota_daily_stats;
```

---

## ✅ COMPLETION CHECKLIST

Mark each item as you complete it:

### Deployment
- [ ] Expedia API deployed
- [ ] Booking.com API deployed
- [ ] Functions verified in Supabase dashboard

### Configuration
- [ ] Property UUID identified
- [ ] Expedia credentials obtained
- [ ] Booking.com credentials obtained
- [ ] Credentials inserted into database
- [ ] Credentials verified in database

### Testing
- [ ] Expedia connection tested successfully
- [ ] Booking.com connection tested successfully
- [ ] Sync logs showing successful operations
- [ ] No errors in function logs

### Portal
- [ ] OTA Management page created
- [ ] Route added to application
- [ ] Menu item added
- [ ] Portal UI tested and working
- [ ] Sync buttons functional

### Production
- [ ] Production credentials obtained
- [ ] Switched to production mode (when ready)
- [ ] Monitoring dashboard created
- [ ] First live booking received and verified

---

## 🎉 SUCCESS!

**Congratulations!** Your HMS portal is now connected to Expedia and Booking.com!

### What Happens Next?

**Bookings will now flow automatically:**
1. Guest books on Expedia/Booking.com
2. OTA sends webhook to your HMS
3. Booking appears in your portal
4. You manage it like any other reservation

**Rates and inventory sync both ways:**
1. Update rates/availability in HMS → pushes to OTAs
2. OTAs update automatically when you sell rooms

---

## 📚 Next Actions

### Immediate (Next 24 hours)
- [ ] Monitor first few bookings closely
- [ ] Test modification/cancellation flows
- [ ] Verify email confirmations working
- [ ] Check sync logs for any errors

### Short-term (Next Week)
- [ ] Train property management staff
- [ ] Set up rate management strategy
- [ ] Configure promotional rates
- [ ] Enable automatic sync jobs

### Long-term (Next Month)
- [ ] Analyze OTA performance metrics
- [ ] Optimize rate strategies
- [ ] Add more OTA channels if needed
- [ ] Implement advanced revenue management

---

## 🆘 Quick Troubleshooting

### Issue: "Integration not configured" error
**Fix:** Run Step 8 to verify credentials are in database

### Issue: API returns 401 Unauthorized
**Fix:** Check credentials match environment (sandbox vs production)

### Issue: No bookings appearing
**Fix:** 
1. Verify webhooks are configured in OTA portals
2. Check webhook logs
3. Test with manual API calls first

### Issue: Sync errors in logs
**Fix:**
1. Check error message in `ota_sync_logs`
2. Verify API credentials still valid
3. Check OTA API status pages

---

## 📞 Need Help?

**Documentation:**
- Full Guide: `docs/OTA_ACTIVATION_COMPLETE_IMPLEMENTATION_GUIDE.md`
- API Reference: `docs/OTA_API_QUICK_REFERENCE.md`
- Summary: `docs/OTA_IMPLEMENTATION_COMPLETE_SUMMARY.md`

**External Resources:**
- Expedia: https://developers.expediagroup.com/support
- Booking.com: https://developers.booking.com/support

---

**Version:** 1.0  
**Created:** December 26, 2024  
**Status:** ✅ READY TO EXECUTE

🚀 **START AT STEP 1 AND DON'T SKIP ANY STEPS!**
