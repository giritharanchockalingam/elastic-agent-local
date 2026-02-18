# Enterprise Rules Engine

## Overview

The Enterprise Rules Engine is a comprehensive system that handles business logic validation, cancellation policies, refund calculations, and financial transaction updates for all booking operations. It ensures data consistency across all screens and communication templates.

## Architecture

### Core Components

1. **Rules Engine Service** (`src/services/rulesEngine.ts`)
   - Cancellation policy validation
   - Refund amount calculations
   - Financial record updates
   - Booking operation validation

2. **Booking Operations Service** (`src/services/bookingOperations.ts`)
   - Create bookings with validation
   - Update bookings with financial impact tracking
   - Cancel bookings with policy enforcement
   - Get comprehensive booking data for communications

3. **Booking Operations Edge Function** (`supabase/functions/booking-operations/index.ts`)
   - Server-side booking operations
   - Rules engine enforcement
   - Financial transaction updates

## Features

### 1. Cancellation Policy Management

The rules engine supports two policy structures:

#### Legacy Structure
```typescript
{
  days_before_checkin: number;
  penalty_type: 'percentage' | 'fixed' | 'nights' | 'none';
  penalty_amount: number;
}
```

#### Enterprise Structure (JSONB)
```typescript
{
  policy_rules: [
    {
      days_before: number;
      penalty_percent?: number;
      penalty_amount?: number;
      penalty_nights?: number;
    }
  ]
}
```

### 2. Refund Calculation

The engine calculates refunds based on:
- Cancellation policy rules
- Days before check-in
- Total booking amount
- Already processed refunds

**Refund Formula:**
```
Refund Amount = Total Amount - Cancellation Fee - Already Refunded
```

### 3. Financial Transaction Updates

Automatically updates:
- Payment records
- Refund records
- Invoice status
- Transaction history

### 4. Booking Operation Validation

Validates:
- Date constraints (check-out after check-in)
- Amount validations (non-negative)
- Guest count requirements
- Status transitions
- Policy compliance

## Usage

### Creating a Booking

```typescript
import { createBooking } from '@/services/bookingOperations';

const result = await createBooking({
  property_id: '...',
  guest_id: '...',
  check_in_date: '2025-12-25',
  check_out_date: '2025-12-27',
  adults: 2,
  children: 0,
  total_amount: 5000,
  // ... other fields
});

if (result.success) {
  console.log('Booking created:', result.reservation_id);
} else {
  console.error('Errors:', result.errors);
}
```

### Updating a Booking

```typescript
import { updateBooking } from '@/services/bookingOperations';

const result = await updateBooking(
  reservationId,
  {
    check_out_date: '2025-12-28',
    total_amount: 6000,
  }
);

if (result.success) {
  console.log('Financial impact:', result.financial_impact);
}
```

### Cancelling a Booking

```typescript
import { cancelBooking } from '@/services/bookingOperations';

const result = await cancelBooking(
  reservationId,
  'Guest requested cancellation',
  userId
);

if (result.success) {
  console.log('Cancellation fee:', result.cancellation_details.cancellation_fee);
  console.log('Refund amount:', result.cancellation_details.refund_amount);
  console.log('Processing time:', result.cancellation_details.processing_time);
}
```

### Getting Booking Data for Communications

```typescript
import { getBookingDataForCommunication } from '@/services/bookingOperations';

const bookingData = await getBookingDataForCommunication(reservationId);

// bookingData contains all variables needed for email templates:
// - booking_number
// - check_in_date
// - check_out_date
// - nights
// - room_type
// - room_number
// - guest_count
// - total_amount
// - payment_status
// - special_requests
// - cancellation_date (if cancelled)
// - refund_amount (if cancelled)
// - refund_status (if cancelled)
// - processing_time (if cancelled)
```

## Communication Template Integration

All communication templates automatically receive accurate data from the rules engine:

1. **Booking Confirmation**: Uses `getBookingDataForCommunication()` to populate all variables
2. **Booking Cancellation**: Includes cancellation fee, refund amount, and processing time
3. **Booking Update**: Shows changes and financial impact
4. **Payment Receipt**: Reflects accurate payment and refund status

## Financial Accuracy

The rules engine ensures:

1. **Consistent Calculations**: All refund calculations use the same logic
2. **Policy Enforcement**: Cancellation policies are consistently applied
3. **Transaction Integrity**: All financial updates are atomic and consistent
4. **Audit Trail**: All changes are tracked with timestamps and user IDs

## Error Handling

The engine provides comprehensive error handling:

- **Validation Errors**: Prevent invalid operations
- **Warnings**: Alert about potential issues (e.g., late cancellations)
- **Policy Errors**: Indicate when policies cannot be applied
- **Financial Errors**: Track issues with payment/refund processing

## Data Consistency

The rules engine maintains data consistency by:

1. **Single Source of Truth**: All calculations use the same service
2. **Atomic Updates**: Financial updates are transactional
3. **Status Synchronization**: Reservation, payment, and invoice statuses stay in sync
4. **Cross-Screen Accuracy**: Same data appears consistently across all screens

## Testing

To test the rules engine:

1. Create bookings with different cancellation policies
2. Cancel bookings at various times before check-in
3. Verify refund calculations match policy rules
4. Check that financial records are updated correctly
5. Confirm communication templates show accurate data

## Future Enhancements

Potential improvements:

1. **Multi-currency Support**: Handle different currencies
2. **Partial Refunds**: Support for partial cancellation refunds
3. **Policy Overrides**: Allow manual policy overrides with approval
4. **Advanced Rules**: Support for complex conditional policies
5. **Analytics**: Track cancellation patterns and policy effectiveness

