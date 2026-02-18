# Financial Domain Map

**Purpose**: Comprehensive mapping of all financial touchpoints across the Aurora HMS / V3 Grand portal.

**Last Updated**: 2024

---

## 1. Data Sources

### 1.1 Database Tables
- **`reservations`**: Room bookings with `total_amount`, `payment_status`
- **`room_types`**: Base pricing (`base_price`, `base_rate`)
- **`pricing_rules`**: Dynamic pricing adjustments
- **`payments`**: Payment transactions linked to reservations
- **`food_orders`**: Restaurant/room service orders with `total_amount`, `order_type`
- **`bar_orders`**: Bar orders with `total_amount`, `payment_status`
- **`spa_bookings`**: Spa appointments (price from `spa_services.price` via FK)
- **`spa_services`**: Service definitions with `price`
- **`events`**: Event bookings with `total_cost`
- **`pos_transactions`**: POS system transactions (outlet_type, amount)
- **`expenses`**: Property expenses
- **`payroll_records`**: Staff payroll
- **`tax_filings`**: Tax compliance records
- **`properties`**: Property settings including `tax_rate`

### 1.2 Views & RPCs
- None currently identified (all direct table queries)

---

## 2. Current Calculation Spots by Domain

### 2.1 Rooms & Stays

#### Files with Room Pricing Logic:
1. **`src/lib/finance/pricing.ts`** ✅ (Centralized)
   - `getRoomTypePricing()`: Main pricing calculation
   - Uses `pricingEngine.ts` for rule evaluation
   - Calculates: base, adjustments, subtotal, taxes, total

2. **`src/pages/BookingEngine.tsx`**
   - **Lines 296-300**: Hardcoded `TAX_RATE = 0.18` (18% GST)
   - **Lines 500-600**: Inline calculations for room prices
   - **Lines 800-900**: `calculateRoomPrice()`, `calculateSubtotal()`, `calculateTax()`, `calculateTotal()`
   - Uses `useBookingState` hook which has its own calculations
   - **Issue**: Duplicate logic, not using centralized `getRoomTypePricing`

3. **`src/pages/public/Booking.tsx`**
   - **Lines 90-110**: Uses `getRoomTypePricing` ✅ (Good)
   - **Lines 107-110**: Fallback calculations if pricing service fails
   - **Issue**: Fallback logic duplicates centralized service

4. **`src/pages/public/BookingFlowUnified.tsx`**
   - **Lines 200-250**: Uses `getRoomTypePricing` ✅ (Good)
   - Similar fallback pattern

5. **`src/components/hotel/BookingWidget.tsx`**
   - **Status**: Unknown - needs review

6. **`src/lib/domain/booking.ts`**
   - **Lines 104-150**: Inline pricing calculation
   - **Issue**: Not using centralized service

#### Observed Inconsistencies:
- Tax rates: 12% (pricing.ts default), 18% (BookingEngine.tsx), 5% (CartSidebar.tsx)
- Some pages use centralized service, others don't
- Fallback calculations duplicate logic

---

### 2.2 Dining / F&B

#### Files with F&B Pricing Logic:
1. **`src/components/restaurant/CartSidebar.tsx`**
   - **Lines 58-71**: Inline calculations
   - **Line 59**: `tax = subtotal * 0.05` (5% GST) - hardcoded
   - **Line 61**: `serviceFee = subtotal * 0.02` (2% service charge) - hardcoded
   - **Line 60**: `deliveryFee = serviceMode === "delivery" ? 50 : 0` - hardcoded
   - **Line 69**: `promoDiscount = promoApplied ? subtotal * 0.10 : 0` - mock logic
   - **Issue**: All hardcoded, no DB/config source

2. **`src/components/restaurant/OrderSummary.tsx`**
   - **Lines 224-260**: Displays pricing breakdown
   - Receives `pricing` prop (calculated elsewhere)
   - **Status**: Display only, no calculation

3. **`src/lib/financialCalculations.ts`**
   - **Lines 135-174**: `calculateRestaurantRevenue()` - aggregation logic
   - **Lines 181-230**: `calculateBarRevenue()` - aggregation logic
   - **Lines 235-239**: `calculateRoomServiceRevenue()` - aggregation logic
   - **Status**: Revenue aggregation (reports), not per-order pricing

