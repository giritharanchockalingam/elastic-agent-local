# Public Portal CRUD Implementation Summary

## Overview

This document summarizes the work completed to fully wire the Hotel + Restaurant landing portal UI to the backend database, enforcing RBAC and RLS, and ensuring all content is live, accurate, and free of stale/junk data.

## ✅ Completed Work

### 1. Database Schema Enhancements

**Migration**: `supabase/migrations/20250130000000_complete_public_portal_schema.sql`

#### New Tables Created:
- **`room_images`**: Stores multiple images per room type with primary image flag and sort order
- **`room_inventory`**: Tracks daily availability, allocated, and blocked room counts per room type
- **`hotel_amenities`**: Property-specific amenities with public visibility flags
- **`media_library`**: Centralized media library for tenant assets (images, videos, documents)

#### Enhanced Tables:
- **`room_types`**: Added `is_public` flag for public portal visibility (already had `property_id`, `slug` from previous migrations)
- **`rooms`**: Already has `property_id` from enterprise schema
- **`restaurants`**: Already has public fields (`outlet_slug`, `is_public`, etc.) from restaurant portal migration
- **`restaurant_menu_items`**: Already has public fields and proper structure

#### Key Features:
- Proper tenant/property scoping on all tables
- Public visibility flags (`is_public`, `is_active`)
- Slug fields for URL-friendly routing
- Image management with primary image support and sort ordering
- Comprehensive indexes for performance

### 2. Row-Level Security (RLS) Policies

**All new tables have comprehensive RLS policies:**

- **Public Read Access**: Anonymous users can view public content (room types, images, amenities) for public properties
- **Staff Access**: Authenticated staff/managers/admins can manage content for their assigned properties
- **Property Scoping**: All policies use `user_has_property_access()` function to ensure users only access data for properties they have access to
- **Role-Based Write Access**: Only staff+ roles can create/update, only admins can delete

**Key Policies:**
- `room_images`: Public read via room types, staff can manage
- `room_inventory`: Staff-only (operational data)
- `hotel_amenities`: Public read for public amenities, staff can manage
- `media_library`: Staff can view/manage media for their tenant
- `room_types`: Updated to include `is_public` and `is_active` filters for public access

### 3. CRUD Service Layer

**File**: `src/lib/services/public-portal-crud.ts`

Comprehensive TypeScript service layer with RBAC enforcement:

#### Functions Implemented:

**Room Types:**
- `createRoomType()` - Create room type (Staff+)
- `updateRoomType()` - Update room type (Staff+)
- `deleteRoomType()` - Delete room type (Admin only)

**Room Images:**
- `createRoomImage()` - Upload/add room image (Staff+)
- `deleteRoomImage()` - Delete room image (Staff+)

**Hotel Amenities:**
- `createHotelAmenity()` - Create amenity (Staff+)
- `updateHotelAmenity()` - Update amenity (Staff+)
- `deleteHotelAmenity()` - Delete amenity (Admin only)

**Restaurant Menu Items:**
- `createRestaurantMenuItem()` - Create menu item (Staff+)
- `updateRestaurantMenuItem()` - Update menu item (Staff+)
- `deleteRestaurantMenuItem()` - Delete menu item (Admin only)

**Restaurant Menu Categories:**
- `createRestaurantMenuCategory()` - Create category (Staff+)
- `updateRestaurantMenuCategory()` - Update category (Staff+)
- `deleteRestaurantMenuCategory()` - Delete category (Admin only)

#### RBAC Enforcement:
- All functions check user authentication
- All functions verify user has required role (Staff/Manager/Admin)
- All functions verify user has property access via `user_has_property_access()`
- Proper error messages for unauthorized access

### 4. Enhanced Public Domain Fetchers

**File**: `src/lib/domain/public.ts`

Updated public data fetchers to use new schema:

#### Changes:
- `listRoomTypes()`: Now filters by `is_public` and `is_active`, fetches images from `room_images` table
- `getRoomTypeBySlug()`: Uses new schema, fetches images from `room_images` table with proper ordering
- Room images are now fetched from the dedicated `room_images` table instead of single `image_url` field
- Images are sorted by primary flag and sort order

## ⏳ Remaining Work

### 1. Audit Public Pages for Mock Data

**Files to Review:**
- `src/pages/public/PropertyLanding.tsx`
- `src/pages/public/RoomsListing.tsx`
- `src/pages/public/RoomTypeDetail.tsx`
- `src/pages/public/RestaurantDetail.tsx`
- `src/pages/public/RestaurantListing.tsx`
- `src/pages/public/TenantLanding.tsx`

**Actions Needed:**
- Remove any hardcoded/mock data
- Ensure all data comes from domain fetchers (`src/lib/domain/public.ts`, `src/lib/domain/restaurant.ts`)
- Remove placeholder images/text
- Replace any static arrays with live queries

