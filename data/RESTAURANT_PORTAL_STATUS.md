# Restaurant Portal Implementation Status

## ✅ Completed

### Step 1: Data Model ✅
**Migration**: `supabase/migrations/20250121000010_restaurant_portal_public_schema.sql`

- ✅ Extended `restaurants` table with public fields (`outlet_slug`, `is_public`, `description_public`, `hours_json`, `phone_public`, `address_public`, `cuisine_tags`)
- ✅ Created `restaurant_menu_categories` table
- ✅ Created `restaurant_menu_items` table
- ✅ Created `restaurant_gallery_images` table
- ✅ Created `restaurant_reservation_requests` table (table bookings)
- ✅ Created `restaurant_orders` table (public portal orders)
- ✅ Created `restaurant_order_items` table (normalized order items)
- ✅ Created public views: `public_restaurant_outlets_v`, `public_restaurant_menu_v`, `public_restaurant_gallery_v`
- ✅ RLS policies for anon read (views only), anon insert (reservations/orders), staff manage
- ✅ Audit logging triggers

### Step 2: Routes & Domain Fetchers ✅ (Partial)

**Files Created/Modified**:
- ✅ `src/lib/tenant/resolveContext.ts` - Added `resolveRestaurantOutlet()` function
- ✅ `src/lib/domain/restaurant.ts` - Created restaurant domain fetchers:
  - `listRestaurantOutlets(ctx)` - List outlets for property
  - `getRestaurantOutlet(ctx, outletSlug)` - Get single outlet
  - `getRestaurantMenu(ctx, outletId)` - Get menu with categories
  - `getRestaurantGallery(ctx, outletId)` - Get gallery images

**Routes Needed** (Not yet implemented):
- ⏳ `/{brandSlug}/{propertySlug}/dining` - List outlets
- ⏳ `/{brandSlug}/{propertySlug}/dining/{outletSlug}` - Outlet landing
- ⏳ `/{brandSlug}/{propertySlug}/dining/{outletSlug}/menu` - Menu page
- ⏳ `/{brandSlug}/{propertySlug}/dining/{outletSlug}/reserve` - Reservation form
- ⏳ `/{brandSlug}/{propertySlug}/dining/{outletSlug}/order` - Order flow

## ⏳ Pending

### Step 3: UX Pages
- ⏳ Restaurant outlet listing page (dining index)
- ⏳ Restaurant outlet landing page (hero, gallery, hours, CTAs)
- ⏳ Menu browsing page (categories, filters, item modals)
- ⏳ Reservation request form (date/time/party size)
- ⏳ Order flow (cart, checkout, confirmation)

### Step 4: Harvest + Rewrite CLI
- ⏳ `scripts/harvest-restaurant-benchmark.ts` - CLI tool
- ⏳ `src/lib/ingestion/rewriteRestaurant.ts` - Rewrite engine
- ⏳ Allowlist configuration for marriott.com
- ⏳ Fact extraction (menu items, hours, location, gallery)

### Step 5: Seed Demo Content
- ⏳ Demo Madurai restaurant content
- ⏳ Menu categories and items (South Indian, Chettinad, Continental, Desserts, Beverages)
- ⏳ Placeholder gallery images

## 🔧 Current State

**Database Schema**: ✅ Complete and ready
**Domain Fetchers**: ✅ Complete
**Routes**: ⏳ Need to be added to `App.tsx`
**Pages**: ⏳ Need to be created
**CLI Harvester**: ⏳ Not started
**Seed Data**: ⏳ Not started

## 📋 Next Steps

1. **Complete Step 2**: Add routes to `App.tsx` for restaurant portal
2. **Start Step 3**: Create restaurant portal pages (start with outlet listing and landing)
3. **Step 4**: Build harvest CLI and rewrite engine
4. **Step 5**: Create seed data for demo restaurant

## 🧪 Testing

To test the schema, run the migration and check:

```sql
-- Check tables
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name LIKE 'restaurant%'
ORDER BY table_name;

-- Check views
SELECT table_name FROM information_schema.views 
WHERE table_schema = 'public' 
AND table_name LIKE 'public_restaurant%';

-- Test public view (empty until data added)
SELECT * FROM public_restaurant_outlets_v LIMIT 5;
```

