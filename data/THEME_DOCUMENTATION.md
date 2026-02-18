# Premium Luxury Theme Documentation

## Theme Overview

The HMS Aurora Portal uses a **Premium Luxury Theme** with a sophisticated Navy Blue and Gold color palette. This theme creates an elegant, trustworthy, and premium hospitality experience.

## Theme Characteristics

### Color Palette

**Primary Colors:**
- **Navy Blue**: Deep navy (`navy-700: #0F172A`) as the primary color
- **Gold/Amber**: Warm gold (`gold-400: #FBBF24`) as the accent color

**Color Spectrum:**
- Navy: 50-900 (light to dark shades)
- Gold: 50-700 (light to dark shades)

### Typography

- **Display Font**: Playfair Display (serif) - Used for headings
- **Body Font**: Inter (sans-serif) - Used for body text
- Large, bold headings with gradient text effects

### Visual Elements

- **Premium Gradients**: Gold gradient buttons and text
- **Premium Shadows**: Deep, layered shadows for depth
- **Glass-morphism**: Backdrop blur effects on cards and modals
- **Smooth Animations**: Framer Motion animations for interactions
- **Hover Effects**: Scale transforms and shadow enhancements

### Design Elements

- Premium card hover effects with elevation
- Image overlays with gradient vignettes
- Gold gradient CTAs (`bg-gold-gradient text-navy-900`)
- Clean, spacious layouts with generous white space
- Sophisticated badge styling with accent colors

## Default Theme Mode

**Current Setting**: `light` mode

The default theme is set to `light` mode to match the landing page aesthetic. This uses:
- White/light backgrounds (`--background: 210 20% 98%`)
- Navy blue primary color
- Gold/amber accent color
- High contrast for readability

## CSS Variables

The theme is defined using CSS variables in `src/index.css`:

```css
:root {
  /* Primary - Deep Navy */
  --primary: 222 47% 11%;
  --primary-foreground: 210 40% 98%;
  
  /* Accent - Warm Gold */
  --accent: 38 92% 50%;
  --accent-foreground: 222 47% 11%;
  
  /* Background & Foreground */
  --background: 210 20% 98%;
  --foreground: 222 47% 11%;
  
  /* Navy Spectrum */
  --navy-50 through --navy-900
  
  /* Gold Spectrum */
  --gold-50 through --gold-700
}
```

## Usage Guidelines

### Buttons

**Primary CTA (Gold Gradient):**
```tsx
<Button className="bg-gold-gradient text-navy-900 hover:opacity-90 font-semibold">
  Book Now
</Button>
```

**Secondary (Outline):**
```tsx
<Button variant="outline">View Details</Button>
```

### Cards

**Premium Card with Hover:**
```tsx
<Card className="shadow-card card-premium-hover">
  {/* Card content */}
</Card>
```

### Text Gradients

**Gold Gradient Text:**
```tsx
<span className="text-gradient-gold">Luxury Hospitality</span>
```

### Badges

```tsx
<Badge className="bg-accent text-accent-foreground">Premium</Badge>
```

## Theme Consistency

To maintain consistency across all pages:

1. **Use Theme Variables**: Always use CSS variables instead of hardcoded colors
2. **Follow Component Patterns**: Use existing UI components (Button, Card, Badge) which have theme-aware styling
3. **Match Landing Page Style**: Reference the landing page (`src/pages/public/Index.tsx`) for styling patterns
4. **Consistent Spacing**: Use Tailwind's spacing scale consistently
5. **Premium Effects**: Apply premium shadows, gradients, and hover effects appropriately

## Theme Customization

Users can customize their theme via `/theme-customization` page, but the default theme (Navy + Gold) should remain consistent for the brand identity.

## Dark Mode Support

Dark mode is available but uses adjusted colors for the Navy + Gold theme. The default remains light mode to match the premium landing page aesthetic.

