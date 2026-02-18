# Public Portal Reconstruction Plan

## Overview
Complete reconstruction of the public portal to use canonical image storage structure and achieve world-class UI/UX standards.

## ✅ Completed: Phase 1 - Core Infrastructure

### 1. Canonical Storage URL Helper
- **File:** `src/lib/images/storageUrl.ts`
- **Purpose:** Generate Supabase Storage URLs from `storage_bucket` + `storage_path`
- **Features:**
  - `getStoragePublicUrl()` - Generate URL from canonical paths
  - `getImageUrl()` - With fallback to `image_url` for backward compatibility

### 2. Image Resolver Updates
- **File:** `src/lib/images/imageResolver.ts`
- **Changes:**
  - All queries now select `storage_bucket` and `storage_path` columns
  - All functions use `getImageUrl()` helper for URL generation
  - Updated functions:
    - `getRoomTypeHero()` - Room type hero images
    - `getRoomTypeGallery()` - Room type gallery
    - `getPropertyHero()` - Property hero images
    - `getPropertyGallery()` - Property galleries by category
    - `getVenueHero()` - Venue hero images (dining/wellness/events)
    - `getVenueGallery()` - Venue galleries

### 3. Domain Functions Updates
- **File:** `src/lib/domain/public.ts`
- **Changes:**
  - `getPropertyImages()` - Uses canonical storage structure
  - `getRoomTypeBySlug()` - Room images use canonical structure
  - `getHarvestedImages()` - Uses canonical structure

## 🚧 Next Steps: Phase 2 - Database Migration

### Required Migration
Run the SQL migration to add `storage_bucket` and `storage_path` columns:
```bash
# File: supabase/migrations/20250131000003_add_storage_path_columns.sql
# Run in Supabase Dashboard > SQL Editor
```

### Upload Images to Storage
Once migration is complete, upload images:
```bash
node scripts/migrate-images-to-supabase.mjs --only-missing
```

## 🎨 Phase 3 - UI/UX Reconstruction (TODO)

### Module 1: Stay (Rooms)
**Pages to Update:**
- `src/pages/public/RoomsListing.tsx`
- `src/pages/public/RoomTypeDetail.tsx`
- `src/pages/public/RoomsGallery.tsx`

**Requirements:**
- Modern, clean design matching world-class hotels
- High-quality image galleries using canonical URLs
- Responsive grid layouts
- Smooth animations and transitions
- Mobile-optimized experience

### Module 2: Dining
**Pages to Update:**
- `src/pages/public/RestaurantListing.tsx`
- `src/pages/public/RestaurantDetailNew.tsx`
- `src/pages/public/RestaurantMenu.tsx`

**Requirements:**
- Elegant restaurant showcase
- Menu display with images
- Reservation integration
- Food photography galleries

### Module 3: Wellness
**Pages to Update:**
- `src/pages/public/Wellness.tsx`

**Requirements:**
- Serene, calming design
- Spa/wellness image galleries
- Treatment/service listings
- Relaxing color palette and typography

### Module 4: Events
**Pages to Update:**
- `src/pages/public/Events.tsx`
- `src/pages/public/EventSpaceDetail.tsx`

**Requirements:**
- Professional event space showcase
- Capacity and amenity displays
- Event gallery images
- Inquiry/booking integration

## 📋 Design Principles

1. **Photorealistic Images**
   - All images use canonical storage paths
   - No fallback placeholders (return null if no image)
   - High-quality, optimized images

2. **World-Class UI/UX**
   - Clean, minimalist design
   - Smooth animations
   - Fast loading times
   - Mobile-first responsive design
   - Accessibility (WCAG 2.1 AA)

3. **Performance**
   - Image lazy loading
   - Optimized image formats (WebP where possible)
   - Efficient caching strategies

4. **Consistency**
   - Unified design language across modules
   - Consistent navigation
   - Brand-aligned color schemes

## 🔄 Migration Strategy

1. **Phase 1:** ✅ Core infrastructure (image URL generation)
2. **Phase 2:** Database migration + image upload (pending)
3. **Phase 3:** UI/UX reconstruction module by module
4. **Phase 4:** Testing and optimization

## 📝 Notes

- TypeScript errors are expected until Supabase types are regenerated
- All image queries now prefer `storage_path` over `image_url`
- Backward compatibility: Falls back to `image_url` if `storage_path` is missing
- Canonical structure: `images/{category}/{filename}` (e.g., `images/rooms/v3-grand-rooms-deluxe-01.jpg`)
