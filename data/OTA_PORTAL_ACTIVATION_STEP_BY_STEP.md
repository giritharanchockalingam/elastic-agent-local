# OTA Portal Activation - Step-by-Step Implementation Guide

## 🎯 Objective
Enable hotel tenants/properties to connect their properties to Expedia and Booking.com directly from the HMS portal, allowing them to:
- Receive bookings automatically from OTAs
- Synchronize rates and inventory
- Manage OTA configurations
- View OTA performance analytics

---

## 📋 Implementation Checklist

### ✅ PHASE 1: EXPEDIA INTEGRATION (Current Focus)

#### Step 1.1: Database Setup
- [ ] Create `ota_configurations` table
- [ ] Create `ota_bookings` table  
- [ ] Create `ota_sync_logs` table
- [ ] Create `ota_property_content` table
- [ ] Create `ota_rate_mappings` table
- [ ] Create `ota_inventory_sync` table
- [ ] Create `ota_webhooks` table
- [ ] Test database schema

#### Step 1.2: Edge Functions Deployment
- [x] Expedia API edge function (ALREADY DONE)
- [ ] Expedia webhook handler
- [ ] Expedia sync scheduler
- [ ] Test edge functions

#### Step 1.3: Portal UI - Expedia Configuration
- [ ] Create `ExpediaSetup.tsx` page
- [ ] Add credential input form
- [ ] Add test connection button
- [ ] Add property mapping UI
- [ ] Add rate plan configuration
- [ ] Add room type mapping
- [ ] Test UI flows

#### Step 1.4: Portal UI - Expedia Management
- [ ] Create `ExpediaBookings.tsx` page
- [ ] Create `ExpediaRates.tsx` page
- [ ] Create `ExpediaInventory.tsx` page
- [ ] Create `ExpediaReports.tsx` page
- [ ] Test all management pages

#### Step 1.5: Automation & Webhooks
- [ ] Deploy webhook handler
- [ ] Configure Expedia webhook URLs
- [ ] Set up scheduled sync jobs (rates, inventory)
- [ ] Test webhook delivery
- [ ] Test sync jobs

#### Step 1.6: Testing & Validation
- [ ] Test booking creation from Expedia
- [ ] Test rate synchronization
- [ ] Test inventory synchronization
- [ ] Test modification/cancellation flows
- [ ] End-to-end validation

---

### ⏭️ PHASE 2: BOOKING.COM INTEGRATION (Next)

#### Step 2.1: Database Enhancements
- [ ] Add Booking.com specific columns
- [ ] Update rate mapping structure
- [ ] Test database updates

#### Step 2.2: Edge Functions Deployment
- [x] Booking.com API edge function (ALREADY DONE)
- [ ] Booking.com webhook handler
- [ ] Booking.com sync scheduler
- [ ] Test edge functions

#### Step 2.3: Portal UI - Booking.com Configuration
- [ ] Create `BookingComSetup.tsx` page
- [ ] Add credential input form
- [ ] Add test connection button
- [ ] Add property mapping UI
- [ ] Test UI flows

#### Step 2.4: Portal UI - Booking.com Management
- [ ] Create `BookingComBookings.tsx` page
- [ ] Create `BookingComRates.tsx` page
- [ ] Create `BookingComInventory.tsx` page
- [ ] Create `BookingComReports.tsx` page
- [ ] Test all management pages

#### Step 2.5: Automation & Webhooks
- [ ] Deploy webhook handler
- [ ] Configure Booking.com webhook URLs
- [ ] Set up scheduled sync jobs
- [ ] Test webhook delivery
- [ ] Test sync jobs

#### Step 2.6: Testing & Validation
- [ ] Test reservation creation
- [ ] Test rate synchronization
- [ ] Test availability synchronization
- [ ] Test modification/cancellation flows
- [ ] End-to-end validation

---

### ⏭️ PHASE 3: UNIFIED OTA MANAGEMENT (Final)

#### Step 3.1: Consolidated Dashboard
- [ ] Create `OTADashboard.tsx` - Overview of all OTAs
- [ ] Add combined analytics
- [ ] Add revenue comparison charts
- [ ] Add performance metrics

#### Step 3.2: Multi-OTA Features
- [ ] Rate parity checking
- [ ] Inventory distribution manager
- [ ] Consolidated booking calendar
- [ ] Unified reporting

#### Step 3.3: Advanced Features
- [ ] Dynamic pricing recommendations
- [ ] Yield management tools
- [ ] Channel performance analytics
- [ ] Automated rules engine

---

## 🚀 STARTING NOW: EXPEDIA PORTAL ENABLEMENT

### What We're Building First

**1. Database Schema** (OTA Configuration Storage)
```sql
-- Tables to store OTA credentials, bookings, sync logs, etc.
```

**2. Admin Setup UI** (Property Owners Can Configure)
```
┌─────────────────────────────────────────┐
│   Expedia Integration Setup             │
├─────────────────────────────────────────┤
│                                          │
│  Property ID: [____________]             │
│  API Key:     [____________]             │
│  API Secret:  [____________]             │
│  EAN ID:      [____________]             │
│                                          │
│  [ Test Connection ]  [Save Configuration]│
│                                          │
│  ✅ Connection Status: Connected         │
│  ✅ Last Sync: 2 minutes ago            │
│                                          │
└─────────────────────────────────────────┘
```

**3. Webhook Handler** (Receive Real-time Bookings)
```typescript
// supabase/functions/expedia-webhook/index.ts
// Receives booking notifications from Expedia
// Automatically creates reservations in HMS
```

**4. Sync Scheduler** (Keep Data Fresh)
```typescript
// Runs every 15 minutes to sync:
// - Rates from HMS → Expedia
// - Inventory from HMS → Expedia
// - Bookings from Expedia → HMS
```