### 2. Create Admin/Staff UI Components

**New Pages/Components Needed:**
- Room Types Management page (create/edit/delete room types)
- Room Images Management (upload/delete/set primary images)
- Hotel Amenities Management page
- Restaurant Menu Items Management (enhance existing `MenuManagement.tsx` if needed)
- Restaurant Menu Categories Management
- Media Library browser/uploader component

**Components to Create:**
- `src/pages/admin/RoomTypesManagement.tsx`
- `src/pages/admin/RoomImagesManagement.tsx`
- `src/pages/admin/HotelAmenitiesManagement.tsx`
- `src/components/admin/MediaLibraryPicker.tsx`

**Features:**
- Use CRUD service layer (`src/lib/services/public-portal-crud.ts`)
- Proper form validation
- Image upload to Supabase Storage
- Drag-and-drop for image ordering
- Primary image selection
- Soft delete (use `is_active` flag)

### 3. Media Library Management

**Implementation Needed:**
- Media upload component (Supabase Storage integration)
- Media browser/selector component
- Media attachment to entities (rooms, menu items, properties)
- Media deletion with usage checks (warn if in use)

**Storage Bucket**: `public-assets` (already created in migration)

### 4. Loading, Empty, Error States

**All Public Pages Need:**
- Loading skeletons/spinners during data fetch
- Empty states when no data (e.g., "No rooms available")
- Error states with user-friendly messages
- Unauthorized states for admin pages

**Components Already Available:**
- `src/components/public/SkeletonLoader.tsx`
- `src/components/public/EmptyState.tsx`
- `src/components/public/RouteErrorBoundary.tsx`

### 5. Image References Cleanup

**Actions Needed:**
- Audit all image references in public pages
- Ensure images come from:
  - `room_images` table for room types
  - `public_property_images` table for properties
  - `restaurant_gallery_images` table for restaurants
  - `restaurant_menu_items.image_url` for menu items
- Remove hardcoded image paths
- Add fallback placeholder images where appropriate

## Database Schema Reference

### Room Types with Images

```sql
-- Room type with images
SELECT rt.*, 
  ARRAY_AGG(ri.image_url ORDER BY ri.is_primary DESC, ri.sort_order) FILTER (WHERE ri.id IS NOT NULL) as images
FROM room_types rt
LEFT JOIN room_images ri ON ri.room_type_id = rt.id
WHERE rt.property_id = ? 
  AND rt.is_public = true 
  AND rt.is_active = true
GROUP BY rt.id;
```

### Property Images

```sql
-- Property images from public_property_images
SELECT * FROM public_property_images
WHERE property_id = ?
ORDER BY sort_order;
```

### Restaurant Gallery

```sql
-- Restaurant gallery images
SELECT * FROM restaurant_gallery_images
WHERE restaurant_id = ?
ORDER BY sort_order;
```

## RBAC Roles Reference

- **Visitor** (anon): Read-only public data
- **Guest** (authenticated, guest role): Same as visitor + manage own bookings
- **Staff** (staff role): CRUD on content for assigned properties
- **Manager** (manager role): All staff + approvals/higher-risk operations
- **Admin** (admin/super_admin role): Tenant-wide configuration

## Testing Checklist

- [ ] Public pages load without errors
- [ ] Room types display with images from database
- [ ] Restaurant menus display correctly
- [ ] Admin pages enforce RBAC (redirect if unauthorized)
- [ ] CRUD operations work for staff/admins
- [ ] RLS policies prevent unauthorized access
- [ ] Images load correctly from database/storage
- [ ] Empty states display when no data
- [ ] Error states display on failures

## Next Steps

1. **Run the migration**: Apply `20250130000000_complete_public_portal_schema.sql`
2. **Test public pages**: Verify data loads correctly
3. **Create admin UI**: Build management pages using CRUD service layer
4. **Implement media library**: Add upload/browse functionality
5. **Audit and cleanup**: Remove all mock data and hardcoded values
6. **Add proper states**: Loading, empty, error states throughout

## Files Modified/Created

### New Files:
- `supabase/migrations/20250130000000_complete_public_portal_schema.sql`
- `src/lib/services/public-portal-crud.ts`
- `docs/PUBLIC_PORTAL_CRUD_IMPLEMENTATION.md`

### Modified Files:
- `src/lib/domain/public.ts` - Enhanced to use new schema

## Notes

- All RLS policies use `user_has_property_access()` function which checks:
  - Super admin access (all properties)
  - User property assignments
  - Staff table associations
- Public pages should use domain fetchers (`src/lib/domain/public.ts`, `src/lib/domain/restaurant.ts`)
- Admin pages should use CRUD service layer (`src/lib/services/public-portal-crud.ts`)
- Image uploads should go to Supabase Storage bucket `public-assets`
- Use soft delete (`is_active = false`) for user-facing entities instead of hard deletes

