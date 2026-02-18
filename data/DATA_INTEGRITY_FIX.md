# Reservation Data Integrity Fix

## Problem

The Reservations page and Check-In/Check-Out page were showing inconsistent data:
- **Reservations page**: Showed 22 overdue checkouts
- **Check-In/Check-Out page**: Showed 0 today's checkouts

## Root Cause

1. **Different Query Logic**: 
   - Reservations page calculated overdue as: `status='checked_in' AND check_out_date < today`
   - Check-In/Check-Out page queried today's checkouts as: `status='checked_in' AND check_out_date = today`
   - These are different queries (overdue vs today)

2. **Data Integrity Issues**:
   - Reservations with `status='checked_in'` but `check_out_date` in the past (should be checked out)
   - Missing `checked_in_at` and `checked_out_at` timestamps
   - Room status mismatches (rooms still marked 'occupied' for checked-out reservations)
   - Invalid date combinations (check_out_date < check_in_date)

## Solution

### 1. Database Migration (`20251226_fix_reservation_data_integrity.sql`)

The migration:
- ✅ Auto-checks out overdue reservations
- ✅ Fixes missing timestamps
- ✅ Updates room statuses
- ✅ Creates housekeeping tasks
- ✅ Adds database constraints to prevent future issues
- ✅ Creates a trigger to auto-update room status on check-in/check-out
- ✅ Creates a view for consistent statistics

### 2. Centralized Service (`reservationDataService.ts`)

Created a shared service that:
- ✅ Provides consistent queries across all pages
- ✅ Uses the database view for statistics
- ✅ Includes validation functions
- ✅ Ensures data integrity

### 3. Updated Pages

- ✅ **Reservations page**: Now uses `getReservationStats()` from the service
- ✅ **Check-In/Check-Out page**: Already uses consistent queries (no changes needed)

## How to Apply the Fix

### Option 1: Run the Migration Script

```bash
./scripts/fix-reservation-data-integrity.sh
```

### Option 2: Manual Migration

1. Go to Supabase Dashboard: https://supabase.com/dashboard
2. Select your project
3. Navigate to **SQL Editor**
4. Copy and paste contents of: `supabase/migrations/20251226_fix_reservation_data_integrity.sql`
5. Run the migration

### Option 3: Via Supabase CLI

```bash
npx supabase db push
```

## Verification

After running the migration, verify:

1. **Check Statistics View**:
   ```sql
   SELECT * FROM reservation_statistics WHERE property_id = 'your-property-id';
   ```

2. **Check for Overdue Reservations**:
   ```sql
   SELECT COUNT(*) FROM reservations 
   WHERE status = 'checked_in' 
   AND check_out_date < CURRENT_DATE;
   ```
   Should return 0.

3. **Check Missing Timestamps**:
   ```sql
   SELECT COUNT(*) FROM reservations 
   WHERE status = 'checked_in' AND checked_in_at IS NULL;
   ```
   Should return 0.

4. **Verify in UI**:
   - Reservations page should show correct overdue count
   - Check-In/Check-Out page should match
   - Both pages should show consistent data

## Prevention

The migration includes:

1. **Database Constraints**:
   - `reservations_status_date_check`: Ensures valid status/date combinations

2. **Trigger Function**:
   - `validate_reservation_status()`: Auto-updates timestamps and room statuses

3. **Auto-Checkout Function**:
   - `auto_checkout_overdue_reservations()`: Can be called via scheduled job

4. **Statistics View**:
   - `reservation_statistics`: Provides consistent stats across all pages

## Scheduled Maintenance

To prevent future issues, set up a scheduled job:

```sql
-- Run daily at 2 AM to auto-checkout overdue reservations
SELECT cron.schedule(
  'auto-checkout-overdue',
  '0 2 * * *',
  $$SELECT auto_checkout_overdue_reservations();$$
);
```

Or use the `scheduled_jobs` table:

```sql
INSERT INTO scheduled_jobs (
  job_name,
  job_type,
  schedule_pattern,
  function_name,
  is_active
) VALUES (
  'auto-checkout-overdue',
  'database_function',
  '0 2 * * *',
  'auto_checkout_overdue_reservations',
  true
);
```

## Related Files

- `supabase/migrations/20251226_fix_reservation_data_integrity.sql` - Migration
- `src/services/reservationDataService.ts` - Centralized service
- `scripts/fix-reservation-data-integrity.sh` - Fix script
- `src/pages/Reservations.tsx` - Updated to use service
- `src/pages/CheckInOut.tsx` - Already uses consistent queries

## Support

If you encounter issues:
1. Check Supabase logs for errors
2. Verify the migration ran successfully
3. Check the statistics view
4. Run validation: `validateReservationIntegrity(propertyId)`

