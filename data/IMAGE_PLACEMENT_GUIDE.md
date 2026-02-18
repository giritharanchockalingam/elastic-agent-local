# Image Placement Guide for Madurai Hotel Portal

## Overview
This guide specifies where each type of image should be displayed in the portal to ensure a cohesive, professional user experience.

## Image Categories & Placement

### 1. Property Hero Images
**Database Table**: `public_property_images` (category: 'hero')

**Display Locations**:
- **Property Landing Page** (`/property/:id` or `/:brandSlug/:propertySlug`)
  - Top hero banner section (full-width, above fold)
  - Image carousel/gallery if multiple hero images
  - Background image for property header

- **Search Results Page** (`/search`)
  - Thumbnail image in property cards
  - Hover state shows larger preview

- **Homepage** (`/`)
  - Property cards/featured properties section
  - Slider/carousel for featured properties

**Component**: `PropertyDetail.tsx`, `PropertyCard.tsx`, `Index.tsx`

---

### 2. Room Type Images
**Database Table**: `room_images` (linked to `room_types`)

**Display Locations**:
- **Property Detail Page - Rooms Section**
  - Room type cards with primary image
  - Room gallery on hover/click

- **Room Listing Page** (`/:brandSlug/:propertySlug/rooms`)
  - Grid/list view of room types with images
  - Room detail modal/page

- **Room Type Detail Page** (`/:brandSlug/:propertySlug/rooms/:roomTypeSlug`)
  - Hero image at top
  - Image gallery below description
  - Multiple angles: bedroom, bathroom, amenities

- **Booking Engine** (`/booking/:propertyId` or `/:brandSlug/:propertySlug/book`)
  - Room selection cards with images
  - Selected room preview

**Component**: `RoomCard.tsx`, `RoomTypeDetail.tsx`, `BookingEngine.tsx`, `RoomsListing.tsx`

---

### 3. Restaurant/Menu Item Images
**Database Table**: `menu_items.image_url`

**Display Locations**:
- **Restaurant Menu Page** (`/dining/:propertyId/menu`)
  - Menu item cards with images
  - Category sections with featured items
  - Image modal on click

- **Restaurant Detail Page** (`/:brandSlug/:propertySlug/dining/:outletSlug`)
  - Gallery section
  - Featured dishes carousel

- **Restaurant Order Page** (`/:brandSlug/:propertySlug/dining/:outletSlug/order`)
  - Menu browsing with images
  - Cart items with thumbnails

**Component**: `MenuItemCard.tsx`, `RestaurantMenu.tsx`, `RestaurantOrderUnified.tsx`

---

### 4. Restaurant Outlet Images
**Database Table**: Restaurant outlets may have `images` array or gallery table

**Display Locations**:
- **Restaurant Landing Page** (`/dining`)
  - Restaurant cards with featured images
  - Gallery sections

- **Restaurant Detail Page**
  - Hero image
  - Gallery carousel

**Component**: `RestaurantDetail.tsx`, `RestaurantLanding.tsx`

---

## Image Loading Best Practices

### 1. Lazy Loading
All images should implement lazy loading:
```tsx
<img 
  src={imageUrl} 
  alt={altText}
  loading="lazy"
  decoding="async"
  className="image-hq"
/>
```

### 2. Responsive Images
Use different image sizes for different viewports:
- Mobile: 800px width
- Tablet: 1200px width
- Desktop: 1920px width (hero), 1200px (cards)

### 3. Image Optimization
- Use WebP format where supported
- Implement proper compression (85-90% quality)
- Serve from CDN or Supabase Storage

### 4. Fallback Images
Always provide fallback images:
```tsx
const imageUrl = room.image || 
  'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=100&auto=format&fit=crop';
```

### 5. Error Handling
Handle image load errors gracefully:
```tsx
onError={(e) => {
  const target = e.target as HTMLImageElement;
  target.src = fallbackImageUrl;
}}
```

---

## Component Integration Checklist

When adding images to components:

- [ ] Images load from database (not hardcoded)
- [ ] Fallback images provided
- [ ] Lazy loading implemented
- [ ] Proper alt text for accessibility
- [ ] Responsive sizing applied
- [ ] Error handling in place
- [ ] Loading states shown
- [ ] Image optimization applied

---

## Image Sources Priority

1. **Primary**: Database (`public_property_images`, `room_images`, `menu_items.image_url`)
2. **Secondary**: Bundled assets (for fallback only)
3. **Tertiary**: Default placeholder images

---

## Culturally Authentic Image Requirements

All images must:
- Showcase South Indian/Madurai cultural elements
- Include temple gopurams in background views where appropriate
- Feature traditional South Indian cuisine and serving styles
- Reflect luxury hospitality standards
- Maintain professional photography quality
- Use warm, golden-hour lighting
- Include traditional design elements naturally integrated

