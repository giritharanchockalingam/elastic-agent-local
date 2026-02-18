# Booking Engine - "No Rooms Available" Fix

## 🔍 Problem

The booking engine shows "No rooms available for selected dates" even when dates are selected.

## 🎯 Root Cause

This happens when:
1. **No room_types exist** in the database
2. **No rooms exist** in the database
3. **All rooms are booked** or have non-available status

## ✅ Quick Fix

### Option 1: Quick Room Seed (Recommended)

1. **Go to Supabase Dashboard:**
   ```
   https://supabase.com/dashboard/project/YOUR_PROJECT_ID/sql/new
   ```

2. **Copy and run this SQL:**
   - Open: `scripts/check-and-seed-rooms.sql`
   - Copy entire contents
   - Paste into SQL Editor
   - Click "Run"

3. **This will create:**
   - 3 Room Types (Standard, Deluxe, Suite)
   - 25 Rooms (10 Standard, 10 Deluxe, 5 Suites)
   - All rooms set to 'available' status

### Option 2: Full Production Seed

If you want complete test data:

1. **Run the full seeding script:**
   ```
   scripts/seed-production-data.sql
   ```

2. **This creates everything:**
   - Tenants and Properties
   - Room Types and Rooms
   - Guests and Sample Reservations
   - All master data

## 🧪 Verify Fix

After seeding:

1. **Refresh the booking engine page**
2. **Select dates** (any future dates)
3. **You should see available rooms:**
   - Standard Room - ₹150/night
   - Deluxe Room - ₹250/night
   - Suite - ₹450/night

4. **Select a room** and complete booking

## 📋 What the Seed Script Does

```sql
-- Creates 3 room types:
- Standard Room (₹150, max 2 guests)
- Deluxe Room (₹250, max 3 guests)
- Suite (₹450, max 4 guests)

-- Creates 25 rooms:
- R001-R010: Standard Rooms (Floor 1-2)
- R011-R020: Deluxe Rooms (Floor 2-3)
- R021-R025: Suites (Floor 3)

-- All rooms set to 'available' status
```

## 🔧 Manual Check

To check if data exists, run in SQL Editor:

```sql
-- Check room types
SELECT COUNT(*) as room_types_count FROM public.room_types;

-- Check rooms
SELECT 
  COUNT(*) as total_rooms,
  COUNT(CASE WHEN status = 'available' THEN 1 END) as available_rooms
FROM public.rooms;

-- List room types
SELECT id, name, base_price, max_occupancy FROM public.room_types;
```

## 🐛 Troubleshooting

### Still no rooms after seeding?

1. **Check browser console** for errors
2. **Verify propertyId** is set in PropertyContext
3. **Check if rooms query is working:**
   - Open browser DevTools → Network tab
   - Look for Supabase queries
   - Check if room_types query returns data

### Rooms exist but still not showing?

1. **Check room status:**
   ```sql
   SELECT room_number, status FROM public.rooms LIMIT 10;
   ```
   - Should have rooms with `status = 'available'`

2. **Check date conflict logic:**
   - The query filters out rooms with conflicting reservations
   - Try dates far in the future (e.g., 6 months from now)

3. **Check propertyId:**
   - Ensure PropertyContext has a valid propertyId
   - Check if rooms are linked to the property (if property_id column exists)

## ✅ Expected Result

After running the seed script, you should see:

- ✅ Room Types: 3
- ✅ Total Rooms: 25
- ✅ Available Rooms: 25

And the booking engine should show available rooms when you select dates!

---

**Quick Fix Script:** `scripts/fix-booking-engine-rooms.sh`

