# Quick Fix: Booking Engine "No Rooms Available"

## 🔍 Problem Identified

The booking engine shows "No rooms available" because:
1. **Rooms table has `property_id` column** (added in migrations)
2. **Query wasn't filtering by `property_id`** ✅ **FIXED**
3. **No rooms exist in database** - Need to seed data

## ✅ Fix Applied

### 1. Query Updated
- ✅ BookingEngine now filters rooms by `property_id`
- ✅ Handles cases where `property_id` might be null (backward compatibility)

### 2. Seed Script Updated
- ✅ Seed script now includes `property_id` when creating rooms

## 🚀 Quick Solution

### Step 1: Seed Room Data

1. **Go to Supabase Dashboard:**
   ```
   https://supabase.com/dashboard/project/YOUR_PROJECT_ID/sql/new
   ```

2. **Run the seed script:**
   - Open: `scripts/check-and-seed-rooms.sql`
   - Copy entire contents
   - Paste into SQL Editor
   - Click "Run"

3. **This will create:**
   - ✅ 3 Room Types (Standard, Deluxe, Suite)
   - ✅ 25 Rooms (all linked to your property)
   - ✅ All rooms set to 'available' status

### Step 2: Verify

After running the script, you should see:
```
Room Types: 3
Rooms: 25
Available Rooms: 25
```

### Step 3: Test Booking Engine

1. **Refresh the booking engine page**
2. **Select dates** (any future dates)
3. **You should now see:**
   - Standard Room - ₹150/night (10 available)
   - Deluxe Room - ₹250/night (10 available)
   - Suite - ₹450/night (5 available)

## 📋 What the Seed Script Does

```sql
-- Creates room types:
1. Standard Room (₹150, max 2 guests)
2. Deluxe Room (₹250, max 3 guests)
3. Suite (₹450, max 4 guests)

-- Creates rooms:
- R001-R010: Standard Rooms (Floor 1-2)
- R011-R020: Deluxe Rooms (Floor 2-3)
- R021-R025: Suites (Floor 3)

-- All linked to your property
-- All set to 'available' status
```

## 🔧 Manual Check (Optional)

To check current data:

```sql
-- Check room types
SELECT COUNT(*) FROM public.room_types;

-- Check rooms
SELECT 
  COUNT(*) as total,
  COUNT(CASE WHEN status = 'available' THEN 1 END) as available
FROM public.rooms;

-- Check property
SELECT id, name FROM public.properties LIMIT 1;
```

## ✅ Expected Result

After seeding:
- ✅ Room Types: 3
- ✅ Total Rooms: 25
- ✅ Available Rooms: 25
- ✅ Booking engine shows available rooms

---

**Quick Fix Script:** `scripts/check-and-seed-rooms.sql`
**Run it in Supabase SQL Editor!**