**5. Management UI** (View & Manage OTA Data)
```
┌─────────────────────────────────────────┐
│   Expedia Bookings                       │
├─────────────────────────────────────────┤
│ Today: 3 bookings | $1,250              │
│                                          │
│ [Booking #EXP-001] - John Smith          │
│  Check-in: Jan 15 | Deluxe Room          │
│  $450 | Status: Confirmed                │
│                                          │
│ [Booking #EXP-002] - Sarah Jones         │
│  Check-in: Jan 16 | Suite                │
│  $800 | Status: Confirmed                │
│                                          │
└─────────────────────────────────────────┘
```

---

## 📁 File Structure We'll Create

```
hms-gcp-refactor/
├── supabase/
│   ├── migrations/
│   │   └── 20251226_ota_portal_enablement.sql        # New migration
│   └── functions/
│       ├── expedia-api/                               # ✅ Exists
│       ├── bookingcom-api/                            # ✅ Exists
│       ├── expedia-webhook/                           # 🆕 To Create
│       │   └── index.ts
│       ├── bookingcom-webhook/                        # 🆕 To Create
│       │   └── index.ts
│       └── ota-sync-scheduler/                        # 🆕 To Create
│           └── index.ts
│
├── src/
│   ├── pages/
│   │   ├── ExpediaSetup.tsx                          # 🆕 Configuration UI
│   │   ├── ExpediaBookings.tsx                       # 🆕 Bookings Management
│   │   ├── ExpediaRates.tsx                          # 🆕 Rate Management
│   │   ├── BookingComSetup.tsx                       # 🆕 Configuration UI
│   │   ├── BookingComBookings.tsx                    # 🆕 Bookings Management
│   │   └── OTADashboard.tsx                          # 🆕 Unified Dashboard
│   │
│   └── services/
│       └── ota/
│           ├── expedia-service.ts                    # 🆕 Frontend service
│           └── bookingcom-service.ts                 # 🆕 Frontend service
│
└── docs/
    ├── OTA_PORTAL_ACTIVATION_STEP_BY_STEP.md        # 📄 This file
    ├── EXPEDIA_SETUP_GUIDE.md                       # 🆕 Setup instructions
    └── BOOKINGCOM_SETUP_GUIDE.md                    # 🆕 Setup instructions
```

---

## 💻 Detailed Implementation: EXPEDIA (Step by Step)

### STEP 1: Create Database Migration

**File:** `supabase/migrations/20251226_ota_portal_enablement.sql`

This migration creates all necessary tables for OTA portal functionality.

### STEP 2: Deploy Expedia Webhook Handler

**File:** `supabase/functions/expedia-webhook/index.ts`

Receives booking notifications from Expedia and creates reservations in HMS.

### STEP 3: Create Expedia Setup UI

**File:** `src/pages/ExpediaSetup.tsx`

Allows property owners to:
- Enter Expedia API credentials
- Test connection
- Map room types
- Configure rate plans

### STEP 4: Create Expedia Bookings UI

**File:** `src/pages/ExpediaBookings.tsx`

Shows all bookings received from Expedia with ability to:
- View booking details
- Modify reservations
- Process cancellations
- Sync manually

### STEP 5: Deploy Sync Scheduler

**File:** `supabase/functions/ota-sync-scheduler/index.ts`

Scheduled Supabase Edge Function that runs periodically to:
- Push rate updates to Expedia
- Push inventory updates to Expedia
- Pull new bookings from Expedia
- Sync property content

### STEP 6: Testing

End-to-end testing of the complete flow:
1. Property owner enters credentials
2. System tests connection
3. Webhook receives test booking
4. Booking appears in HMS
5. Rate update syncs to Expedia
6. Inventory update syncs to Expedia

---

## 🎯 Success Criteria

### For Expedia Integration ✅
- [ ] Property owner can configure Expedia credentials via UI
- [ ] Credentials are securely stored in database
- [ ] Test connection button validates API access
- [ ] Webhook receives and processes bookings correctly
- [ ] Bookings from Expedia appear in HMS within 5 seconds
- [ ] Rate updates sync to Expedia within 15 minutes
- [ ] Inventory updates sync to Expedia within 5 minutes
- [ ] Property owner can view all Expedia bookings
- [ ] Modifications and cancellations work bidirectionally

### For Booking.com Integration ✅
(Same criteria as Expedia)

### For Unified Dashboard ✅
- [ ] Shows combined data from both OTAs
- [ ] Revenue comparison by channel
- [ ] Performance analytics
- [ ] Trend charts

---

## 📞 Next Actions (IMMEDIATE)

**I will now create the following in order:**

1. ✅ **Database Migration** - Create OTA configuration tables
2. ✅ **Expedia Webhook Handler** - Receive bookings in real-time
3. ✅ **Expedia Setup UI** - Configuration page for property owners
4. ✅ **Expedia Bookings UI** - View and manage Expedia bookings
5. ✅ **Sync Scheduler** - Automated synchronization
6. ✅ **Testing Guide** - How to test the integration

**Then repeat for Booking.com.**

---

## 📝 Notes

- **Security**: All API credentials are encrypted in database
- **Testing**: Use sandbox mode for all testing
- **Webhooks**: Require HTTPS endpoints (provided by Supabase)
- **Rate Limits**: Respect OTA API rate limits
- **Error Handling**: Robust retry logic for failed syncs
- **Logging**: All API calls logged for debugging

---

**Ready to start implementation!**  
**Starting with: Database Migration for OTA Portal Enablement**

---

**Version**: 1.0  
**Last Updated**: December 26, 2024  
**Status**: READY TO IMPLEMENT
