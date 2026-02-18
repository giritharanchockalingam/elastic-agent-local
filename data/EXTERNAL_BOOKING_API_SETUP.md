# External Booking API Setup Guide

This guide walks you through setting up external booking provider integrations (Booking.com, Expedia) for the HMS Booking Engine.

## Prerequisites

- Supabase CLI installed (`npm install -g supabase`)
- Supabase project linked to your local environment
- Docker Desktop running (for local Edge Function development)

---

## Step 1: Install Supabase CLI

```bash
# Install Supabase CLI globally
npm install -g supabase

# Or use npx (no global install needed)
npx supabase --version
```

---

## Step 2: Login to Supabase

```bash
# Login to Supabase (opens browser for authentication)
npx supabase login
```

---

## Step 3: Link Your Project

```bash
# Navigate to project root
cd /Users/giritharanchockalingam/Desktop/GitHub/hms-gcp-refactor

# Link to your Supabase project
# You'll need your project reference ID from the Supabase dashboard
npx supabase link --project-ref qnwsnrfcnonaxvnithfv
```

To find your project reference:
1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to Project Settings → General
4. Copy the "Reference ID"

---

## Step 4: Initialize Supabase Functions (if not already done)

```bash
# Initialize supabase if not already done
npx supabase init
```

This creates the `supabase/` directory structure if it doesn't exist.

---

## Step 5: Deploy the Edge Function

```bash
# Deploy the booking-engine-api function
npx supabase functions deploy booking-engine-api --no-verify-jwt
```

The `--no-verify-jwt` flag allows the function to be called from the frontend without additional JWT verification (the Supabase client handles auth).

---

## Step 6: Set Environment Variables (Optional - for Production)

For sandbox/demo mode, no environment variables are needed. The function will return mock data.

For production integration with real APIs:

```bash
# Set Booking.com credentials
npx supabase secrets set BOOKING_COM_API_KEY=your_api_key
npx supabase secrets set BOOKING_COM_API_SECRET=your_api_secret
npx supabase secrets set BOOKING_COM_SANDBOX=false

# Set Expedia credentials
npx supabase secrets set EXPEDIA_API_KEY=your_api_key
npx supabase secrets set EXPEDIA_API_SECRET=your_api_secret
npx supabase secrets set EXPEDIA_SANDBOX=false
```

---

## Step 7: Test the Edge Function

### Using cURL:

```bash
# Test availability endpoint
curl -X POST 'https://qnwsnrfcnonaxvnithfv.supabase.co/functions/v1/booking-engine-api' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  --data '{
    "provider": "booking.com",
    "action": "getAvailability",
    "params": {
      "hotelId": "00000000-0000-0000-0000-000000000111",
      "checkIn": "2025-12-20",
      "checkOut": "2025-12-25",
      "adults": 2
    }
  }'
```

### Using the HMS UI:

1. Start the dev server: `npm run dev`
2. Navigate to: `/booking-engine`
3. Select "Booking.com" or "Expedia" from the provider dropdown
4. The rooms should now load from the Edge Function

---

## Step 8: Update the Frontend to Use Real API

The BookingEngine.tsx has been updated to support both demo mode and real Edge Functions. Once the Edge Function is deployed, update the fetch logic:

Edit `src/pages/BookingEngine.tsx`:

```typescript
// Fetch external provider availability
useEffect(() => {
  async function fetchExternalAvailability() {
    if (selectedProvider === 'internal' || !bookingForm.checkInDate || !bookingForm.checkOutDate) {
      setExternalRooms([]);
      return;
    }

    setLoadingExternal(true);
    try {
      const { data, error } = await supabase.functions.invoke('booking-engine-api', {
        body: {
          provider: selectedProvider,
          action: 'getAvailability',
          params: {
            hotelId: propertyId || '',
            checkIn: bookingForm.checkInDate,
            checkOut: bookingForm.checkOutDate,
            adults: bookingForm.adults,
            children: bookingForm.children,
          },
        },
      });

      if (error) throw error;

      // Transform response
      const transformedRooms = (data?.data || []).map((room: any) => ({
        id: room.roomId || room.id,
        name: room.name,
        description: room.description || '',
        base_price: room.price || 0,
        max_occupancy: room.maxOccupancy || 2,
        amenities: room.amenities || [],
        image_url: room.images?.[0] || '',
        availableRooms: room.available ? 1 : 0,
        provider: selectedProvider,
      }));

      setExternalRooms(transformedRooms);
    } catch (error: any) {
      console.error('Failed to fetch external availability:', error);
      toast({
        title: "Error",
        description: "Failed to fetch rooms from external provider",
        variant: "destructive"
      });
    } finally {
      setLoadingExternal(false);
    }
  }

  fetchExternalAvailability();
}, [selectedProvider, bookingForm.checkInDate, bookingForm.checkOutDate, bookingForm.adults, bookingForm.children, propertyId]);
```

