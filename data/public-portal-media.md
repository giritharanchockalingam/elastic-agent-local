# Public Portal Media System

## Overview

The Public Portal Media System provides a scalable, image-driven UI/UX architecture for displaying hotel images across all public-facing pages. It uses a centralized catalog system, reusable premium components, and a build-time manifest generation strategy.

## Architecture

### 1. Image Catalog (`src/config/imageCatalog.ts`)

Central registry for all images with category-based organization:

- **Categories**: `rooms`, `dining`, `bar`, `spa`, `events`, `amenities`, `lobby`, `experiences`, `offers`, `hero`, `exterior`
- **Subcategories**: Room types, event venues, dining outlets, spa services
- **Helper Functions**:
  - `getImages(catalog, category, subcategory?, limit?)` - Filter images by category
  - `getFeaturedImages(catalog, category, subcategory?, count)` - Get top priority images
  - `resolveImageSrc(item)` - Resolve image URL (local or Supabase)

### 2. Image Loading Hook (`src/hooks/useImageCatalog.ts`)

React hook that:
- Loads images from generated manifest (static)
- Fetches images from database (dynamic)
- Combines both sources into a unified catalog
- Caches results for performance

### 3. Media Components (`src/components/public/media/`)

Reusable premium components:

- **`CategoryShowcase`** - Editorial strip (feature + 2 supporting images + copy + CTA)
- **`MasonryGallery`** - Responsive masonry grid
- **`ImageCarousel`** - Swipeable carousel with thumbnails
- **`RoomTypeGallery`** - Tabbed room type gallery
- **`VenueGallery`** - Venue hero + carousel + menu highlights
- **`EventSpaceGallery`** - Event space cards + gallery + inquiry CTA
- **`Lightbox`** - High-quality image viewer with keyboard support

## Adding New Images

### Step 1: Upload Images

1. **Local Development**: Place images in `/Users/giritharanchockalingam/Projects/images/`
2. **Production**: Upload to Supabase Storage bucket `property-images`

### Step 2: Generate Manifest (Development)

Run the build-time manifest generator:

```bash
node scripts/build-image-manifest.mjs
```

This scans the local images directory and generates `src/config/generatedImageManifest.json`.

### Step 3: Insert into Database (Production)

For production, insert image references into `public_property_images`:

```sql
INSERT INTO public_property_images (
  property_id,
  image_url,
  alt_text,
  category,
  subcategory,
  sort_order,
  tenant_id,
  image_key
) VALUES (
  '00000000-0000-0000-0000-000000000111',
  'https://...supabase.co/storage/v1/object/public/property-images/v3-grand-hotel-room-deluxe-01.jpg',
  'V3 Grand Hotel - Deluxe Room',
  'room',
  'deluxe',
  0,
  'your-tenant-id',
  'v3-grand-hotel-room-deluxe-01'
);
```

### Step 4: Images Automatically Appear

The system automatically:
- Loads images from manifest (dev) or database (prod)
- Organizes by category/subcategory
- Sorts by `sort_order` (lower = higher priority)
- Makes them available via `useImageCatalog` hook

## Filename Patterns

Images are automatically categorized based on filename patterns:

| Pattern | Category | Subcategory |
|---------|----------|-------------|
| `*-hero-*`, `*-exterior-*` | `exterior` | - |
| `*-room-*`, `*-rooms-*` | `rooms` | `standard`, `deluxe`, `executive`, `suite`, `presidential` |
| `*-dining-*`, `*-restaurant-*`, `*-veda-*` | `dining` | `veda`, `ember`, `in-room` |
| `*-bar-*`, `*-ember-*`, `*-lounge-*` | `bar` | - |
| `*-spa-*`, `*-aura-*`, `*-wellness-*` | `spa` | `treatments`, `rituals`, `fitness`, `pool` |
| `*-event-*`, `*-hall-*`, `*-pavilion-*`, `*-forum-*` | `events` | `grand-hall`, `pavilion`, `forum` |
| `*-pool-*`, `*-fitness-*`, `*-gym-*`, `*-amenities-*` | `amenities` | - |
| `*-lobby-*`, `*-reception-*` | `lobby` | - |
| `*-experience-*`, `*-culture-*`, `*-concierge-*` | `experiences` | - |
| `*-offer-*`, `*-package-*` | `offers` | - |

## Using Components

### CategoryShowcase

```tsx
import { CategoryShowcase } from '@/components/public/media';
import { useImageCatalog } from '@/hooks/useImageCatalog';
import { getFeaturedImages } from '@/config/imageCatalog';

const { catalog } = useImageCatalog(propertyId);
const images = getFeaturedImages(catalog, 'dining', 'veda', 3);

<CategoryShowcase
  images={images}
  title="Veda Restaurant"
  subtitle="Fine Dining Experience"
  description="Experience authentic flavors..."
  ctaLabel="View Menu"
  ctaHref="/dining/veda/menu"
/>
```

