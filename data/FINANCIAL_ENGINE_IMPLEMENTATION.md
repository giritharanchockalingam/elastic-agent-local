# Financial Engine Implementation Guide

**Purpose**: Guide for refactoring pages to use the centralized Financial Engine.

**Last Updated**: 2024

---

## Overview

The Financial Engine provides a centralized, consistent way to handle all financial calculations across the application. This guide explains how to refactor existing pages to use the engine.

---

## Architecture

### Core Modules

1. **Domain Model** (`src/lib/finance/domain.ts`):
   - Canonical types: `Money`, `PriceComponent`, `RoomStayPricing`, `DiningCheck`, etc.
   - Single source of truth for financial data structures

2. **Pricing Engine** (`src/lib/finance/pricingEngine.ts`):
   - `computeRoomStayPricing()`: Room pricing
   - `computeDiningCheck()`: F&B pricing
   - `computeSpaSessionPricing()`: Spa pricing
   - `computeEventBookingPricing()`: Event pricing

3. **Booking Engine** (`src/lib/finance/bookingEngine.ts`):
   - `buildRoomBookingPayload()`: Creates booking with financial snapshot
   - `normalizeBookingRow()`: Converts DB row to financial snapshot
   - `createBookingWithPricing()`: Creates booking with validated pricing

4. **Summary Engine** (`src/lib/finance/summaryEngine.ts`):
   - `getGuestFinancialSummary()`: Guest summaries
   - `getPropertyFinancialSummary()`: Property-level summaries

### React Hooks

All hooks are in `src/hooks/finance/`:

- `useRoomStayPricing()`: Room pricing preview
- `useBookingPricingPreview()`: Full booking pricing
- `useGuestFinancialSummary()`: Guest summaries
- `useDiningCheckPreview()`: F&B order pricing
- `useSpaSessionPricingPreview()`: Spa pricing
- `useEventPricingPreview()`: Event pricing

---

## Refactoring Patterns

### Pattern 1: Room Pricing

**Before**:
```tsx
const subtotal = roomPrice * nights;
const tax = subtotal * 0.12; // Hardcoded
const total = subtotal + tax;
```

**After**:
```tsx
import { useRoomStayPricing } from '@/hooks/finance';

const { pricing, formatted, isLoading } = useRoomStayPricing({
  propertyId,
  roomTypeId,
  checkIn: checkInDate,
  checkOut: checkOutDate,
  guests: { adults, children, rooms: 1 },
});

// Use pricing.total.amount or formatted.total
```

### Pattern 2: F&B Pricing

**Before**:
```tsx
const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
const tax = subtotal * 0.05; // Hardcoded
const serviceFee = subtotal * 0.02; // Hardcoded
const total = subtotal + tax + serviceFee;
```

**After**:
```tsx
import { useDiningCheckPreview } from '@/hooks/finance';

const { check, formatted, isLoading } = useDiningCheckPreview({
  propertyId,
  venueId,
  items: cartItems.map(item => ({
    id: item.id,
    name: item.name,
    quantity: item.quantity,
    unitPrice: item.price,
  })),
  serviceMode: 'dine-in',
});

// Use check.total.amount or formatted.total
```

### Pattern 3: Booking Creation

**Before**:
```tsx
const total = calculateTotal(); // Inline calculation
await createReservation({
  ...bookingData,
  total_amount: total, // May not match what was shown
});
```

**After**:
```tsx
import { createBookingWithPricing } from '@/lib/finance/bookingEngine';

const result = await createBookingWithPricing({
  propertyId,
  roomTypeId,
  guestId,
  checkInDate,
  checkOutDate,
  adults,
  children,
  // ... other params
});

// result.financialSnapshot contains the canonical pricing
// result.reservationId is the created booking ID
```

### Pattern 4: Guest Summary

**Before**:
```tsx
const bookings = await fetchBookings(guestId);
const total = bookings.reduce((sum, b) => sum + b.total_amount, 0);
```

**After**:
```tsx
import { useGuestFinancialSummary } from '@/hooks/finance';

const { summary, formatted, isLoading } = useGuestFinancialSummary({
  guestId,
});

// summary.totalSpend.amount or formatted.totalSpend
// summary.upcomingBookings, summary.pastBookings
```

---

## Refactoring Checklist

### For Each Page/Component:

- [ ] **Identify financial calculations**:
  - Find all places where prices, totals, taxes, fees are calculated
  - List all hardcoded values (tax rates, service charges, etc.)

- [ ] **Choose the right hook/service**:
  - Room bookings → `useRoomStayPricing()` or `useBookingPricingPreview()`
  - F&B orders → `useDiningCheckPreview()`
  - Spa bookings → `useSpaSessionPricingPreview()`
  - Events → `useEventPricingPreview()`
  - Guest summaries → `useGuestFinancialSummary()`

- [ ] **Replace inline calculations**:
  - Remove hardcoded tax rates, service charges, etc.
  - Replace with hook/service calls
  - Use `formatted` values for display

- [ ] **Update display logic**:
  - Use `formatted.*` for currency display
  - Use `pricing.*` or `check.*` for detailed breakdowns
  - Handle loading and error states

- [ ] **Test**:
  - Verify totals match between selection, review, and confirmation
  - Check that values are consistent across pages
  - Test with different property settings (tax rates, etc.)

---

## Pages to Refactor

### High Priority

1. **`src/components/restaurant/CartSidebar.tsx`** ⚠️
   - **Status**: Hardcoded calculations (tax 5%, service charge 2%, delivery fee ₹50)
   - **Action**: Use `useDiningCheckPreview()`
   - **Props needed**: `propertyId`, `venueId`

