# Public Portal Refactoring Plan

## Overview
Refactor the portal to achieve clear separation:
- **Public Landing Page** = All guest-related front-end actions (booking, restaurant orders, reservations)
- **Portal** = Core HMS for back office and operations (staff/admin only)

## Current State Analysis

### Portal Pages (Back Office - Staff/Admin Only)
✅ **Keep as-is** - These are well-built for operations:
- `Reservations.tsx` - Staff view of all reservations (CRUD, stats, bulk operations)
- `Restaurant.tsx` - Staff view of restaurant transactions (POS, payments, analytics)
- `FoodOrders.tsx` - Staff view of room service orders
- `BookingEngine.tsx` - Staff booking creation tool

### Public Pages (Guest-Facing)
⚠️ **Needs consolidation**:
- `public/Booking.tsx` - Guest booking flow (UUID-based)
- `public/BookingFlow.tsx` - Guest booking flow (slug-based)
- `public/BookingConfirmation.tsx` - Booking confirmation
- `public/RestaurantOrder.tsx` - Guest restaurant ordering (slug-based)
- `public/OrderFlow.tsx` - Guest restaurant ordering (alternative flow)
- `public/OrderConfirmation.tsx` - Order confirmation
- `public/RestaurantReserve.tsx` - Guest table reservation

### Account Pages (Authenticated Guests)
⚠️ **Needs enhancement**:
- `account/Bookings.tsx` - Basic guest view of own bookings
- `account/GuestDashboard.tsx` - Guest dashboard

## Refactoring Strategy

### Phase 1: Consolidate Public Booking Flows
**Goal**: Single, unified booking flow for guests

**Actions**:
1. Merge `Booking.tsx` and `BookingFlow.tsx` into a single `BookingFlow.tsx`
2. Support both UUID and slug-based property identification
3. Extract reusable booking components:
   - `BookingDatePicker.tsx`
   - `BookingGuestForm.tsx`
   - `BookingReview.tsx`
   - `BookingPayment.tsx`

### Phase 2: Consolidate Public Restaurant Flows
**Goal**: Single, unified restaurant ordering flow

**Actions**:
1. Merge `RestaurantOrder.tsx` and `OrderFlow.tsx` into a single `RestaurantOrder.tsx`
2. Support both UUID and slug-based restaurant identification
3. Extract reusable restaurant components:
   - `RestaurantMenu.tsx` (already exists, enhance)
   - `RestaurantCart.tsx`
   - `RestaurantCheckout.tsx`

### Phase 3: Enhance Account Pages
**Goal**: Rich guest self-service portal

**Actions**:
1. Enhance `account/Bookings.tsx` with features from portal `Reservations.tsx`:
   - View own bookings with filters
   - Cancel/modify bookings
   - View booking details
   - Download booking confirmation
2. Add new account pages:
   - `account/Orders.tsx` - View restaurant orders
   - `account/Reservations.tsx` - View table reservations
   - `account/Preferences.tsx` - Guest preferences

### Phase 4: Create Shared Components/Hooks
**Goal**: Reusable logic for both public and account pages

**Actions**:
1. Create shared hooks:
   - `hooks/shared/useBookingFlow.ts` - Booking flow logic
   - `hooks/shared/useRestaurantOrder.ts` - Restaurant order logic
   - `hooks/shared/useGuestBookings.ts` - Guest booking queries
2. Create shared components:
   - `components/shared/BookingSummary.tsx`
   - `components/shared/OrderSummary.tsx`
   - `components/shared/PaymentForm.tsx`

### Phase 5: Update Routing
**Goal**: Clear separation of concerns

**Actions**:
1. Public routes (no auth required):
   - `/` - Home
   - `/property/:id` - Property detail
   - `/booking/:propertyId` - Booking flow
   - `/dining/:propertyId` - Restaurant listing
   - `/dining/:propertyId/:outletSlug` - Restaurant detail
   - `/dining/:propertyId/:outletSlug/order` - Restaurant order
   - `/dining/:propertyId/:outletSlug/reserve` - Table reservation

2. Account routes (auth required, guest scope):
   - `/account` - Guest dashboard
   - `/account/bookings` - My bookings
   - `/account/orders` - My orders
   - `/account/reservations` - My table reservations
   - `/account/preferences` - Preferences

3. Portal routes (auth required, staff/admin scope):
   - `/dashboard` - Staff dashboard
   - `/reservations` - All reservations (staff view)
   - `/restaurant` - Restaurant operations (staff view)
   - `/food-orders` - Food orders (staff view)

## Implementation Details

### Shared Booking Logic
Extract from portal `Reservations.tsx`:
- Booking validation
- Guest creation/lookup
- Availability checking
- Price calculation
- Reservation creation

**Scope for public pages**: Only own bookings, simplified UI
**Scope for portal pages**: All bookings, full CRUD, bulk operations

### Shared Restaurant Logic
Extract from portal `Restaurant.tsx`:
- Order creation
- Payment processing
- Order status tracking

**Scope for public pages**: Guest orders only, simplified UI
**Scope for portal pages**: All orders, full POS, analytics

## Benefits

1. **Clear Separation**: Portal = operations, Public = guest actions
2. **Code Reuse**: Shared components/hooks reduce duplication
3. **Better UX**: Unified flows for guests, no confusion
4. **Maintainability**: Single source of truth for booking/ordering logic
5. **Scalability**: Easy to add new guest-facing features

## Migration Path

1. Create new consolidated pages alongside existing ones
2. Update routing to use new pages
3. Test thoroughly
4. Remove old duplicate pages
5. Update documentation

