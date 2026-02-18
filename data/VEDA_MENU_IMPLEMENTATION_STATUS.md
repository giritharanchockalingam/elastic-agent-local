# Veda Restaurant Menu Implementation Status

## Summary

This document tracks the implementation status of the three main tasks for the Veda restaurant menu and data model.

## Task 1: ✅ COMPLETE - Ensure Veda Order Page is 100% DB-Driven

**Status:** ✅ **VERIFIED - Already 100% DB-Driven**

**Findings:**
- `RestaurantOrderUnified.tsx` (the order page at `/property/v3-grand-hotel/dining/veda/order`) is already fully database-driven
- Uses `getRestaurantMenu()` from `@/lib/domain/restaurant.ts`
- Queries `restaurant_menu_v` view which joins:
  - `restaurant_menu_items` table
  - `restaurant_menu_categories` table
  - `restaurants` table
  - `properties_view` (for security)
- No hardcoded menu items found
- All menu data (items, categories, prices, images, dietary tags) comes from the database
- Prices are stored in `price_cents` (integer) and converted to display currency

**Data Flow:**
```
RestaurantOrderUnified.tsx
  → getRestaurantMenu(ctx, outletId)
    → restaurant_menu_v view
      → restaurant_menu_items (is_public = true)
      → restaurant_menu_categories (is_public = true)
```

**Verification:**
- ✅ All menu items come from `restaurant_menu_items` table
- ✅ Categories come from `restaurant_menu_categories` table
- ✅ Prices are stored as `price_cents` in database
- ✅ Images are stored in `image_url` column
- ✅ Dietary tags are stored in `dietary_tags` array column
- ✅ Currency is stored in `currency` column (default: 'INR')

**No action required** - Task 1 is complete.

---

## Task 2: 🔄 IN PROGRESS - Fix & Complete Veda Menu Highlights Classification

**Status:** 🔄 **IN PROGRESS**

### Current State

**Menu Highlights Section (RestaurantDetailNew.tsx):**
- Currently uses **gallery images** (`categorizedGalleryImages`) from `useVenueGallery` hook
- Images are categorized by filename/storage path patterns (appetizers, main-course, desserts, drinks)
- **NOT linked to actual menu items in the database**
- This means:
  - Menu Highlights show images, but clicking doesn't link to actual menu items
  - Items shown in highlights may not exist as menu items
  - No prices or descriptions shown in highlights

### Changes Made

1. **Database Schema:**
   - ✅ Created migration: `20250201000001_add_is_highlight_to_menu_items.sql`
   - ✅ Adds `is_highlight` BOOLEAN column to `restaurant_menu_items` table
   - ✅ Adds index on `is_highlight` for efficient queries
   - ✅ Default value: `FALSE`

2. **TypeScript Interfaces:**
   - ✅ Added `is_highlight?: boolean` to `MenuItem` interface in `diningService.ts`
   - ✅ Added `isHighlight?: boolean` to `RestaurantMenuItem` interface in `restaurant.ts`

3. **Domain Service:**
   - ✅ Created `getHighlightedMenuItems()` function in `restaurant.ts`
   - ✅ Queries `restaurant_menu_items` table with `is_highlight = true`
   - ✅ Returns actual menu items (not just images)
   - ✅ Includes categories, prices, descriptions, dietary tags, images

### Remaining Work

1. **Update RestaurantDetailNew.tsx:**
   - [ ] Replace `categorizedGalleryImages` logic with `getHighlightedMenuItems()`
   - [ ] Query highlighted menu items from database
   - [ ] Group highlighted items by category (appetizers, main-course, desserts, beverages)
   - [ ] Display actual menu items with:
     - Item name
     - Description
     - Price
     - Image (from `image_url` column)
     - Dietary tags
   - [ ] Update Menu Highlights section to use menu items instead of gallery images

2. **Category Mapping:**
   - [ ] Ensure menu categories match the display categories:
     - Appetizers / Starters
     - Main Course
     - Breads / Rotis
     - Desserts
     - Beverages / Drinks
   - [ ] Verify category names in `restaurant_menu_categories` table
   - [ ] Map DB categories to display categories if needed

3. **Data Verification:**
   - [ ] Verify all highlighted items exist in `restaurant_menu_items` table
   - [ ] Ensure all highlighted items have correct categories
   - [ ] Ensure all highlighted items have prices set
   - [ ] Mark items as `is_highlight = true` in database

### Recommended Approach

