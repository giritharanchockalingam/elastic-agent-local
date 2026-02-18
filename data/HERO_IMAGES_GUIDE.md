# Hero Images System Guide

## Overview

The hero images system provides a centralized, scalable way to manage and display hero images across the public portal. It supports both local assets and Supabase Storage URLs.

## Architecture

### 1. Configuration (`src/config/heroImages.ts`)

Defines hero image sets per page:
- **Page Keys**: `home`, `rooms`, `dining`, `bar`, `spa`, `events`, `experiences`, `about`, `offers`
- **Categories**: Maps to database image categories (`exterior`, `lobby`, `restaurant`, `spa`, `events`, `room`, `bar`)
- **Rotation Modes**: `single`, `carousel`, `rotation` (3-image)

### 2. Image Resolver (`src/services/imageResolver.ts`)

Abstraction layer for resolving image URLs:
- Currently uses Supabase Storage URLs from database
- Future-ready for local assets
- Includes preloading and optimization utilities

### 3. Components

- **`HeroBanner`**: Main component that handles all hero display modes
- **`HeroCarousel`**: Auto-rotating carousel with swipe support
- **`HeroImageOverlay`**: Text overlay with gradient for readability

## Usage

### Basic Usage

```tsx
import { HeroBanner } from '@/components/public/HeroBanner';

<HeroBanner
  pageKey="home"
  propertySlug="v3-grand-hotel"
  title="Welcome"
  subtitle="Experience Luxury"
  ctaLabel="Book Now"
  ctaHref="/search"
  height="90vh"
  showThumbnails={true}
/>
```

### Props

- `pageKey`: Page identifier (determines which images to fetch)
- `propertyId` / `propertySlug`: Property identifier
- `title`, `subtitle`, `description`: Text content
- `ctaLabel`, `ctaHref`: Call-to-action button
- `badge`: Optional badge text
- `height`: Hero height (default: "90vh")
- `showThumbnails`: Show thumbnail strip on desktop (default: true)

## Adding New Hero Images

### Step 1: Upload to Supabase Storage

1. Upload images to Supabase Storage bucket: `property-images`
2. Use naming convention: `v3-grand-hotel-{category}-{number}.jpg`
   - Examples:
     - `v3-grand-hotel-hero-01.jpg`
     - `v3-grand-hotel-lobby-01.jpg`
     - `v3-grand-hotel-dining-01.jpg`

### Step 2: Insert into Database

Run SQL to insert image references:

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
  'https://your-project.supabase.co/storage/v1/object/public/property-images/v3-grand-hotel-hero-01.jpg',
  'V3 Grand Hotel - Hero image',
  'exterior', -- or 'lobby', 'restaurant', 'spa', 'events', etc.
  0, -- Lower = higher priority
  'your-tenant-id',
  'v3-grand-hotel-hero-01'
);
```

### Step 3: Images Automatically Appear

The hero system automatically:
- Fetches images by category from database
- Sorts by `sort_order` (lower = higher priority)
- Displays according to page's rotation mode

## Page-Specific Configuration

### Home Page (`home`)
- **Category**: `exterior`
- **Mode**: `carousel` (auto-rotate)
- **Images**: All hero images, sorted by priority

### Rooms Page (`rooms`)
- **Category**: `room`
- **Mode**: `rotation` (3-image rotation)
- **Images**: Room images

### Dining Page (`dining`)
- **Category**: `restaurant`
- **Mode**: `single`
- **Images**: Restaurant images

### Spa Page (`spa`)
- **Category**: `spa`
- **Mode**: `rotation` (3-image rotation)
- **Images**: Spa images

### Events Page (`events`)
- **Category**: `events`
- **Mode**: `single`
- **Images**: Event venue images

### About Page (`about`)
- **Category**: `lobby`
- **Mode**: `rotation` (3-image rotation)
- **Images**: Lobby/reception images

## Image Categories

| Category | Used By Pages | Description |
|----------|---------------|-------------|
| `exterior` | `home`, `experiences`, `offers` | Hotel exterior/hero images |
| `lobby` | `about` | Lobby and reception areas |
| `restaurant` | `dining` | Restaurant images |
| `bar` | `bar` | Bar/lounge images |
| `spa` | `spa` | Spa and wellness images |
| `events` | `events` | Event venue images |
| `room` | `rooms` | Room type images |

## Performance Optimizations

1. **Lazy Loading**: Non-initial images load lazily
2. **Preloading**: Next image in carousel is preloaded
3. **Priority**: First image uses `fetchPriority="high"`
4. **Async Decoding**: Images use `decoding="async"`

## Accessibility

- Proper `alt` text for all images
- Keyboard navigation (arrow keys for carousel)
- Reduced motion support (respects `prefers-reduced-motion`)
- ARIA labels for controls

## Future Enhancements

### Local Assets Support

To use local assets instead of Supabase:

1. Place images in `/public/images/hero/`
2. Update `imageResolver.ts`:

```typescript
export function getHeroSrc(imageKey: string, baseUrl?: string): string {
  if (baseUrl) return baseUrl; // Supabase URL takes priority
  
  // Local asset fallback
  return `/images/hero/${imageKey}.jpg`;
}
```

3. Update `heroImages.ts` to include local image keys:

```typescript
export const heroImageSets: Record<PageKey, Omit<HeroSet, "images">> = {
  home: {
    pageKey: "home",
    category: "exterior",
    rotationMode: "carousel",
    fallbackImageKey: "v3-grand-hotel-hero-03",
    localImages: [
      { id: "hero-01", imageKey: "v3-grand-hotel-hero-01", alt: "..." },
      { id: "hero-02", imageKey: "v3-grand-hotel-hero-02", alt: "..." },
    ],
  },
  // ...
};
```

## Troubleshooting

### Images Not Showing

1. Check database: Ensure images are in `public_property_images` table
2. Check category: Ensure category matches page configuration
3. Check property ID: Ensure `property_id` is correct
4. Check RLS: Ensure RLS policies allow public read access

### Carousel Not Auto-Rotating

- Check `autoRotate` prop (default: `true`)
- Check `rotationInterval` (default: 5000ms)
- Check if user is hovering (pauses rotation)

### Thumbnails Not Showing

- Only shows on desktop (`lg:` breakpoint)
- Only shows if `showThumbnails={true}` and multiple images exist

## Examples

See these pages for implementation examples:
- `src/pages/public/Index.tsx` - Homepage carousel
- `src/pages/public/RoomsListing.tsx` - Rooms page rotation
- `src/pages/public/RestaurantDetail.tsx` - Dining page single image
- `src/pages/public/Events.tsx` - Events page single image
