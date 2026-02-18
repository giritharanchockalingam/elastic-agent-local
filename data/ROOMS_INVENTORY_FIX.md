# Rooms Inventory - Only 7 Rooms Showing - Fix Guide

## 🔍 Problem

Only 7 rooms are showing in the Rooms Inventory page, but the seed script should create 25 rooms.

## 🎯 Root Causes

1. **RoomsInventory wasn't filtering by `property_id`**
   - The query was fetching ALL rooms from the database
   - If rooms don't have `property_id` set, or have different `property_id`, they won't show correctly
   - ✅ **FIXED**: Query now filters by `property_id`

2. **Existing rooms may not have `property_id`**
   - Rooms created before the `property_id` column was added
   - Rooms created manually without `property_id`
   - ✅ **SOLUTION**: Script to update existing rooms

3. **Not all 25 rooms were created**
   - Seed script may not have run completely
   - Only 7 rooms were created manually
   - ✅ **SOLUTION**: Script to ensure 25 rooms exist

## ✅ Fixes Applied

### 1. Code Fix
- ✅ Updated `RoomsInventory.tsx` to filter by `property_id`
- ✅ Added `useProperty` hook to get current property
- ✅ Query now only shows rooms for the current property

### 2. Diagnostic Scripts
- ✅ `scripts/check-room-count.sql` - Check how many rooms exist and their `property_id`
- ✅ `scripts/fix-rooms-property-id.sql` - Update existing rooms with `property_id`
- ✅ `scripts/ensure-25-rooms.sql` - Complete solution to ensure 25 rooms exist

## 🚀 Quick Fix

### Step 1: Run Diagnostic (Optional)
```sql
-- Run in Supabase SQL Editor
-- File: scripts/check-room-count.sql
```
This will show:
- Total rooms count
- Rooms by property_id
- Rooms without property_id
- Room types count

### Step 2: Fix Everything
```sql
-- Run in Supabase SQL Editor
-- File: scripts/ensure-25-rooms.sql
```

This script will:
1. ✅ Get or create property
2. ✅ Create room types if missing (Standard, Deluxe, Suite)
3. ✅ Update existing rooms with `property_id` if missing
4. ✅ Create rooms up to 25 total (R001-R025)
5. ✅ Ensure all rooms have `property_id`

### Step 3: Refresh Page
1. Refresh the Rooms Inventory page
2. You should now see 25 rooms (or all rooms for your property)

## 📋 What the Script Creates

### Room Types (3):
- **Standard Room** - ₹150/night, Max 2 guests
- **Deluxe Room** - ₹250/night, Max 3 guests
- **Suite** - ₹450/night, Max 4 guests

### Rooms (25 total):
- **R001-R010**: Standard Rooms (Floor 1-2)
- **R011-R020**: Deluxe Rooms (Floor 2-3)
- **R021-R025**: Suites (Floor 3)

All rooms:
- ✅ Linked to your property (`property_id`)
- ✅ Set to 'available' status
- ✅ Properly linked to room types

## 🔧 Manual Fix (If Needed)

If you want to manually update existing rooms:

```sql
-- Update existing rooms with property_id
UPDATE public.rooms
SET property_id = (SELECT id FROM public.properties LIMIT 1)
WHERE property_id IS NULL;
```

## ✅ Expected Result

After running `ensure-25-rooms.sql`:
- ✅ Room Types: 3
- ✅ Total Rooms: 25 (or more if you had some already)
- ✅ All rooms have `property_id`
- ✅ Rooms Inventory shows all rooms for your property

## 🐛 Troubleshooting

### Still only showing 7 rooms?

1. **Check if script ran successfully:**
   ```sql
   SELECT COUNT(*) FROM public.rooms;
   ```

2. **Check property_id:**
   ```sql
   SELECT property_id, COUNT(*) 
   FROM public.rooms 
   GROUP BY property_id;
   ```

3. **Verify your property ID:**
   - Check PropertyContext in browser console
   - Or run: `SELECT id, name FROM public.properties LIMIT 1;`

4. **Clear browser cache and refresh**

### Rooms showing but wrong property?

- The query now filters by `property_id` from PropertyContext
- Make sure PropertyContext is loading the correct property
- Check if multiple properties exist

---

**Quick Fix:** Run `scripts/ensure-25-rooms.sql` in Supabase SQL Editor!

