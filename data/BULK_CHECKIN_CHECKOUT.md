# Bulk Check-In/Check-Out System

## Overview

The bulk check-in/check-out system enables hotel staff to process multiple reservations simultaneously with comprehensive rules engine validation and automated guest communications.

## Features

- ✅ **Rules Engine Validation**: Validates each reservation against business rules before processing
- ✅ **Bulk Operations**: Process multiple check-ins/check-outs in a single operation
- ✅ **Guest Communications**: Automatically triggers email/SMS notifications to guests
- ✅ **Compliance Checking**: Validates FRRO requirements, age verification, and payment status
- ✅ **Room Management**: Automatically updates room status and creates housekeeping tasks
- ✅ **Error Handling**: Detailed validation results with errors and warnings per reservation

## Architecture

### Components

1. **Rules Engine** (`src/services/checkInOutRulesEngine.ts`)
   - Validates check-in/check-out requirements
   - Checks compliance (FRRO, age verification, ID documents)
   - Validates payment status and room availability

2. **Edge Function** (`supabase/functions/bulk-checkin-checkout/index.ts`)
   - Processes bulk operations server-side
   - Updates reservations and rooms
   - Triggers guest communications via communication queue

3. **Frontend Service** (`src/services/bulkCheckInOutService.ts`)
   - Client-side service for bulk operations
   - Fetches eligible reservations
   - Calls Edge Function with proper options

4. **UI Component** (`src/components/BulkCheckInOut.tsx`)
   - User interface for bulk operations
   - Selection and validation UI
   - Results display

## Usage

### Accessing Bulk Operations

1. Navigate to **Check-In/Check-Out** page
2. Click on **Bulk Check-In** or **Bulk Check-Out** tab
3. Select reservations to process
4. Configure options (communications, validation, etc.)
5. Click **Validate** to preview results
6. Click **Execute** to process

### Options

- **Send Guest Communications**: Automatically send confirmation emails/SMS (default: enabled)
- **Skip Validation**: Bypass rules engine validation (not recommended)
- **Auto-Assign Rooms**: Automatically assign available rooms (check-in only)
- **Require ID Verification**: Only process reservations with verified IDs (check-in only)
- **Require Deposit**: Only process reservations with sufficient deposit (check-in only)

## Validation Rules

### Check-In Rules

1. **Status Validation**: Reservation must be `confirmed` or `pending`
2. **Date Validation**: Check-in date should be today or within 1 day
3. **Room Availability**: Assigned room must be `available` or `cleaning`
4. **Payment Status**: At least 10% deposit required (warning if less)
5. **ID Verification**: ID should be verified (warning if not)
6. **Age Verification**: Guest must be at least 18 years old
7. **FRRO Compliance**: International guests must have approved FRRO submission

### Check-Out Rules

1. **Status Validation**: Reservation must be `checked_in`
2. **Date Validation**: Check-out date validation
3. **Room Assignment**: Room must be assigned
4. **Payment Status**: Outstanding balance warnings
5. **Pending Charges**: Check for pending food orders/services

## Communication Integration

The system automatically adds entries to the `communication_queue` table:

- **Check-In**: `checkin_confirmation` communication type
- **Check-Out**: `checkout_confirmation` communication type

These are processed by the `process-communication-queue` Edge Function, which:
1. Fetches guest, booking, and property data
2. Replaces template variables
3. Sends emails via `send-guest-communication` function

## API Reference

### Edge Function

**Endpoint**: `bulk-checkin-checkout`

**Request**:
```json
{
  "reservationIds": ["uuid1", "uuid2", ...],
  "operation": "checkin" | "checkout",
  "propertyId": "uuid",
  "userId": "uuid",
  "options": {
    "skipValidation": false,
    "autoAssignRooms": false,
    "sendCommunications": true,
    "requireIdVerification": false,
    "requireDeposit": false
  }
}
```

**Response**:
```json
{
  "success": true,
  "processed": 5,
  "succeeded": 4,
  "failed": 1,
  "results": [
    {
      "reservationId": "uuid",
      "reservationNumber": "RES-12345",
      "success": true,
      "communicationSent": true
    }
  ],
  "summary": {
    "total": 5,
    "successful": 4,
    "failed": 1,
    "skipped": 0
  }
}
```

### Frontend Service

```typescript
import { executeBulkCheckInOut } from '@/services/bulkCheckInOutService';

const result = await executeBulkCheckInOut(
  ['reservation-id-1', 'reservation-id-2'],
  'checkin',
  propertyId,
  {
    sendCommunications: true,
    autoAssignRooms: true,
  }
);
```

## Error Handling

The system provides detailed error information:

- **Errors**: Block operations (e.g., wrong status, room unavailable)
- **Warnings**: Don't block but indicate potential issues (e.g., insufficient deposit, ID not verified)

Each reservation result includes:
- Success/failure status
- List of errors (if any)
- List of warnings (if any)
- Communication status

## Best Practices

1. **Always Validate First**: Use the "Validate" button before executing bulk operations
2. **Review Warnings**: Check warnings to ensure compliance
3. **Enable Communications**: Keep guest communications enabled for better guest experience
4. **Don't Skip Validation**: Only skip validation in exceptional circumstances
5. **Monitor Results**: Review the results summary after each operation

## Troubleshooting

### No Eligible Reservations

- Check date filters (defaults to today)
- Verify reservation status matches requirements
- Ensure property ID is correct

### Validation Failures

- Review error messages for each reservation
- Check room availability
- Verify payment status
- Ensure compliance requirements are met

### Communication Not Sent

- Check `communication_queue` table for entries
- Verify `process-communication-queue` function is running
- Check email template configuration
- Review Edge Function logs

## Security

- All operations require authentication
- User ID is logged for audit purposes
- RLS policies enforce property-level access
- Validation prevents unauthorized operations

## Related Documentation

- [Guest Communication System](./AUTOMATED_COMMUNICATIONS.md)
- [Rules Engine](./RULES_ENGINE.md)
- [Check-In/Check-Out Page](../src/pages/CheckInOut.tsx)

