# Events Images Setup Guide

## Overview

This guide explains how to generate and upload event space images for the public portal.

## Problem

The `public_property_images` table had a CHECK constraint that only allowed these categories:
- `'reception', 'lobby', 'restaurant', 'spa', 'pool', 'parking', 'room', 'exterior', 'other'`

Event categories (`'banquet'`, `'wedding'`, `'meeting'`) were not allowed, causing image queries to fail.

## Solution

1. **Updated database constraint** to allow event categories
2. **Created scripts** to generate 6 images each for:
   - Grand Hall (wedding/reception)
   - Pavilion (banquet)
   - Forum (meeting/conference)
3. **Created upload script** to migrate images to Supabase with proper metadata

## Files Created

1. **Migration**: `supabase/migrations/20250130000001_add_events_categories.sql`
   - Adds `'banquet'`, `'wedding'`, `'meeting'` to category CHECK constraint

2. **Generation Script**: `scripts/generate-events-images.mjs`
   - Uses OpenAI DALL-E 3 API to generate 6 images per event space
   - Output: `/Users/giritharanchockalingam/Projects/images/events-generated/`

3. **Upload Script**: `scripts/upload-events-images.mjs`
   - Uploads generated images to Supabase storage
   - Inserts records into `public_property_images` with proper categories

## Step 1: Run Migration

First, apply the migration to update the database constraint:

```bash
# Using Supabase CLI
supabase migration up

# Or manually apply the SQL
psql -h your-db-host -U postgres -d postgres -f supabase/migrations/20250130000001_add_events_categories.sql
```

## Step 2: Generate Images

Set your OpenAI API key and generate images:

```bash
# Set OpenAI API key
export OPENAI_API_KEY="your-openai-api-key"

# Optional: Configure retry settings
export OPENAI_MAX_ATTEMPTS=12
export OPENAI_BASE_DELAY_MS=2500

# Generate all images
node scripts/generate-events-images.mjs

# Or generate only missing images
node scripts/generate-events-images.mjs --only-missing
```

This will generate:
- 6 images for Grand Hall → `events-generated/grand-hall/`
- 6 images for Pavilion → `events-generated/pavilion/`
- 6 images for Forum → `events-generated/forum/`

**Total: 18 images**

## Step 3: Upload to Supabase

Set your Supabase credentials and upload images:

```bash
# Set Supabase credentials
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"

# Upload and migrate images
node scripts/upload-events-images.mjs
```

The script will:
1. Upload images to Supabase storage bucket `images`
2. Store with paths: `events/{space-slug}/{filename}`
3. Insert records into `public_property_images` with:
   - Category: `'wedding'` (grand-hall), `'banquet'` (pavilion), `'meeting'` (forum)
   - Image key: `events/{space-slug}/{filename}`
   - Proper alt_text and sort_order

## Verification

After uploading, verify images are available:

1. **Check database**:
```sql
SELECT category, COUNT(*) 
FROM public_property_images 
WHERE property_id = '00000000-0000-0000-0000-000000000111'
  AND category IN ('wedding', 'banquet', 'meeting')
GROUP BY category;
```

Expected:
- `wedding`: 6 images (Grand Hall)
- `banquet`: 6 images (Pavilion)
- `meeting`: 6 images (Forum)

2. **Check public portal**:
- `/property/v3-grand-hotel/events/grand-hall`
- `/property/v3-grand-hotel/events/pavilion`
- `/property/v3-grand-hotel/events/forum`
- `/property/v3-grand-hotel/events/gallery`

Images should now display correctly on all Events pages.

## Image Categories

The image resolver will now correctly query by category:

- **Grand Hall**: `category = 'wedding'` OR `image_key LIKE '%grand-hall%'` OR `image_key LIKE '%wedding%'`
- **Pavilion**: `category = 'banquet'` OR `image_key LIKE '%pavilion%'` OR `image_key LIKE '%banquet%'`
- **Forum**: `category = 'meeting'` OR `image_key LIKE '%forum%'` OR `image_key LIKE '%meeting%'`

## Troubleshooting

### Images not showing

1. **Check database constraint**:
```sql
SELECT constraint_name, check_clause 
FROM information_schema.check_constraints 
WHERE table_name = 'public_property_images' 
  AND constraint_name LIKE '%category%';
```

Should include: `'banquet', 'wedding', 'meeting'`

2. **Check images exist**:
```sql
SELECT category, image_key, image_url 
FROM public_property_images 
WHERE property_id = '00000000-0000-0000-0000-000000000111'
  AND image_key LIKE 'events/%'
ORDER BY category, sort_order;
```

3. **Check storage bucket**:
- Verify images exist in `images` bucket
- Check storage paths: `events/{space-slug}/{filename}`

### Generation fails

- Verify `OPENAI_API_KEY` is set correctly
- Check API quota/rate limits
- Use `--only-missing` to skip existing files

### Upload fails

- Verify `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are correct
- Check storage bucket exists: `images`
- Verify RLS policies allow inserts

## Next Steps

After images are uploaded and verified:

1. Test all Events pages load images correctly
2. Verify filtering works (Weddings, Banquets, Meetings tabs)
3. Check lightbox/gallery functionality
4. Verify mobile responsiveness

## Summary

✅ Database constraint updated to allow event categories
✅ Generation script creates 18 images (6 per space)
✅ Upload script migrates images to Supabase with proper metadata
✅ Images now display correctly on all Events pages
