# Expense Capping Fix - Removing Artificial Precision

## Problem Identified

The dashboard was showing **exactly -50% profit margin** when expenses exceeded revenue. This was caused by an artificial expense capping mechanism that:

1. Capped expenses at exactly **150% of revenue** when they exceeded that threshold
2. This always resulted in: `Profit Margin = (Revenue - 1.5 × Revenue) / Revenue × 100 = -50%`
3. Created artificial precision that looked suspicious and "mocked up"

## Root Cause

**File**: `src/pages/Dashboard.tsx` (lines 435-441)

```typescript
// OLD CODE (PROBLEMATIC):
const maxReasonableExpenses = totalRevenue * 1.5;
const adjustedExpenses = totalExpenses > maxReasonableExpenses ? maxReasonableExpenses : totalExpenses;
// This always resulted in exactly -50% profit margin when expenses > 150% of revenue
```

## Solution Applied

1. **Removed artificial capping** - Expenses now use actual values
2. **Added warning logging** - If expenses exceed revenue, log a warning but show actual numbers
3. **Fixed date range alignment** - Expenses now use same 30-day period as revenue
4. **Updated all calculations** - All references to `adjustedExpenses` now use `totalExpenses`

## Changes Made

### 1. Expense Calculation (Dashboard.tsx)
- **Before**: Capped at 150% of revenue (creating -50% profit margin)
- **After**: Uses actual expenses, logs warning if > 100% of revenue

### 2. Date Range Alignment
- **Before**: Expenses filtered by `dateRange` (rolling 30 days), revenue by `last30Days` (could mismatch)
- **After**: Both use `last30Days` for consistency

### 3. All Financial Calculations
- Updated: GOP, CPAR, Labor Cost, Cash Flow, Budget Variance
- All now use `totalExpenses` instead of capped `adjustedExpenses`

## Impact

- ✅ **Profit margin** now shows actual calculated value (not always -50%)
- ✅ **Expense ratio** shows actual percentage (not always 150%)
- ✅ **All financial metrics** reflect real data, not artificial caps
- ✅ **Warning logged** if expenses seem unreasonably high (for data quality checks)

## Testing

Run the expense-revenue diagnostic:

```bash
psql $DATABASE_URL -f db-scripts/diagnose-expense-revenue-mismatch.sql
```

This will show:
- Actual expense ratio
- Revenue breakdown
- Expense distribution
- Potential duplicate expenses

## Notes

- If expenses legitimately exceed revenue (e.g., during renovations, low season), the dashboard will now show the actual negative profit margin
- The warning in console helps identify data quality issues
- No more artificial rounding to suspiciously round numbers like -50%