### MasonryGallery

```tsx
import { MasonryGallery } from '@/components/public/media';
import { getImages } from '@/config/imageCatalog';

const images = getImages(catalog, 'spa', undefined, 12);

<MasonryGallery
  images={images}
  columns={3}
  gap="md"
  onImageClick={(index) => openLightbox(index)}
/>
```

### RoomTypeGallery

```tsx
import { RoomTypeGallery } from '@/components/public/media';

const roomTypes = [
  {
    id: 'deluxe',
    name: 'Deluxe Room',
    description: 'Spacious and comfortable...',
    highlights: ['City View', 'King Bed', 'Minibar'],
    price: '₹5,000/night',
  },
  // ...
];

<RoomTypeGallery
  catalog={catalog}
  roomTypes={roomTypes}
/>
```

### VenueGallery

```tsx
import { VenueGallery } from '@/components/public/media';

<VenueGallery
  catalog={catalog}
  category="dining"
  subcategory="veda"
  name="Veda"
  description="Fine dining restaurant..."
  highlights={['Fine Dining', 'Wine Selection', 'Private Dining']}
  menuItems={[
    { name: 'Signature Dish', image: featuredImage, description: '...' },
  ]}
  ctaLabel="Reserve a Table"
  ctaHref="/dining/veda/reserve"
/>
```

### EventSpaceGallery

```tsx
import { EventSpaceGallery } from '@/components/public/media';

const spaces = [
  {
    id: 'grand-hall',
    name: 'The Grand Hall',
    description: 'Elegant ballroom...',
    capacity: '500+',
    type: 'Ballroom',
    features: ['Stage', 'Sound System', 'Lighting'],
  },
  // ...
];

<EventSpaceGallery
  catalog={catalog}
  spaces={spaces}
  inquiryHref="/contact"
/>
```

## Page Layouts

Each major page follows this structure:

1. **HeroBanner** - Hero section with carousel/single image
2. **CategoryShowcase** - 3-up editorial strip
3. **Highlights Cards** - 3-6 feature cards
4. **Curated Gallery** - Carousel or masonry grid
5. **CTA Section** - Book/Enquire buttons

### Example: Dining Page

```tsx
export default function Dining() {
  const { catalog } = useImageCatalog(propertyId);
  const featuredImages = getFeaturedImages(catalog, 'dining', 'veda', 3);
  const galleryImages = getImages(catalog, 'dining', 'veda', 12);

  return (
    <>
      <HeroBanner pageKey="dining" ... />
      <CategoryShowcase images={featuredImages} ... />
      <VenueGallery catalog={catalog} category="dining" ... />
      <MasonryGallery images={galleryImages} ... />
    </>
  );
}
```

## Gallery Page

The Gallery page (`/gallery` or `/:brandSlug/:propertySlug/gallery`) provides:

- Category tabs for filtering
- Masonry grid layout
- Lightbox viewer on click
- Responsive design

## Performance

### Build-Time Manifest

- Images are scanned at build time
- Manifest JSON is generated and committed
- Runtime reads manifest (fast, no file system access)
- No bundling of 100+ images into JS

### Lazy Loading

- Images use `loading="lazy"` for non-critical images
- First image uses `loading="eager"` and `fetchPriority="high"`
- Carousel preloads next image

### Caching

- React Query caches catalog for 10 minutes
- Images are cached by browser
- Supabase Storage provides CDN caching

## Accessibility

- Proper `alt` text for all images
- Keyboard navigation (arrow keys, Escape)
- ARIA labels for controls
- Reduced motion support
- Focus management in lightbox

## Future Enhancements

### Local Assets Support

To use local assets instead of Supabase:

1. Copy images to `public/images/v3-grand/`
2. Update `resolveImageSrc` to check local paths first
3. Manifest paths already point to `/images/v3-grand/...`

### CDN Optimization

Add image transformation parameters:

```typescript
export function resolveImageSrc(item: ImageItem): string {
  if (item.src.includes('supabase')) {
    // Add transformation params
    return `${item.src}?width=1200&quality=85`;
  }
  return item.src;
}
```

## Troubleshooting

### Images Not Showing

1. Check manifest: Ensure images are in `generatedImageManifest.json`
2. Check database: Verify images in `public_property_images` table
3. Check category: Ensure category matches filename pattern
4. Check RLS: Ensure RLS policies allow public read access

### Build Errors

- Ensure manifest file exists: `src/config/generatedImageManifest.json`
- Run manifest generator: `node scripts/build-image-manifest.mjs`
- Check image paths in manifest match actual file locations

### Performance Issues

- Use `limit` parameter to restrict image counts
- Implement pagination for large galleries
- Use responsive image sizes (future: add `srcset` support)
