# Automated Booking Communications

## Overview

The system automatically sends email communications for all booking operations, whether performed directly through the system or via third-party integrations (OTA, channel managers, etc.).

## Supported Operations

### 1. Booking Creation
- **Trigger**: When a new reservation is created with status 'pending' or 'confirmed'
- **Communication**: Booking Confirmation email
- **Template**: `booking_confirmation`
- **Works for**: 
  - Direct/internal bookings
  - OTA bookings (Booking.com, Expedia)
  - Channel manager bookings
  - API-created bookings

### 2. Booking Updates
- **Trigger**: When significant fields change:
  - Check-in date
  - Check-out date
  - Total amount
  - Room assignment
- **Communication**: Booking Update notification
- **Template**: `booking_update`
- **Works for**: All booking sources

### 3. Booking Cancellation
- **Trigger**: When reservation status changes to 'cancelled'
- **Communication**: Cancellation confirmation with refund details
- **Template**: `booking_cancellation`
- **Includes**:
  - Cancellation fee
  - Refund amount
  - Refund status
  - Processing time
- **Works for**: All booking sources

## Implementation

### Database Triggers

Automated communications are triggered via PostgreSQL triggers that fire on:
- `INSERT` into `reservations` table
- `UPDATE` of `reservations` table (for status changes or significant field updates)

The trigger function `send_automated_booking_communication()`:
1. Detects the type of operation (create/update/cancel)
2. Fetches guest information
3. Queues communication via background job
4. Does not block the transaction if communication fails

### Service Layer

The `bookingOperations` service also includes communication triggers:
- `createBooking()` - Sends confirmation after successful creation
- `updateBooking()` - Sends update notification after changes
- `cancelBooking()` - Sends cancellation email with refund details

### Edge Function

The `booking-operations` edge function handles:
- Direct booking operations via API
- Automated communication triggers from database
- Third-party webhook processing

## Communication Flow

```
Booking Operation
    ↓
Database Trigger / Service Call
    ↓
Determine Communication Type
    ↓
Fetch Guest & Booking Data
    ↓
Get Email Template
    ↓
Replace Variables (Rules Engine)
    ↓
Send via send-guest-communication
    ↓
Log in guest_communication table
```

## Template Variables

All templates automatically receive accurate data from the rules engine:

### Booking Confirmation
- `{{booking_number}}`
- `{{check_in_date}}`
- `{{check_out_date}}`
- `{{nights}}`
- `{{room_type}}`
- `{{room_number}}`
- `{{guest_count}}`
- `{{total_amount}}`
- `{{payment_status}}`
- `{{special_requests}}`

### Booking Update
- All confirmation variables
- Plus: Change details

### Booking Cancellation
- All confirmation variables
- Plus:
  - `{{cancellation_date}}`
  - `{{refund_amount}}`
  - `{{refund_status}}`
  - `{{processing_time}}`

## Third-Party Integration Support

### OTA Bookings (Booking.com, Expedia)
- Automatically triggered when reservation is created via OTA API
- Uses same templates and rules engine
- Includes OTA-specific metadata in communication

### Channel Manager Bookings
- Triggered when bookings sync from channel manager
- Maintains consistency across all channels
- Uses property-specific templates

### API Bookings
- Any booking created via API triggers communication
- Supports webhook callbacks
- Includes API metadata

## Error Handling

- **Non-blocking**: Communication failures don't fail booking operations
- **Logging**: All communication attempts are logged
- **Retry**: Failed communications can be retried manually
- **Fallback**: System continues to function even if email service is down

## Configuration

### Enable/Disable Automated Communications

To disable automated communications for a property:
```sql
-- Disable trigger for specific property
ALTER TABLE reservations DISABLE TRIGGER trigger_send_booking_confirmation;
ALTER TABLE reservations DISABLE TRIGGER trigger_send_booking_update;
```

### Customize Templates

Templates can be customized per property:
- Edit templates in `email_templates` table
- Use property-specific templates
- Support multiple languages

## Monitoring

All automated communications are logged in:
- `guest_communication` table - Communication history
- `email_log` table - Email delivery status
- `sms_log` table - SMS delivery status (if applicable)

## Benefits

1. **Consistency**: All bookings receive communications, regardless of source
2. **Accuracy**: Rules engine ensures correct refund calculations
3. **Automation**: No manual intervention required
4. **Reliability**: Database triggers ensure communications are sent
5. **Flexibility**: Templates can be customized per property

