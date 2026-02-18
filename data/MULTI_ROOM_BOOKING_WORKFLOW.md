# Multi-Room Booking Workflow

## Overview

The booking system supports booking multiple rooms of **different types** in a single reservation. This is perfect for:
- Families needing different room types (e.g., Suite for parents, Standard for kids)
- Groups with varying preferences
- Corporate bookings with different room categories

## How It Works

### Room 1 (First Room)
- **Option A:** Pre-select from "Select Your Room" gallery at the top
  - Room type is automatically set
  - Shows "Selected from room gallery above" with "Change" button
  - Can change to a different room type if needed

- **Option B:** Select directly in the booking form
  - If not pre-selected, shows full room type selector
  - Choose from available room types with images and pricing

### Room 2, 3, 4+ (Additional Rooms)
- **Always shows room type selector** (not affected by top selector)
- Each room can independently select:
  - Different room type (e.g., Room 1 = Deluxe, Room 2 = Standard, Room 3 = Suite)
  - Different rate plan
  - Different guest count (adults/children)
  - Different preferences (bed, floor, smoking)

## User Workflow

### Scenario: Family Booking 3 Different Room Types

1. **Select Room 1 from Gallery:**
   - User clicks "Deluxe Room" in top gallery
   - Room 1 is automatically set to Deluxe Room
   - Summary shows: "Room 1: Deluxe Room - ₹8,000/night"

2. **Add Room 2:**
   - Click "Add Another Room" button
   - Room 2 card appears with empty room type
   - User selects "Standard Room" from dropdown
   - Summary updates: Shows both Room 1 and Room 2 with individual pricing

3. **Add Room 3:**
   - Click "Add Another Room" again
   - Room 3 card appears
   - User selects "Executive Suite" from dropdown
   - Summary updates: Shows all 3 rooms with different types and prices

4. **Customize Each Room:**
   - Room 1: 2 Adults, Deluxe Room, King Bed
   - Room 2: 1 Adult, 2 Children, Standard Room, Twin Beds
   - Room 3: 2 Adults, Executive Suite, High Floor

5. **Complete Booking:**
   - Summary shows total for all rooms combined
   - Single reservation created with multiple room bookings
   - Each room can have different pricing based on type and rate plan

## Summary Display

The booking summary shows:
- **Room 1:** Room type, per-night rate, total for stay
- **Room 2:** Room type, per-night rate, total for stay
- **Room 3+:** Each room listed separately
- **Subtotal:** Sum of all rooms
- **Taxes:** Calculated on total
- **Grand Total:** Final amount

## Technical Implementation

### Data Structure
```typescript
bookingForm.rooms = [
  {
    roomTypeId: "deluxe-room-id",
    roomTypeName: "Deluxe Room",
    basePrice: 8000,
    adults: 2,
    children: 0,
    // ... other fields
  },
  {
    roomTypeId: "standard-room-id",  // Different room type!
    roomTypeName: "Standard Room",
    basePrice: 5000,
    adults: 1,
    children: 2,
    // ... other fields
  },
  // ... more rooms
]
```

### Key Features
- ✅ Each room can have different `roomTypeId`
- ✅ Each room can have different `basePrice`
- ✅ Each room can have different `ratePlanId`
- ✅ Summary calculates total for all rooms
- ✅ Room 1 can be pre-selected from top gallery
- ✅ Rooms 2+ always show room type selector

## UI/UX Improvements

1. **Clear Room Identification:**
   - Each room shows "Room 1", "Room 2", etc. badges
   - Summary clearly labels each room

2. **Independent Selection:**
   - Room type selector only hidden for Room 1 if pre-selected
   - All other rooms can always select their type

3. **Visual Separation:**
   - Each room in summary has border separator
   - Easy to see individual room pricing

4. **Flexible Workflow:**
   - Can start with Room 1 pre-selected OR empty
   - Can add/remove rooms at any time
   - Can change any room's type independently

## Example Use Cases

### Use Case 1: Family with Kids
- Room 1: Deluxe Room (Parents) - 2 Adults
- Room 2: Standard Room (Kids) - 1 Adult, 2 Children
- Room 3: Standard Room (Grandparents) - 2 Adults

### Use Case 2: Corporate Group
- Room 1: Executive Suite (CEO) - 1 Adult
- Room 2: Deluxe Room (Manager) - 1 Adult
- Room 3-5: Standard Rooms (Staff) - 1 Adult each

### Use Case 3: Wedding Party
- Room 1: Presidential Suite (Bride & Groom) - 2 Adults
- Room 2-3: Executive Suites (Parents) - 2 Adults each
- Room 4-10: Standard Rooms (Guests) - 2 Adults each

## Benefits

1. **Single Reservation:** All rooms in one booking
2. **Flexible Selection:** Each room can be different
3. **Clear Pricing:** See individual and total costs
4. **Easy Management:** Add/remove rooms as needed
5. **Better UX:** No need to create separate bookings
