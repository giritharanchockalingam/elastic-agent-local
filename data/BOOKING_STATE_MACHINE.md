# Booking Flow State Machine

## Overview

The booking flow state machine implements a robust, enterprise-grade state management system for the booking process with comprehensive error handling, retry logic, and state persistence.

## Architecture

### State Machine Components

1. **State Definitions** (`src/lib/state/bookingStateMachine.ts`)
   - Defines all booking states and events
   - State transition validation
   - Context validation
   - Utility functions for price changes, session expiration, etc.

2. **React Hook** (`src/hooks/useBookingStateMachine.ts`)
   - React hook for state machine usage
   - State persistence to sessionStorage
   - Automatic session/hold expiration checking
   - Error handling and retry logic

3. **Error Dialog Component** (`src/components/booking/BookingErrorDialog.tsx`)
   - User-friendly error display
   - Retry/cancel options based on error type
   - Recovery actions

## States

### Booking States

- `BROWSING` - User browsing available rooms
- `SELECTING_ROOM` - User viewing room details, deciding
- `FILLING_GUEST_DETAILS` - User filling guest information form
- `REVIEWING` - User reviewing booking details before payment
- `PAYMENT_IN_PROGRESS` - Payment processing
- `PAYMENT_FAILED` - Payment failed, retry available
- `CONFIRMED` - Booking confirmed (terminal)
- `EXPIRED` - Booking expired (terminal, recoverable)
- `CANCELLED` - Booking cancelled (terminal)

## State Transitions

```
BROWSING → SELECTING_ROOM (SELECT_ROOM)

SELECTING_ROOM → FILLING_GUEST_DETAILS (CONTINUE_TO_GUEST_DETAILS)
SELECTING_ROOM → BROWSING (BACK_TO_ROOM_SELECTION)

FILLING_GUEST_DETAILS → REVIEWING (SUBMIT_GUEST_DETAILS)
FILLING_GUEST_DETAILS → SELECTING_ROOM (BACK_TO_ROOM_SELECTION)

REVIEWING → PAYMENT_IN_PROGRESS (START_PAYMENT)
REVIEWING → FILLING_GUEST_DETAILS (EDIT_DETAILS)
REVIEWING → SELECTING_ROOM (CHANGE_ROOM)

PAYMENT_IN_PROGRESS → CONFIRMED (PAYMENT_SUCCESS)
PAYMENT_IN_PROGRESS → PAYMENT_FAILED (PAYMENT_FAILURE)
PAYMENT_IN_PROGRESS → PAYMENT_FAILED (TIMEOUT)
PAYMENT_IN_PROGRESS → EXPIRED (EXPIRE)

PAYMENT_FAILED → REVIEWING (RETRY_PAYMENT)
PAYMENT_FAILED → REVIEWING (CHANGE_PAYMENT_METHOD)
PAYMENT_FAILED → EXPIRED (EXPIRE)

EXPIRED → BROWSING (START_OVER)
```

## Usage Example

```typescript
import { useBookingStateMachine } from '@/hooks/useBookingStateMachine';
import { BookingEvent, BookingState } from '@/lib/state/bookingStateMachine';
import { BookingErrorDialog } from '@/components/booking';

function BookingFlow() {
  const [showErrorDialog, setShowErrorDialog] = useState(false);
  
  const bookingSM = useBookingStateMachine(
    {
      // Initial context
      checkInDate: new Date(),
      checkOutDate: new Date(Date.now() + 86400000),
      guests: { adults: 2, children: 0, rooms: 1 },
    },
    {
      onStateChange: (state, context) => {
        console.log('State changed:', state, context);
      },
      onError: (error) => {
        setShowErrorDialog(true);
      },
      persistState: true,
      sessionDurationMinutes: 30,
      holdDurationMinutes: 15,
    }
  );

  // Select room
  const handleRoomSelect = (roomId: string) => {
    bookingSM.updateContext({ roomTypeId: roomId });
    bookingSM.send(BookingEvent.SELECT_ROOM);
  };

  // Continue to guest details
  const handleContinue = () => {
    if (bookingSM.canSend(BookingEvent.CONTINUE_TO_GUEST_DETAILS)) {
      bookingSM.send(BookingEvent.CONTINUE_TO_GUEST_DETAILS);
    }
  };

  // Submit guest details
  const handleSubmitGuestDetails = (details: GuestDetails) => {
    bookingSM.updateContext({ guestDetails: details });
    bookingSM.send(BookingEvent.SUBMIT_GUEST_DETAILS);
  };

  // Start payment
  const handleStartPayment = async () => {
    bookingSM.send(BookingEvent.START_PAYMENT);
    
    try {
      // Process payment
      await processPayment(bookingSM.context);
      bookingSM.send(BookingEvent.PAYMENT_SUCCESS, {
        bookingId: 'BK-12345',
        reservationNumber: 'RES-12345',
      });
    } catch (error) {
      bookingSM.send(BookingEvent.PAYMENT_FAILURE);
    }
  };

  // Retry payment
  const handleRetry = () => {
    bookingSM.retry();
  };

  return (
    <>
      {/* Booking UI based on bookingSM.state */}
      
      <BookingErrorDialog
        open={showErrorDialog}
        onOpenChange={setShowErrorDialog}
        error={bookingSM.context.error}
        state={bookingSM.state}
        onRetry={handleRetry}
        onCancel={() => bookingSM.cancel()}
        onStartOver={() => bookingSM.reset()}
      />
    </>
  );
}
```

## Error Handling

### Error Types

1. **SESSION_EXPIRED** - Session expired, must start over
2. **PRICE_CHANGED** - Price changed >5%, user must review
3. **AVAILABILITY_CHANGED** - Room no longer available
4. **PAYMENT_FAILED** - Payment failed, retry available
5. **NETWORK_ERROR** - Connection error, retry available
6. **TIMEOUT** - Request timeout, retry available
7. **VALIDATION_ERROR** - Invalid context/state
8. **MAX_RETRIES_EXCEEDED** - Maximum retry attempts exceeded

### Retry Logic

- Automatic retry for retryable errors (up to maxRetries, default: 3)
- Manual retry via `retry()` method
- Retry count tracked in context
- Different retry strategies based on error type

## State Persistence

- State persisted to `sessionStorage` automatically
- Restored on page reload
- Cleared on terminal states (CONFIRMED, CANCELLED)
- Session expiration tracked and validated

## Price Change Detection

- Monitors price changes during booking
- Alerts user if price changes >5%
- Updates context with new price
- Requires user confirmation before proceeding

## Session Management

- Session expiration: 30 minutes (configurable)
- Room hold expiration: 15 minutes (configurable)
- Automatic expiration checking every 5 seconds
- Graceful handling of expired sessions

## Context Validation

Each state transition validates required context:
- `SELECTING_ROOM`: Requires dates and guests
- `FILLING_GUEST_DETAILS`: Requires room selection
- `REVIEWING`: Requires guest details
- `PAYMENT_IN_PROGRESS`: Requires valid total amount

## Telemetry

Events are logged for analytics:
- State transitions
- Error occurrences
- Retry attempts
- Session expiration
- Price changes

## Best Practices

1. Always check `canSend()` before sending events
2. Update context before sending events when needed
3. Handle errors gracefully with user-friendly messages
4. Implement retry logic for network errors
5. Validate context before critical transitions
6. Clear persisted state on terminal states
7. Monitor session expiration and handle gracefully