1. **Use `getHighlightedMenuItems()` function:**
   ```typescript
   const { data: highlightedItems } = useQuery({
     queryKey: ['highlighted-menu-items', outlet?.id],
     queryFn: async () => {
       if (!context || !outlet) return [];
       return getHighlightedMenuItems(context, outlet.id);
     },
     enabled: !!context && !!outlet,
   });
   ```

2. **Group by category:**
   - Use `categoryName` from menu items
   - Map DB category names to display categories
   - Group items: appetizers, main-course, breads, desserts, beverages

3. **Display in Menu Highlights:**
   - Show actual menu items (not gallery images)
   - Display name, description, price, image
   - Link to order page or show in modal

---

## Task 3: 📋 PENDING - Review Data Model (Restaurant/Bar/Spa as Sub-Properties)

**Status:** 📋 **PENDING - Analysis Needed**

### Current Schema Analysis

**Properties Table:**
- `properties` table contains the main hotel (V3 Grand Hotel)
- Has `property_id` (UUID primary key)
- Has `property_slug` for URL routing
- Has `tenant_id` (FK to tenants table)

**Restaurants Table:**
- `restaurants` table represents outlets (Veda, Ember, etc.)
- Has `property_id` (FK to properties) ✅
- Has `outlet_slug` for URL routing ✅
- Has `is_public`, `status`, etc.
- **This is already structured as sub-property/outlet model** ✅

**Revenue Attribution:**
- `restaurant_orders` table has:
  - `restaurant_id` (FK to restaurants) ✅
  - `property_id` (FK to properties) ✅
  - `tenant_id` (FK to tenants) ✅
- This allows revenue aggregation:
  - By outlet (restaurant_id)
  - By property (property_id)
  - By tenant (tenant_id)

### Current Structure Assessment

✅ **Good:**
- Restaurants are already modeled as sub-properties (via `property_id` FK)
- Orders link to both `restaurant_id` and `property_id`
- Revenue can be aggregated at multiple levels

⚠️ **Considerations:**
- Need to verify spa/bar tables follow same pattern
- Need to verify all revenue-bearing tables (orders, bookings, spa bookings) link to outlets
- May want to add `outlet_type` enum column for clarity:
  - 'restaurant'
  - 'bar'
  - 'spa'
  - 'pool_bar'
  - 'event_space'

### Recommended Data Model Review

1. **Verify all outlet types:**
   - [ ] Check if spa/bar have separate tables or use restaurants table
   - [ ] Check if spa bookings link to spa outlet
   - [ ] Check if bar orders link to bar outlet

2. **Add outlet_type if needed:**
   - [ ] Add `outlet_type` column to restaurants table (or create unified outlets table)
   - [ ] Allows filtering: restaurant vs bar vs spa

3. **Verify revenue attribution:**
   - [ ] Ensure all orders/bookings link to outlet_id
   - [ ] Ensure revenue aggregates correctly by outlet
   - [ ] Test reporting queries

4. **Documentation:**
   - [ ] Create ER diagram
   - [ ] Document revenue flow
   - [ ] Document aggregation patterns

### Industry Standard Model

**Typical Hotel Practice:**
```
Property (V3 Grand Hotel)
  ├── Outlet: Veda (restaurant)
  │     └── Orders → revenue_center: "VEDA"
  ├── Outlet: Ember (bar)
  │     └── Orders → revenue_center: "EMBER"
  ├── Outlet: Spa (wellness)
  │     └── Bookings → revenue_center: "SPA"
  └── Outlet: Pool Bar
        └── Orders → revenue_center: "POOL_BAR"
```

**Current Model:**
```
properties
  └── restaurants (property_id FK)
        └── restaurant_orders (restaurant_id FK, property_id FK)
```

**Assessment:** ✅ Current model already follows industry standards!

---

## Next Steps

1. **Task 2 Completion:**
   - Update RestaurantDetailNew to use `getHighlightedMenuItems()`
   - Replace gallery images with actual menu items
   - Test menu highlights display

2. **Task 3 Analysis:**
   - Review spa/bar table structure
   - Verify revenue attribution
   - Document data model

3. **Data Seeding:**
   - Mark appropriate menu items as `is_highlight = true`
   - Verify categories are correct
   - Verify prices are set

---

## Files Changed

1. `supabase/migrations/20250201000001_add_is_highlight_to_menu_items.sql` - Migration to add is_highlight column
2. `src/services/data/diningService.ts` - Added `is_highlight` to MenuItem interface
3. `src/lib/domain/restaurant.ts` - Added `isHighlight` to RestaurantMenuItem interface, created `getHighlightedMenuItems()` function

## Files To Change

1. `src/pages/public/RestaurantDetailNew.tsx` - Update Menu Highlights section to use menu items instead of gallery images
