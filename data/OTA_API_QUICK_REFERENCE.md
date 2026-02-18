# OTA API Quick Reference Guide

## 🎯 Overview

This document provides a quick reference for all available OTA API operations for Expedia and Booking.com integrations.

---

## 📡 API Endpoints

### Base URLs

```
Expedia API:  YOUR_SUPABASE_URL/functions/v1/expedia-api
Booking.com:  YOUR_SUPABASE_URL/functions/v1/bookingcom-api
```

### Authentication

All requests require:
```http
Authorization: Bearer YOUR_SUPABASE_ACCESS_TOKEN
Content-Type: application/json
```

---

## 🏨 Expedia API Operations

### 1. Get Bookings

Retrieve bookings for a date range.

**Request:**
```json
{
  "action": "getBookings",
  "property_id": "uuid",
  "params": {
    "start_date": "2025-01-01",
    "end_date": "2025-01-31",
    "status": "confirmed"  // optional: confirmed, cancelled, modified
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "bookings": [
      {
        "booking_id": "EXP123456",
        "itinerary_id": "ITN123456",
        "status": "confirmed",
        "guest": {
          "name": "John Doe",
          "email": "john@example.com"
        },
        "check_in": "2025-01-15",
        "check_out": "2025-01-18",
        "rooms": [...],
        "total_amount": 450.00,
        "currency": "USD"
      }
    ]
  }
}
```

### 2. Get Booking Details

Get detailed information about a specific booking.

**Request:**
```json
{
  "action": "getBookingDetails",
  "property_id": "uuid",
  "params": {
    "booking_id": "EXP123456"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "booking_id": "EXP123456",
    "itinerary_id": "ITN123456",
    "status": "confirmed",
    "guest": {...},
    "rooms": [...],
    "payment": {...},
    "special_requests": "Late check-in"
  }
}
```

### 3. Create Booking

Create a new booking (typically from webhook).

**Request:**
```json
{
  "action": "createBooking",
  "property_id": "uuid",
  "params": {
    "itinerary_id": "ITN123456",
    "check_in": "2025-01-15",
    "check_out": "2025-01-18",
    "rooms": [
      {
        "room_type_id": "DELUXE",
        "rate_plan_id": "BAR",
        "adults": 2,
        "children": 0
      }
    ],
    "guest_info": {
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "+1234567890"
    },
    "payment_info": {
      "method": "credit_card",
      "total": 450.00,
      "currency": "USD"
    }
  }
}
```

### 4. Modify Booking

Update an existing booking.

**Request:**
```json
{
  "action": "modifyBooking",
  "property_id": "uuid",
  "params": {
    "booking_id": "EXP123456",
    "modifications": {
      "check_out": "2025-01-19",  // Extended stay
      "rooms": [...],  // Modified room configuration
      "special_requests": "Early check-in requested"
    }
  }
}
```

### 5. Cancel Booking

Cancel a booking.

**Request:**
```json
{
  "action": "cancelBooking",
  "property_id": "uuid",
  "params": {
    "booking_id": "EXP123456",
    "reason": "Guest requested cancellation"
  }
}
```

### 6. Check Availability

Check room availability for date range.

**Request:**
```json
{
  "action": "checkAvailability",
  "property_id": "uuid",
  "params": {
    "start_date": "2025-01-15",
    "end_date": "2025-01-18",
    "room_types": ["DELUXE", "SUITE"]  // optional filter
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "availability": [
      {
        "date": "2025-01-15",
        "room_type": "DELUXE",
        "available_rooms": 5,
        "restrictions": {
          "min_stay": 2,
          "max_stay": 7,
          "closed_to_arrival": false,
          "closed_to_departure": false
        }
      }
    ]
  }
}
```

### 7. Update Rates

Push rate updates to Expedia.

**Request:**
```json
{
  "action": "updateRates",
  "property_id": "uuid",
  "params": {
    "rates": [
      {
        "room_type_id": "DELUXE",
        "rate_plan_id": "BAR",
        "start_date": "2025-01-15",
        "end_date": "2025-01-31",
        "currency": "USD",
        "base_rate": 150.00,
        "occupancy_pricing": {
          "1": 120.00,
          "2": 150.00,
          "3": 180.00
        }
      }
    ]
  }
}
```

### 8. Update Inventory

Update room inventory/availability.

**Request:**
```json
{
  "action": "updateInventory",
  "property_id": "uuid",
  "params": {
    "inventory": [
      {
        "room_type_id": "DELUXE",
        "date": "2025-01-15",
        "available_rooms": 5,
        "restrictions": {
          "min_stay": 2,
          "closed_to_arrival": false
        }
      }
    ]
  }
}
```

### 9. Sync Content

Sync property content (descriptions, images, amenities).

