# Image Upload Guide - V3 Grand Hotel

## Overview
This guide explains how to upload the V3 Grand Hotel collage image to Supabase Storage and update the database.

## Method 1: Using Supabase Dashboard (Recommended)

### Step 1: Upload Image to Supabase Storage
1. Go to your Supabase Dashboard
2. Navigate to **Storage** → **Buckets**
3. Find or create the `property-images` bucket (or check what bucket name is used)
4. Click **Upload** and select your collage image
5. Name it: `v3-grand-hotel-hero-main.jpg` (or appropriate extension)
6. Copy the public URL after upload

### Step 2: Update Database
Run the SQL script with the public URL:

```sql
-- Open scripts/update-v3-grand-hotel-image.sql
-- Replace 'YOUR_IMAGE_URL_HERE' with the public URL from Step 1
-- Then run the script in Supabase SQL Editor
```

Or run directly in SQL Editor:

```sql
DO $$
DECLARE
  v_property_id UUID := '00000000-0000-0000-0000-000000000111';
  v_tenant_id UUID;
  v_image_url TEXT := 'YOUR_PUBLIC_URL_HERE'; -- Paste URL from Step 1
  v_image_key TEXT := 'v3-grand-hotel-hero-main.jpg';
BEGIN
  -- Get tenant_id
  SELECT tenant_id INTO v_tenant_id
  FROM properties
  WHERE id = v_property_id;
  
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Property not found';
  END IF;

  -- Insert or update
  INSERT INTO public_property_images (
    tenant_id,
    property_id,
    image_key,
    image_url,
    category,
    alt_text,
    sort_order
  ) VALUES (
    v_tenant_id,
    v_property_id,
    v_image_key,
    v_image_url,
    'exterior',
    'V3 Grand Hotel Madurai - Luxury accommodations with temple view, fine dining, world-class service, and infinity pool',
    1
  )
  ON CONFLICT (tenant_id, property_id, image_key) DO UPDATE SET
    image_url = EXCLUDED.image_url,
    alt_text = EXCLUDED.alt_text,
    sort_order = EXCLUDED.sort_order;
END $$;
```

## Method 2: Using Node.js Script

### Prerequisites
```bash
npm install @supabase/supabase-js
```

### Setup Environment Variables
```bash
export VITE_SUPABASE_URL="your-supabase-url"
export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
export IMAGE_URL="url-to-download-image-from"
# OR
export IMAGE_PATH="/path/to/local/image.jpg"
```

### Run Script
```bash
node scripts/upload-image-simple.js
```

## Method 3: Using Supabase CLI

### Upload via CLI
```bash
# Install Supabase CLI if not already installed
npm install -g supabase

# Login
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Upload image
supabase storage upload property-images v3-grand-hotel-hero-main.jpg --file /path/to/image.jpg
```

### Get Public URL
The public URL will be:
```
https://[project-ref].supabase.co/storage/v1/object/public/property-images/v3-grand-hotel-hero-main.jpg
```

Then use Method 1, Step 2 to update the database.

## Verify Upload

After uploading, verify the image is accessible:

```sql
SELECT 
  id,
  tenant_id,
  property_id,
  image_key,
  image_url,
  category,
  alt_text,
  sort_order
FROM public_property_images
WHERE property_id = '00000000-0000-0000-0000-000000000111'
  AND category = 'exterior'
ORDER BY sort_order;
```

Visit the property page to confirm the image displays correctly.

## Notes

- **Bucket Name**: Check your actual bucket name - it might be `property-images`, `images`, `public-images`, etc.
- **Image Format**: Supports JPG, PNG, WebP
- **Recommended Size**: 1920x1080 or larger for hero images
- **File Naming**: Use descriptive, unique names like `v3-grand-hotel-hero-main.jpg`

