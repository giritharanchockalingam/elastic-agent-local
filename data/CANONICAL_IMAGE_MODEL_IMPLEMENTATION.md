# Canonical Image Model - Complete Implementation Guide

## Overview

This document outlines the complete implementation of the canonical image model that strictly enforces folder structure → database category mapping and ensures seamless image loading in the frontend.

## ✅ Completed Tasks

1. **Database Schema Migration** (`supabase/migrations/20250131000002_canonical_image_model_complete.sql`)
   - Added missing columns: `storage_path`, `storage_bucket`, `thumbnail_url`, `updated_at`
   - Updated category constraint to include ALL canonical categories: `bar`, `banquet`, `wedding`, `meeting`
   - Added indexes for performance
   - Added trigger for `updated_at` timestamp

2. **Migration Script Updates** (`scripts/migrate-canonical-images.mjs`)
   - Strict category enforcement via `getValidCategory()` function
   - Canonical folder mapping:
     - `property/` → `exterior`
     - `lobby/` → `lobby`
     - `dining/bar/` → `bar`
     - `dining/restaurant/` → `restaurant`
     - `wellness/pool/` → `pool`
     - `wellness/spa/` → `spa`
     - `wellness/fitnesscenter/` → `spa`
     - `events/forum/` → `meeting`
     - `events/grand-hall/` → `wedding`
     - `events/pavilion/` → `banquet`
     - `stay/rooms/` → handled separately (room_images)
   - Uploads both originals and thumbnails by default
   - Proper `thumbnail_url` handling in database inserts

3. **Frontend Service Updates** (`src/services/data/propertyImageService.ts`)
   - Uses `thumbnail_url` column from database if available
   - Falls back to derived thumbnail URL if not provided
   - Properly handles all canonical categories

4. **Type Definitions** (`src/types/images.ts`)
   - Canonical `ImageCategory` type
   - `PropertyImage` interface with all required fields
   - `RoomImage` interface for room images

5. **Utility Functions** (`src/utils/imageUtils.ts`)
   - `deriveThumbnailUrl()` - derives thumbnail URL from full URL
   - `resolveImageUrl()` - context-aware image URL resolution (hero uses full, gallery uses thumbnail)
   - Handles both PropertyImage and RoomImage types

## 🔧 Required Actions

### Step 1: Run Database Migration

**BEFORE running the image migration script**, apply the database migration:

```bash
# Option 1: Via Supabase Dashboard
# 1. Go to: https://supabase.com/dashboard/project/YOUR_PROJECT_ID
# 2. Navigate to: SQL Editor → New Query
# 3. Copy contents of: supabase/migrations/20250131000002_canonical_image_model_complete.sql
# 4. Paste and run

# Option 2: Via Supabase CLI
supabase migration up
```

This migration will:
- Add `storage_path`, `storage_bucket`, `thumbnail_url`, `updated_at` columns
- Update category constraint to include `bar`, `banquet`, `wedding`, `meeting`
- Create indexes and triggers

### Step 2: Clean Supabase Storage

```bash
node scripts/cleanup-supabase-images.mjs
```

This removes all existing images for the property, ensuring a clean slate.

### Step 3: Generate Thumbnails (if not already done)

```bash
node scripts/generate-thumbnails.mjs
```

This generates 960px-wide thumbnails for all images in the canonical structure.

### Step 4: Run Image Migration

```bash
node scripts/migrate-canonical-images.mjs
```

This will:
- Scan canonical `images/` directory
- Infer categories from folder structure (strict canonical model)
- Upload originals and thumbnails to Supabase Storage
- Insert/update records in `public_property_images` with correct categories
- Generate room image mapping files (CSV + SQL template)

**Expected Output:**
```
📊 Summary:
   Total files: 278
   ✅ Processed: 278
   ⏭️  Skipped: 0
   ❌ Errors: 0
   
   By Category:
      exterior: 10
      lobby: 15
      bar: 9
      restaurant: 12
      pool: 8
      spa: 7
      meeting: 5
      wedding: 3
      banquet: 4
      other: 0  # Should be minimal
```

### Step 5: Verify Frontend Loading