**Request:**
```json
{
  "action": "syncContent",
  "property_id": "uuid",
  "params": {}
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "property_name": "Grand Hotel",
    "description": "...",
    "amenities": [...],
    "images": [...],
    "policies": {...}
  }
}
```

---

## 🌍 Booking.com API Operations

### 1. Get Reservations

**Request:**
```json
{
  "action": "getReservations",
  "property_id": "uuid",
  "params": {
    "start_date": "2025-01-01",
    "end_date": "2025-01-31",
    "status": "confirmed"  // optional
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "reservations": [
      {
        "reservation_id": "BDC789012",
        "status": "confirmed",
        "guest": {
          "name": "Jane Smith",
          "email": "jane@example.com"
        },
        "check_in": "2025-01-20",
        "check_out": "2025-01-23",
        "rooms": [...],
        "total_amount": 380.00,
        "currency": "EUR"
      }
    ]
  }
}
```

### 2. Get Reservation Details

**Request:**
```json
{
  "action": "getReservationDetails",
  "property_id": "uuid",
  "params": {
    "reservation_id": "BDC789012"
  }
}
```

### 3. Create Reservation

**Request:**
```json
{
  "action": "createReservation",
  "property_id": "uuid",
  "params": {
    "reservation_id": "BDC789012",
    "check_in": "2025-01-20",
    "check_out": "2025-01-23",
    "rooms": [
      {
        "room_type_id": "SUPERIOR",
        "rate_plan_id": "NR",
        "adults": 2,
        "children": 1
      }
    ],
    "guest_info": {
      "name": "Jane Smith",
      "email": "jane@example.com",
      "phone": "+44123456789"
    },
    "payment_info": {
      "method": "booking_com_collect",
      "total": 380.00,
      "currency": "EUR"
    }
  }
}
```

### 4. Modify Reservation

**Request:**
```json
{
  "action": "modifyReservation",
  "property_id": "uuid",
  "params": {
    "reservation_id": "BDC789012",
    "modifications": {
      "check_in": "2025-01-21",  // Changed check-in
      "rooms": [...]
    }
  }
}
```

### 5. Cancel Reservation

**Request:**
```json
{
  "action": "cancelReservation",
  "property_id": "uuid",
  "params": {
    "reservation_id": "BDC789012",
    "reason": "Guest cancellation"
  }
}
```

### 6. Check Availability

**Request:**
```json
{
  "action": "checkAvailability",
  "property_id": "uuid",
  "params": {
    "start_date": "2025-01-20",
    "end_date": "2025-01-23",
    "room_types": ["SUPERIOR", "DELUXE"]
  }
}
```

### 7. Update Rates

**Request:**
```json
{
  "action": "updateRates",
  "property_id": "uuid",
  "params": {
    "rates": [
      {
        "room_type_id": "SUPERIOR",
        "rate_plan_id": "NR",
        "date_from": "2025-01-20",
        "date_to": "2025-01-31",
        "currency": "EUR",
        "price": 120.00
      }
    ]
  }
}
```

### 8. Update Availability

**Request:**
```json
{
  "action": "updateAvailability",
  "property_id": "uuid",
  "params": {
    "availability": [
      {
        "room_type_id": "SUPERIOR",
        "date": "2025-01-20",
        "available_rooms": 8,
        "restrictions": {
          "min_stay": 1,
          "closed_to_arrival": false
        }
      }
    ]
  }
}
```

### 9. Sync Property Info

**Request:**
```json
{
  "action": "syncPropertyInfo",
  "property_id": "uuid",
  "params": {}
}
```

---

## 🔄 Webhook Events

### Expedia Webhooks

**Endpoint:** `YOUR_SUPABASE_URL/functions/v1/ota-webhook`

**Event Types:**
- `booking.created` - New booking received
- `booking.modified` - Booking details changed
- `booking.cancelled` - Booking cancelled

**Payload Structure:**
```json
{
  "provider": "expedia",
  "event_type": "booking.created",
  "data": {
    "booking_id": "EXP123456",
    "itinerary_id": "ITN123456",
    // ... booking details
  }
}
```

### Booking.com Webhooks

**Event Types:**
- `reservation.created` - New reservation received
- `reservation.modified` - Reservation changed
- `reservation.cancelled` - Reservation cancelled

**Payload Structure:**
```json
{
  "provider": "booking_com",
  "event_type": "reservation.created",
  "data": {
    "reservation_id": "BDC789012",
    // ... reservation details
  }
}
```

---

## 📊 Response Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Operation completed successfully |
| 400 | Bad Request | Check request parameters |
| 401 | Unauthorized | Verify API credentials |
| 404 | Not Found | Resource doesn't exist |
| 500 | Server Error | Contact support |