2. **`src/pages/BookingEngine.tsx`** ⚠️
   - **Status**: Has its own `calculateRoomPrice()` logic, hardcoded tax rate 18%
   - **Action**: Use `useRoomStayPricing()` and `useBookingPricingPreview()`
   - **Note**: Large file, refactor incrementally

3. **`src/pages/public/Booking.tsx`** ✅
   - **Status**: Already uses `getRoomTypePricing()` but has fallback logic
   - **Action**: Remove fallback, use hook instead

4. **`src/pages/public/BookingFlowUnified.tsx`** ✅
   - **Status**: Already uses `getRoomTypePricing()` but has fallback logic
   - **Action**: Remove fallback, use hook instead

### Medium Priority

5. **`src/lib/domain/booking.ts`** ⚠️
   - **Status**: Inline pricing calculation
   - **Action**: Use `buildRoomBookingPayload()` from booking engine

6. **`src/pages/account/Bookings.tsx`** ✅
   - **Status**: Uses domain service, but could use `normalizeBookingRow()` for consistency
   - **Action**: Use `normalizeBookingRow()` for display

7. **`src/pages/FinancialReports.tsx`** ⚠️
   - **Status**: Uses `calculateTotalRevenue()` (good), but some inline calculations
   - **Action**: Use `getPropertyFinancialSummary()` for consistency

### Low Priority

8. **`src/pages/Accounting.tsx`** ⚠️
   - **Status**: Direct DB queries, no centralized aggregation
   - **Action**: Use summary engine functions

9. **`src/pages/Spa.tsx`** ⚠️
   - **Status**: Revenue aggregation only, no per-booking pricing
   - **Action**: Use `useSpaSessionPricingPreview()` for booking previews

10. **`src/pages/public/RestaurantOrder.tsx`** / **`RestaurantOrderUnified.tsx`** ❓
    - **Status**: Unknown - needs review
    - **Action**: Use `useDiningCheckPreview()` if pricing is calculated

---

## Migration Strategy

### Phase 1: Core Engine (✅ Complete)
- [x] Domain model
- [x] Pricing engine
- [x] Booking engine
- [x] Summary engine
- [x] React hooks

### Phase 2: High-Priority Pages (In Progress)
- [ ] CartSidebar.tsx
- [ ] BookingEngine.tsx
- [ ] Remove fallback logic from Booking.tsx and BookingFlowUnified.tsx

### Phase 3: Medium-Priority Pages
- [ ] domain/booking.ts
- [ ] account/Bookings.tsx
- [ ] FinancialReports.tsx

### Phase 4: Low-Priority Pages
- [ ] Accounting.tsx
- [ ] Spa.tsx
- [ ] RestaurantOrder.tsx

### Phase 5: Cleanup
- [ ] Remove unused calculation functions
- [ ] Update documentation
- [ ] Add tests

---

## Common Issues & Solutions

### Issue 1: Missing propertyId/venueId

**Problem**: Component doesn't have `propertyId` or `venueId` to pass to hook.

**Solution**:
- Use `useProperty()` hook from `PropertyContext`
- Pass as prop from parent component
- Extract from route params (`useParams()`)

### Issue 2: Hook returns null during loading

**Problem**: Component tries to access `pricing.total.amount` when `pricing` is null.

**Solution**:
```tsx
const { pricing, isLoading } = useRoomStayPricing({...});

if (isLoading) return <Loading />;
if (!pricing) return <Error />;

// Now safe to use pricing.total.amount
```

### Issue 3: Need to update existing booking

**Problem**: Existing booking has wrong total, need to recompute.

**Solution**:
- Use `buildRoomBookingPayload()` to get correct pricing
- Update `reservations.total_amount` in database
- See maintenance scripts for bulk updates

### Issue 4: Custom pricing rules

**Problem**: Need to apply custom discount or fee not in engine.

**Solution**:
- Add to `context.extras` or `context.promoCode`
- Extend pricing engine to support new rule types
- Or apply as post-processing (not recommended)

---

## Testing

### Unit Tests

Test each engine function:
```ts
import { computeRoomStayPricing } from '@/lib/finance/pricingEngine';

test('computes room pricing correctly', async () => {
  const pricing = await computeRoomStayPricing({
    propertyId: '...',
    roomTypeId: '...',
    checkIn: '2024-01-01',
    checkOut: '2024-01-03',
    guests: { adults: 2, rooms: 1 },
  });
  
  expect(pricing.total.amount).toBeGreaterThan(0);
  expect(pricing.nights).toBe(2);
});
```

### Integration Tests

Test hooks with React Query:
```tsx
import { renderHook, waitFor } from '@testing-library/react';
import { useRoomStayPricing } from '@/hooks/finance';

test('hook returns pricing', async () => {
  const { result } = renderHook(() => useRoomStayPricing({...}));
  
  await waitFor(() => expect(result.current.pricing).not.toBeNull());
  expect(result.current.formatted.total).toMatch(/^₹/);
});
```

### E2E Tests

Test full booking flow:
- Select room → Review → Confirm
- Verify totals match at each step
- Verify persisted total matches displayed total

---

## Performance Considerations

1. **Caching**: Hooks use React Query with `staleTime` to cache results
2. **Parallel Queries**: Use `Promise.all()` in engine functions to fetch data in parallel
3. **Lazy Loading**: Only compute pricing when needed (use `enabled` flag in hooks)

---

## Support

For questions or issues:
1. Review this guide
2. Check `docs/FINANCIAL_DOMAIN_MAP.md` for current state
3. Contact development team
