# Centralized Booking State Management

## Overview

The `useBookingState` hook provides a unified, centralized state management solution for all booking flows in the application. It consolidates form data, room selections, validation, external bookings, and payment state into a single, reusable hook.

## Features

✅ **Centralized State**: All booking-related state in one place  
✅ **Type-Safe**: Full TypeScript support with comprehensive types  
✅ **Reactive**: Automatic computed values (nights, totals, taxes)  
✅ **Validation**: Built-in step-by-step and full form validation  
✅ **Room Management**: Add, remove, update rooms with helper functions  
✅ **External Bookings**: Support for Booking.com and Expedia integrations  
✅ **Payment State**: Complete payment flow state management  
✅ **Reset/Clear**: Easy state reset and cleanup  

## Installation

The hook is already available at `src/hooks/useBookingState.ts`. Import it like:

```typescript
import { useBookingState } from '@/hooks/useBookingState';
```

## Basic Usage

```typescript
import { useBookingState } from '@/hooks/useBookingState';

function MyBookingComponent() {
  const {
    state,
    updateForm,
    addRoom,
    removeRoom,
    updateRoom,
    setStep,
    nextStep,
    previousStep,
    setDates,
    validateStep,
    validateForm,
    reset,
    // ... many more helpers
  } = useBookingState({
    initialStep: 1,
    taxRate: 0.18, // 18% GST
    onFormChange: (form) => {
      console.log('Form changed:', form);
    },
    onStepChange: (step) => {
      console.log('Step changed:', step);
    },
  });

  // Access state
  const { form, currentStep, nights, subtotal, tax, total } = state;

  // Update form
  updateForm({ checkInDate: '2026-01-15', checkOutDate: '2026-01-20' });

  // Add room
  addRoom();

  // Update room
  updateRoom(0, { adults: 3, children: 1 });

  // Validate current step
  if (validateStep(currentStep)) {
    nextStep();
  }

  return (
    <div>
      <p>Current Step: {currentStep}</p>
      <p>Nights: {nights}</p>
      <p>Total: ₹{total.toLocaleString()}</p>
      {/* Your booking UI */}
    </div>
  );
}
```

## API Reference

### State Object

The `state` object contains all booking state:

```typescript
interface BookingState {
  // Form data
  form: BookingFormData;
  
  // Step/wizard
  currentStep: number;
  
  // Confirmation
  confirmation: BookingConfirmation | null;
  
  // Payment
  clientSecret: string;
  reservationId: string;
  paymentCompleted: boolean;
  
  // External bookings
  selectedProvider: 'internal' | 'booking.com' | 'expedia';
  externalRooms: any[];
  loadingExternal: boolean;
  externalBookingResult: any | null;
  
  // UI state
  showPolicyDialog: boolean;
  validationErrors: string[];
  availabilityWarnings: string[];
  
  // Computed values
  nights: number;
  subtotal: number;
  tax: number;
  total: number;
}
```

### Form Actions

#### `updateForm(updates: Partial<BookingFormData>)`
Update any part of the form:

```typescript
updateForm({
  checkInDate: '2026-01-15',
  checkOutDate: '2026-01-20',
  purposeOfVisit: 'business',
});
```

#### `updatePrimaryGuest(guest: Partial<GuestDetails>)`
Update primary guest information:

```typescript
updatePrimaryGuest({
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
  phone: '1234567890',
});
```

#### `updateSpecialRequests(requests: Partial<SpecialRequests>)`
Update special requests:

```typescript
updateSpecialRequests({
  earlyCheckIn: true,
  airportPickup: true,
  otherRequests: 'Late arrival',
});
```

### Room Actions

#### `addRoom()`
Add a new room to the booking:

```typescript
addRoom(); // Adds a room with default values
```

#### `removeRoom(index: number)`
Remove a room from the booking:

```typescript
removeRoom(1); // Removes room at index 1
```

#### `updateRoom(index: number, updates: Partial<RoomBooking>)`
Update a specific room:

```typescript
updateRoom(0, {
  adults: 3,
  children: 1,
  bedPreference: 'king',
});
```

#### `selectRoomType(index: number, roomType: { id: string; name: string; basePrice?: number })`
Select a room type for a room:

```typescript
selectRoomType(0, {
  id: 'room-type-id',
  name: 'Deluxe Room',
  basePrice: 5000,
});
```

### Step Actions

#### `setStep(step: number)`
Jump to a specific step (1-5):

```typescript
setStep(3); // Go to step 3
```

#### `nextStep()`
Move to the next step:

```typescript
if (validateStep(currentStep)) {
  nextStep();
}
```

#### `previousStep()`
Move to the previous step:

```typescript
previousStep();
```

### Date Actions

#### `setDates(checkIn: string, checkOut: string)`
Update check-in and check-out dates:

```typescript
setDates('2026-01-15', '2026-01-20');
```

### Validation

#### `validateStep(step: number): boolean`
Validate a specific step:

```typescript
if (validateStep(1)) {
  // Step 1 is valid, proceed
  nextStep();
}
```

#### `validateForm(): boolean`
Validate the entire form:

```typescript
if (validateForm()) {
  // Form is valid, submit booking
  submitBooking();
}
```

