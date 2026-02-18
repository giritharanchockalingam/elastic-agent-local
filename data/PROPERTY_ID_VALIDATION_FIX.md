# Property ID Validation & Fix Guide

## 🎯 Target Property ID
**`00000000-0000-0000-0000-000000000111`**

## ✅ Fixes Applied

### 1. PropertyContext Updated
- ✅ Now fetches property with ID: `00000000-0000-0000-0000-000000000111`
- ✅ No longer uses `LIMIT 1` which could get wrong property
- ✅ Uses specific property ID lookup

### 2. SQL Scripts Updated
- ✅ `scripts/ensure-25-rooms.sql` - Uses correct property_id
- ✅ `scripts/check-and-seed-rooms.sql` - Uses correct property_id
- ✅ `scripts/fix-rooms-to-correct-property.sql` - NEW: Fixes all existing rooms
- ✅ `scripts/validate-property-id.sql` - NEW: Validates current state

## 🚀 Quick Fix Steps

### Step 1: Validate Current State
```sql
-- Run in Supabase SQL Editor
-- File: scripts/validate-property-id.sql
```

This will show:
- ✅ If property exists
- ✅ How many rooms have correct property_id
- ✅ How many rooms have wrong property_id
- ✅ List of all rooms for target property

### Step 2: Fix All Rooms
```sql
-- Run in Supabase SQL Editor
-- File: scripts/fix-rooms-to-correct-property.sql
```

This will:
- ✅ Create property if it doesn't exist
- ✅ Update ALL rooms to use property_id: `00000000-0000-0000-0000-000000000111`
- ✅ Show verification results

### Step 3: Ensure 25 Rooms Exist
```sql
-- Run in Supabase SQL Editor
-- File: scripts/ensure-25-rooms.sql
```

This will:
- ✅ Create room types if missing
- ✅ Create rooms up to 25 total
- ✅ All rooms will have correct property_id

### Step 4: Refresh UI
1. **Hard refresh browser** (Ctrl+Shift+R or Cmd+Shift+R)
2. **Check browser console** for any errors
3. **Verify PropertyContext** is loading correct property_id
4. **Check Rooms Inventory** - should show all 25 rooms

## 🔍 Validation Queries

### Check Property Exists
```sql
SELECT id, name, code 
FROM public.properties 
WHERE id = '00000000-0000-0000-0000-000000000111';
```

### Check Rooms Count
```sql
SELECT 
  COUNT(*) as total_rooms,
  COUNT(CASE WHEN property_id = '00000000-0000-0000-0000-000000000111' THEN 1 END) as correct_property_rooms
FROM public.rooms;
```

### List All Rooms for Target Property
```sql
SELECT 
  room_number,
  property_id,
  status,
  floor,
  (SELECT name FROM public.room_types WHERE id = rooms.room_type_id) as room_type
FROM public.rooms
WHERE property_id = '00000000-0000-0000-0000-000000000111'
ORDER BY room_number;
```

## 🐛 Troubleshooting

### Still showing only 7 rooms?

1. **Check browser console:**
   - Open DevTools → Console
   - Look for PropertyContext logs
   - Verify property_id being used

2. **Check PropertyContext:**
   ```javascript
   // In browser console
   // The PropertyContext should be using: 00000000-0000-0000-0000-000000000111
   ```

3. **Verify database:**
   ```sql
   -- Run this to see what property_id rooms have
   SELECT property_id, COUNT(*) 
   FROM public.rooms 
   GROUP BY property_id;
   ```

4. **Clear browser cache:**
   - Hard refresh: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
   - Or clear cache completely

### Property doesn't exist?

Run this to create it:
```sql
-- Create tenant
INSERT INTO public.tenants (id, name, code, subscription_plan, subscription_status, status)
VALUES ('00000000-0000-0000-0000-000000000001', 'Aurora Hotels Group', 'AURORA', 'enterprise', 'active', 'active')
ON CONFLICT (code) DO NOTHING;

-- Create property
INSERT INTO public.properties (id, tenant_id, code, name, status)
VALUES ('00000000-0000-0000-0000-000000000111', '00000000-0000-0000-0000-000000000001', 'AURORA-MAIN', 'Aurora Grand Hotel', 'active')
ON CONFLICT (id) DO NOTHING;
```

## ✅ Expected Result

After running all scripts:
- ✅ Property exists with ID: `00000000-0000-0000-0000-000000000111`
- ✅ All 25 rooms have property_id: `00000000-0000-0000-0000-000000000111`
- ✅ PropertyContext loads correct property
- ✅ Rooms Inventory shows all 25 rooms
- ✅ Booking Engine shows available rooms

---

**Quick Fix:** Run `scripts/fix-rooms-to-correct-property.sql` then `scripts/ensure-25-rooms.sql`

