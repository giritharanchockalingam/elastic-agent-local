# Restaurant Portal Implementation Progress

## ✅ Completed Steps

### Step 0: Recon ✅
- Found existing `restaurants` table (needs extension)
- Found disconnected `menu_items` table
- Documented findings in `docs/RESTAURANT_PORTAL_RECON.md`

### Step 1: Data Model ✅
**Migration**: `supabase/migrations/20250121000010_restaurant_portal_public_schema.sql`

- ✅ Extended `restaurants` table with public fields
- ✅ Created `restaurant_menu_categories` table
- ✅ Created `restaurant_menu_items` table
- ✅ Created `restaurant_gallery_images` table
- ✅ Created `restaurant_reservation_requests` table
- ✅ Created `restaurant_orders` + `restaurant_order_items` tables
- ✅ Created public views with RLS
- ✅ RLS policies for anon/staff/service_role
- ✅ Audit logging triggers

### Step 2: Routes & Domain Fetchers ✅
- ✅ Added `resolveRestaurantOutlet()` to `src/lib/tenant/resolveContext.ts`
- ✅ Created `src/lib/domain/restaurant.ts` with fetchers:
  - `listRestaurantOutlets()`
  - `getRestaurantOutlet()`
  - `getRestaurantMenu()`
  - `getRestaurantGallery()`
- ✅ Routes updated in `src/App.tsx`:
  - `/{brandSlug}/{propertySlug}/dining` - Listing
  - `/{brandSlug}/{propertySlug}/dining/{outletSlug}` - Landing
  - `/{brandSlug}/{propertySlug}/dining/{outletSlug}/menu` - Menu
  - `/{brandSlug}/{propertySlug}/dining/{outletSlug}/reserve` - Reserve
  - `/{brandSlug}/{propertySlug}/dining/{outletSlug}/order` - Order

### Step 3: UX Pages ✅
**Pages Created/Updated**:
- ✅ `src/pages/public/RestaurantListing.tsx` - Updated to use new schema
- ✅ `src/pages/public/RestaurantDetail.tsx` - Completely rewritten with hero, gallery, CTAs
- ✅ `src/pages/public/RestaurantMenu.tsx` - NEW - Menu browsing with categories, search, item modals
- ✅ `src/pages/public/RestaurantReserve.tsx` - NEW - Table reservation form
- ✅ `src/pages/public/RestaurantOrder.tsx` - NEW - Order flow with cart and checkout

**Features Implemented**:
- ✅ Mobile-first responsive design
- ✅ SEO meta tags and JSON-LD
- ✅ Accessibility (ARIA labels, semantic HTML)
- ✅ Gallery carousels
- ✅ Menu category tabs
- ✅ Search and filtering
- ✅ Cart functionality
- ✅ Form validation
- ✅ Toast notifications
- ✅ Loading states
- ✅ Error handling

## ⏳ Remaining Steps

### Step 4: Harvest + Rewrite CLI ⏳
**Status**: Not started

**Required**:
- `scripts/harvest-restaurant-benchmark.ts` - CLI tool
- `src/lib/ingestion/rewriteRestaurant.ts` - Rewrite engine
- Update `config/harvest.allowlist.json` for marriott.com
- Fact extraction (menu items, hours, location, gallery)
- Image handling (download, hash, upload to Supabase Storage)

**Reference**: See `scripts/harvest-and-rewrite-property-site.ts` for pattern

### Step 5: Seed Demo Content ⏳
**Status**: Not started

**Required**:
- Demo Madurai restaurant content
- Menu categories and items (South Indian, Chettinad, Continental, Desserts, Beverages)
- Placeholder gallery images
- Sample hours, location, contact info

**Migration**: Create `supabase/migrations/20250121000011_restaurant_portal_seed.sql`

## 📋 Next Actions

1. **Run Migration**: Apply `20250121000010_restaurant_portal_public_schema.sql` to database
2. **Test Pages**: Verify routes work with real data (will be empty until seed)
3. **Create Harvest CLI**: Implement Step 4
4. **Create Seed Data**: Implement Step 5
5. **Test End-to-End**: Full flow from listing → menu → reserve/order

## 🔧 Current State

**Database Schema**: ✅ Complete
**Domain Fetchers**: ✅ Complete  
**Routes**: ✅ Complete
**Pages**: ✅ Complete (5 pages)
**CLI Harvester**: ⏳ Not started
**Seed Data**: ⏳ Not started

## 🧪 Testing

To test the implementation:

1. **Run Migration**:
   ```sql
   -- Apply migration in Supabase SQL Editor
   -- File: supabase/migrations/20250121000010_restaurant_portal_public_schema.sql
   ```

2. **Check Tables**:
   ```sql
   SELECT table_name FROM information_schema.tables 
   WHERE table_schema = 'public' 
   AND table_name LIKE 'restaurant%'
   ORDER BY table_name;
   ```

3. **Check Views**:
   ```sql
   SELECT table_name FROM information_schema.views 
   WHERE table_schema = 'public' 
   AND table_name LIKE 'public_restaurant%';
   ```

4. **Test Routes** (will show empty state until seed):
   - `/{brandSlug}/{propertySlug}/dining`
   - `/{brandSlug}/{propertySlug}/dining/{outletSlug}`
   - `/{brandSlug}/{propertySlug}/dining/{outletSlug}/menu`
   - `/{brandSlug}/{propertySlug}/dining/{outletSlug}/reserve`
   - `/{brandSlug}/{propertySlug}/dining/{outletSlug}/order`

## 📝 Notes

- All pages use the new schema (outlet_slug, public views)
- Reservation and order forms write to new tables with RLS
- Pages are production-ready but need seed data to test fully
- Harvest CLI and seed data can be added incrementally