### External Booking Actions

#### `setProvider(provider: 'internal' | 'booking.com' | 'expedia')`
Set the booking provider:

```typescript
setProvider('booking.com');
```

#### `setExternalRooms(rooms: any[])`
Set external rooms from Booking.com or Expedia:

```typescript
setExternalRooms(externalRoomsData);
```

### Reset Actions

#### `reset()`
Reset all state to initial values:

```typescript
reset(); // Resets everything
```

#### `resetForm()`
Reset only the form data:

```typescript
resetForm(); // Resets form but keeps UI state
```

### Computed Helpers

#### `getNights(): number`
Get the number of nights:

```typescript
const nights = getNights();
```

#### `getTotalGuests(): { adults: number; children: number }`
Get total guests across all rooms:

```typescript
const { adults, children } = getTotalGuests();
```

#### `getTotalAmount(): number`
Get the total booking amount:

```typescript
const total = getTotalAmount();
```

## Integration Example

Here's how to integrate with an existing booking component:

```typescript
import { useBookingState } from '@/hooks/useBookingState';

function BookingComponent() {
  const booking = useBookingState({
    initialStep: 1,
    taxRate: 0.18,
  });

  const handleSubmit = async () => {
    // Validate form
    if (!booking.validateForm()) {
      return;
    }

    // Submit booking with state.form data
    const result = await createBooking({
      ...booking.state.form,
      totalAmount: booking.getTotalAmount(),
    });

    if (result.success) {
      booking.setConfirmation(result.confirmation);
      booking.setStep(5); // Confirmation step
    }
  };

  return (
    <div>
      {/* Step 1: Dates & Rooms */}
      {booking.state.currentStep === 1 && (
        <div>
          <input
            type="date"
            value={booking.state.form.checkInDate}
            onChange={(e) => booking.setDates(e.target.value, booking.state.form.checkOutDate)}
          />
          {/* Room selection */}
          {booking.state.form.rooms.map((room, index) => (
            <RoomSelector
              key={index}
              room={room}
              onSelect={(roomType) => booking.selectRoomType(index, roomType)}
            />
          ))}
          <Button onClick={booking.addRoom}>Add Another Room</Button>
        </div>
      )}

      {/* Step 2: Guest Details */}
      {booking.state.currentStep === 2 && (
        <GuestForm
          guest={booking.state.form.primaryGuest}
          onChange={(guest) => booking.updatePrimaryGuest(guest)}
        />
      )}

      {/* Show validation errors */}
      {booking.state.validationErrors.length > 0 && (
        <div>
          {booking.state.validationErrors.map((error, i) => (
            <p key={i}>{error}</p>
          ))}
        </div>
      )}

      {/* Navigation */}
      <div>
        {booking.state.currentStep > 1 && (
          <Button onClick={booking.previousStep}>Back</Button>
        )}
        {booking.state.currentStep < 4 && (
          <Button
            onClick={() => {
              if (booking.validateStep(booking.state.currentStep)) {
                booking.nextStep();
              }
            }}
          >
            Next
          </Button>
        )}
      </div>

      {/* Summary */}
      <div>
        <p>Nights: {booking.state.nights}</p>
        <p>Subtotal: ₹{booking.state.subtotal.toLocaleString()}</p>
        <p>Tax: ₹{booking.state.tax.toLocaleString()}</p>
        <p>Total: ₹{booking.state.total.toLocaleString()}</p>
      </div>
    </div>
  );
}
```

## Migration Guide

To migrate from local state to `useBookingState`:

1. **Replace useState declarations**:
   ```typescript
   // Before
   const [bookingForm, setBookingForm] = useState(INITIAL_FORM);
   const [step, setStep] = useState(1);
   
   // After
   const { state, setStep } = useBookingState();
   const bookingForm = state.form;
   ```

2. **Replace form updates**:
   ```typescript
   // Before
   setBookingForm(prev => ({ ...prev, checkInDate: '2026-01-15' }));
   
   // After
   updateForm({ checkInDate: '2026-01-15' });
   ```

3. **Replace room operations**:
   ```typescript
   // Before
   setBookingForm(prev => ({
     ...prev,
     rooms: [...prev.rooms, newRoom],
   }));
   
   // After
   addRoom();
   ```

4. **Use computed values**:
   ```typescript
   // Before
   const nights = calculateNights(bookingForm.checkInDate, bookingForm.checkOutDate);
   const total = calculateTotal(bookingForm);
   
   // After
   const { nights, total } = state;
   ```

## Benefits

✅ **Consistency**: Same state structure across all booking flows  
✅ **Type Safety**: Full TypeScript support prevents errors  
✅ **Maintainability**: Single source of truth for booking state  
✅ **Reusability**: Use in any component that needs booking state  
✅ **Computed Values**: Automatic calculations (no manual recalculation)  
✅ **Validation**: Built-in validation logic  
✅ **Testing**: Easy to test with isolated state  

## Next Steps

1. Gradually migrate existing booking components to use `useBookingState`
2. Create booking context provider if global state is needed
3. Add persistence (sessionStorage) if needed
4. Extend with additional validation rules as needed
