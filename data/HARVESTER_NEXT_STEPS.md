# Harvester Next Steps - After Successful Dry-Run

## ✅ Current Status

Your dry-run was **successful**! The harvester extracted:
- **8 rooms** from thethangamgrand.com
- **1 service** 
- Images, location, and other facts

The error at the end is just a shell interpretation issue (harmless).

## Next Steps

### Step 1: Run Database Migration

Apply the migration to create the content tables:

```bash
# If using Supabase CLI locally
supabase migration up 20250121000007_public_property_content_tables

# Or run the SQL file directly in Supabase SQL Editor
# File: supabase/migrations/20250121000007_public_property_content_tables.sql
```

This creates:
- `public_property_content` table
- `public_property_images` table  
- `public_ingestion_runs` table
- `public-assets` storage bucket

### Step 2: Set Environment Variables

Create a `.env.local` file (or export in your shell):

```bash
# For apply mode (server-side only)
export SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co
export SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
```

**Get Service Role Key:**
1. Go to: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/settings/api
2. Find "service_role" key (NOT anon key)
3. Click "Reveal" and copy it

⚠️ **Security:** Never commit the service role key to git!

### Step 3: Run Apply Mode

Once migration is applied and env vars are set:

```bash
npm run harvest:thangamgrand:npm -- --tenant <your-tenant-id> --property <your-property-id> --apply
```

This will:
1. ✅ Rewrite content into original marketing copy
2. ✅ Download images (up to 50)
3. ✅ Deduplicate by SHA256 hash
4. ✅ Upload to Supabase Storage
5. ✅ Write content to database
6. ✅ Log the run

### Step 4: View Results

After apply mode completes, visit:
```
/{brandSlug}/{propertySlug}
```

For example:
```
/grand-hospitality/downtown-hotel
```

You should see:
- Gallery carousel with harvested images
- Rewritten hero title/subtitle
- Services grid
- Room cards from harvested content
- Nearby attractions
- FAQ section

## Troubleshooting

### Error: "Domain not in allowlist"
- Check `config/harvest.allowlist.json`
- Ensure `thethangamgrand.com` is in the array

### Error: "Missing Supabase credentials"
- Set `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` environment variables
- Use service role key (not anon key)

### Error: "Table does not exist"
- Run the migration: `20250121000007_public_property_content_tables.sql`

### Error: "Bucket does not exist"
- The migration should create it automatically
- If not, create manually in Supabase Dashboard → Storage

### Images not uploading
- Check storage bucket permissions
- Verify service role key has storage write access
- Check image URLs are accessible (not blocked by CORS)

## Expected Output from Apply Mode

```
🌐 Harvesting from: thethangamgrand.com
📋 Mode: apply
⏱️  Delay: 250ms between requests
📄 Max pages: 25
📥 Fetching: https://thethangamgrand.com

📊 Extracted Facts:
{...}

✍️  Rewriting content...

📤 Applying harvest to database...
✅ Created ingestion run: <run-id>

🖼️  Processing 20 images...
  [1/20] https://thethangamgrand.com/images/...
    ✅ Uploaded: https://...
  [2/20] ...
    ⏭️  Skipped (duplicate)
  ...

✅ Processed 18 images

📝 Writing content to database...
✅ Content written to database

✅ Harvest applied successfully!
📊 Stats: 8 rooms, 1 services, 18 images
```

## Verification

After apply mode, verify in Supabase:

```sql
-- Check content
SELECT * FROM public_property_content 
WHERE property_id = '<your-property-id>';

-- Check images
SELECT COUNT(*) FROM public_property_images 
WHERE property_id = '<your-property-id>';

-- Check ingestion run
SELECT * FROM public_ingestion_runs 
WHERE property_id = '<your-property-id>' 
ORDER BY created_at DESC LIMIT 1;
```

## Next: Enhance Extraction

The current extraction found 8 rooms and 1 service. You can enhance the extraction logic in:
- `scripts/harvest-and-rewrite-property-site.ts`
- Functions: `extractRooms()`, `extractServices()`, etc.

Add more specific selectors for thethangamgrand.com's HTML structure to extract more data.

