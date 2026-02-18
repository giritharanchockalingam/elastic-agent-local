# Booking Engine Enhancement Template

## Required Imports

```typescript
import { useEffect } from 'react';
import { loadIntegrationConfigs } from '@/services/config/integration-config';
import { BookingEngineService } from '@/services/booking-engine';
```

## State Additions

```typescript
const [selectedProvider, setSelectedProvider] = useState<'internal' | 'booking.com' | 'expedia'>('internal');
const [bookingService, setBookingService] = useState<BookingEngineService | null>(null);
const [showConfigDialog, setShowConfigDialog] = useState(false);
```

## Service Initialization

```typescript
useEffect(() => {
  async function initService() {
    try {
      const configs = await loadIntegrationConfigs();
      if (configs.bookingEngine) {
        const service = new BookingEngineService(configs.bookingEngine);
        setBookingService(service);
      }
    } catch (error) {
      console.error('Failed to initialize booking service:', error);
    }
  }
  initService();
}, []);
```

## Provider Selector UI (Add in Step 1)

```typescript
<Card className="glass-card">
  <CardHeader>
    <CardTitle>Select Booking Provider</CardTitle>
  </CardHeader>
  <CardContent>
    <Select value={selectedProvider} onValueChange={setSelectedProvider}>
      <SelectTrigger>
        <SelectValue />
      </SelectTrigger>
      <SelectContent>
        <SelectItem value="internal">Internal System</SelectItem>
        <SelectItem value="booking.com">Booking.com</SelectItem>
        <SelectItem value="expedia">Expedia</SelectItem>
      </SelectContent>
    </Select>
    {selectedProvider !== 'internal' && (
      <Button onClick={() => setShowConfigDialog(true)} className="mt-2">
        Configure {selectedProvider}
      </Button>
    )}
  </CardContent>
</Card>
```

## External Provider Availability Check

```typescript
// In roomTypes query, add external provider check
if (selectedProvider !== 'internal' && bookingService) {
  const { data, error } = await supabase.functions.invoke('booking-engine-api', {
    body: {
      provider: selectedProvider,
      action: 'getAvailability',
      params: {
        hotelId: propertyId,
        checkIn: bookingForm.checkInDate,
        checkOut: bookingForm.checkOutDate,
        adults: bookingForm.adults,
        children: bookingForm.children,
      },
    },
  });
  
  if (!error && data?.data) {
    // Transform external provider rooms to match internal format
    return data.data;
  }
}
```

## External Provider Booking Creation

```typescript
// In createBookingMutation, add external provider handling
if (selectedProvider !== 'internal') {
  const { data, error } = await supabase.functions.invoke('booking-engine-api', {
    body: {
      provider: selectedProvider,
      action: 'createBooking',
      params: {
        hotelId: propertyId,
        roomId: bookingForm.roomTypeId,
        checkIn: bookingForm.checkInDate,
        checkOut: bookingForm.checkOutDate,
        guests: {
          firstName: bookingForm.firstName,
          lastName: bookingForm.lastName,
          email: bookingForm.email,
          phone: bookingForm.phone,
        },
        adults: bookingForm.adults,
        children: bookingForm.children,
        specialRequests: bookingForm.specialRequests,
      },
    },
  });
  
  if (error) throw error;
  
  // Handle external booking confirmation
  setBookingConfirmation(data.data);
  setStep(4); // Go to confirmation
  return;
}
```
