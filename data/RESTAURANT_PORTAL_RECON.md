# Restaurant Portal Recon Summary

## Step 0: Existing Schema Analysis

### ✅ Tables Found

#### 1. **Restaurants Table** (`public.restaurants`)
**Location**: `supabase/migrations/20251112032554_25ee2f16-bf7d-48e1-a240-1164756f4025.sql`

```sql
CREATE TABLE IF NOT EXISTS public.restaurants (
  id UUID PRIMARY KEY,
  property_id UUID REFERENCES properties(id),
  name TEXT NOT NULL,
  code TEXT NOT NULL,
  cuisine_type TEXT,
  seating_capacity INTEGER,
  opening_time TIME,
  closing_time TIME,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  UNIQUE(property_id, code)
);
```

**Status**: ✅ Exists, but lacks:
- `outlet_slug` (needed for public URLs)
- `description_public` (public-facing description)
- `is_public` (visibility flag)
- `hours_json` (structured hours)
- `phone_public`, `address_public` (public contact info)
- `cuisine_tags` (array for filtering)

#### 2. **Menu Items Table** (`public.menu_items`)
**Location**: Multiple migrations reference this

**Current Schema** (from types.ts):
- `id`, `name`, `description`, `category`, `price`, `is_available`
- `dietary_info` (JSONB), `image_url`, `spice_level`, `allergens`
- ❌ **NO `restaurant_id` or `outlet_id`** - menu items are NOT linked to restaurants/outlets!
- ❌ **NO `tenant_id` or `property_id`** - no tenant/property scoping!

**Status**: ⚠️ Exists but **disconnected** from restaurants. Cannot be used for restaurant menus as-is.

#### 3. **Outlets Table** (`public.outlets`)
**Location**: Referenced in `db/enterprise-phase2-fb-housekeeping.sql` (NOT in supabase/migrations/)

```sql
CREATE TABLE public.outlets (
  id UUID PRIMARY KEY,
  property_id UUID REFERENCES properties(id),
  name VARCHAR(200) NOT NULL,
  outlet_type VARCHAR(50) NOT NULL, -- 'restaurant', 'bar', 'cafe', etc.
  location VARCHAR(200),
  capacity INTEGER,
  operating_hours JSONB,
  contact_phone VARCHAR(50),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);
```

**Status**: ⚠️ **UNCLEAR** if this table exists in production schema. Not found in recent migrations. May only exist in dev/test SQL files.

#### 4. **Menu Categories** (`public.menu_categories`)
**Location**: Referenced in `db/enterprise-phase2-fb-housekeeping.sql`

```sql
CREATE TABLE public.menu_categories (
  id UUID PRIMARY KEY,
  outlet_id UUID REFERENCES outlets(id),
  name VARCHAR(200) NOT NULL,
  description TEXT,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);
```

**Status**: ⚠️ **UNCLEAR** if exists. Depends on `outlets` table.

#### 5. **Food Orders** (`public.food_orders`)
**Location**: `supabase/migrations/20251112020704_7a1b120d-137f-4027-919f-0aaba912cfec.sql`

```sql
CREATE TABLE IF NOT EXISTS public.food_orders (
  id UUID PRIMARY KEY,
  reservation_id UUID REFERENCES reservations(id),
  room_id UUID REFERENCES rooms(id),
  order_type TEXT CHECK (order_type IN ('room_service', 'restaurant', 'bar')),
  items JSONB NOT NULL,  -- ❌ JSONB items, not normalized!
  total_amount DECIMAL(10,2) NOT NULL,
  status TEXT DEFAULT 'pending',
  special_instructions TEXT,
  ordered_at TIMESTAMPTZ DEFAULT NOW(),
  delivered_at TIMESTAMPTZ
);
```

**Status**: ✅ Exists but:
- ❌ Uses JSONB `items` (not normalized order_items table)
- ❌ No `restaurant_id` or `outlet_id` link
- ❌ No `tenant_id` or `property_id` (relies on reservation/room)
- ❌ No `contact_json` for anon orders
- ❌ No `fulfillment_type` (pickup/dine-in/delivery)
- ❌ No `channel` (web/mobile/phone)

#### 6. **Reservations** (`public.reservations`)
**Location**: `supabase/migrations/20251112020704_7a1b120d-137f-4027-919f-0aaba912cfec.sql`

**Status**: ✅ Exists for hotel room reservations. Can be reused pattern, but needs restaurant-specific table.

#### 7. **POS Transactions** (`public.pos_transactions`)
**Location**: `supabase/migrations/20251112032554_25ee2f16-bf7d-48e1-a240-1164756f4025.sql`

```sql
CREATE TABLE IF NOT EXISTS public.pos_transactions (
  id UUID PRIMARY KEY,
  property_id UUID REFERENCES properties(id),
  outlet_type TEXT,
  outlet_id UUID,  -- ✅ Generic outlet reference!
  ...
);
```

**Status**: ✅ Has `outlet_id` + `outlet_type` pattern (supports restaurants/bars generically).

---

## ❌ Missing for Public Restaurant Portal

1. **Restaurant Outlets with Public Fields**
   - Need `outlet_slug`, `is_public`, `description_public`, `phone_public`, `address_public`
   - Need `hours_json` for structured hours
   - Need `cuisine_tags` array

2. **Menu Structure Linked to Outlets**
   - `menu_categories` linked to `outlet_id`
   - `menu_items` linked to `category_id` + `outlet_id`

3. **Public Views**
   - `public_restaurant_outlets_v` (only `is_public = true`)
   - `public_restaurant_menu_v` (public categories + items)

4. **Restaurant Reservation Requests**
   - Table for table reservations (separate from hotel room reservations)
   - Anon can INSERT, staff can read/manage

5. **Public Restaurant Orders**
   - Table for pickup/dine-in orders from public portal
   - Normalized `order_items` table (not JSONB)
   - `fulfillment_type`, `channel`, `contact_json`

6. **Gallery Images**
   - `restaurant_gallery_images` table linked to outlets

---

## 📋 Recommendation: Hybrid Approach

### Option A: Extend Existing `restaurants` Table (Simpler)
- ✅ Table already exists with `property_id`, `name`, `code`, `status`
- Add: `outlet_slug`, `is_public`, `description_public`, `hours_json`, `phone_public`, `address_public`, `cuisine_tags`
- Create new `restaurant_menu_categories` and `restaurant_menu_items` tables linked to `restaurant_id`

### Option B: Use Generic `outlets` Table (More Flexible)
- If `outlets` table exists, use it (check first!)
- Filter by `outlet_type = 'restaurant'`
- More flexible for future bar/cafe portals

### ⚠️ Decision Needed

**Check if `outlets` table exists in production:**
```sql
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'outlets'
);
```

**If YES**: Use `outlets` table, extend with public fields
**If NO**: Extend `restaurants` table with public fields

---

## Next Steps (Step 1)

Based on recon, we'll:

1. **Check if `outlets` exists** → Use it if yes, otherwise extend `restaurants`
2. **Create public restaurant schema**:
   - Extend outlet/restaurant table with public fields
   - Create `restaurant_menu_categories` linked to outlet
   - Create `restaurant_menu_items` linked to category
   - Create `restaurant_gallery_images` linked to outlet
   - Create `restaurant_reservation_requests` for table bookings
   - Create `restaurant_orders` + `restaurant_order_items` for public orders
3. **Create public views** with RLS
4. **Add RLS policies** for anon read (views only) and anon insert (requests/orders)

