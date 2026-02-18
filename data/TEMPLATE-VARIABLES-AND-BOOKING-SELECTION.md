# Template Variables and Booking Selection Guide

## Overview

This document explains how the guest communication system handles:
1. Template variable replacement
2. Booking selection when guests have multiple reservations
3. Mass communication processing

## Template Variable Replacement

### Supported Variables

The system supports a comprehensive set of template variables:

#### Guest Variables
- `{{guest_name}}` - Full name (first + last)
- `{{user_name}}` - Alias for guest_name
- `{{guest_first_name}}` - First name only
- `{{guest_last_name}}` - Last name only
- `{{guest_email}}` - Masked for privacy (shows "[Email address protected for privacy]")
- `{{guest_phone}}` - Masked phone (shows last 4 digits only)

#### Property Variables
- `{{hotel_name}}` or `{{property_name}}` - Hotel name
- `{{hotel_phone}}` - Hotel phone number
- `{{hotel_email}}` - Hotel email
- `{{hotel_address}}` - Hotel address
- `{{hotel_website}}` - Hotel website
- `{{concierge_phone}}` - Concierge phone

#### Booking Variables (requires booking data)
- `{{booking_number}}` - Booking/reservation number
- `{{reservation_number}}` - Same as booking_number
- `{{check_in_date}}` - Formatted check-in date (e.g., "Monday, January 1, 2025")
- `{{check_out_date}}` - Formatted check-out date
- `{{check_in_time}}` - Check-in time (default: "3:00 PM")
- `{{check_out_time}}` - Check-out time (default: "11:00 AM")
- `{{nights}}` - Number of nights
- `{{room_type}}` - Room type name
- `{{room_number}}` - Room number
- `{{guest_count}}` - Total number of guests
- `{{adults}}` - Number of adults
- `{{children}}` - Number of children
- `{{total_amount}}` - Total booking amount (₹ formatted)
- `{{payment_status}}` - Payment status
- `{{special_requests}}` - **Formatted special requests (PII filtered)**
- `{{cancellation_date}}` - Cancellation date (if cancelled)
- `{{refund_amount}}` - Refund amount (if applicable)
- `{{refund_status}}` - Refund status

#### Payment Variables (requires payment data)
- `{{payment_number}}` - Payment reference number
- `{{transaction_id}}` - Transaction ID
- `{{payment_date}}` - Payment date
- `{{payment_method}}` - Payment method
- `{{amount}}` - Payment amount (₹ formatted)
- `{{failure_reason}}` - Failure reason (if payment failed)
- `{{outstanding_amount}}` - Outstanding amount
- `{{due_date}}` - Due date

#### Service-Specific Variables (defaults provided, should be customized)
- `{{verification_link}}` - Email verification link (needs token generation)
- `{{feedback_link}}` - Feedback link with booking number
- `{{booking_link}}` - Direct booking link
- `{{request_number}}` - Service request number
- `{{order_number}}` - Room service order number
- `{{appointment_number}}` - Spa/appointment number
- `{{discount_percent}}` - Discount percentage (default: 10)
- `{{issue_description}}` - Maintenance issue description
- `{{priority}}` - Request priority (default: "normal")
- `{{estimated_time}}` - Estimated resolution time (default: "2-4 hours")
- `{{items}}` - Ordered items
- `{{delivery_time}}` - Delivery time in minutes (default: 30)
- `{{service_name}}` - Service name
- `{{appointment_date}}` - Appointment date
- `{{appointment_time}}` - Appointment time
- `{{duration}}` - Duration in minutes (default: 60)
- `{{therapist_name}}` - Therapist name
- `{{expiry_time}}` - Link expiry time in hours (default: 24)

### PII Protection

**CRITICAL:** The system automatically filters out sensitive data:
- ID numbers, passport numbers, Aadhar numbers → Protected messages
- Dates of birth → Protected messages
- Full addresses → Protected messages
- Email addresses → Masked in email body
- Phone numbers → Masked (last 4 digits only)
- Special requests → Formatted, PII fields removed

## Booking Selection Logic

When a guest has multiple reservations, the system uses intelligent selection:

### Priority Order

1. **Explicit `reservation_id` provided** (highest priority)
   - If `reservation_id` is passed in the request, that specific reservation is used
   - This is used when sending booking-specific communications

2. **Most recent upcoming confirmed booking**
   - If no `reservation_id`, selects the next upcoming confirmed booking
   - Prioritizes bookings that haven't happened yet

3. **Most recent confirmed booking** (fallback)
   - If no upcoming bookings, selects the most recent confirmed booking
   - Used for follow-up communications after checkout

