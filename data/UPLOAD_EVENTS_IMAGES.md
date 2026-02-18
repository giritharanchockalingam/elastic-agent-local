# Upload Events Images - Quick Guide

## ✅ Status
All 18 images have been generated successfully!

## Next Step: Upload to Supabase

### 1. Set Environment Variables

```bash
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
```

**To get your credentials:**
- **SUPABASE_URL**: From your Supabase Dashboard → Settings → API → Project URL
- **SUPABASE_SERVICE_ROLE_KEY**: From your Supabase Dashboard → Settings → API → service_role key (secret)

### 2. Upload Images

```bash
node scripts/upload-events-images.mjs
```

### What the Script Does

1. **Scans** generated images from `/Users/giritharanchockalingam/Projects/images/events-generated/`
2. **Uploads** to Supabase storage bucket `images` with paths:
   - `events/grand-hall/v3-grand-hotel-events-grand-hall-01.jpg` (etc.)
   - `events/pavilion/v3-grand-hotel-events-pavilion-01.jpg` (etc.)
   - `events/forum/v3-grand-hotel-events-forum-01.jpg` (etc.)
3. **Inserts** records into `public_property_images` with:
   - Category: `'wedding'` (Grand Hall), `'banquet'` (Pavilion), `'meeting'` (Forum)
   - Image key: `events/{space-slug}/{filename}`
   - Alt text: Space-specific descriptions
   - Sort order: Based on filename number (01, 02, etc.)
   - SHA256 hash: For deduplication

### Expected Output

```
📤 Upload Plan
   Total images: 18
   Spaces: 3
   Storage bucket: images

[1/18] grand-hall/v3-grand-hotel-events-grand-hall-01.jpg
   📤 Uploading to storage...
   ✅ Uploaded: https://...
   💾 Inserting database record...
   ✅ Record inserted (category: wedding, sort_order: 1)

... (continues for all 18 images)

✅ Upload Complete
   Success: 18
   Errors: 0
```

### 3. Verify Images

After uploading, verify in Supabase:

```sql
SELECT category, COUNT(*) as count
FROM public_property_images
WHERE property_id = '00000000-0000-0000-0000-000000000111'
  AND image_key LIKE 'events/%'
GROUP BY category
ORDER BY category;
```

Expected:
- `banquet`: 6 images (Pavilion)
- `meeting`: 6 images (Forum)
- `wedding`: 6 images (Grand Hall)

### 4. Check Public Portal

Visit these pages to see the images:
- `/property/v3-grand-hotel/events/grand-hall` - Should show 6 Grand Hall images
- `/property/v3-grand-hotel/events/pavilion` - Should show 6 Pavilion images
- `/property/v3-grand-hotel/events/forum` - Should show 6 Forum images
- `/property/v3-grand-hotel/events/gallery` - Should show all 18 images categorized

## Troubleshooting

### "SUPABASE_URL missing"
- Set the environment variable: `export SUPABASE_URL="https://your-project.supabase.co"`

### "SUPABASE_SERVICE_ROLE_KEY missing"
- Set the environment variable: `export SUPABASE_SERVICE_ROLE_KEY="your-key"`
- Get it from Supabase Dashboard → Settings → API → service_role key

### "Upload failed"
- Check your Supabase storage bucket `images` exists
- Verify RLS policies allow inserts
- Check network connection

### "Insert failed"
- Verify the migration was applied (categories include 'wedding', 'banquet', 'meeting')
- Check that property_id exists in the database

## Summary

✅ Images generated: 18 (6 per space)
⏳ Next: Upload to Supabase
✅ After upload: Images will display on Events pages