The frontend services are already updated to handle:
- All canonical categories
- Thumbnail URLs from database or derived
- Context-aware image resolution (hero = full, gallery = thumbnail)
- Safe fallbacks

Test by:
1. Loading property pages that use `getPropertyHeroImage()` - should use full-size images
2. Loading gallery grids that use `getPropertyGalleryImages()` - should use thumbnails
3. Verify all categories load correctly (bar, banquet, wedding, meeting, etc.)

## 📋 Category Mapping Reference

| Folder Path | Database Category | Notes |
|-------------|-------------------|-------|
| `images/property/*` | `exterior` | Property hero/exterior shots |
| `images/lobby/*` | `lobby` | Lobby/reception area |
| `images/dining/bar/*` | `bar` | Bar/lounge images |
| `images/dining/restaurant/*` | `restaurant` | Restaurant interior/food |
| `images/wellness/pool/*` | `pool` | Pool/leisure |
| `images/wellness/spa/*` | `spa` | Spa/wellness |
| `images/wellness/fitnesscenter/*` | `spa` | Fitness center (maps to spa) |
| `images/events/forum/*` | `meeting` | Meeting room/forum |
| `images/events/grand-hall/*` | `wedding` | Wedding venue/grand hall |
| `images/events/pavilion/*` | `banquet` | Banquet hall/pavilion |
| `images/stay/rooms/*` | `room` | Room images (handled separately in `room_images` table) |

## 🚨 Important Notes

1. **Category Constraint**: The database constraint MUST include all categories. If you see "Category 'bar' not allowed" errors, the migration hasn't been run yet.

2. **Thumbnail URLs**: Thumbnails are stored in `properties/{property-id}/thumbnails/` subtree. The migration script automatically uploads them and stores the URL in `thumbnail_url` column.

3. **Strict Enforcement**: The migration script enforces canonical folder structure. Categories not matching the canonical structure will be normalized (e.g., `lounge` → `bar`, `fitness` → `spa`).

4. **Room Images**: Room images under `stay/rooms/` are NOT automatically inserted into `room_images` table. Use the generated CSV + SQL template for manual mapping.

## 🐛 Troubleshooting

### Issue: "Category 'bar' not allowed"
**Solution**: Run the migration `20250131000002_canonical_image_model_complete.sql` to add `bar` category to constraint.

### Issue: "Column 'thumbnail_url' does not exist"
**Solution**: Run the migration to add the `thumbnail_url` column.

### Issue: All images categorized as "other"
**Solution**: This was a bug in `inferCategoryFromPath()` - already fixed. Re-run migration script.

### Issue: Thumbnails not loading
**Solution**: 
1. Verify thumbnails were generated: `ls images/thumbnails/`
2. Verify thumbnails were uploaded: Check Supabase Storage `property-images/properties/{id}/thumbnails/`
3. Verify `thumbnail_url` is populated in database
4. Frontend service will derive from `image_url` if `thumbnail_url` is missing

## ✅ Verification Checklist

- [ ] Migration `20250131000002_canonical_image_model_complete.sql` applied
- [ ] Category constraint includes: `bar`, `banquet`, `wedding`, `meeting`
- [ ] Columns exist: `storage_path`, `storage_bucket`, `thumbnail_url`, `updated_at`
- [ ] Storage cleaned (no old images)
- [ ] Thumbnails generated (`images/thumbnails/` populated)
- [ ] Migration script run successfully
- [ ] All images categorized correctly (not all "other")
- [ ] Thumbnails uploaded to Supabase Storage
- [ ] `thumbnail_url` populated in database
- [ ] Frontend images load correctly (hero = full, gallery = thumbnail)
- [ ] All canonical categories display correctly in UI

## 📚 Related Files

- Migration: `supabase/migrations/20250131000002_canonical_image_model_complete.sql`
- Migration Script: `scripts/migrate-canonical-images.mjs`
- Thumbnail Generator: `scripts/generate-thumbnails.mjs`
- Cleanup Script: `scripts/cleanup-supabase-images.mjs`
- Frontend Service: `src/services/data/propertyImageService.ts`
- Types: `src/types/images.ts`
- Utilities: `src/utils/imageUtils.ts`
- Documentation: `scripts/README_IMAGE_MIGRATION.md`
