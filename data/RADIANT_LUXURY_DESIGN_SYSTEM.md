# Radiant Luxury Design System

## Overview

A unified design system that applies a consistent "radiant luxury" look-and-feel across the entire portal (public pages + guest account pages + authenticated flows). Every page now feels like one premium, cohesive product.

## Design Principles

### Radiant Luxury Definition

- **Subtle warm gradients**: Off-white → warm gold tint (not loud)
- **Premium depth**: Soft shadows, refined borders, 2xl rounding
- **Gold for primary actions only**: Reserved for CTAs and key interactions
- **Editorial typography**: Clear hierarchy with generous whitespace
- **Consistent surfaces**: "Paper" cards, "glass" hero panels, unified empty states
- **Micro-interactions**: Hover lift, soft glow, smooth transitions
- **Accessibility**: Respects `prefers-reduced-motion`

## Design Tokens

**Location**: `src/config/designTokens.ts`

Centralized tokens for:
- Colors (gold, navy, ink, paper, muted)
- Gradients (hero overlay, surface, button, warm tint)
- Border radius scale (sm → 2xl)
- Shadow scale (sm → premium, gold)
- Spacing constants (section, container, content widths)
- Typography scale (display, body)
- Animation tokens (duration, easing)
- Reusable class name helpers

## Component System

### Buttons

**Location**: `src/components/ui/button.tsx`

**Variants**:
- `primaryGold`: Radiant gold pill for primary CTAs
- `secondaryOutline`: Clean outline for secondary actions
- `ghostLink`: Subtle link-style button
- `default`, `destructive`, `outline`, `secondary`, `ghost`, `link`

**Usage**:
```tsx
<Button variant="primaryGold" size="sm">Book Now</Button>
<Button variant="secondaryOutline">Learn More</Button>
```

### Cards

**Location**: `src/components/ui/card.tsx`

**Variants**:
- `surface`: Paper card with shadow-md (default)
- `surfaceElevated`: Stronger shadow-lg for emphasis
- `glass`: Translucent backdrop-blur for hero/feature panels
- `default`: Minimal shadow-sm

**Usage**:
```tsx
<Card variant="surface">Content</Card>
<Card variant="glass">Hero Panel</Card>
```

### Header Strip

**Location**: `src/components/ui/HeaderStrip.tsx`

Consistent header pattern for major pages with:
- Title (display font, large)
- Optional subtitle
- Optional chip/badge
- Gold accent line beneath

**Usage**:
```tsx
<HeaderStrip
  title="Book Your Stay"
  subtitle="V3 Grand Hotel"
  chip="Premium"
/>
```

### Empty State

**Location**: `src/components/public/EmptyState.tsx`

Enhanced empty state with:
- Icon support
- Title and description
- Primary CTA (gold button)
- Secondary CTA (outline button)

**Usage**:
```tsx
<EmptyState
  icon={<Calendar />}
  title="No Bookings Yet"
  description="Start by making a reservation"
  primaryAction={{
    label: "Explore Rooms",
    onClick: () => navigate('/rooms')
  }}
  secondaryAction={{
    label: "Contact Concierge",
    onClick: () => navigate('/contact')
  }}
/>
```

## Layouts

### Public Layout

**Location**: `src/components/layout/PublicLayout.tsx`

Standardized layout for public pages:
- Radiant background gradient
- Consistent header/footer
- Unified spacing and section rhythm

### Main Layout (Authenticated)

**Location**: `src/components/layout/MainLayout.tsx`

Standardized layout for authenticated pages:
- Same radiant background treatment
- Backdrop blur on header
- Consistent footer

## Background Treatment

**Location**: `src/index.css`

All pages now have:
- Subtle warm gradient: `linear-gradient(180deg, hsl(210 20% 98%) 0%, hsl(210 20% 96%) 100%)`
- Radial vignette overlay for depth
- Fixed attachment for consistent feel

## Accessibility

### Reduced Motion

All animations respect `prefers-reduced-motion`:
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

## Migration Guide

### Before → After

**Buttons**:
```tsx
// Before
<Button className="bg-gold-gradient text-navy-900 hover:opacity-90 font-semibold rounded-full px-6 shadow-lg">
  Book Now
</Button>

// After
<Button variant="primaryGold" size="sm">Book Now</Button>
```

**Cards**:
```tsx
// Before
<div className="rounded-lg border bg-card shadow-md">Content</div>

// After
<Card variant="surface">Content</Card>
```

**Headers**:
```tsx
// Before
<div className="mb-8">
  <h1 className="text-4xl font-bold">Title</h1>
  <p className="text-muted-foreground">Subtitle</p>
</div>

// After
<HeaderStrip title="Title" subtitle="Subtitle" />
```

## Files Changed

### Created
- `src/config/designTokens.ts`
- `src/components/ui/HeaderStrip.tsx`
- `src/components/layout/PublicLayout.tsx`
- `docs/RADIANT_LUXURY_DESIGN_SYSTEM.md`

### Enhanced
- `src/components/ui/button.tsx` (added variants)
- `src/components/ui/card.tsx` (added variants)
- `src/components/public/EmptyState.tsx` (enhanced CTAs)
- `src/components/layout/MainLayout.tsx` (radiant background)
- `src/components/layout/PublicShell.tsx` (uses PublicLayout)
- `src/index.css` (radiant background + reduced motion)

### Refactored
- `src/pages/public/Index.tsx`
- `src/pages/public/PropertyReservations.tsx`
- `src/components/guest/*` (all guest components)
- `src/components/booking/RoomTypeSelector.tsx`

## Next Steps

To apply the design system to remaining pages:

1. Replace ad-hoc buttons with `variant="primaryGold"` or `variant="secondaryOutline"`
2. Replace custom cards with `<Card variant="surface">` or `<Card variant="surfaceElevated">`
3. Replace page headers with `<HeaderStrip>`
4. Replace empty states with `<EmptyState>` component
5. Remove hardcoded gradients, shadows, and spacing in favor of tokens

## Benefits

- **Consistency**: Every page feels like one product
- **Maintainability**: Centralized tokens, easy to update
- **Performance**: No duplicate styles, optimized CSS
- **Accessibility**: Built-in reduced motion support
- **Developer Experience**: Clear component API, type-safe
