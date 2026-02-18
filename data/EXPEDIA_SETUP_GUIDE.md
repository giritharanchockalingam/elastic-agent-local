# Expedia Integration Setup Guide for Property Owners

## 🎯 Overview

This guide will walk you through connecting your property to **Expedia Partner Solutions**, enabling you to receive bookings directly from millions of travelers worldwide.

---

## 📋 What You'll Need

Before starting, gather these items from Expedia:

### 1. Expedia Partner Account
- ✅ Active Expedia partner account
- ✅ Property listed on Expedia
- ✅ Access to Expedia Partner Central

### 2. API Credentials
You'll need these from Expedia:
- **API Key** (also called Client ID)
- **API Secret** (also called Client Secret)  
- **EAN Hotel ID** (your property's Expedia ID)
- **Property ID** (if different from EAN ID)

### 3. Where to Get Credentials

1. **Log in to Expedia Partner Central**
   - Go to https://partner.expedia.com
   - Sign in with your partner credentials

2. **Navigate to API Settings**
   - Click on "Account" → "API Settings"
   - Or contact your Expedia account manager

3. **Request API Access**
   - If you don't see API settings, email: `lxapi@expedia.com`
   - Subject: "API Access Request - [Your Property Name]"
   - Include your property ID and contact information

4. **Get Sandbox Credentials (for testing)**
   - Request sandbox environment access
   - Use these for testing before going live

---

## 🚀 Step-by-Step Setup

### STEP 1: Configure Integration in HMS

1. **Log in to your HMS Portal**
   - Navigate to **Settings** → **Integrations** → **OTA Channels**

2. **Click "Add New OTA"**
   - Select "Expedia Partner Solutions"

3. **Enter Your Credentials**
   ```
   Integration Name:  Expedia - [Your Property Name]
   API Key:          [Your API Key from Expedia]
   API Secret:       [Your API Secret from Expedia]
   EAN Hotel ID:     [Your EAN/Hotel ID]
   Property ID:      [Your Property ID]
   
   Test Mode:        ✓ ENABLED (for testing)
   Auto-Sync:        ✓ ENABLED
   ```

4. **Click "Test Connection"**
   - Wait for green checkmark ✅
   - If you see an error ❌, verify your credentials

5. **Click "Save Configuration"**

---

### STEP 2: Map Room Types

You need to map your internal room types to Expedia's room types.

1. **Go to "Room Type Mapping"**
   - Under Expedia integration settings

2. **For Each Room Type:**
   ```
   Internal Room Type: Deluxe King Room
   Expedia Room Type:  King Room - Deluxe
   Expedia Room ID:    123456
   ```

3. **Save Mappings**

**How to find Expedia Room IDs:**
- Log in to Expedia Partner Central
- Go to "Property Content" → "Room Types"
- Copy the Room ID for each room type

---

### STEP 3: Configure Rate Plans

Map your rate plans to Expedia's rate plans.

1. **Go to "Rate Plan Mapping"**

2. **Map Your Rates:**
   ```
   Internal Rate:     Best Available Rate (BAR)
   Expedia Rate:      Standard Rate
   Expedia Rate ID:   789012
   
   Adjustment:        None
   (Or add % markup/discount if needed)
   ```

3. **Common Rate Plans:**
   - **BAR** (Best Available Rate) - Standard public rate
   - **Corporate Rate** - For business travelers  
   - **Package Rate** - Room + extras
   - **Non-Refundable** - Lower rate, no cancellation

---

### STEP 4: Set Up Webhooks

Webhooks allow Expedia to notify you instantly of new bookings.

1. **Get Your Webhook URL:**
   ```
   https://[your-supabase-project].supabase.co/functions/v1/expedia-webhook
   ```

2. **Configure in Expedia Partner Central:**
   - Go to "API Settings" → "Webhooks"
   - Click "Add Webhook"
   - Enter webhook URL
   - Select events:
     - ✓ Booking Created
     - ✓ Booking Modified
     - ✓ Booking Cancelled
   - Save

3. **Test Webhook:**
   - Click "Send Test Event" in Expedia
   - Check HMS → Integrations → Expedia → "Webhook Logs"
   - You should see the test event ✅

---

### STEP 5: Initial Sync

Synchronize your property data with Expedia.

1. **Sync Property Content:**
   - Go to "Expedia Integration" → "Content Sync"
   - Click "Sync Property Information"
   - This sends:
     - Property description
     - Amenities
     - Policies
     - Photos (if configured)

2. **Sync Current Rates:**
   - Go to "Rate Management"
   - Click "Push All Rates to Expedia"
   - Verify rates appear correctly in Expedia Partner Central

3. **Sync Inventory:**
   - Go to "Inventory Management"
   - Click "Push Current Inventory"
   - Check availability shows correctly on Expedia

---

### STEP 6: Test Booking Flow

Before going live, test the complete booking process.

1. **Create Test Booking in Expedia:**
   - Use Expedia's test mode
   - Make a test reservation
   - Use test credit card (provided by Expedia)

2. **Verify in HMS:**
   - Go to "Bookings" → "OTA Bookings"
   - You should see the test booking within 5 seconds
   - Check all details are correct

3. **Test Modification:**
   - Modify the booking in Expedia
   - Verify changes appear in HMS

4. **Test Cancellation:**
   - Cancel the booking in Expedia
   - Verify status updates in HMS

---

### STEP 7: Go Live!

Once testing is complete, switch to production.

1. **Switch to Production Mode:**
   - Go to Expedia Integration settings
   - Uncheck "Test Mode"
   - Click "Update Configuration"

2. **Update Webhook to Production:**
   - Same webhook URL works for both
   - Ensure it's configured in production Expedia account

3. **Monitor Initial Bookings:**
   - Watch for your first real booking
   - Verify all data flows correctly

4. **Enable Automatic Sync:**
   - Rates sync every 15 minutes
   - Inventory syncs every 5 minutes
   - Bookings sync instantly via webhook

---

## 📊 Daily Operations

### Viewing Expedia Bookings

1. **Dashboard:**
   - Go to "Dashboard" → "OTA Performance"
   - See today's Expedia bookings and revenue

2. **All Bookings:**
   - Go to "Bookings" → "OTA Bookings" → Filter: "Expedia"
   - See all past and upcoming Expedia reservations

### Updating Rates

**Option 1: Automatic Sync (Recommended)**
- Update rates in HMS
- They automatically sync to Expedia within 15 minutes

**Option 2: Manual Push**
- Go to "Expedia Integration" → "Rate Management"
- Update rates
- Click "Push to Expedia Now"

### Managing Inventory

**Option 1: Automatic Sync (Recommended)**
- Update room availability in HMS
- Syncs to Expedia within 5 minutes

**Option 2: Manual Push**
- Go to "Expedia Integration" → "Inventory"
- Update availability
- Click "Sync Now"

---

## 🔍 Monitoring & Reporting

### Check Sync Status

1. **Go to "Expedia Integration" → "Sync Logs"**
2. **View recent syncs:**
   - ✅ Green = Success
   - ⏳ Yellow = In Progress
   - ❌ Red = Failed (check error details)

### View Performance Reports

1. **Revenue Reports:**
   - Go to "Reports" → "OTA Revenue"
   - Filter by "Expedia"
   - See booking trends, revenue, ADR

2. **Channel Comparison:**
   - Compare Expedia vs. direct bookings
   - See which channel performs better

---

## ⚠️ Troubleshooting

### Bookings Not Appearing in HMS

**Check:**
1. ✓ Webhook is configured correctly in Expedia
2. ✓ Webhook URL is accessible (test with browser)
3. ✓ Integration is set to "Active" in HMS
4. ✓ Property mapping is correct

**Solution:**
- Go to "Webhook Logs" and check for errors
- Manually sync: "Expedia Integration" → "Pull Bookings"

### Rates Not Syncing

**Check:**
1. ✓ Rate mappings are configured
2. ✓ Room type mappings are correct
3. ✓ Sync is enabled

**Solution:**
- Go to "Sync Logs" and check errors
- Try manual push: "Push Rates to Expedia"

### Connection Errors

**Check:**
1. ✓ API credentials are correct
2. ✓ Test Mode matches your Expedia account
3. ✓ API access is enabled in Expedia

**Solution:**
- Re-enter credentials
- Click "Test Connection"
- Contact Expedia support if persistent

---

## 💡 Best Practices

### Rate Management
- ✅ Use dynamic pricing for better revenue
- ✅ Keep rate parity across all channels
- ✅ Monitor competitor rates on Expedia

### Inventory Management
- ✅ Never oversell - use inventory limits
- ✅ Update availability in real-time
- ✅ Block dates for maintenance promptly

### Guest Experience
- ✅ Respond to guest messages within 24 hours
- ✅ Ensure property information is accurate
- ✅ Upload high-quality photos

### Performance
- ✅ Monitor booking conversion rates
- ✅ Track guest reviews on Expedia
- ✅ Analyze booking patterns

---

## 📞 Support

### HMS Support
- **Email**: support@yourhms.com
- **Documentation**: Go to "Help" in HMS portal
- **Live Chat**: Available in HMS portal

### Expedia Support
- **Partner Central**: https://partner.expedia.com
- **Email**: partnersupport@expedia.com
- **Phone**: [Your region's Expedia support number]

---

## ✅ Setup Checklist

Before considering setup complete:

- [ ] API credentials entered and tested
- [ ] Room type mappings configured
- [ ] Rate plan mappings configured
- [ ] Webhooks configured and tested
- [ ] Property content synced
- [ ] Initial rates synced
- [ ] Initial inventory synced
- [ ] Test booking completed successfully
- [ ] Test modification completed
- [ ] Test cancellation completed
- [ ] Switched to production mode
- [ ] First real booking received ✨

---

**Congratulations! Your property is now live on Expedia!** 🎉

Start receiving bookings from millions of travelers worldwide. Monitor your performance in the HMS dashboard and optimize your rates for maximum revenue.

---

**Document Version**: 1.0  
**Last Updated**: December 26, 2024  
**Next Review**: January 26, 2025
