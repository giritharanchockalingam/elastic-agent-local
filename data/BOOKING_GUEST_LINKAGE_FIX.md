# Booking and Guest Linkage Fix

## Issue
Bookings are being confirmed but not showing up in the guest profile page.

## Root Cause
When a booking is created through the public portal, the reservation may not be properly linked to a guest record in the `guests` table. The `getGuestBookings` function queries reservations by `guest_id`, so if the linkage is missing, bookings won't appear.

## Solution

### 1. Ensure Guest Record Creation
When creating a booking, ensure:
- A guest record exists in the `guests` table with the correct `user_id`
- The reservation has the `guest_id` field set to the guest record ID

### 2. Database Fix Script
Run `scripts/fix-restaurant-and-bookings.sql` to:
- Link existing orphaned reservations to guest records
- Verify restaurant data exists

### 3. Code Fixes Needed

#### In Booking Creation Flow
Ensure that when a booking is created:
1. If user is authenticated, find or create guest record:
   ```typescript
   // Get or create guest record
   const { data: guest } = await supabase
     .from('guests')
     .select('id')
     .eq('user_id', userId)
     .maybeSingle();

   let guestId;
   if (!guest) {
     // Create guest record
     const { data: newGuest } = await supabase
       .from('guests')
       .insert({
         user_id: userId,
         property_id: propertyId,
         email: bookingEmail,
         phone: bookingPhone,
         first_name: firstName,
         last_name: lastName,
       })
       .select('id')
       .single();
     guestId = newGuest?.id;
   } else {
     guestId = guest.id;
   }
   ```

2. Use `guest_id` when creating reservation:
   ```typescript
   const { data: reservation } = await supabase
     .from('reservations')
     .insert({
       property_id: propertyId,
       guest_id: guestId, // CRITICAL: Must link to guest record
       room_type_id: roomTypeId,
       check_in_date: checkInDate,
       check_out_date: checkOutDate,
       // ... other fields
     })
     .select()
     .single();
   ```

#### In Guest Bookings Query
The `getGuestBookings` function already correctly:
- Gets guest record by `user_id`
- Queries reservations by `guest_id`

The issue is likely that `guest_id` is NULL or doesn't match.

## Verification Queries

```sql
-- Check if reservations have guest_id
SELECT 
  r.id,
  r.reservation_number,
  r.status,
  r.guest_id,
  g.id as guest_exists,
  g.user_id
FROM reservations r
LEFT JOIN guests g ON g.id = r.guest_id
WHERE r.status IN ('confirmed', 'pending')
ORDER BY r.created_at DESC
LIMIT 20;

-- Check guest records for a user
SELECT 
  g.id,
  g.user_id,
  g.email,
  COUNT(r.id) as reservation_count
FROM guests g
LEFT JOIN reservations r ON r.guest_id = g.id
WHERE g.user_id = 'YOUR_USER_ID_HERE'
GROUP BY g.id, g.user_id, g.email;
```

