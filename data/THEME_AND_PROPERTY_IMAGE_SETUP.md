# Theme and Property Image Setup Guide

## Overview
This guide explains how to set the V3 Grand Hotel property image and apply the Mews Modern theme across both the public portal and HMS portal.

## 1. Property Image Setup

### Step 1: Upload the Property Image
1. Upload the provided collage image to your image hosting/CDN (or Supabase Storage)
2. Note the full URL of the uploaded image

### Step 2: Update Database
Run the SQL script to update the property image:

```bash
# Update the image URL in scripts/update-v3-grand-hotel-image.sql
# Then run:
psql $DATABASE_URL -f scripts/update-v3-grand-hotel-image.sql
```

**Note:** You must replace the placeholder URL in the script with your actual uploaded image URL.

### Step 3: Verify
The image will appear on:
- Property detail page (`/property/v3-grand-hotel`)
- Property landing page (`/{brandSlug}/{propertySlug}`)
- Guest dashboard (if applicable)

## 2. Mews Modern Theme Implementation

### Current Status
The "Mews Modern" theme is already available in the theme system. It features:
- Primary Color: `#0066FF` (Bright Blue)
- Secondary Color: `#00A8E8` (Sky Blue)
- Background: `#FFFFFF` (White)
- Design: Clean, automation-first, modern interface

### Setting as Default Theme

#### Option A: Database Default (Recommended)
Update the system configuration to set Mews Modern as the default theme:

```sql
-- Set default theme in system_settings table
INSERT INTO system_settings (
  setting_key,
  setting_value,
  category,
  description,
  data_type
) VALUES (
  'default_theme',
  'Mews Modern',
  'theme',
  'Default theme for all portals',
  'string'
)
ON CONFLICT (setting_key) DO UPDATE SET
  setting_value = 'Mews Modern',
  updated_at = NOW();
```

#### Option B: Code Default
The theme system initializes with a default theme. To change it:
1. Update `src/hooks/useThemeInit.ts` to use "Mews Modern" as default
2. Or update the theme initialization in `src/App.tsx`

### Applying Theme to Both Portals

The theme system applies CSS variables globally, so it will affect:
- ✅ Public Portal (guest-facing pages)
- ✅ HMS Portal (staff/admin pages)
- ✅ Account Pages (guest account pages)

### Theme Customization (Admin/Super Admin)

Admin and super admin users can change the theme via:
1. **System Configuration Page** (`/portal/system-config`)
   - Navigate to Theme Settings section
   - Select "Mews Modern" or any other preset theme
   - Click "Apply Theme"

2. **Theme Customization Page** (`/portal/theme`)
   - Browse preset themes
   - Select "Mews Modern"
   - Customize colors if needed
   - Save preferences

### Theme Persistence

Themes are stored in:
- **User-level**: `user_theme_preferences` table (for individual user preferences)
- **System-level**: `system_settings` table (for default/global theme)

### Applying Theme Changes

When a theme is selected:
1. Theme configuration is saved to the database
2. CSS variables are updated via `applyThemeToCSS()` function
3. Changes are applied immediately to the current page
4. Theme persists across page reloads and sessions

## 3. Files Modified

### Property Image
- `scripts/update-v3-grand-hotel-image.sql` - SQL script to update property image
- `src/pages/public/PropertyDetail.tsx` - Displays property hero image
- `src/pages/public/PropertyLanding.tsx` - Displays property hero image

### Theme System
- `src/pages/ThemeCustomization.tsx` - Theme selection UI (already has Mews Modern)
- `src/lib/themeUtils.ts` - Theme utility functions
- `src/components/ThemeProvider.tsx` - Theme provider component
- `src/hooks/useThemeInit.ts` - Theme initialization hook
- `src/index.css` - Base CSS variables

## 4. Next Steps

1. **Upload Property Image**: Upload the collage image and update the SQL script with the URL
2. **Set Default Theme**: Run the SQL query to set Mews Modern as default (or update code)
3. **Test Theme Application**: Verify theme applies to both portals
4. **Configure Admin Access**: Ensure admin/super admin can access theme settings

## 5. Customization Notes

- Themes can be customized per user or globally
- The Mews Modern theme uses a clean, modern color palette
- Theme changes are applied instantly without page reload
- All themes maintain WCAG AA contrast compliance

