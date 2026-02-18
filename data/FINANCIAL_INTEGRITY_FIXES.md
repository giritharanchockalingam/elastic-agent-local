# Financial Data Integrity Fixes

## Overview

This document describes the comprehensive fixes applied to ensure financial numbers are accurate, consistent, and match to the cent across all pages of the application.

## Issues Identified

1. **Precision Issues**: Floating-point arithmetic causing rounding errors
2. **Double-Counting**: POS transactions counted in both food_orders/bar_orders and separately
3. **Inconsistent Calculations**: Different pages using different calculation methods
4. **Data Mismatches**: Payments not matching reservation totals, invoices not matching payments
5. **Date Filtering**: Inconsistent date range filtering across pages

## Fixes Applied

### 1. Safe Number Function (`src/lib/utils.ts`)

**Issue**: `safeNumber` didn't round to 2 decimal places, causing floating-point precision errors.

**Fix**: 
```typescript
export function safeNumber(value: number | string | null | undefined): number {
  if (value === null || value === undefined || value === '') return 0;
  const num = typeof value === 'string' ? parseFloat(value) : Number(value);
  if (isNaN(num)) return 0;
  // Round to 2 decimal places to prevent floating-point errors
  return Math.round(num * 100) / 100;
}
```

**Impact**: All financial calculations now round to 2 decimal places, ensuring amounts match to the cent.

### 2. Double-Counting Prevention (`src/lib/financialCalculations.ts`)

**Issue**: POS transactions were being counted in both:
- `food_orders`/`bar_orders` tables
- `pos_transactions` table separately

This caused revenue to be inflated.

**Fix**: 
- Modified `calculateRestaurantRevenue` to only count POS transactions if no matching `food_order` exists
- Modified `calculateBarRevenue` to only count POS transactions if no matching `bar_order` exists
- Matching is done by date and amount (within 1 rupee tolerance)

**Impact**: Revenue calculations now accurately reflect actual revenue without double-counting.

### 3. Database Precision Fix (`db-scripts/fix-financial-precision.sql`)

**Issue**: Database stored amounts with more than 2 decimal places, causing inconsistencies.

**Fix**: SQL script that:
- Rounds all amounts to 2 decimal places
- Validates payment totals match reservation totals
- Fixes invoice `amount_paid` to match sum of payments
- Fixes invoice `balance_due` calculations
- Validates `food_orders.total_amount` matches items sum
- Creates validation function to check data integrity

**Usage**:
```bash
psql $DATABASE_URL -f db-scripts/fix-financial-precision.sql
```

### 4. Diagnostic Tool (`scripts/diagnose-financial-integrity.ts`)

**Purpose**: Validates financial data integrity end-to-end.

**Checks**:
- Room revenue: Payments match reservation totals
- Food orders: `total_amount` matches items sum
- Bar orders: Amounts are properly rounded
- Invoices: `amount_paid` matches payment sum, `balance_due` is correct
- POS transactions: No double-counting with food_orders/bar_orders

**Usage**:
```bash
./scripts/diagnose-financial-integrity.sh
```

**Output**: 
- Console report with all issues
- JSON report: `financial-integrity-report.json`

## Validation Function

A PostgreSQL function `validate_financial_integrity(property_uuid)` checks:
1. Payments match reservation totals
2. Invoice `amount_paid` matches payment sum
3. Invoice `balance_due` calculation is correct
4. Food orders `total_amount` matches items sum

**Usage**:
```sql
SELECT * FROM validate_financial_integrity('property-uuid-here');
```

## Best Practices

### 1. Always Use `safeNumber`
```typescript
// ✅ Correct
const amount = safeNumber(payment.amount);

// ❌ Wrong
const amount = Number(payment.amount); // May have precision issues
```

### 2. Use Unified Calculation Functions
```typescript
// ✅ Correct - uses unified functions
import { calculateTotalRevenue } from '@/lib/financialCalculations';
const revenue = calculateTotalRevenue({ payments, foodOrders, ... });

// ❌ Wrong - custom calculation
const revenue = payments.reduce((sum, p) => sum + p.amount, 0);
```

### 3. Consistent Date Filtering
```typescript
// ✅ Correct - uses unified date range
import { calculateDateRange, filterFoodOrdersByDate } from '@/lib/financialCalculations';
const dateRange = calculateDateRange('month');
const filtered = filterFoodOrdersByDate(foodOrders, dateRange);

// ❌ Wrong - custom date filtering
const filtered = foodOrders.filter(f => new Date(f.created_at) > someDate);
```

### 4. Validate Before Display
```typescript
// ✅ Correct - validate and round
const displayAmount = safeNumber(amount).toFixed(2);

// ❌ Wrong - direct display
const displayAmount = amount.toFixed(2); // May be undefined/null
```

## Testing

### Run Diagnostic Tool
```bash
./scripts/diagnose-financial-integrity.sh
```

### Fix Database Issues
```bash
psql $DATABASE_URL -f db-scripts/fix-financial-precision.sql
```

### Validate After Fixes
```sql
SELECT * FROM validate_financial_integrity('your-property-id');
```

## Expected Results

After applying all fixes:

1. **All amounts rounded to 2 decimal places**
   - No floating-point precision errors
   - All calculations match to the cent

2. **No double-counting**
   - POS transactions only counted once
   - Revenue totals are accurate

3. **Consistent across pages**
   - Dashboard, Revenue, Financial Reports, Accounting all show same numbers
   - Same date ranges produce same results

4. **Data integrity**
   - Payments match reservation totals
   - Invoice amounts match payment sums
   - Food order totals match items sum

## Related Files

- `src/lib/utils.ts` - `safeNumber` function
- `src/lib/financialCalculations.ts` - Unified calculation functions
- `db-scripts/fix-financial-precision.sql` - Database fixes
- `scripts/diagnose-financial-integrity.ts` - Diagnostic tool
- `scripts/diagnose-financial-integrity.sh` - Shell wrapper
