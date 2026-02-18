# Restaurant Portal - Step 1 Complete ✅

## Summary

Step 1 (Data Model) is complete. Created comprehensive restaurant portal schema with public views and RLS policies.

## Migration Created

**File**: `supabase/migrations/20250121000010_restaurant_portal_public_schema.sql`

## What Was Created

### 1. Extended `restaurants` Table
Added public-facing fields:
- `outlet_slug` (TEXT) - URL-friendly identifier
- `is_public` (BOOLEAN) - Visibility flag
- `description_public` (TEXT) - Public description
- `hours_json` (JSONB) - Structured operating hours
- `phone_public` (TEXT) - Public phone number
- `address_public` (TEXT) - Public address
- `cuisine_tags` (TEXT[]) - Array of cuisine tags for filtering

**Constraints**:
- Unique constraint on `(property_id, outlet_slug)`
- Indexes on `outlet_slug` and `is_public`

### 2. Restaurant Menu Tables
- **`restaurant_menu_categories`** - Categories linked to restaurants
- **`restaurant_menu_items`** - Menu items linked to categories and restaurants
  - Supports: price_cents, currency, dietary_tags, spice_level, image_url
  - Public visibility flags

### 3. Restaurant Gallery
- **`restaurant_gallery_images`** - Gallery images linked to restaurants
  - Supports: image_url, alt_text, category, sort_order, dimensions

### 4. Restaurant Reservation Requests
- **`restaurant_reservation_requests`** - Table booking requests
  - Fields: requested_date, requested_time, party_size, contact info
  - Status tracking: new, confirmed, seated, cancelled, no-show, completed

### 5. Restaurant Orders
- **`restaurant_orders`** - Public portal orders (pickup/dine-in)
  - Fields: order_number, status, channel, fulfillment_type, totals_json, contact_json
  - Status tracking: pending, confirmed, preparing, ready, completed, cancelled
- **`restaurant_order_items`** - Normalized order line items
  - Links to menu items with snapshots for historical accuracy

### 6. Public Views
Created safe public read surfaces:
- **`public_restaurant_outlets_v`** - Public restaurant outlets only
- **`public_restaurant_menu_v`** - Public menu items only
- **`public_restaurant_gallery_v`** - Public gallery images only

All views filter by `is_public = TRUE` and join with `public_properties` to ensure tenant/property scoping.

### 7. RLS Policies
- **Public Read**: Anon can SELECT from views only (no direct table access)
- **Public Write**: Anon can INSERT into `restaurant_reservation_requests` and `restaurant_orders` (no SELECT)
- **Staff Access**: Authenticated staff can view/manage reservation requests and orders
- **Service Role**: Full access for ingestion CLI

### 8. Audit Logging
- Triggers on `restaurant_reservation_requests` and `restaurant_orders` INSERT
- Logs to `audit_logs` table (if exists)
- Action types: `restaurant_reservation_request_created`, `restaurant_order_created`

## Security Features

✅ **RLS Enabled** on all tables
✅ **Public Views** for safe anon access
✅ **No Direct Table Access** for anon role
✅ **Rate Limiting** infrastructure already exists (reuse from public portal)
✅ **Audit Logging** on all public write actions
✅ **Service Role Policies** for ingestion CLI
✅ **Tenant/Property Scoping** enforced via public_properties join

## Next Steps (Step 2)

1. Create `resolveRestaurantOutlet` function in `src/lib/tenant/resolveContext.ts` (or new file)
2. Create restaurant domain fetchers in `src/lib/domain/restaurant.ts`:
   - `listRestaurantOutlets(ctx)` - List outlets for a property
   - `getRestaurantOutlet(ctx, outletSlug)` - Get single outlet details
   - `getRestaurantMenu(ctx, outletId)` - Get menu with categories
   - `getRestaurantGallery(ctx, outletId)` - Get gallery images
3. Create routes in `src/App.tsx`:
   - `/{brandSlug}/{propertySlug}/dining` - List outlets
   - `/{brandSlug}/{propertySlug}/dining/{outletSlug}` - Outlet landing
   - `/{brandSlug}/{propertySlug}/dining/{outletSlug}/menu` - Menu page
   - `/{brandSlug}/{propertySlug}/dining/{outletSlug}/reserve` - Reservation form
   - `/{brandSlug}/{propertySlug}/dining/{outletSlug}/order` - Order flow
4. Create page components (Step 3)

## Testing

To test the schema:

```sql
-- Check if tables were created
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name LIKE 'restaurant%'
ORDER BY table_name;

-- Check if views were created
SELECT table_name 
FROM information_schema.views 
WHERE table_schema = 'public' 
AND table_name LIKE 'public_restaurant%';

-- Test public view (will be empty until data is added)
SELECT * FROM public_restaurant_outlets_v LIMIT 5;
```

