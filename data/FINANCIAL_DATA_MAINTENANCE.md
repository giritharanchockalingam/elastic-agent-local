# Financial Data Maintenance

**Purpose**: Scripts and procedures for maintaining financial data quality and consistency.

**Last Updated**: 2024

---

## Overview

This document describes maintenance scripts and procedures for ensuring financial data integrity across the Aurora HMS / V3 Grand portal. These scripts help identify and fix:

- Bookings with null or zero totals
- Inconsistent nights vs. dates calculations
- Missing relationships (orphaned records)
- Pricing discrepancies

---

## Scripts

### 1. Recompute Booking Totals

**File**: `scripts/recompute-booking-totals.mjs`

**Purpose**: Recomputes `total_amount` for bookings using the centralized pricing engine.

**Usage**:
```bash
node scripts/recompute-booking-totals.mjs [--property-id=<uuid>] [--dry-run]
```

**What it does**:
1. Fetches all bookings (optionally filtered by property)
2. For each booking:
   - Extracts room type, dates, guests, extras
   - Calls `computeRoomStayPricing()` from the centralized engine
   - Updates `total_amount` if different from current value
3. Reports:
   - Number of bookings processed
   - Number of bookings updated
   - Total amount corrections

**Safety**:
- `--dry-run` flag shows what would be changed without making updates
- Only updates if new total differs from current by more than ₹1 (handles rounding)
- Logs all changes for audit trail

**Limitations**:
- Only works for room bookings (not spa, events, dining)
- Requires valid room_type_id, check_in_date, check_out_date
- Skips bookings with missing required data

---

### 2. Validate Financial Consistency

**File**: `scripts/validate-financial-consistency.mjs`

**Purpose**: Validates financial data consistency across tables.

**Usage**:
```bash
node scripts/validate-financial-consistency.mjs [--property-id=<uuid>] [--output=csv]
```

**What it checks**:
1. **Booking totals**:
   - `reservations.total_amount` matches calculated pricing
   - `reservations.total_amount` matches sum of `payments.amount` for same reservation
2. **Revenue consistency**:
   - `payments` sum matches `reservations.total_amount` (for completed payments)
   - `food_orders.total_amount` matches sum of line items (if line items exist)
   - `spa_bookings` have valid `spa_services` relationships
3. **Orphaned records**:
   - Reservations without valid `room_type_id`
   - Payments without valid `reservation_id`
   - Spa bookings without valid `service_id`

**Output**:
- Console report (default)
- CSV file (with `--output=csv`) with detailed findings

**Limitations**:
- Some checks require assumptions (e.g., tax rates may have changed)
- Historical data may have different pricing rules

---

### 3. Fix Orphaned Records

**File**: `scripts/fix-orphaned-records.mjs`

**Purpose**: Identifies and optionally fixes orphaned financial records.

**Usage**:
```bash
node scripts/fix-orphaned-records.mjs [--fix] [--property-id=<uuid>]
```

**What it fixes**:
1. **Reservations**:
   - Missing `room_type_id` → Attempts to infer from `room_id`
   - Missing `property_id` → Attempts to infer from `room_type_id`
2. **Payments**:
   - Missing `reservation_id` → Attempts to match by guest_id + date + amount
3. **Spa bookings**:
   - Missing `service_id` → Flags for manual review (cannot auto-fix)

**Safety**:
- `--fix` flag required to make changes
- Creates backup before making changes
- Logs all fixes for audit trail

**Limitations**:
- Some fixes require manual review
- Matching by amount/date is not 100% reliable

---

## SQL Scripts

### 1. Identify Zero/Null Totals

**File**: `db-scripts/identify-zero-totals.sql`

**Purpose**: Finds bookings with zero or null totals.

**Usage**:
```sql
-- Run in Supabase SQL editor or psql
\i db-scripts/identify-zero-totals.sql
```

**Output**: List of reservations with:
- `id`
- `reservation_number`
- `total_amount` (current value)
- `room_type_id`
- `check_in_date`
- `check_out_date`
- Calculated total (if possible)

---

### 2. Validate Nights Calculation

**File**: `db-scripts/validate-nights-calculation.sql`

**Purpose**: Validates that nights calculation matches date difference.

**Usage**:
```sql
\i db-scripts/validate-nights-calculation.sql
```

**Output**: List of reservations where:
- Calculated nights ≠ expected nights
- Missing check-in or check-out dates
- Invalid date ranges (check-out <= check-in)

---

### 3. Recompute Totals (SQL)

**File**: `db-scripts/recompute-totals.sql`

**Purpose**: SQL-based recomputation of booking totals (simpler than Node script).

**Usage**:
```sql
-- Review first
SELECT * FROM (
  -- Query from script
) AS review;

-- Then apply updates (if safe)
UPDATE reservations
SET total_amount = calculated_total
WHERE id IN (...);
```

**Limitations**:
- Does not use centralized pricing engine (uses SQL calculations)
- Less accurate than Node script
- Use only if Node script is not available

---

## Procedures

### Weekly Maintenance

1. **Run validation script**:
   ```bash
   node scripts/validate-financial-consistency.mjs --output=csv
   ```
2. **Review CSV output** for anomalies
3. **Fix critical issues** (zero totals, orphaned records)
4. **Document findings** in maintenance log

### Monthly Maintenance

1. **Recompute booking totals** (for recent bookings only):
   ```bash
   node scripts/recompute-booking-totals.mjs --property-id=<uuid> --dry-run
   ```
2. **Review changes** in dry-run output
3. **Apply updates** if safe:
   ```bash
   node scripts/recompute-booking-totals.mjs --property-id=<uuid>
   ```
4. **Fix orphaned records**:
   ```bash
   node scripts/fix-orphaned-records.mjs --fix
   ```

### After Pricing Rule Changes

1. **Recompute all affected bookings**:
   ```bash
   node scripts/recompute-booking-totals.mjs
   ```
2. **Validate consistency**:
   ```bash
   node scripts/validate-financial-consistency.mjs
   ```

---

## Known Limitations

1. **Historical Data**:
   - Old bookings may have been created with different pricing rules
   - Recomputing may change historical totals (not recommended)

2. **Tax Rate Changes**:
   - If tax rates changed, historical bookings will have different totals
   - Recomputing will update totals (may not be desired)

3. **Manual Adjustments**:
   - Some bookings may have manual adjustments (discounts, refunds)
   - Recomputing may overwrite these (be careful)

4. **Missing Data**:
   - Some bookings may be missing required fields (room_type_id, dates)
   - Cannot recompute without this data

---

## Best Practices

1. **Always use `--dry-run` first** to preview changes
2. **Backup database** before running fix scripts
3. **Review logs** after running scripts
4. **Document exceptions** (bookings that cannot be auto-fixed)
5. **Test on staging** before running on production

---

## Future Enhancements

1. **Automated daily validation** (cron job)
2. **Alert system** for anomalies
3. **Dashboard** for financial data quality metrics
4. **API endpoints** for programmatic access to maintenance functions

---

## Support

For questions or issues with maintenance scripts:
1. Check script logs for error messages
2. Review this documentation
3. Contact development team