4. **`src/pages/public/RestaurantOrder.tsx`** / **`RestaurantOrderUnified.tsx`**
   - **Status**: Unknown - needs review

#### Observed Inconsistencies:
- Tax rates vary (5% in CartSidebar, 12% default in pricing.ts)
- Service charges hardcoded
- Promo codes are mock logic
- No centralized F&B pricing service

---

### 2.3 Wellness / Spa

#### Files with Spa Pricing Logic:
1. **`src/pages/Spa.tsx`**
   - **Lines 132-174**: Revenue calculation from `spa_bookings` + `spa_services`
   - **Line 151-158**: Extracts price from nested `spa_services.price`
   - **Status**: Revenue aggregation only, not per-booking pricing

2. **`src/lib/financialCalculations.ts`**
   - **Lines 247-268**: `calculateSpaRevenue()` - aggregation logic
   - Same pattern: extracts price from `spa_services.price`

3. **`src/pages/Accounting.tsx`**
   - **Lines 400-500**: Displays spa bookings with prices
   - **Issue**: Direct access to nested `spa_services.price` (fragile)

#### Observed Inconsistencies:
- No centralized spa pricing service
- Price extraction logic duplicated
- No support for packages, add-ons, discounts

---

### 2.4 Events & Banquets

#### Files with Event Pricing Logic:
1. **`src/lib/financialCalculations.ts`**
   - **Lines 273-277**: `calculateEventsRevenue()` - simple aggregation
   - Filters cancelled events, sums `total_cost`

2. **`src/pages/Accounting.tsx`**
   - **Lines 500-600**: Displays events with `total_cost`

#### Observed Inconsistencies:
- No pricing calculation service (assumes `total_cost` is pre-calculated)
- No support for per-person charges, venue rental, packages
- No centralized event pricing engine

---

### 2.5 Cross-Cutting (My Account, Dashboards, Reports)

#### Files with Summary/Aggregation Logic:
1. **`src/lib/finance/summary.ts`** ✅ (Centralized)
   - `getGuestBookingSummary()`: Guest booking summaries
   - Uses real DB data, no mocks

2. **`src/pages/account/Bookings.tsx`**
   - **Lines 52-59**: Fetches bookings via `getGuestBookings()`
   - **Status**: Uses domain service, not direct calculations

3. **`src/pages/FinancialReports.tsx`**
   - **Lines 690-970**: Comprehensive financial metrics
   - Uses `calculateTotalRevenue()` from `financialCalculations.ts` ✅
   - **Lines 704-970**: Calculates EBITDA, net profit, margins
   - **Issue**: Some inline calculations, but mostly uses centralized functions

4. **`src/pages/Revenue.tsx`**
   - **Status**: Unknown - needs review

5. **`src/pages/Dashboard.tsx`**
   - **Status**: Unknown - needs review

6. **`src/pages/Accounting.tsx`**
   - **Lines 200-600**: Displays various financial transactions
   - **Issue**: Direct DB queries, no centralized aggregation

#### Observed Inconsistencies:
- Some pages use centralized functions, others don't
- Dashboard widgets may have duplicate aggregation logic

---

## 3. Observed Inconsistencies & Duplication

### 3.1 Tax Rates
- **12%**: Default in `pricing.ts` (GST for India)
- **18%**: Hardcoded in `BookingEngine.tsx`
- **5%**: Hardcoded in `CartSidebar.tsx` (F&B)
- **Issue**: Should come from `properties.tax_rate` or config

### 3.2 Service Charges
- **2%**: Hardcoded in `CartSidebar.tsx` (F&B)
- **No service charge**: Room bookings (may be intentional)
- **Issue**: Should be configurable per property/venue

### 3.3 Pricing Calculation Duplication
- `BookingEngine.tsx` has its own `calculateRoomPrice()` logic
- `pricing.ts` has `getRoomTypePricing()` (centralized)
- `domain/booking.ts` has inline calculations
- **Issue**: Three different implementations

