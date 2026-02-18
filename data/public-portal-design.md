# Public Portal Design System

**Date**: 2025-01-21  
**Status**: Implemented

## Overview

World-class design system for the public hospitality portal, ensuring premium UX, accessibility, and performance.

## Component Library

### Core Components

#### `Hero`
- **Purpose**: Premium hero section with background image, headline, tagline, and CTAs
- **Props**: `backgroundImage`, `headline`, `tagline`, `primaryCta`, `secondaryCta`, `height`
- **Features**:
  - Gradient overlay for text readability
  - Responsive height variants (sm, md, lg, xl)
  - Optimized image loading (eager, fetchPriority)
  - Proper ARIA labels

#### `PropertyCard`
- **Purpose**: Beautiful property card with image, location, amenities, and CTA
- **Props**: Property data (name, slug, image, location, starRating, amenities)
- **Features**:
  - Hover effects (scale image, shadow)
  - Star rating overlay
  - Lazy loading images
  - Responsive grid support

#### `TrustBadges`
- **Purpose**: Display security, quality, and trust indicators
- **Props**: `badges` (customizable), `variant` (default/compact)
- **Features**:
  - Icon + label pairs
  - Accessible labels
  - Flexible layout

#### `ValuePropositionCard`
- **Purpose**: Value proposition cards with icon, title, description
- **Props**: `icon`, `title`, `description`
- **Features**:
  - Centered layout
  - Icon container with brand color
  - Hover shadow effects

#### `CTAStrip`
- **Purpose**: Conversion-focused call-to-action section
- **Props**: `title`, `description`, `primaryCta`, `secondaryCta`, `variant` (gradient/card)
- **Features**:
  - Gradient background option
  - Multiple CTA buttons
  - Responsive layout

#### `SectionHeader`
- **Purpose**: Consistent section headers with title, description, and optional action
- **Props**: `title`, `description`, `actionLabel`, `actionHref`, `centered`
- **Features**:
  - Flexible layout (left-aligned or centered)
  - Optional action link/button

#### `EmptyState`
- **Purpose**: Premium empty state component (not raw text)
- **Props**: `icon`, `title`, `description`, `action`
- **Features**:
  - Centered layout
  - Optional icon, description, and action button

### Existing Components (Enhanced)

#### `SEOHead`
- Meta tags, OpenGraph, Twitter Cards, JSON-LD structured data
- Already implemented and used

#### `LeadCaptureForm`
- Rate-limited lead capture with audit logging
- Already implemented and used

#### `SkeletonLoader`
- Loading states (SkeletonHero, SkeletonCard, SkeletonText)
- Already implemented

### New Components

#### `RouteErrorBoundary`
- Route-level error boundary
- Catches component errors and displays premium error state
- Reload button for recovery

## Design Tokens

### Typography
- **Fonts**: Inter (body), Outfit (headings) - already configured
- **Scale**: Responsive text sizes (text-4xl to text-7xl for hero)
- **Line height**: Default Tailwind (leading-tight for headings)

### Spacing
- **Container**: `container mx-auto px-4`
- **Section padding**: `py-12 md:py-16` (standard), `py-8` (compact)
- **Grid gaps**: `gap-6 md:gap-8` (standard cards)

### Colors
- **Primary**: From tenant branding or CSS variables
- **Gradients**: `bg-gradient-to-r from-primary to-primary/80`
- **Overlays**: `bg-black/40 via-black/50 to-black/70` (hero)

### Animations
- **Fade in**: `animate-fade-in` (already in Tailwind config)
- **Transitions**: `transition-all duration-300` (cards), `transition-transform duration-500` (images)
- **Hover**: Scale images, shadow changes

## Layout Patterns

### Hero Section
```tsx
<Hero
  backgroundImage={heroImageUrl}
  headline={heroTitle}
  tagline={heroTagline}
  primaryCta={{ label: 'Explore Properties', href: '#properties' }}
  height="lg"
/>
```

