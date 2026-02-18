# Fix: Booking Update Trigger for Room Changes

## Problem

Room updates on confirmed bookings were not triggering email communications. For example:
- Booking: `BCOM-MJLYTQF2`
- Room changed to: Room 2302 (Executive Suite)
- Expected: Booking update email sent
- Actual: No email sent

## Root Cause

The trigger was checking for room_id changes, but there may have been issues with:
1. The WHEN condition not evaluating correctly
2. Silent failures in the trigger function
3. Missing error logging

## Solution

### 1. Improved Trigger Function

**File**: `supabase/migrations/20251226_fix_booking_update_trigger.sql`

**Changes**:
- ✅ Added explicit room_id change detection with logging
- ✅ Better error handling and logging
- ✅ Prevents duplicate pending entries by deleting old ones first
- ✅ More detailed NOTICE messages for debugging

### 2. Enhanced Trigger WHEN Condition

The trigger now explicitly checks for room_id changes:

```sql
WHEN (
  -- Status changes OR
  (status change conditions) OR
  -- Room ID changed (explicit check)
  (OLD.room_id IS DISTINCT FROM NEW.room_id AND NEW.status NOT IN ('cancelled', 'checked_out')) OR
  -- Other field changes
  (dates or amount changed)
)
```

### 3. Manual Trigger Script

**File**: `scripts/manually-trigger-booking-update.sql`

Use this to manually queue a booking update communication if the trigger didn't fire:

```sql
-- Set the booking number
\set booking_number 'BCOM-MJLYTQF2'

-- Run the script
\i scripts/manually-trigger-booking-update.sql
```

## Deployment

### Step 1: Apply Migration

Run in Supabase SQL Editor:

```sql
\i supabase/migrations/20251226_fix_booking_update_trigger.sql
```

Or copy-paste the contents of the file.

### Step 2: Verify Trigger

```sql
-- Check if trigger exists and is enabled
SELECT 
  tgname as trigger_name,
  tgenabled as enabled,
  tgrelid::regclass as table_name
FROM pg_trigger
WHERE tgname = 'trigger_send_booking_update';
```

Should show: `enabled = 'O'` (enabled)

### Step 3: Test

1. Update a booking's room_id
2. Check communication_queue:
```sql
SELECT * FROM communication_queue 
WHERE communication_type = 'booking_update'
ORDER BY created_at DESC LIMIT 5;
```

3. Process the queue (or wait for scheduled job)

## Diagnostic Queries

### Check if Communication Was Queued

```sql
SELECT 
  cq.id,
  cq.communication_type,
  cq.status,
  cq.created_at,
  cq.error_message,
  r.reservation_number
FROM communication_queue cq
JOIN reservations r ON r.id = cq.reservation_id
WHERE r.reservation_number = 'BCOM-MJLYTQF2'
ORDER BY cq.created_at DESC;
```

### Check Trigger Logs

The trigger now logs NOTICE messages. Check Supabase logs for:
- `Room changed: OLD.room_id = ..., NEW.room_id = ...`
- `Booking update triggered: room_changed=..., dates_changed=..., amount_changed=...`
- `Communication queued: type=..., reservation=..., guest=...`

### Manual Trigger (If Needed)

If the trigger still doesn't fire, manually queue the communication:

```sql
\i scripts/manually-trigger-booking-update.sql
```

## What Changed

### Before
- Trigger might silently fail
- No logging for room changes
- ON CONFLICT DO NOTHING might prevent inserts

### After
- ✅ Explicit room_id change detection
- ✅ Detailed logging (NOTICE messages)
- ✅ Prevents duplicates by deleting old pending entries
- ✅ Better error handling

## Testing Checklist

- [ ] Apply migration
- [ ] Verify trigger is enabled
- [ ] Update a booking's room_id
- [ ] Check communication_queue for entry
- [ ] Verify email is sent
- [ ] Check logs for NOTICE messages

## Next Steps

After applying the fix:

1. **For the specific booking** (`BCOM-MJLYTQF2`):
   - Run `scripts/manually-trigger-booking-update.sql` to send the update email now
   - Or wait for the next room update to test the trigger

2. **For future bookings**:
   - The trigger will now fire automatically for room changes
   - Monitor logs to ensure it's working

3. **Monitor**:
   - Check `communication_queue` table regularly
   - Verify emails are being sent
   - Check for any error messages

## Related Files

- `supabase/migrations/20251226_fix_booking_update_trigger.sql` - Main fix
- `scripts/manually-trigger-booking-update.sql` - Manual trigger script
- `scripts/check-booking-communication.sql` - Diagnostic queries

