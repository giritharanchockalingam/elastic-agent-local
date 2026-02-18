# Atomic Room Reservation System

## Overview

This document describes the world-class, enterprise-grade atomic room reservation system that ensures data consistency, prevents race conditions, and handles all edge cases for multi-room bookings.

## Problem Statement

The previous implementation had critical issues:
1. **Race Conditions**: Multiple users could book the same room simultaneously
2. **No Atomicity**: Room availability checks and reservation creation were separate operations
3. **Partial Failures**: If one room failed, others were already checked but not rolled back
4. **State Inconsistency**: UI showed availability but didn't lock rooms during booking
5. **Concurrent Bookings**: No protection against double-booking

## Solution Architecture

### 1. Database Function: `reserve_rooms_atomic`

A PostgreSQL function that ensures atomic reservation of multiple rooms with:
- **Row-level locking** (`FOR UPDATE SKIP LOCKED`) to prevent concurrent bookings
- **Atomic operations** - all rooms reserved or none
- **Automatic rollback** on any failure
- **Comprehensive validation** before any changes

### Key Features:

```sql
reserve_rooms_atomic(
  p_property_id UUID,
  p_check_in_date DATE,
  p_check_out_date DATE,
  p_room_type_ids UUID[],  -- Array of room types to reserve
  p_guest_id UUID,
  p_reservation_number TEXT,
  p_total_amount DECIMAL,
  p_adults INTEGER,
  p_children INTEGER,
  p_special_requests JSONB
)
```

**Returns:**
- `success`: Boolean indicating success/failure
- `reservation_id`: UUID of created reservation
- `room_ids`: Array of reserved room IDs
- `error_message`: Detailed error if failed

### 2. How It Works

#### Step 1: Validation
- Validates all input parameters
- Checks date validity (check-out > check-in)
- Ensures property exists

#### Step 2: Room Selection (with Locking)
For each room type:
1. Query available rooms with `FOR UPDATE SKIP LOCKED`
   - Prevents concurrent bookings of the same room
   - Skips already-locked rooms (being booked by others)
2. Filter by:
   - Correct room type
   - Not in maintenance/out_of_order
   - No conflicting reservations in date range
3. Select first available room
4. If any room type fails → **ROLLBACK ALL**

#### Step 3: Reservation Creation
- Create primary reservation (first room)
- Create linked reservations for additional rooms (if multi-room)
- Update room status to 'reserved'
- All in a single transaction

#### Step 4: Return Result
- Success: Return reservation ID and room IDs
- Failure: Return error message, all changes rolled back

### 3. Frontend Integration

The `BookingEngine` component now:

1. **Validates all rooms** before calling function
2. **Calls atomic function** for internal bookings
3. **Handles errors gracefully** with user-friendly messages
4. **Maintains state consistency** throughout the flow

## Edge Cases Handled

### 1. Concurrent Bookings
- **Solution**: `FOR UPDATE SKIP LOCKED` ensures only one booking per room
- **Result**: Second booking gets next available room or fails gracefully

### 2. Partial Availability
- **Scenario**: Room 1 available, Room 2 not available
- **Solution**: Function checks ALL rooms before reserving ANY
- **Result**: All-or-nothing - either all rooms reserved or none

### 3. Date Conflicts
- **Scenario**: Room reserved for overlapping dates
- **Solution**: Function checks existing reservations before selecting rooms
- **Result**: Only truly available rooms are selected

### 4. Room Status Changes
- **Scenario**: Room goes to maintenance during booking
- **Solution**: Function filters by status in real-time
- **Result**: Only operational rooms are selected

### 5. Network Failures
- **Scenario**: Connection drops during booking
- **Solution**: Database transaction ensures atomicity
- **Result**: Either complete booking or complete rollback

### 6. Multiple Room Types
- **Scenario**: Booking 3 different room types
- **Solution**: Function handles array of room types
- **Result**: All rooms reserved atomically

## State Management

### UI State Flow

1. **User Selects Rooms**
   - Each room maintains independent state
   - State updates use functional updates to prevent stale closures
   - React keys include room index and type ID

2. **User Clicks "Complete Booking"**
   - All room selections validated
   - Atomic function called with all room types
   - Loading state shown during processing

3. **Function Executes**
   - Database locks rooms atomically
   - All rooms reserved or none
   - State updated only on success

4. **Success/Error Handling**
   - Success: Show confirmation with all rooms
   - Error: Show specific error message, state unchanged

## Error Messages

The system provides specific, actionable error messages:

- `"No rooms available for [Room Type] on selected dates"` - Specific room type unavailable
- `"Reservation failed: [reason]"` - Database error details
- `"Please select a room type for all rooms"` - Validation error
- `"Reservation created but no rooms assigned"` - Data integrity error

## Performance Considerations

1. **Locking Strategy**: `SKIP LOCKED` prevents blocking - other bookings continue
2. **Index Usage**: Queries use indexes on `room_type_id`, `property_id`, `status`
3. **Transaction Scope**: Minimal transaction time reduces lock contention
4. **Batch Operations**: All rooms reserved in single function call

## Testing Scenarios

### Test Case 1: Single Room Booking
- ✅ Select one room type
- ✅ Complete booking
- ✅ Room reserved, status updated

### Test Case 2: Multi-Room Same Type
- ✅ Select 2 rooms of same type
- ✅ Complete booking
- ✅ Both rooms reserved

### Test Case 3: Multi-Room Different Types
- ✅ Select 3 different room types
- ✅ Complete booking
- ✅ All 3 rooms reserved atomically

### Test Case 4: Concurrent Booking
- ✅ User A and User B book same room simultaneously
- ✅ One succeeds, one gets next available or error
- ✅ No double-booking

### Test Case 5: Partial Availability
- ✅ Room 1 available, Room 2 not available
- ✅ Booking fails with specific error
- ✅ No partial reservations created

### Test Case 6: Date Conflict
- ✅ Try to book room already reserved for dates
- ✅ Function finds next available room
- ✅ Or fails if no rooms available

## Migration

The atomic reservation function is created in:
```
supabase/migrations/20251230000004_atomic_room_reservation.sql
```

To apply:
```bash
# Via Supabase CLI
supabase db reset

# Or apply migration directly
psql -f supabase/migrations/20251230000004_atomic_room_reservation.sql
```

## Future Enhancements

1. **Optimistic Locking**: Add version numbers to rooms for better concurrency
2. **Reservation Queue**: Queue system for high-demand periods
3. **Automatic Retry**: Retry with different rooms on failure
4. **Real-time Updates**: WebSocket updates for availability changes
5. **Caching**: Cache availability for frequently queried dates

## Conclusion

This atomic reservation system ensures:
- ✅ **Data Consistency**: All-or-nothing reservations
- ✅ **Race Condition Prevention**: Row-level locking
- ✅ **State Integrity**: UI state matches database state
- ✅ **Error Handling**: Comprehensive error messages
- ✅ **Scalability**: Handles concurrent bookings efficiently
- ✅ **World-Class UX**: Smooth, reliable booking experience
