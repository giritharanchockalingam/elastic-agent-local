# Events Images Display Fix

## Problem
- 24 total images (6 old + 18 new)
- Images are in database but showing as placeholders
- Each space should show 8 unique images but showing duplicates/placeholders

## Root Cause
The image filtering logic wasn't correctly matching images to their spaces because:
1. `imageKey` wasn't being passed correctly from resolver to component
2. Filtering was too strict and missing space-specific images
3. Query wasn't prioritizing category-based lookup (now that categories exist)

## Fixes Applied

### 1. Updated Image Resolver (`src/lib/images/imageResolver.ts`)
- **Added category-based query**: Now queries by `category IN ('wedding', 'banquet', 'meeting')` first (most efficient)
- **Added image_key pattern fallback**: Still queries by patterns for backward compatibility
- **Preserved `imageKey` and `sortOrder`**: Both are now included in `ResolvedImage` interface
- **Updated category derivation**: Better logic to map image_key to category (grand-hall → wedding, pavilion → banquet, forum → meeting)

### 2. Updated EventSpaceDetail Filtering (`src/pages/public/EventSpaceDetail.tsx`)
- **Prioritizes exact space slug matches**: Images with space slug in `image_key` (e.g., `events/grand-hall/...`) are shown first
- **Less strict filtering**: Shows images even if they don't perfectly match, as long as they're event-related
- **Better sorting**: Sorts by space slug presence first, then by `sort_order`
- **Improved imageKey extraction**: Uses `imageKey`, `storagePath`, or `image_url` as fallback

### 3. Updated Hook Signature (`src/hooks/public/useResolvedImages.ts`)
- **Added `enabled` parameter**: Properly passes through to `getVenueGallery`
- **Preserves `preferredCategories`**: Allows space-specific category filtering

## Expected Behavior

After these fixes:
- **Grand Hall page** (`/property/v3-grand-hotel/events/grand-hall`):
  - Shows images with `image_key` containing `grand-hall` OR category = `'wedding'`
  - Prioritizes exact matches (images with `events/grand-hall/...` in key)
  
- **Pavilion page** (`/property/v3-grand-hotel/events/pavilion`):
  - Shows images with `image_key` containing `pavilion` OR category = `'banquet'`
  - Prioritizes exact matches (images with `events/pavilion/...` in key)
  
- **Forum page** (`/property/v3-grand-hotel/events/forum`):
  - Shows images with `image_key` containing `forum` OR category = `'meeting'`
  - Prioritizes exact matches (images with `events/forum/...` in key)

## Verification

Check browser console for:
- `[EventSpaceDetail]` warnings if no space-specific images found
- `[ImageResolver]` warnings if queries fail

Check database:
```sql
SELECT category, image_key, sort_order 
FROM public_property_images 
WHERE property_id = '00000000-0000-0000-0000-000000000111'
  AND image_key LIKE 'events/%'
ORDER BY category, sort_order;
```

Should show:
- `wedding` category: 6-8 images with `events/grand-hall/...` keys
- `banquet` category: 6-8 images with `events/pavilion/...` keys  
- `meeting` category: 6-8 images with `events/forum/...` keys

## Next Steps

1. **Clear browser cache** and refresh the Events pages
2. **Check browser console** for any errors or warnings
3. **Verify images load** on each space page
4. If still showing placeholders, check:
   - Image URLs are accessible
   - Storage bucket permissions
   - RLS policies allow reading images