### Property Grid
```tsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 md:gap-8">
  {properties.map(property => (
    <PropertyCard {...property} />
  ))}
</div>
```

### Value Props Grid
```tsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 md:gap-8">
  {valueProps.map(prop => (
    <ValuePropositionCard {...prop} />
  ))}
</div>
```

## Accessibility

### WCAG 2.1 AA Compliance
- **ARIA labels**: All icons have `aria-hidden="true"`, images have alt text
- **Semantic HTML**: Proper heading hierarchy (h1, h2, h3)
- **Focus management**: Buttons and links are keyboard accessible
- **Color contrast**: Uses design system colors with proper contrast
- **Screen readers**: Descriptive labels for all interactive elements

### Best Practices
- Skip links (can be added if needed)
- Focus visible styles (via Tailwind)
- Proper heading hierarchy
- Alt text for all images
- ARIA labels for icon-only buttons

## Performance

### Image Optimization
- **Hero images**: `loading="eager"`, `fetchPriority="high"`, width/height attributes
- **Property cards**: `loading="lazy"`, width/height attributes
- **Responsive images**: Can be extended with srcset if needed

### Loading States
- Skeleton loaders for all data sections
- Progressive enhancement (content loads incrementally)

### Caching
- React Query caching for data fetches
- Can add service worker for static assets if needed

## Responsive Design

### Breakpoints (Tailwind defaults)
- **sm**: 640px
- **md**: 768px
- **lg**: 1024px
- **xl**: 1280px
- **2xl**: 1400px

### Mobile-First Approach
- Base styles for mobile
- `md:` prefix for tablet+
- `lg:` prefix for desktop+

## Tenant Theming

### Safe Theming
- Logo URL from `tenant.branding.logoUrl`
- Primary color from `tenant.branding.primaryColor` (via CSS variables)
- No arbitrary CSS injection
- Whitelisted font choices (Inter, Outfit)

### Fallbacks
- Default colors from CSS variables if tenant branding missing
- Placeholder images if hero image missing
- Default value props if tenant content missing

## Content Strategy

### Data Sources
1. **Tenant Content**: `public_tenant_content_v` (hero, tagline, value props)
2. **Tenant Info**: `public_tenants` (name, branding)
3. **Properties**: `public_properties` (property listings)

### Fallback Content
- Default value propositions if tenant content missing
- Generic taglines if tenant content missing
- Empty states for missing data (not blank sections)

## SEO

### Meta Tags
- Dynamic title, description, image
- OpenGraph tags
- Twitter Cards
- JSON-LD structured data (Organization schema)

### Best Practices
- Unique titles per page
- Descriptive meta descriptions
- Proper heading hierarchy (h1 → h2 → h3)
- Semantic HTML

## Conversion Optimization

### CTA Strategy
- Primary CTA: "Explore Properties" (above fold)
- Secondary CTA: "Sign In / Create Account"
- Multiple CTAs: Hero, properties section, bottom strip
- Clear value props before CTAs

### User Flow
1. Hero section (hook)
2. Trust badges (credibility)
3. Value propositions (benefits)
4. Properties (showcase)
5. Lead capture (conversion)
6. Final CTA strip (last chance)

## File Structure

```
src/components/public/
  ├── Hero.tsx
  ├── PropertyCard.tsx
  ├── TrustBadges.tsx
  ├── ValuePropositionCard.tsx
  ├── CTAStrip.tsx
  ├── SectionHeader.tsx
  ├── EmptyState.tsx
  ├── RouteErrorBoundary.tsx
  ├── SEOHead.tsx (existing)
  ├── LeadCaptureForm.tsx (existing)
  └── SkeletonLoader.tsx (existing)
```

## Usage Example

```tsx
import { Hero, PropertyCard, TrustBadges, ValuePropositionCard, CTAStrip } from '@/components/public';

<TenantLanding>
  <Hero {...heroProps} />
  <TrustBadges />
  <ValuePropositionCard {...valueProps} />
  <PropertyCard {...propertyProps} />
  <CTAStrip {...ctaProps} />
</TenantLanding>
```