---

## Troubleshooting

### CORS Errors
If you see CORS errors, ensure the Edge Function includes proper CORS headers:
```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}
```

### Function Not Found (404)
- Verify the function was deployed: `npx supabase functions list`
- Check function logs: `npx supabase functions logs booking-engine-api`

### Authentication Errors
- Ensure you're passing the correct API key
- Try deploying with `--no-verify-jwt` flag

### View Function Logs
```bash
# View real-time logs
npx supabase functions logs booking-engine-api --tail
```

---

## Production Setup: Booking.com Integration

To integrate with the real Booking.com API:

1. **Become a Booking.com Connectivity Partner**
   - Apply at: https://www.booking.com/content/affiliates.html
   - Complete the technical certification process

2. **Get API Credentials**
   - Obtain your `client_id` and `client_secret` from the partner portal

3. **Set Environment Variables**
   ```bash
   npx supabase secrets set BOOKING_COM_API_KEY=your_client_id
   npx supabase secrets set BOOKING_COM_API_SECRET=your_client_secret
   npx supabase secrets set BOOKING_COM_SANDBOX=false
   ```

4. **Update Edge Function** to use real API endpoints

---

## Production Setup: Expedia Integration

To integrate with the real Expedia API:

1. **Join Expedia Partner Central**
   - Sign up at: https://partner.expediagroup.com/

2. **Get API Access**
   - Request API access through the partner portal
   - Complete integration requirements

3. **Set Environment Variables**
   ```bash
   npx supabase secrets set EXPEDIA_API_KEY=your_api_key
   npx supabase secrets set EXPEDIA_API_SECRET=your_api_secret
   npx supabase secrets set EXPEDIA_SANDBOX=false
   ```

---

## Quick Deploy Script

Run this script to deploy the Edge Function:

```bash
#!/bin/bash
# deploy-booking-api.sh

echo "🚀 Deploying Booking Engine API..."

# Check if Supabase CLI is installed
if ! command -v npx &> /dev/null; then
    echo "❌ npx not found. Please install Node.js"
    exit 1
fi

# Deploy the function
npx supabase functions deploy booking-engine-api --no-verify-jwt

if [ $? -eq 0 ]; then
    echo "✅ Edge Function deployed successfully!"
    echo ""
    echo "Test the API:"
    echo "curl -X POST 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/booking-engine-api' \\"
    echo "  -H 'Content-Type: application/json' \\"
    echo "  --data '{\"provider\": \"booking.com\", \"action\": \"getAvailability\", \"params\": {}}'"
else
    echo "❌ Deployment failed. Check the logs above."
fi
```

---

## Summary

| Step | Command | Description |
|------|---------|-------------|
| 1 | `npm install -g supabase` | Install CLI |
| 2 | `npx supabase login` | Authenticate |
| 3 | `npx supabase link --project-ref YOUR_REF` | Link project |
| 4 | `npx supabase functions deploy booking-engine-api --no-verify-jwt` | Deploy function |
| 5 | Test in UI at `/booking-engine` | Verify it works |

---

## Files Created

- `supabase/functions/booking-engine-api/index.ts` - The Edge Function
- `docs/EXTERNAL_BOOKING_API_SETUP.md` - This guide

After deploying, the Booking Engine will connect to real external providers (in sandbox mode initially).

