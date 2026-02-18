# Quick Fix: Missing `thumbnail_url` Column Error

## Error Message
```
Could not find the 'thumbnail_url' column of 'public_property_images' in the schema cache
```

## Cause
The migration `20250131000002_canonical_image_model_complete.sql` hasn't been run yet, so the `thumbnail_url`, `storage_path`, and `storage_bucket` columns don't exist in the database.

## Solution: Run the Migration First

### Option 1: Via Supabase Dashboard (Recommended)

1. **Go to Supabase Dashboard:**
   ```
   https://supabase.com/dashboard/project/YOUR_PROJECT_ID
   ```

2. **Navigate to SQL Editor:**
   - Click: **SQL Editor** → **New Query**

3. **Run the Migration:**
   - Open file: `supabase/migrations/20250131000002_canonical_image_model_complete.sql`
   - Copy entire contents
   - Paste into SQL Editor
   - Click **Run**

4. **Verify Migration:**
   ```sql
   -- Check if columns exist
   SELECT column_name, data_type 
   FROM information_schema.columns 
   WHERE table_schema = 'public' 
     AND table_name = 'public_property_images'
     AND column_name IN ('thumbnail_url', 'storage_path', 'storage_bucket', 'updated_at')
   ORDER BY column_name;
   ```
   
   **Expected:** Should return 4 rows

### Option 2: Continue Without Migration (Temporary)

The migration script now handles missing columns gracefully:

- ✅ Will continue with base columns only (`image_key`, `image_url`, `category`, etc.)
- ⚠️ `thumbnail_url` won't be stored (but thumbnails will still be uploaded to storage)
- ⚠️ `storage_path` and `storage_bucket` won't be stored (but images will still work)
- ✅ You can add these columns later and re-run migration to populate them

**However, it's strongly recommended to run the migration first** to get full features.

## After Running Migration

1. **Re-run the image migration:**
   ```bash
   node scripts/migrate-canonical-images.mjs
   ```

2. **Expected Output:**
   - ✅ No errors about missing columns
   - ✅ All images processed successfully
   - ✅ `thumbnail_url` stored in database
   - ✅ `storage_path` and `storage_bucket` stored

## What the Migration Adds

The migration `20250131000002_canonical_image_model_complete.sql` adds:

1. **`storage_path`** - Canonical storage path (e.g., `properties/{id}/dining/bar/filename.jpg`)
2. **`storage_bucket`** - Storage bucket name (`property-images`)
3. **`thumbnail_url`** - Public URL to 960px thumbnail
4. **`updated_at`** - Timestamp for tracking updates
5. **Category constraint update** - Adds `bar`, `banquet`, `wedding`, `meeting` categories
6. **Indexes** - Performance indexes on new columns
7. **Trigger** - Auto-update `updated_at` on row updates

## Verification Checklist

After running migration:

- [ ] `thumbnail_url` column exists
- [ ] `storage_path` column exists
- [ ] `storage_bucket` column exists
- [ ] `updated_at` column exists
- [ ] Category constraint includes: `bar`, `banquet`, `wedding`, `meeting`
- [ ] Migration script runs without column errors
- [ ] Images are inserted with all columns populated
