# Component Splitting Plan

**Purpose**: Strategic plan for splitting large components into smaller, maintainable pieces.

---

## BookingEngine.tsx (3000+ lines)

### Current Structure
- Step 1: Stay Details & Room Selection (~1000 lines)
- Step 2: Guest Details Form (~600 lines)
- Step 3: Review & Payment (~800 lines)
- Step 4: Payment & Confirmation (~600 lines)
- Shared: Pricing calculations, validation, booking creation (~400 lines)

### Planned Split

**Created:**
- ✅ `src/components/booking/BookingTypes.ts` - Shared types
- ✅ `src/components/booking/BookingConstants.ts` - Shared constants
- ✅ `src/components/booking/BookingStep1StayDetails.tsx` - Step 1 component (partial)

**To Create:**
- `src/components/booking/BookingStep2GuestDetails.tsx` - Guest details form
- `src/components/booking/BookingStep3Review.tsx` - Review & payment
- `src/components/booking/BookingStep4Confirmation.tsx` - Payment & confirmation
- `src/components/booking/BookingSummarySidebar.tsx` - Pricing breakdown sidebar
- `src/components/booking/BookingValidation.ts` - Validation utilities

**Refactor Main Component:**
- Keep `src/pages/BookingEngine.tsx` as orchestrator (~500 lines)
- Import and compose step components
- Keep state management and booking creation logic

**Benefits:**
- Each step is ~200-400 lines (maintainable)
- Easier to test individual steps
- Can reuse steps in other booking flows
- Better code organization

---

## FinancialReports.tsx (1600+ lines)

### Current Structure
- Financial Metrics Cards (~300 lines)
- Revenue Breakdown (~400 lines)
- Expenses Breakdown (~400 lines)
- Profit & Loss (~300 lines)
- Cash Flow (~200 lines)

### Planned Split

**To Create:**
- `src/components/financial/FinancialMetricsCards.tsx` - Top metric tiles
- `src/components/financial/RevenueBreakdownSection.tsx` - Revenue charts
- `src/components/financial/ExpensesBreakdownSection.tsx` - Expense charts
- `src/components/financial/ProfitLossSection.tsx` - P&L charts
- `src/components/financial/CashFlowSection.tsx` - Cash flow charts
- `src/components/financial/FinancialReportsFilters.tsx` - Period/report type selectors
- `src/hooks/finance/useFinancialReports.ts` - Data fetching hook

**Refactor Main Component:**
- Keep `src/pages/FinancialReports.tsx` as orchestrator (~200 lines)
- Import and compose sections
- Use centralized hook for data

**Benefits:**
- Each section is ~200-400 lines
- Can reuse sections in other reports
- Easier to test individual sections
- Better performance (lazy load sections)

---

## Implementation Strategy

### Phase 1: Extract Shared Code ✅
- [x] Create shared types (BookingTypes.ts)
- [x] Create shared constants (BookingConstants.ts)
- [x] Create Step 1 component (partial)

### Phase 2: Extract Steps (Incremental)
- [ ] Extract Step 2 (Guest Details)
- [ ] Extract Step 3 (Review)
- [ ] Extract Step 4 (Confirmation)
- [ ] Extract Summary Sidebar
- [ ] Refactor main component to use extracted components

### Phase 3: Extract Financial Sections
- [ ] Extract Financial Metrics Cards
- [ ] Extract Revenue Breakdown
- [ ] Extract Expenses Breakdown
- [ ] Extract P&L Section
- [ ] Create useFinancialReports hook
- [ ] Refactor main component

### Phase 4: Testing & Cleanup
- [ ] Test all extracted components
- [ ] Remove duplicate code
- [ ] Update imports across codebase
- [ ] Verify no regressions

---

## Notes

- **Incremental Approach**: Split one component at a time, test, then move to next
- **Backward Compatibility**: Keep main components working during refactoring
- **Shared Logic**: Extract common validation, pricing, formatting to utilities
- **Performance**: Use lazy loading for extracted components
