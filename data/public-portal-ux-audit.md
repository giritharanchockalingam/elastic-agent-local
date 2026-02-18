# Public Portal UX Audit

**Date**: 2025-01-21  
**Page Audited**: Tenant Landing Page (`/{brandSlug}`)  
**Route**: `/grand-hospitality`

## Current State

### Structure ✅
- Basic page structure exists with logical sections
- SEO component (`SEOHead`) implemented
- Skeleton loaders for loading states
- Lead capture form component
- Error state handling

### Components Used
- `Card`, `Button`, `Badge` from shadcn/ui
- `SEOHead` for meta tags
- `LeadCaptureForm` for lead capture
- `SkeletonLoader` variants

### Data Sources
- `getBrandLanding()` - tenant info from `public_tenants`
- `listTenantProperties()` - properties from `public_properties`
- Branding data from tenant `branding` JSONB field

## Issues Identified

### 1. Visual Design - "Dumb & Numb" ⚠️
- **No hero imagery**: Hero section is text-only on gradient background, lacks visual impact
- **Generic design**: Looks like a template, not a premium hospitality brand
- **Weak visual hierarchy**: Text sizes and spacing don't create compelling focal points
- **Missing gallery/imagery**: No property images in hero, limited visual storytelling
- **Plain property cards**: Basic cards without premium feel (no hover effects, limited imagery)

### 2. Content & Data Gaps ⚠️
- **No tenant-level content table**: No `public_tenant_content` for hero images, taglines, value props
- **Limited property imagery**: Properties may not have images in `public_metadata.images`
- **Generic copy**: "Your gateway to exceptional hospitality" is placeholder-level generic
- **Missing experiences preview**: No dining/events/wellness modules shown
- **No dynamic tagline**: Tagline is hardcoded, should come from content data

### 3. Information Architecture ⚠️
- **Missing sections**:
  - Premium hero with background image
  - Value propositions section (exists but generic)
  - Experiences preview (dining/events/wellness)
  - Social proof/testimonials (if available)
- **Properties section**: Works but could be more compelling
- **CTA placement**: Multiple CTAs but not strategically placed

### 4. Component Quality ⚠️
- **No premium components**: Missing Hero, PropertyCard, GalleryCarousel, TrustBadges as reusable primitives
- **Skeletons**: Basic, could be more realistic
- **No empty states**: No premium empty state components for missing data

### 5. Performance & Accessibility ⚠️
- **Images**: No image optimization (responsive sizes, lazy loading not enforced)
- **Layout shift**: No width/height attributes on images
- **Error boundaries**: Missing route-level error boundary
- **Accessibility**: Basic ARIA, but could be improved (skip links, better focus management)

### 6. Conversion Optimization ⚠️
- **CTA strategy**: CTAs exist but not optimized for conversion flow
- **Property picker**: If multiple properties, no modal/flow to select property before booking
- **Auth friction**: "Sign In" links to `/auth` but no clear guest signup path distinction

### 7. Design System Gaps ⚠️
- **No design tokens**: Typography scale not consistently defined
- **Spacing**: Inconsistent spacing scale
- **Theming**: Branding from DB exists but not fully utilized (logo, colors)
- **Component library**: Missing premium hospitality-focused components

## Design System Findings

### Existing Assets ✅
- Tailwind CSS configured
- CSS variables for colors in `index.css`
- shadcn/ui base components (Card, Button, Badge)
- Theme utilities (`themeUtils.ts`)
- Glassmorphism utilities (`.glass`, `.glass-card`)

### Missing Assets ❌
- Typography scale component/system
- Spacing scale documentation
- Premium component library (Hero, PropertyCard, etc.)
- Image optimization utilities
- Error boundary component (generic exists, but not used on route)

## Data Model Gaps

### Existing Tables ✅
- `public_tenants` - tenant info with branding
- `public_properties` - property info with `public_metadata`
- `public_property_content` - property-level content (hero, gallery, etc.)
- `public_property_images` - property images

### Missing Tables ❌
- `public_tenant_content` - tenant-level content (hero images, taglines, value props, testimonials)
- Content seed data for `grand-hospitality` tenant

## Priority Fixes

### High Priority 🔴
1. Create `public_tenant_content` table for tenant-level hero/content
2. Build premium component library (Hero, PropertyCard, GalleryCarousel)
3. Upgrade hero section with background image and better visual hierarchy
4. Seed realistic content for `grand-hospitality` tenant
5. Add error boundary to route

### Medium Priority 🟡
1. Improve property cards with better imagery and hover states
2. Add experiences preview section (dining/events)
3. Optimize images (responsive, lazy loading, dimensions)
4. Enhance accessibility (skip links, focus management)
5. Add property picker modal for multi-property booking

### Low Priority 🟢
1. Add testimonials/social proof section
2. Enhance animations (subtle, modern)
3. Add analytics hooks for CTA clicks
4. Performance audit (Lighthouse targets)

## Next Steps

1. **Step 1**: Create design system components (Hero, PropertyCard, etc.)
2. **Step 2**: Upgrade TenantLanding page with premium sections
3. **Step 3**: Create `public_tenant_content` table and seed content
4. **Step 4**: Performance & accessibility improvements
5. **Step 5**: Conversion flow optimization

