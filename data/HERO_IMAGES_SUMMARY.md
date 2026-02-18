# Hero Images System - Implementation Summary

## Files Created

### Configuration
1. **`src/config/heroImages.ts`**
   - Hero image registry configuration
   - Page keys: `home`, `rooms`, `dining`, `bar`, `spa`, `events`, `experiences`, `about`, `offers`
   - Maps pages to database categories and rotation modes

### Services
2. **`src/services/imageResolver.ts`**
   - Image URL resolution abstraction
   - Preloading utilities
   - Future-ready for local assets

### Components
3. **`src/components/public/HeroBanner.tsx`**
   - Main hero banner component
   - Handles single, carousel, and rotation modes
   - Integrates with database queries

4. **`src/components/public/HeroCarousel.tsx`**
   - Auto-rotating carousel with swipe support
   - Thumbnail strip on desktop
   - Dots indicator on mobile

5. **`src/components/public/HeroImageOverlay.tsx`**
   - Text overlay with gradient for readability
   - Supports title, subtitle, description, CTA
   - Alignment options (left, center, right)

## Files Modified

### Public Pages Updated
1. **`src/pages/public/Index.tsx`** - Homepage carousel
2. **`src/pages/public/RoomsListing.tsx`** - Rooms rotation
3. **`src/pages/public/RestaurantDetail.tsx`** - Dining single image
4. **`src/pages/public/Events.tsx`** - Events single image
5. **`src/pages/public/Wellness.tsx`** - Spa rotation
6. **`src/pages/public/Experiences.tsx`** - Experiences single image
7. **`src/pages/public/About.tsx`** - About rotation
8. **`src/pages/public/Offers.tsx`** - Offers single image
9. **`src/pages/public/PropertyLanding.tsx`** - Property landing carousel

## How to Add New Hero Images

### Step 1: Upload to Supabase Storage

1. Upload image to Supabase Storage bucket: `property-images`
2. Use naming convention: `v3-grand-hotel-{category}-{number}.jpg`
   - Examples:
     - `v3-grand-hotel-hero-11.jpg` (for homepage)
     - `v3-grand-hotel-lobby-02.jpg` (for about page)
     - `v3-grand-hotel-dining-02.jpg` (for dining page)

### Step 2: Insert into Database

```sql
INSERT INTO public_property_images (
  property_id,
  image_url,
  alt_text,
  category,
  sort_order,
  tenant_id,
  image_key
) VALUES (
  '00000000-0000-0000-0000-000000000111', -- V3 Grand Hotel ID
  'https://your-project.supabase.co/storage/v1/object/public/property-images/v3-grand-hotel-hero-11.jpg',
  'V3 Grand Hotel - Hero image 11',
  'exterior', -- Category determines which pages show it
  1, -- Lower = higher priority (0 = primary)
  'your-tenant-id',
  'v3-grand-hotel-hero-11'
);
```

### Step 3: Images Automatically Appear

The hero system automatically:
- Fetches images by category from database
- Sorts by `sort_order` (lower = higher priority)
- Displays according to page's rotation mode

## Page Configuration

| Page | Category | Mode | Description |
|------|----------|------|-------------|
| `home` | `exterior` | `carousel` | Auto-rotate all hero images |
| `rooms` | `room` | `rotation` | 3-image rotation |
| `dining` | `restaurant` | `single` | Single hero image |
| `bar` | `bar` | `single` | Single hero image |
| `spa` | `spa` | `rotation` | 3-image rotation |
| `events` | `events` | `single` | Single hero image |
| `experiences` | `exterior` | `single` | Single hero image |
| `about` | `lobby` | `rotation` | 3-image rotation |
| `offers` | `exterior` | `single` | Single hero image |

## Usage Example

```tsx
import { HeroBanner } from '@/components/public/HeroBanner';

<HeroBanner
  pageKey="home"
  propertySlug="v3-grand-hotel"
  title="Welcome"
  subtitle="Experience Luxury"
  description="Discover our premium hotels"
  ctaLabel="Book Now"
  ctaHref="/search"
  badge="Premium Hotels"
  height="90vh"
  showThumbnails={true}
/>
```

## Performance Features

- ✅ Lazy loading for non-initial images
- ✅ Preloading next image in carousel
- ✅ Priority loading for first image
- ✅ Async decoding
- ✅ Responsive image loading

## Accessibility Features

- ✅ Proper `alt` text for all images
- ✅ Keyboard navigation (arrow keys)
- ✅ ARIA labels for controls
- ✅ Reduced motion support

## Future Enhancements

### Local Assets Support

To use local assets instead of Supabase:

1. Place images in `/public/images/hero/`
2. Update `imageResolver.ts` to check local paths first
3. Update `heroImages.ts` to include local image keys

See `docs/HERO_IMAGES_GUIDE.md` for detailed instructions.
