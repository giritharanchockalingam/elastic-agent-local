# Image & Icon Quality Guidelines

## Overview

All images and icons in the HMS Aurora Portal are optimized for high quality and vibrant display. This document outlines the standards and best practices.

## Image Quality Standards

### 1. Unsplash Images

All Unsplash images use **maximum quality** settings:
- **Quality**: `q=100` (maximum quality)
- **Format**: `auto=format` (auto-optimizes to WebP when supported)
- **Fit**: `fit=crop` (crops to fit dimensions)
- **Dimensions**: 
  - Hero images: `w=1920`
  - Card images: `w=800`
  - Thumbnails: `w=400`
  - Gallery: `w=1200`

**Example:**
```tsx
<img 
  src="https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1920&q=100&auto=format&fit=crop"
  alt="Description"
  width={1920}
  height={1080}
  loading="eager"
  fetchPriority="high"
  decoding="async"
/>
```

### 2. Image Attributes

All images should include:
- `width` and `height` attributes for proper aspect ratio and layout stability
- `loading="lazy"` for below-the-fold images, `loading="eager"` for hero images
- `fetchPriority="high"` for hero/above-the-fold images
- `decoding="async"` for better performance
- `className="image-hq"` for high-quality rendering CSS

**Hero Images:**
```tsx
<img
  src={imageUrl}
  alt={altText}
  width={1920}
  height={1080}
  loading="eager"
  fetchPriority="high"
  decoding="async"
  className="image-hq"
/>
```

**Card Images:**
```tsx
<img
  src={imageUrl}
  alt={altText}
  width={800}
  height={533}
  loading="lazy"
  fetchPriority="auto"
  decoding="async"
  className="image-hq"
/>
```

### 3. Icon Quality

Icons use **Lucide React** (SVG icons) for crisp, scalable rendering:

- Icons are SVG-based (vector graphics) for infinite scalability
- Use appropriate sizes: `h-4 w-4`, `h-5 w-5`, `h-6 w-6` for UI elements
- Icons automatically have crisp rendering via CSS
- Add `className="icon-sharp"` for extra crispness when needed

**Best Practices:**
```tsx
import { Star, Heart, MapPin } from 'lucide-react';

// Standard icon usage (automatically crisp)
<Star className="h-5 w-5 text-accent" />

// For extra crisp rendering on important icons
<Heart className="h-6 w-6 text-primary icon-sharp" />
```

### 4. CSS Image Rendering

The application includes CSS optimizations for high-quality image rendering:

```css
/* Applied globally */
img {
  image-rendering: -webkit-optimize-contrast;
  image-rendering: crisp-edges;
  image-rendering: auto;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

svg {
  shape-rendering: geometricPrecision;
  text-rendering: geometricPrecision;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
```

### 5. Utility Functions

Use the `imageUtils.ts` utility functions for consistent image quality:

```tsx
import { getHighQualityUnsplashUrl, PREMIUM_IMAGES } from '@/lib/imageUtils';

// Get high-quality Unsplash URL
const heroImage = getHighQualityUnsplashUrl('photo-1566073771259-6a8506099945', 1920);

// Use pre-configured premium images
const restaurantImage = PREMIUM_IMAGES.restaurantInterior;
```

## Quality Checklist

When adding or updating images:

- [ ] Uses `q=100` for Unsplash URLs
- [ ] Includes `width` and `height` attributes
- [ ] Has appropriate `loading` attribute (eager for hero, lazy for others)
- [ ] Uses `fetchPriority="high"` for above-the-fold images
- [ ] Includes `decoding="async"` attribute
- [ ] Has descriptive `alt` text
- [ ] Uses `className="image-hq"` for CSS optimization
- [ ] Image dimensions match display size (no unnecessary upscaling)

## Icon Quality Checklist

When using icons:

- [ ] Uses Lucide React icons (SVG-based)
- [ ] Appropriate size for context (`h-4 w-4` for small, `h-5 w-5` for standard, `h-6 w-6` for prominent)
- [ ] Includes `aria-hidden="true"` if decorative
- [ ] Uses semantic color classes (`text-accent`, `text-primary`, etc.)
- [ ] Icons are automatically crisp via CSS

## Performance Considerations

While maintaining high quality:

1. **Lazy Loading**: Use `loading="lazy"` for images below the fold
2. **Format Optimization**: Unsplash `auto=format` automatically serves WebP when supported
3. **Appropriate Sizing**: Don't load larger images than needed (use `w=` parameter)
4. **Priority**: Use `fetchPriority="high"` only for critical above-the-fold images

## Examples

### Hero Image
```tsx
<img
  src="https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1920&q=100&auto=format&fit=crop"
  alt="Luxury hotel lobby"
  width={1920}
  height={1080}
  className="w-full h-full object-cover image-hq"
  loading="eager"
  fetchPriority="high"
  decoding="async"
/>
```

### Property Card Image
```tsx
<img
  src={property.imageUrl}
  alt={property.name}
  width={800}
  height={533}
  className="w-full h-full object-cover image-hq group-hover:scale-110 transition-transform"
  loading="lazy"
  fetchPriority="auto"
  decoding="async"
/>
```

### Icon with High Quality
```tsx
<Star 
  className="h-5 w-5 text-accent icon-sharp" 
  aria-hidden="true"
/>
```

