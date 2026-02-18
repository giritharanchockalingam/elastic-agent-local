# Fix: Events Categories Migration Error

## Problem

Error: `check constraint "public_property_images_category_check" of relation "public_property_images" is violated by some row`

This happens because there are existing rows in the table with categories that are not in the new constraint.

## Solution

Use the **safe migration script** that:
1. Updates invalid categories to 'other' first
2. Then applies the new constraint

## Steps

1. **Open Supabase Dashboard** → **SQL Editor** → **New Query**

2. **Copy and run** the contents of `db-scripts/add-events-categories-safe.sql`:

```sql
-- Step 1: Check existing categories (optional, for information)
SELECT category, COUNT(*) as count
FROM public.public_property_images
GROUP BY category
ORDER BY count DESC;

-- Step 2: Update invalid categories to 'other'
UPDATE public.public_property_images
SET category = 'other'
WHERE category NOT IN (
  'reception', 'lobby', 'restaurant', 'spa', 'pool', 'parking', 
  'room', 'exterior', 'other',
  'banquet', 'wedding', 'meeting'
);

-- Step 3: Drop existing constraint
ALTER TABLE public.public_property_images
DROP CONSTRAINT IF EXISTS public.public_property_images_category_check;

-- Step 4: Recreate with event categories
ALTER TABLE public.public_property_images
ADD CONSTRAINT public_property_images_category_check 
CHECK (category IN (
  'reception', 'lobby', 'restaurant', 'spa', 'pool', 'parking', 
  'room', 'exterior', 'other',
  'banquet', 'wedding', 'meeting'
));

-- Step 5: Add comment
COMMENT ON COLUMN public.public_property_images.category IS 
'Image category: reception, lobby, restaurant, spa, pool, parking, room, exterior, other, banquet (banquet halls), wedding (weddings/receptions), meeting (meetings/conferences)';

-- Step 6: Verify constraint
SELECT 
  constraint_name,
  check_clause
FROM information_schema.check_constraints
WHERE table_name = 'public_property_images'
  AND constraint_name LIKE '%category%';

-- Step 7: Show final category distribution
SELECT category, COUNT(*) as count
FROM public.public_property_images
GROUP BY category
ORDER BY count DESC;
```

3. **Click Run**

## What Happens

1. The script first shows what categories currently exist
2. Updates any rows with invalid categories to 'other'
3. Drops the old constraint
4. Creates the new constraint with event categories
5. Verifies the constraint was applied
6. Shows the final category distribution

## After Migration

Once the migration succeeds, you can:

1. **Generate event images**:
```bash
export OPENAI_API_KEY="your-key"
node scripts/generate-events-images.mjs
```

2. **Upload event images**:
```bash
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
node scripts/upload-events-images.mjs
```

The uploaded images will use the new categories:
- `'wedding'` for Grand Hall images
- `'banquet'` for Pavilion images
- `'meeting'` for Forum images
