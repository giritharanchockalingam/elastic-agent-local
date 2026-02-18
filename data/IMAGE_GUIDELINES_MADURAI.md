# Image Guidelines for Madurai Luxury Hotel Portal

## Overview
This document outlines the image requirements and specifications for the luxury hotel portal in Madurai, South India. All images must be culturally authentic, high-quality, and professionally produced.

## Image Specifications

### Technical Requirements
- **Resolution**: Minimum 1920x1080px for hero images, 1200x800px for room images
- **Format**: JPEG or WebP (optimized for web)
- **Quality**: 90-100% JPEG quality, optimized file sizes
- **Aspect Ratios**:
  - Hero images: 16:9 (1920x1080)
  - Room images: 3:2 (1200x800) or 4:3
  - Thumbnail images: 1:1 (800x800) or 4:3
  - Menu item images: 1:1 (800x800)

### Cultural Authenticity Requirements
All images must reflect authentic South Indian and Madurai-specific elements:

1. **Architectural Elements**:
   - Meenakshi Amman Temple gopurams (temple towers) in background views
   - Traditional South Indian architectural motifs
   - Wooden carvings and traditional patterns
   - Marble and stone work typical of South Indian temples and palaces

2. **Culinary Elements**:
   - Traditional banana leaf meals (South Indian thali)
   - Brass and copper serving vessels (katoris, thalis)
   - Traditional South Indian dishes: dosa, idli, vada, sambar, rasam, biryani
   - Filter coffee (South Indian kaapi) presentation
   - Traditional sweets: payasam, halwa, mysore pak

3. **Cultural Context**:
   - Traditional flowers: jasmine (malligai), marigold
   - Traditional fabrics: kanchipuram silk, cotton
   - Traditional lamps: oil lamps (deepam), brass lamps
   - Pooja/ritual elements if appropriate

## Image Categories

### 1. Property Hero Images
**Purpose**: Main banner images for property landing pages

**Content Requirements**:
- Exterior shots showing hotel facade with traditional architectural elements
- Luxury lobby/reception areas with South Indian design influences
- Views of Madurai skyline with temple gopurams visible
- Warm, golden-hour lighting
- Professional, aspirational travel photography style

**Example Subjects**:
- Hotel exterior at sunset with temple gopurams in background
- Grand lobby with traditional South Indian architectural details
- Entrance with traditional lamp displays and floral arrangements

**Storage**: `public_property_images` table, category: 'hero'

---

### 2. Room Type Images
**Purpose**: Showcase different room categories and amenities

**Content Requirements**:
- Well-appointed rooms with luxury amenities
- Views of temple gopurams or Madurai cityscape from windows
- Traditional South Indian design elements integrated with modern luxury
- Warm, inviting lighting
- Multiple angles: bedroom, bathroom, sitting area

**Room Categories**:
- **Standard/Deluxe Rooms**: Clean, comfortable, with city/temple views
- **Executive/Premium Rooms**: Enhanced amenities, larger spaces
- **Suites**: Spacious, luxury accommodations with separate living areas
- **Spa Suites**: Rooms with private spa facilities, traditional wellness elements

**Storage**: `room_images` table, linked to `room_types`

---

### 3. Restaurant/Menu Images
**Purpose**: Showcase dining experiences and menu items

**Content Requirements**:
- Traditional South Indian meals presented on banana leaves
- Traditional serving vessels (brass katoris, thalis)
- Live cooking stations (dosai griddles, tandoor)
- Restaurant interiors with warm, inviting ambiance
- Traditional dining settings with cultural elements

**Menu Item Categories**:
- **Breakfast**: Dosa, idli, vada, pongal, upma
- **Traditional Meals**: Full South Indian thali, banana leaf meals
- **Rice Varieties**: Biryani, puliyodarai (tamarind rice), lemon rice
- **Curries & Sides**: Sambar, rasam, kootu, poriyal
- **Beverages**: Filter coffee, lassi, buttermilk, fresh juices
- **Desserts**: Payasam, halwa, traditional sweets

**Storage**: `menu_items.image_url` field

---

### 4. Amenities & Services Images
**Purpose**: Showcase hotel facilities and services

**Content Requirements**:
- Spa/wellness facilities with traditional elements
- Swimming pool areas (if applicable)
- Bar/lounge areas
- Business/meeting facilities
- Recreational areas

---

## Image Generation Prompts

For AI image generation tools, use these culturally authentic prompts:

### Property Hero Image
```
"Luxury hotel exterior in Madurai, South India, featuring modern architecture with traditional South Indian design elements. The Meenakshi Amman Temple gopurams visible in the background at golden hour. Warm lighting, professional architecture photography, high resolution, vibrant colors, culturally authentic"
```

### Luxury Suite with Temple View
```
"Spacious luxury hotel suite with floor-to-ceiling windows overlooking Madurai city skyline. Traditional multi-tiered temple gopurams (Meenakshi Amman Temple) visible in the distance at sunset. Room features elegant modern furniture with traditional South Indian design accents, plush white bedding, warm wood tones, brass lamps, fresh jasmine garlands. Golden hour lighting, professional hotel photography, high-end luxury, culturally authentic South Indian aesthetics"
```

### Traditional South Indian Dining
```
"Traditional South Indian meal beautifully presented on a fresh banana leaf. Multiple brass katoris (bowls) containing sambar, rasam, curries, and side dishes arranged in an elegant thali style. Steam rising from hot rice in the center. Warm, inviting restaurant ambiance with soft lighting, traditional South Indian decor elements in background. Professional food photography, appetizing, culturally authentic, high resolution"
```

### Restaurant Interior
```
"Elegant South Indian fine-dining restaurant interior. Warm, golden lighting, traditional South Indian architectural elements like carved wooden panels, brass oil lamps, fresh jasmine garlands. Tables set with banana leaves and traditional serving vessels. Open kitchen visible in background with chefs preparing traditional dishes. Sophisticated, inviting atmosphere, professional restaurant photography, culturally authentic Madurai cuisine"
```

### Spa/Welcome Area
```
"Luxury hotel spa suite with traditional South Indian wellness elements. White marble surfaces, warm lighting, traditional oil lamps (deepam), fresh jasmine garlands. Professional massage table with white linens, separate sitting area with traditional wooden furniture. Elegant, serene atmosphere, professional hospitality photography, culturally authentic South Indian spa aesthetics"
```

## Implementation Notes

1. **Image Upload**: Use Supabase Storage or CDN for image hosting
2. **Lazy Loading**: Implement lazy loading for all images
3. **Responsive Images**: Serve different sizes for different viewports
4. **Alt Text**: Always include descriptive, culturally appropriate alt text
5. **SEO**: Use descriptive filenames and proper metadata

## Quality Checklist

Before using any image, verify:
- [ ] High resolution (meets minimum requirements)
- [ ] Culturally authentic South Indian/Madurai elements
- [ ] Professional photography quality
- [ ] Appropriate lighting and composition
- [ ] Relevant to hotel/restaurant context
- [ ] Optimized file size for web
- [ ] Descriptive alt text provided
- [ ] Proper categorization in database