---

## 🔍 Error Handling

All API responses follow this structure:

**Success:**
```json
{
  "success": true,
  "data": { ... }
}
```

**Error:**
```json
{
  "success": false,
  "error": "Error message",
  "details": "Detailed error information"
}
```

---

## 📝 Common Use Cases

### Use Case 1: Daily Booking Sync

```javascript
async function syncDailyBookings() {
  const today = new Date().toISOString().split('T')[0];
  const nextMonth = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
    .toISOString()
    .split('T')[0];

  // Sync Expedia
  await fetch(`${SUPABASE_URL}/functions/v1/expedia-api`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      action: 'getBookings',
      property_id: propertyId,
      params: {
        start_date: today,
        end_date: nextMonth
      }
    })
  });

  // Sync Booking.com
  await fetch(`${SUPABASE_URL}/functions/v1/bookingcom-api`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      action: 'getReservations',
      property_id: propertyId,
      params: {
        start_date: today,
        end_date: nextMonth
      }
    })
  });
}
```

### Use Case 2: Update Rates Across All OTAs

```javascript
async function updateRatesAllOTAs(rates) {
  const rateData = {
    rates: [
      {
        room_type_id: 'DELUXE',
        rate_plan_id: 'BAR',
        start_date: '2025-02-01',
        end_date: '2025-02-28',
        currency: 'USD',
        base_rate: 175.00,
        occupancy_pricing: {
          '1': 140.00,
          '2': 175.00,
          '3': 210.00
        }
      }
    ]
  };

  // Update Expedia
  await fetch(`${SUPABASE_URL}/functions/v1/expedia-api`, {
    method: 'POST',
    body: JSON.stringify({
      action: 'updateRates',
      property_id: propertyId,
      params: rateData
    })
  });

  // Update Booking.com (slightly different format)
  await fetch(`${SUPABASE_URL}/functions/v1/bookingcom-api`, {
    method: 'POST',
    body: JSON.stringify({
      action: 'updateRates',
      property_id: propertyId,
      params: {
        rates: [
          {
            room_type_id: 'DELUXE',
            rate_plan_id: 'NR',
            date_from: '2025-02-01',
            date_to: '2025-02-28',
            currency: 'EUR',
            price: 165.00
          }
        ]
      }
    })
  });
}
```

### Use Case 3: Real-time Availability Update

```javascript
async function updateInventoryRealtime(roomTypeId, date, availableRooms) {
  const inventoryData = {
    inventory: [
      {
        room_type_id: roomTypeId,
        date: date,
        available_rooms: availableRooms,
        restrictions: {
          min_stay: 1,
          closed_to_arrival: false,
          closed_to_departure: false
        }
      }
    ]
  };

  // Update Expedia
  await fetch(`${SUPABASE_URL}/functions/v1/expedia-api`, {
    method: 'POST',
    body: JSON.stringify({
      action: 'updateInventory',
      property_id: propertyId,
      params: inventoryData
    })
  });

  // Update Booking.com
  await fetch(`${SUPABASE_URL}/functions/v1/bookingcom-api`, {
    method: 'POST',
    body: JSON.stringify({
      action: 'updateAvailability',
      property_id: propertyId,
      params: {
        availability: [
          {
            room_type_id: roomTypeId,
            date: date,
            available_rooms: availableRooms
          }
        ]
      }
    })
  });
}
```

---

## 🎓 Best Practices

1. **Always handle errors gracefully**
   ```javascript
   try {
     const response = await fetch(...);
     const result = await response.json();
     if (!result.success) {
       console.error('API Error:', result.error);
       // Handle error appropriately
     }
   } catch (error) {
     console.error('Network Error:', error);
     // Retry or alert user
   }
   ```

2. **Use batch updates when possible**
   - Update multiple dates/rooms in one API call
   - Reduces API call count and improves performance

3. **Implement retry logic for critical operations**
   ```javascript
   async function withRetry(fn, maxRetries = 3) {
     for (let i = 0; i < maxRetries; i++) {
       try {
         return await fn();
       } catch (error) {
         if (i === maxRetries - 1) throw error;
         await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
       }
     }
   }
   ```

4. **Log all operations for audit trail**
   - All operations are automatically logged to `ota_sync_logs` table
   - Review logs regularly for issues

5. **Monitor rate limits**
   - Expedia: 100 requests/minute per property
   - Booking.com: 50 requests/minute per property

---

## 📞 Support

For issues with:
- **Expedia API:** https://developers.expediagroup.com/support
- **Booking.com API:** https://developers.booking.com/support
- **HMS Integration:** Contact your system administrator

---

**Document Version:** 1.0  
**Last Updated:** December 26, 2024  
**Next Review:** January 26, 2025
