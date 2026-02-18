# Events Pages Standardization Plan

## Current State Analysis

### ✅ What's Working
- Events pages ARE wrapped with `PublicRoute` (provides `PublicShell` → `PublicLayout`)
- `space_utilization_logs` table exists for event bookings
- Images are being loaded (after fixes)
- Basic structure exists

### ❌ Issues to Fix

1. **Layout Inconsistencies**
   - Events.tsx uses `ExperienceShell` (different from RestaurantDetail)
   - EventSpaceDetail.tsx uses `VenuePage` (different structure)
   - Inconsistent spacing, typography, component usage

2. **Missing Booking Flow**
   - No dedicated EventBookingRequest page (unlike RestaurantReserve)
   - Redirects to generic `/account/requests?type=event`
   - Missing proper booking form with all required fields

3. **Information Display**
   - Missing consistent InfoCard sections (capacity, pricing, availability)
   - No details sections like RestaurantDetail
   - Missing contact/pricing information

4. **CRUD Operations**
   - No event booking management page for guests
   - Can't view/edit/cancel event bookings
   - Missing availability checking

## Standard Pattern (from RestaurantDetail)

```typescript
1. SEOHead
2. HeroBanner (title, subtitle, image, height="70vh")
3. Gallery Section (container mx-auto px-4 py-12, ImageGallery)
4. Details Section (container mx-auto px-4 py-12, InfoCard grid)
5. CTA Section (bg-primary, container mx-auto px-4 py-12)
```

## Implementation Steps

### Phase 1: Standardize Layout (Events.tsx)
- Replace `ExperienceShell` with standard pattern
- Use `HeroBanner` component
- Use standard sections with consistent spacing
- Match RestaurantDetail structure

### Phase 2: Standardize EventSpaceDetail.tsx
- Replace `VenuePage` OR update to match standard
- Use `HeroBanner` + standard sections
- Add InfoCard sections (capacity, features, pricing)
- Add Contact/Inquiry section

### Phase 3: Create EventBookingRequest Page
- Similar to RestaurantReserve.tsx
- Form fields: event type, space, date/time, guest count, requirements, contact
- Use `space_utilization_logs` table
- Route: `/property/v3-grand-hotel/events/:spaceSlug/request`

### Phase 4: Add Event Booking Management
- Create EventBookings.tsx (in account section)
- List user's event bookings
- View/edit/cancel functionality

### Phase 5: Standardize Header/Footer
- Verify all pages use same header/footer via PublicRoute
- Ensure consistent sizing and spacing

## Files to Create/Modify

### New Files
- `src/pages/public/EventBookingRequest.tsx`
- `src/pages/account/EventBookings.tsx`
- `src/services/data/eventService.ts`

### Files to Modify
- `src/pages/public/Events.tsx` - Standardize layout
- `src/pages/public/EventSpaceDetail.tsx` - Standardize layout
- `src/routes/index.tsx` - Add EventBookingRequest route