### 3.4 F&B Pricing
- All logic in `CartSidebar.tsx` is hardcoded
- No service layer for F&B pricing
- Promo codes are mock logic
- **Issue**: No centralized F&B pricing engine

### 3.5 Spa/Events Pricing
- No pricing calculation services
- Assumes prices are pre-calculated in DB
- **Issue**: No support for dynamic pricing, packages, discounts

---

## 4. Missing Centralized Services

### 4.1 F&B Pricing Engine
- Calculate subtotal from menu items
- Apply service charges (configurable per venue)
- Apply taxes (configurable per property/venue)
- Apply discounts/promo codes
- Calculate delivery fees
- Handle tips (dine-in only)

### 4.2 Spa Pricing Engine
- Base service price from `spa_services`
- Package pricing (multiple services)
- Add-ons (extras, upgrades)
- Duration-based pricing
- Discounts/promo codes

### 4.3 Event Pricing Engine
- Venue rental (base cost)
- Per-person charges
- Package pricing (food + venue + services)
- Add-ons (decor, AV, etc.)
- Taxes and service charges

### 4.4 Unified Financial Hooks
- `useRoomStayPricing()`: Room pricing preview
- `useBookingPricingPreview()`: Full booking pricing
- `useGuestFinancialSummary()`: Guest summaries
- `useDiningCheckPreview()`: F&B order pricing
- `useSpaSessionPricingPreview()`: Spa pricing
- `useEventPricingPreview()`: Event pricing

---

## 5. Recommendations

### 5.1 Immediate Actions
1. ✅ **Already Done**: Centralized room pricing (`src/lib/finance/pricing.ts`)
2. ✅ **Already Done**: Centralized booking service (`src/lib/finance/bookings.ts`)
3. ✅ **Already Done**: Centralized summary service (`src/lib/finance/summary.ts`)
4. ⚠️ **In Progress**: Refactor `BookingEngine.tsx` to use centralized pricing
5. ⚠️ **In Progress**: Refactor `BookingFlowUnified.tsx` to remove fallback logic
6. ❌ **TODO**: Create F&B pricing engine
7. ❌ **TODO**: Create Spa pricing engine
8. ❌ **TODO**: Create Event pricing engine
9. ❌ **TODO**: Create financial hooks layer
10. ❌ **TODO**: Refactor all pages to use hooks

### 5.2 Data Quality Issues
- Some bookings have `total_amount = 0` or `null`
- Inconsistent nights vs. dates calculations
- Some spa bookings missing service relationships
- **Action**: Create data quality scripts (see PART 6)

---

## 6. File Inventory

### 6.1 Files with Financial Logic (by domain)

**Rooms:**
- `src/lib/finance/pricing.ts` ✅
- `src/lib/finance/bookings.ts` ✅
- `src/pages/BookingEngine.tsx` ⚠️
- `src/pages/public/Booking.tsx` ✅
- `src/pages/public/BookingFlowUnified.tsx` ✅
- `src/lib/domain/booking.ts` ⚠️

**F&B:**
- `src/components/restaurant/CartSidebar.tsx` ❌
- `src/components/restaurant/OrderSummary.tsx` (display only)
- `src/lib/financialCalculations.ts` (aggregation only)

**Spa:**
- `src/pages/Spa.tsx` (aggregation only)
- `src/lib/financialCalculations.ts` (aggregation only)

**Events:**
- `src/lib/financialCalculations.ts` (aggregation only)

**Reports/Dashboards:**
- `src/lib/finance/summary.ts` ✅
- `src/pages/FinancialReports.tsx` ⚠️
- `src/pages/Accounting.tsx` ⚠️
- `src/pages/Revenue.tsx` (unknown)

**Legacy/Supporting:**
- `src/services/pricingEngine.ts` ✅ (rule evaluation)
- `src/lib/financialCalculations.ts` ✅ (revenue aggregation)

### 6.2 Legend
- ✅ = Centralized, follows best practices
- ⚠️ = Partially centralized, needs refactoring
- ❌ = Hardcoded/inline logic, needs centralization

---

**Next Steps**: See `docs/FINANCIAL_ENGINE_IMPLEMENTATION.md` (to be created in PART 3)
