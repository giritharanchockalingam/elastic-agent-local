# Booking.com Integration Setup Guide for Property Owners

## 🎯 Overview

This guide will walk you through connecting your property to **Booking.com Connectivity API**, enabling you to receive reservations directly from one of the world's largest travel platforms.

---

## 📋 What You'll Need

Before starting, gather these items from Booking.com:

### 1. Booking.com Partner Account
- ✅ Active Booking.com extranet account
- ✅ Property listed on Booking.com
- ✅ Connectivity certification completed

### 2. API Credentials
You'll need these from Booking.com:
- **API Key**
- **Partner ID**
- **Hotel ID** (your property's Booking.com ID)
- **Username** (for XML API access)
- **Password** (for XML API access)

### 3. Where to Get Credentials

1. **Log in to Booking.com Extranet**
   - Go to https://admin.booking.com
   - Sign in with your extranet credentials

2. **Request Connectivity Access**
   - Go to "Connectivity" section
   - Click "Request API Access"
   - Complete connectivity certification (if not done)

3. **Get API Credentials**
   - Once approved, credentials appear in:
   - "Connectivity" → "API Settings"
   - Or contact connectivity@booking.com

4. **Test Environment**
   - Request sandbox/test credentials
   - Use for testing before going live

---

## 🚀 Step-by-Step Setup

### STEP 1: Configure Integration in HMS

1. **Log in to your HMS Portal**
   - Navigate to **Settings** → **Integrations** → **OTA Channels**

2. **Click "Add New OTA"**
   - Select "Booking.com Connectivity"

3. **Enter Your Credentials**
   ```
   Integration Name:  Booking.com - [Your Property Name]
   API Key:          [Your API Key]
   Partner ID:       [Your Partner ID]
   Hotel ID:         [Your Hotel ID]
   Username:         [Your XML API Username]
   Password:         [Your XML API Password]
   
   Test Mode:        ✓ ENABLED (for testing)
   Auto-Sync:        ✓ ENABLED
   ```

4. **Click "Test Connection"**
   - Wait for green checkmark ✅
   - If error ❌, verify credentials

5. **Click "Save Configuration"**

---

### STEP 2: Map Room Types

Map your internal room types to Booking.com room types.

1. **Go to "Room Type Mapping"**
   - Under Booking.com integration settings

2. **For Each Room Type:**
   ```
   Internal Room Type:    Deluxe King Room
   Booking.com Room Type: Double Room - King Bed
   Booking.com Room ID:   12345678
   ```

3. **Save Mappings**

**How to find Booking.com Room IDs:**
- Log in to Booking.com Extranet
- Go to "Property" → "Rooms & Rates"
- Note the Room Type ID for each room

---

### STEP 3: Configure Rate Plans

Map your rate plans to Booking.com rate plans.

1. **Go to "Rate Plan Mapping"**

2. **Map Your Rates:**
   ```
   Internal Rate:           Best Available Rate (BAR)
   Booking.com Rate:        Flexible Rate
   Booking.com Rate ID:     87654321
   
   Adjustment:              None
   (Or add % markup/discount if needed)
   ```

3. **Common Rate Plans:**
   - **Flexible Rate** - Standard cancellable rate
   - **Non-Refundable** - Lower rate, no cancellation
   - **Early Bird** - Advance purchase discount
   - **Genius Rate** - For Genius members

---

### STEP 4: Set Up Webhooks (Reservations)

Webhooks allow Booking.com to notify you instantly of new reservations.

1. **Get Your Webhook URL:**
   ```
   https://[your-supabase-project].supabase.co/functions/v1/bookingcom-webhook
   ```

2. **Configure in Booking.com Extranet:**
   - Go to "Connectivity" → "Webhook Settings"
   - Click "Add Webhook Endpoint"
   - Enter webhook URL
   - Select events:
     - ✓ New Reservation
     - ✓ Reservation Modified
     - ✓ Reservation Cancelled
   - Save

3. **Test Webhook:**
   - Click "Test Webhook" in Extranet
   - Check HMS → Integrations → Booking.com → "Webhook Logs"
   - Verify test event received ✅

---

### STEP 5: Initial Sync

Synchronize your property data with Booking.com.

1. **Sync Property Information:**
   - Go to "Booking.com Integration" → "Property Sync"
   - Click "Sync Property Details"
   - Syncs:
     - Property description
     - Facilities & services
     - Policies
     - Check-in/out times

2. **Sync Current Rates:**
   - Go to "Rate Management"
   - Click "Push All Rates to Booking.com"
   - Verify rates in Booking.com Extranet

3. **Sync Availability:**
   - Go to "Availability Management"
   - Click "Push Current Availability"
   - Check room availability shows correctly

---

### STEP 6: Test Reservation Flow

Test the complete reservation process before going live.

1. **Create Test Reservation:**
   - Use Booking.com test environment
   - Make a test reservation
   - Use test payment method

2. **Verify in HMS:**
   - Go to "Bookings" → "OTA Bookings"
   - Test reservation should appear within 5 seconds
   - Verify all details are correct:
     - Guest name
     - Dates
     - Room type
     - Price

3. **Test Modification:**
   - Modify reservation in Extranet
   - Verify changes in HMS

4. **Test Cancellation:**
   - Cancel reservation in Extranet
   - Verify cancellation in HMS

---

### STEP 7: Go Live!

Switch to production after successful testing.

1. **Switch to Production Mode:**
   - Go to Booking.com Integration settings
   - Uncheck "Test Mode"
   - Click "Update Configuration"

2. **Update Production Credentials:**
   - Enter production API credentials
   - Save configuration

3. **Verify Webhook (Production):**
   - Ensure webhook URL is in production Extranet
   - Send test event from production account

4. **Monitor First Reservations:**
   - Watch for first real reservation
   - Verify all data flows correctly

5. **Enable Automatic Sync:**
   - Rates sync every 15 minutes
   - Availability syncs every 5 minutes
   - Reservations sync instantly via webhook

---

## 📊 Daily Operations

### Viewing Booking.com Reservations

1. **Dashboard:**
   - Go to "Dashboard" → "OTA Performance"
   - See today's Booking.com reservations and revenue

2. **All Reservations:**
   - Go to "Bookings" → "OTA Bookings"
   - Filter: "Booking.com"
   - View all reservations

### Updating Rates

**Automatic Sync (Recommended):**
- Update rates in HMS
- Automatically sync to Booking.com within 15 minutes

**Manual Push:**
- Go to "Booking.com Integration" → "Rate Management"
- Update rates
- Click "Push to Booking.com Now"

### Managing Availability

**Automatic Sync (Recommended):**
- Update availability in HMS
- Syncs to Booking.com within 5 minutes

**Manual Push:**
- Go to "Booking.com Integration" → "Availability"
- Update
- Click "Sync Now"

### Restrictions

Set booking restrictions:
- **Minimum Stay**: Minimum nights required
- **Maximum Stay**: Maximum nights allowed
- **Closed to Arrival**: Can't check in on specific dates
- **Closed to Departure**: Can't check out on specific dates

---

## 🔍 Monitoring & Reporting

### Check Sync Status

1. **Go to "Booking.com Integration" → "Sync Logs"**
2. **View recent syncs:**
   - ✅ Green = Success
   - ⏳ Yellow = Processing
   - ❌ Red = Failed (view error)

### Performance Reports

1. **Revenue Reports:**
   - Go to "Reports" → "OTA Revenue"
   - Filter: "Booking.com"
   - View booking trends, revenue, ADR

2. **Booking Analysis:**
   - See booking patterns
   - Identify high-demand periods
   - Optimize pricing

---

## ⚠️ Troubleshooting

### Reservations Not Appearing

**Check:**
1. ✓ Webhook configured in Extranet
2. ✓ Webhook URL is correct and accessible
3. ✓ Integration is "Active" in HMS
4. ✓ Room mapping is correct

**Solution:**
- Check "Webhook Logs" for errors
- Manual sync: "Pull Reservations from Booking.com"
- Contact Booking.com connectivity support

### Rates Not Syncing

**Check:**
1. ✓ Rate mappings configured correctly
2. ✓ Room type mappings are correct
3. ✓ Rate sync is enabled
4. ✓ Rates are within Booking.com guidelines

**Solution:**
- Check "Sync Logs" for specific errors
- Try manual push
- Verify rate caps aren't violated

### Availability Issues

**Check:**
1. ✓ Inventory sync is enabled
2. ✓ Room count is correct
3. ✓ No overbooking protection blocking sync

**Solution:**
- Manual push availability
- Check for rate/availability mismatches
- Verify restrictions aren't conflicting

### Connection Errors

**Check:**
1. ✓ All credentials are correct
2. ✓ Test/Production mode matches account
3. ✓ API access is active

**Solution:**
- Re-enter credentials
- Test connection
- Contact connectivity@booking.com

---

## 💡 Best Practices

### Visibility & Content
- ✅ Complete all property information
- ✅ Upload high-quality photos (min 10 photos)
- ✅ Keep descriptions updated
- ✅ Highlight unique features

### Pricing Strategy
- ✅ Use dynamic pricing
- ✅ Maintain rate parity
- ✅ Offer Genius discounts
- ✅ Create special offers

### Availability
- ✅ Keep calendar updated
- ✅ Never oversell
- ✅ Use stop-sell carefully
- ✅ Open bookings far in advance

### Guest Service
- ✅ Respond to messages within 24 hours
- ✅ Maintain high review scores
- ✅ Handle issues professionally
- ✅ Request reviews after stay

---

## 🎯 Booking.com Requirements

### Content Quality Standards
- Property description: Min 300 characters
- Photos: Min 10 high-quality images
- Facilities: Complete and accurate
- Policies: Clear cancellation policy

### Performance Standards
- Review score: Aim for 8.0+
- Response time: <24 hours
- Cancellation rate: <5%
- No-show rate: <2%

### Connectivity Requirements
- Availability updates: Every 24 hours minimum
- Rate updates: As needed
- Reservation confirmations: Within 24 hours

---

## 📞 Support

### HMS Support
- **Email**: support@yourhms.com
- **Documentation**: Help section in HMS
- **Live Chat**: Available in HMS portal

### Booking.com Support
- **Extranet**: https://admin.booking.com
- **Connectivity**: connectivity@booking.com
- **Partner Support**: partnersupport@booking.com
- **Phone**: [Your region's support number]

---

## ✅ Setup Checklist

Complete before going live:

- [ ] API credentials entered and tested
- [ ] Room type mappings configured
- [ ] Rate plan mappings configured
- [ ] Webhooks configured and tested
- [ ] Property information synced
- [ ] Initial rates synced
- [ ] Initial availability synced
- [ ] Test reservation completed
- [ ] Test modification completed
- [ ] Test cancellation completed
- [ ] Production credentials configured
- [ ] First real reservation received ✨

---

**Congratulations! Your property is now live on Booking.com!** 🎉

Start receiving reservations from travelers around the world. Monitor your performance and maintain high quality standards for best results.

---

**Document Version**: 1.0  
**Last Updated**: December 26, 2024  
**Next Review**: January 26, 2025
