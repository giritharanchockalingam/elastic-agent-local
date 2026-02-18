# Financial Data Consistency Audit

## Overview
This document tracks the consistency of financial data calculations across all portal pages to ensure accuracy and prevent discrepancies.

## Pages Audited

### ✅ Dashboard.tsx
- **Status**: ✅ FIXED
- **Uses Unified Calculations**: Yes (`calculateTotalRevenue`, `calculateDateRange`)
- **Bar Orders Filter**: Includes `pending` status ✅
- **Date Range**: Rolling 30 days (primary), Calendar month (comparison)
- **Data Sources**: payments, food_orders, bar_orders, spa_bookings, events, pos_transactions
- **Issues Fixed**:
  - ✅ Fixed bar orders to include `pending` status
  - ✅ Fixed date range queries to use explicit 90-day window
  - ✅ Fixed revenue trend chart to include all revenue sources

### ✅ FinancialReports.tsx
- **Status**: ✅ CONSISTENT
- **Uses Unified Calculations**: Yes (`calculateTotalRevenue`, `calculateRestaurantRevenue`, `calculateBarRevenue`)
- **Bar Orders Filter**: Needs verification
- **Date Range**: Uses `calculateDateRange`
- **Data Sources**: All revenue sources included

### ✅ Accounting.tsx
- **Status**: ✅ CONSISTENT
- **Uses Unified Calculations**: Yes (`calculateTotalRevenue`)
- **Bar Orders Filter**: Needs verification
- **Date Range**: Uses `calculateDateRange`
- **Data Sources**: All revenue sources included

### ✅ Revenue.tsx
- **Status**: ✅ CONSISTENT
- **Uses Unified Calculations**: Yes (`calculateTotalRevenue`, `filterFoodOrdersByDate`, `filterBarOrdersByDate`)
- **Bar Orders Filter**: Needs verification
- **Date Range**: Uses `calculateDateRange`
- **Data Sources**: All revenue sources included

### ⚠️ Finance.tsx
- **Status**: ✅ FIXED
- **Uses Unified Calculations**: Now uses `calculateTotalRevenue` ✅
- **Bar Orders Filter**: Now includes `pending` status ✅
- **Date Range**: Now uses `calculateDateRange` ✅
- **Data Sources**: Now includes all revenue sources (food, bar, spa, events) ✅
- **Issues Fixed**:
  - ✅ Was only calculating revenue from payments
  - ✅ Now uses unified calculation functions
  - ✅ Now includes F&B, spa, and events revenue

### ⚠️ Analytics.tsx
- **Status**: ⚠️ NEEDS REVIEW
- **Uses Unified Calculations**: Partial (uses manual calculation for fallback)
- **Bar Orders Filter**: Not applicable (only uses payments for revenue)
- **Date Range**: Manual calculation (calendar month)
- **Data Sources**: payments (primary), analytics tables (fallback)
- **Issues**:
  - Uses manual revenue calculation as fallback
  - Should use `calculateTotalRevenue` for consistency
  - Only shows room revenue, not total revenue

### ⚠️ RevenueAnalytics.tsx
- **Status**: ⚠️ NEEDS REVIEW
- **Uses Unified Calculations**: Yes (`calculateTotalRevenue`)
- **Bar Orders Filter**: Needs to include `pending` status
- **Date Range**: Manual calculation (not using `calculateDateRange` consistently)
- **Data Sources**: All revenue sources included
- **Issues**:
  - Bar orders may not include `pending` status
  - Date range calculation is manual instead of using `calculateDateRange`

## Key Consistency Rules

### 1. Revenue Calculation
- **MUST** use `calculateTotalRevenue` from `@/lib/financialCalculations`
- **MUST** include all revenue sources: payments, food_orders, bar_orders, spa_bookings, events, pos_transactions
- **MUST NOT** use manual `.reduce()` calculations for total revenue

### 2. Bar Orders Filtering
- **MUST** include orders with `payment_status`: `null`, `'paid'`, `'completed'`, `'pending'`
- **MUST NOT** exclude `pending` orders (they represent accounts receivable)
- **MUST** use: `!b.payment_status || b.payment_status === 'paid' || b.payment_status === 'completed' || b.payment_status === 'pending'`

### 3. Date Range Calculation
- **MUST** use `calculateDateRange` from `@/lib/financialCalculations`
- **MUST** use `filterFoodOrdersByDate` and `filterBarOrdersByDate` for consistent filtering
- **MUST NOT** use manual date calculations

### 4. Payment Status Filtering
- **Payments**: Only `'completed'` status
- **Bar Orders**: `null`, `'paid'`, `'completed'`, `'pending'`
- **Food Orders**: Exclude `'cancelled'` status

## Diagnostic Tools

### Run Consistency Check
```bash
npx tsx scripts/diagnose-financial-consistency.ts
```

This will generate `financial-consistency-report.md` with detailed findings.

## Action Items

- [ ] Fix `Analytics.tsx` to use `calculateTotalRevenue` for fallback calculation
- [ ] Fix `RevenueAnalytics.tsx` to include `pending` bar orders
- [ ] Fix `RevenueAnalytics.tsx` to use `calculateDateRange` consistently
- [ ] Verify all pages use `filterBarOrdersByDate` with correct payment status filter
- [ ] Add unit tests for revenue calculation consistency
- [ ] Document expected revenue breakdowns for each page

## Testing Checklist

- [ ] Dashboard total revenue matches Revenue page
- [ ] Dashboard total revenue matches Financial Reports
- [ ] Dashboard total revenue matches Accounting page
- [ ] Finance page total revenue matches other pages
- [ ] All pages show same bar revenue (including pending orders)
- [ ] All pages show same food revenue
- [ ] Date range filtering is consistent across pages
- [ ] No hardcoded financial values exist
- [ ] No mock/test data in production code
