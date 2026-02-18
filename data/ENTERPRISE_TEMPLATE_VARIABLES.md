# Enterprise-Grade Template Variable System

## Overview

This system ensures ALL email templates (14+) are populated with meaningful, accurate information, similar to how Expedia and Booking.com handle communications. It intelligently handles guests with multiple bookings by selecting the correct reservation.

## Key Features

### 1. Intelligent Booking Selection

When a guest has multiple bookings, the system selects the correct one using this priority:

1. **Specific Reservation ID** (if provided in communication context)
2. **Most Recent Upcoming Booking** (confirmed, check-in date >= today)
3. **Most Recent Confirmed Booking** (any date)
4. **Most Recent Booking** (any status)

This ensures communications always reference the relevant booking.

### 2. Industry-Standard Formatting

All data is formatted to match industry standards (Expedia/Booking.com style):

- **Dates**: "Monday, January 15, 2024" (full weekday + date)
- **Times**: "3:00 PM" / "11:00 AM" (12-hour format)
- **Amounts**: "₹12,345.67" (currency symbol + formatted number with decimals)
- **Payment Methods**: "Credit Card" (formatted from "credit_card")

### 3. Comprehensive Variable Coverage

The system handles ALL template variables across ALL 14+ templates:

#### Guest Variables
- `{{guest_name}}` - Full name
- `{{guest_first_name}}` - First name
- `{{guest_last_name}}` - Last name
- `{{guest_email}}` - Email address
- `{{guest_phone}}` - Phone number

#### Booking Variables
- `{{booking_number}}` - Reservation number
- `{{reservation_number}}` - Same as booking_number
- `{{booking_reference}}` - Booking reference
- `{{confirmation_number}}` - Confirmation number
- `{{check_in_date}}` - Formatted check-in date
- `{{check_out_date}}` - Formatted check-out date
- `{{check_in_time}}` - Check-in time (default: 3:00 PM)
- `{{check_out_time}}` - Check-out time (default: 11:00 AM)
- `{{nights}}` - Number of nights
- `{{room_type}}` - Room type name
- `{{room_number}}` - Room number
- `{{guest_count}}` - Total guests
- `{{adults}}` - Number of adults
- `{{children}}` - Number of children
- `{{total_amount}}` - Total booking amount (formatted)
- `{{payment_status}}` - Payment status
- `{{special_requests}}` - Special requests
- `{{cancellation_date}}` - Cancellation date (if cancelled)
- `{{refund_amount}}` - Refund amount (if cancelled)
- `{{refund_status}}` - Refund status (Full/Partial/No Refund)
- `{{processing_time}}` - Refund processing time

#### Payment Variables
- `{{payment_number}}` - Payment ID (PAY-XXXXXXXX)
- `{{transaction_id}}` - Transaction ID (TXN-XXXXXXXX)
- `{{payment_date}}` - Payment date (formatted)
- `{{payment_method}}` - Payment method (formatted)
- `{{amount}}` - Payment amount (formatted)
- `{{booking_reference}}` - Associated booking reference
- `{{failure_reason}}` - Payment failure reason
- `{{outstanding_amount}}` - Outstanding balance
- `{{due_date}}` - Payment due date

#### Property Variables
- `{{hotel_name}}` - Hotel/property name
- `{{property_name}}` - Same as hotel_name
- `{{hotel_phone}}` - Hotel phone number
- `{{hotel_email}}` - Hotel email address
- `{{hotel_address}}` - Hotel address
- `{{hotel_website}}` - Hotel website
- `{{concierge_phone}}` - Concierge phone
- `{{amenities}}` - Hotel amenities list

#### Service Variables (for service templates)
- `{{order_number}}` - Room service order number
- `{{appointment_number}}` - Spa appointment number
- `{{service_name}}` - Service name
- `{{appointment_date}}` - Appointment date
- `{{appointment_time}}` - Appointment time
- `{{duration}}` - Service duration
- `{{therapist_name}}` - Therapist name
- `{{items}}` - Ordered items
- `{{delivery_time}}` - Estimated delivery time
- `{{request_number}}` - Maintenance request number
- `{{issue_description}}` - Issue description
- `{{priority}}` - Request priority
- `{{estimated_time}}` - Estimated resolution time

#### System Variables (for system templates)
- `{{user_name}}` - User name
- `{{reset_link}}` - Password reset link
- `{{verification_link}}` - Email verification link
- `{{expiry_time}}` - Link expiry time
- `{{feedback_link}}` - Feedback form link
- `{{discount_percent}}` - Discount percentage
- `{{booking_link}}` - Booking link

## Template Categories

### 1. Booking Templates
- `booking_confirmation` - New booking confirmation
- `booking_update` - Booking modification notification
- `booking_cancellation` - Cancellation with refund details
- `checkin_confirmation` - Check-in confirmation
- `checkout_confirmation` - Check-out confirmation
- `check_in_reminder` - Pre-arrival reminder
- `check_out_reminder` - Pre-departure reminder

### 2. Payment Templates
- `payment_received` - Payment receipt
- `payment_failed` - Payment failure notification
- `payment_reminder` - Outstanding balance reminder
- `refund_confirmation` - Refund processed confirmation

### 3. Guest Service Templates
- `welcome_email` - Welcome message
- `feedback_request` - Post-stay feedback request
- `thank_you_after_stay` - Thank you message

### 4. Service Templates
- `room_service_order_confirmation` - Room service order
- `spa_appointment_confirmation` - Spa booking
- `maintenance_request_confirmation` - Maintenance request

### 5. System Templates
- `password_reset` - Password reset
- `account_verification` - Email verification

## Implementation

### Shared Module
All variable replacement logic is centralized in:
- `supabase/functions/_shared/templateVariables.ts`

This ensures consistency across all edge functions.

### Functions Using This System
1. `process-communication-queue` - Processes queued communications
2. `send-guest-communication` - Direct communication sending
3. `booking-operations` - Booking-related communications
4. `send-checkin-email` - Check-in/check-out emails

### Frontend Integration
- `src/services/templateVariableService.ts` - Frontend service (for preview/editing)
- `src/pages/GuestCommunication.tsx` - Uses the service for template preview

## Data Accuracy Guarantees

1. **Correct Booking Selection**: Always uses the most relevant booking
2. **Accurate Financial Data**: Uses rules engine for refund calculations
3. **Consistent Formatting**: All dates, amounts, and times formatted consistently
4. **Complete Coverage**: All variables replaced, no placeholders remain
5. **Fallback Values**: Graceful handling of missing data (shows "N/A" instead of errors)

## Example Output

**Before (with placeholders):**
```
Payment Receipt - {{payment_number}}
Dear {{guest_name}},
Thank you for your payment of {{amount}}.
```

**After (enterprise-grade):**
```
Payment Receipt - PAY-A1B2C3D4
Dear John Smith,
Thank you for your payment of ₹5,000.00.
```

## Testing

To verify all templates work correctly:

1. Create test bookings for a guest
2. Send communications for each template type
3. Verify all variables are replaced
4. Check formatting matches industry standards
5. Test with guests having multiple bookings

## Deployment

After updating the code:

```bash
# Deploy updated functions
supabase functions deploy process-communication-queue
supabase functions deploy send-guest-communication
supabase functions deploy booking-operations
supabase functions deploy send-checkin-email
```

All templates will now use the enterprise-grade variable replacement system!