### Implementation

The selection is handled by `getCorrectBooking()` function in `_shared/templateVariables.ts`:

```typescript
// Priority: reservation_id > most recent upcoming > most recent
export async function getCorrectBooking(
  supabase: any,
  guestId: string,
  propertyId: string,
  reservationId?: string  // Optional: specific reservation to use
): Promise<any | null>
```

### When to Pass `reservation_id`

**You should pass `reservation_id` when:**
- Sending booking confirmation emails (use the specific booking)
- Sending check-in reminders (use the upcoming booking)
- Sending booking cancellation emails (use the cancelled booking)
- Any communication that's specific to a particular reservation

**You can omit `reservation_id` when:**
- Sending general welcome emails
- Sending feedback requests (system will use most recent booking)
- Sending marketing/promotional emails
- Mass communications (each guest gets their most relevant booking)

### How It Works in Code

```typescript
// In send-guest-communication edge function
const { reservation_id } = body; // Optional reservation ID from request

// Get the correct booking (handles multiple bookings intelligently)
const correctReservation = await getCorrectBookingShared(
  supabaseAdmin || supabaseClient,
  guest_id,
  property_id,
  reservation_id  // Pass through if provided
);
```

## Mass Communication

### How It Works

Mass communication processes **each guest individually** with personalized data:

1. **Selection**: You select multiple guests from the guest list
2. **Individual Processing**: For each selected guest:
   - Fetches that guest's personal data
   - Finds their most relevant booking (using booking selection logic)
   - Replaces all template variables with **their specific data**
   - Sends the personalized message

3. **Parallel Execution**: All messages are sent in parallel using `Promise.allSettled()` for efficiency

4. **Results**: Shows success/failure count for all messages

### Example Flow

```typescript
// Mass communication sends to multiple guests
data.guest_ids.map(async (guestId) => {
  // 1. Get this guest's data
  const guest = guests.find(g => g.id === guestId);
  
  // 2. Get this guest's most relevant booking
  const bookingData = await fetchBookingData(guestId);
  
  // 3. Personalize template for THIS guest
  subject = await replaceTemplateVariables(subject, guest, bookingData);
  message = await replaceTemplateVariables(message, guest, bookingData);
  
  // 4. Send personalized message
  return supabase.functions.invoke('send-guest-communication', {
    body: { guest_id: guestId, subject, message, ... }
  });
})
```

### Mass Communication Features

✅ **Personalized**: Each guest receives a message with their own data
✅ **Booking-Aware**: Each guest gets their most relevant booking information
✅ **Parallel**: All messages sent simultaneously for speed
✅ **Fault-Tolerant**: Failed messages don't block successful ones
✅ **Reporting**: Shows how many succeeded/failed

### Best Practices

1. **Use Templates**: Create email templates with variables, don't hard-code values
2. **Test First**: Send to one guest first to verify template works
3. **Check Booking Data**: Ensure guests have booking data if templates use booking variables
4. **Handle Missing Data**: Templates gracefully handle missing booking data (shows "N/A")

## Service-Specific Variables

Some templates require data from specific services (concierge, spa, room service). Currently, these use sensible defaults, but for production:

### Recommended Approach

**Option 1: Pass via `variables` field**
```typescript
supabase.functions.invoke('send-guest-communication', {
  body: {
    guest_id: '...',
    subject: '...',
    message: 'Your order {{order_number}}...',
    variables: {
      order_number: 'ORD-12345',
      items: 'Pasta, Salad, Wine',
      delivery_time: '25'
    }
  }
})
```

**Option 2: Fetch from service tables**
Modify the edge function to fetch data from:
- `concierge_requests` for request numbers
- `spa_bookings` for appointment details
- `room_service_orders` for order information

## Troubleshooting

### Variables Not Replaced

If you see `{{variable_name}}` in emails:
1. Check variable name spelling (case-sensitive)
2. Ensure required data exists (e.g., booking for booking variables)
3. Check if variable is in the supported list above

### Wrong Booking Selected

If the wrong booking is used:
1. Pass `reservation_id` explicitly in the request
2. Check if guest has multiple bookings
3. Verify booking selection logic priorities

### Mass Communication Issues

If mass communication fails:
1. Check individual guest data (some might be missing)
2. Verify all selected guests have required data
3. Check function logs for specific error messages

## Future Enhancements

Planned improvements:
- Dynamic service variable fetching from related tables
- Template variable validation before sending
- Preview mode to see personalized template before sending
- Variable suggestion/autocomplete in template editor

