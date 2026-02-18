# Events Pages Consistency & Standardization Plan

## Overview
Comprehensive plan to standardize all Events pages to match the consistent pattern used across other public portal pages (Restaurant, Wellness, etc.).

## Current Issues Identified

### 1. Layout Inconsistencies
- ✅ Events pages ARE wrapped with `PublicRoute` (provides `TenantShell`)
- ❌ Events.tsx uses `ExperienceShell` while RestaurantDetail uses `HeroBanner` + standard sections
- ❌ EventSpaceDetail uses `VenuePage` component which has different structure
- ❌ Inconsistent spacing, typography, and component usage

### 2. Header/Footer Sizing
- ❌ Header/footer sizing may differ between pages
- ❌ Need to verify consistent sizing across all public pages

### 3. Body Content & Context
- ❌ Events.tsx has redundant image sections that could be simplified
- ❌ EventSpaceDetail lacks consistent information display pattern
- ❌ Missing standard sections (details, contact, pricing, availability)

### 4. Workflow & Information Capture
- ❌ No dedicated EventBookingRequest page (unlike RestaurantReserve)
- ❌ Event bookings redirect to generic `/account/requests?type=event`
- ❌ Missing proper event booking form with all required fields:
  - Event type (wedding, banquet, meeting)
  - Event space selection
  - Date/time
  - Guest count
  - Special requirements
  - Contact information
  - Budget/pricing tier

### 5. CRUD Operations
- ❌ No dedicated event booking management page for guests
- ❌ Guests can't view/edit/cancel their event bookings
- ❌ Missing event availability checking
- ❌ Missing event pricing display

## Standard Pattern (from RestaurantDetail)

```typescript
// Structure:
1. SEOHead
2. HeroBanner (title, subtitle, image, height="70vh")
3. Gallery Section (container mx-auto px-4 py-12)
4. Details Section (InfoCard components in grid)
5. CTA Section (bg-primary, centered buttons)
```

## Implementation Plan

### Phase 1: Standardize Layout Structure
1. **Events.tsx**
   - Replace `ExperienceShell` with standard pattern (HeroBanner + sections)
   - Match RestaurantDetail/Wellness layout
   - Consistent spacing: `container mx-auto px-4 py-12`
   - Standard section headers: `text-3xl font-bold text-center mb-8`

2. **EventSpaceDetail.tsx**
   - Replace `VenuePage` with standard pattern (HeroBanner + sections)
   - Or update VenuePage to match standard if it's used elsewhere
   - Add Details section with InfoCard components (capacity, features, pricing)
   - Add Contact/Inquiry section

### Phase 2: Create Event Booking Flow
1. **Create EventBookingRequest.tsx**
   - Similar to RestaurantReserve.tsx
   - Route: `/property/v3-grand-hotel/events/:spaceSlug/request`
   - Form fields:
     - Event type dropdown
     - Event space (pre-filled from route)
     - Event date
     - Event time
     - Guest count
     - Event duration
     - Special requirements/notes
     - Contact information (name, email, phone)
     - Budget range (optional)
   
2. **Update Database/Service Layer**
   - Check if `event_bookings` or similar table exists
   - Create service functions for event bookings
   - Add validation and availability checking

### Phase 3: Add Event Booking Management
1. **Create EventBookings.tsx** (in account section)
   - List user's event bookings
   - View booking details
   - Cancel/modify bookings
   - Similar to guest booking management

### Phase 4: Standardize Information Display
1. **EventSpaceDetail.tsx**
   - Add consistent InfoCard sections:
     - Capacity & Layout
     - Features & Amenities
     - Pricing & Packages
     - Availability Calendar
     - Location & Contact

2. **Events.tsx**
   - Simplify sections to match Wellness pattern
   - Remove redundant image filtering
   - Use standard gallery component

### Phase 5: Header/Footer Consistency
1. Verify all Events pages use same header/footer via PublicRoute
2. Ensure consistent sizing and spacing
3. Test responsive behavior

## Files to Create/Modify

### New Files
- `src/pages/public/EventBookingRequest.tsx` - Event booking form page
- `src/pages/account/EventBookings.tsx` - Event bookings management
- `src/services/data/eventService.ts` - Event booking service functions
- `supabase/migrations/XXXXX_create_event_bookings.sql` - Event bookings table (if needed)

### Files to Modify
- `src/pages/public/Events.tsx` - Standardize layout
- `src/pages/public/EventSpaceDetail.tsx` - Standardize layout, add details sections
- `src/routes/index.tsx` - Add EventBookingRequest route
- `src/pages/account/Requests.tsx` - Optionally improve event request handling

## Success Criteria
1. ✅ All Events pages match RestaurantDetail layout pattern
2. ✅ Consistent header/footer sizing across all pages
3. ✅ Standard information display (InfoCard, sections, spacing)
4. ✅ Dedicated event booking form (like RestaurantReserve)
5. ✅ Guests can create/view/manage event bookings
6. ✅ All pages capture consistent information
7. ✅ Consistent workflow across all public pages
