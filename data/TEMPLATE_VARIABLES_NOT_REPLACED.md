# Fix: Template Variables Not Being Replaced

## Problem
Email subjects show `{{booking_number}}` and `{{payment_number}}` instead of actual values.

## Root Cause Analysis

The `replaceAllTemplateVariables` function exists and should replace variables, but it's not working. Possible causes:

1. **bookingData is null/undefined** - No booking data passed to replacement function
2. **Variable format mismatch** - Function looks for specific property names
3. **Replacement not being called** - Condition check fails
4. **Data format issue** - bookingData doesn't have expected properties

## Current Code Flow

1. `process-communication-queue` gets booking data
2. Formats it with `formatBookingData`
3. Calls `replaceAllTemplateVariables(message, formattedGuest, bookingData, paymentData, propertyData)`
4. Function should replace `{{booking_number}}` with `booking.booking_number`

## Check What's Happening

### Step 1: Check Edge Function Logs

Go to Supabase Dashboard → Edge Functions → `process-communication-queue` → Logs

Look for:
- `[process-communication-queue] Booking data:` - Should show booking data
- `[process-communication-queue] Replacing template variables` - Should see replacement happening
- Any errors about missing properties

### Step 2: Verify Booking Data Structure

The `formatBookingData` function should return:
```typescript
{
  booking_number: string,
  reservation_number: string,
  // ... other fields
}
```

Check if `booking_number` is actually in the formatted data.

### Step 3: Check Template Content

Run this SQL:

```sql
SELECT 
  template_code,
  subject,
  LEFT(body, 200) as body_preview
FROM email_templates
WHERE template_code IN ('booking_confirmation', 'payment_received', 'booking_cancellation')
  AND is_active = true;
```

Verify templates use `{{booking_number}}` (with double curly braces).

## Quick Fix Test

Create a test to see what data is being passed:

Add logging in `process-communication-queue/index.ts`:

```typescript
console.log('[process-communication-queue] Booking data:', JSON.stringify(bookingData));
console.log('[process-communication-queue] Subject before:', subject);
console.log('[process-communication-queue] Subject after:', subject);
```

This will show if data exists and if replacement is happening.

## Most Likely Issue

Based on the code, `bookingData` might be missing the `booking_number` property. Check if:

1. `reservation.reservation_number` exists (should map to `booking_number`)
2. `formatBookingData` is correctly formatting the data
3. The replacement function is receiving the data

## Solution

If `booking_number` is missing from `bookingData`, the replacement will fail. We need to ensure:

1. Reservation data includes `reservation_number`
2. `formatBookingData` maps it to `booking_number`
3. `replaceAllTemplateVariables` receives correct data structure

Check the Edge Function logs first to see what data is actually being passed to the replacement function.

