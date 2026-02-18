# Service Operations - Data Synchronization with Public Portal

## Overview

The **Service Operations** page (`/portal/service-operations`) is a unified HMS portal interface for managing revenue-generating services:
- **Bar Orders** (HMS portal only)
- **SPA Bookings** (Synced ✅)
- **Events** (HMS portal only)
- **Restaurant Reservations** (⚠️ Partially synced - needs enhancement)

## Current Synchronization Status

### ✅ SPA Bookings - FULLY SYNCED
- **Public Portal**: Creates `spa_bookings` records via AI Assistant or booking forms
- **HMS Portal**: Service Operations reads from `spa_bookings` table
- **Status**: ✅ Unified and seamless

### ⚠️ Restaurant Reservations - PARTIALLY SYNCED
- **Public Portal**: Creates `restaurant_reservation_requests` via:
  - `RestaurantReserve.tsx` page (table reservations)
  - AI Assistant (creates actual `restaurant_reservation_requests` records)
- **HMS Portal**: Service Operations does NOT currently display `restaurant_reservation_requests`
- **Current Behavior**: Restaurant reservations are only visible in dedicated Restaurant/Concierge pages
- **Recommendation**: Add a "Restaurant Reservations" tab or integrate into Service Operations for unified view

### ❌ Bar Orders - HMS PORTAL ONLY
- **Public Portal**: Does not create bar orders (guests order from restaurant menu)
- **HMS Portal**: Service Operations creates and manages `bar_orders` for hotel guests and walk-in visitors
- **Status**: As intended - Bar orders are staff-managed

### ❌ Events - HMS PORTAL ONLY
- **Public Portal**: Does not create events
- **HMS Portal**: Service Operations creates and manages `events` for corporate meetings, weddings, etc.
- **Status**: As intended - Events are staff-managed

## Data Flow

### SPA Bookings Flow
```
Public Portal (Guest)
  ↓
Creates: spa_bookings
  - guest_id
  - service_id
  - booking_date
  - booking_time
  - status: 'pending'
  ↓
HMS Portal Service Operations
  ↓
Reads: spa_bookings
  - Displays in "SPA Bookings" tab
  - Can update status, payment
  - Can add to guest folio (if hotel guest)
```

### Restaurant Reservations Flow (Current - Needs Enhancement)
```
Public Portal (Guest)
  ↓
Creates: restaurant_reservation_requests
  - requested_date
  - requested_time
  - party_size
  - name, phone, email
  - status: 'new'
  ↓
HMS Portal Restaurant/Concierge Pages
  ↓
Manages: restaurant_reservation_requests
  - View and confirm reservations
  - NOT visible in Service Operations
```

### Bar Orders Flow
```
HMS Portal Staff
  ↓
Service Operations → "Bar Orders" tab
  ↓
Creates: bar_orders
  - For hotel guests (added to folio)
  - For walk-in visitors (direct payment)
  ↓
Can be viewed in:
  - Service Operations
  - Bar management pages
```

## Recommendations

### 1. Enhance Service Operations to Include Restaurant Reservations
Add a new tab or section to display `restaurant_reservation_requests`:
- Show pending, confirmed, and seated reservations
- Allow staff to confirm/cancel reservations
- Link to guest reservations if guest is checked in

### 2. Ensure No Orphan Data
- ✅ **SPA Bookings**: All public portal bookings are visible in HMS
- ⚠️ **Restaurant Reservations**: Currently not in Service Operations (but visible in other HMS pages)
- ✅ **Bar Orders**: HMS-only (no public portal creation)
- ✅ **Events**: HMS-only (no public portal creation)

### 3. Real-Time Updates
All tables use Supabase real-time subscriptions for instant updates:
- `spa_bookings` - Real-time updates between portals
- `restaurant_reservation_requests` - Real-time updates (if added to Service Operations)
- `bar_orders` - Real-time updates in HMS

## Tables Involved

| Table | Created By | Viewed In | Sync Status |
|-------|-----------|-----------|-------------|
| `spa_bookings` | Public Portal (AI/Forms) | Service Operations | ✅ Synced |
| `restaurant_reservation_requests` | Public Portal (Forms/AI) | Restaurant Pages | ⚠️ Separate |
| `bar_orders` | HMS Portal | Service Operations | ✅ HMS-only |
| `events` | HMS Portal | Service Operations | ✅ HMS-only |

## Implementation Notes

- All records include `property_id` for proper RLS enforcement
- Guest-linked records use `guest_id` for seamless folio integration
- Payment methods: `folio` (hotel guests) vs. `cash/card/upi` (visitors)
- Real-time subscriptions ensure instant visibility of new records
