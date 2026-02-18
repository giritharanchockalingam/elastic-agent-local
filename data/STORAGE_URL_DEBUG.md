# Storage URL Debugging Guide

## Issue
Browser shows DNS error with malformed URL: `.costorage` instead of `.co/storage`

## Expected URL Format
```
https://qnwsnrfcnonaxvnithfv.supabase.co/storage/v1/object/public/images/rooms/v3-grand-rooms-deluxe-01.jpg
```

## Actual Error URL
```
https://qnwsnrfcnonaxvnithfv.supabase.costorage/v1/object/public/images/rooms/v3-grand-rooms-deluxe-01.jpg
```

## Debugging Steps

### 1. Check Browser Console
Open browser DevTools → Console and look for:
```
[StorageUrl] Generated URL: { bucket: 'images', storagePath: '...', publicUrl: '...' }
```

### 2. Check Network Tab
- Open DevTools → Network
- Filter by "images" or the filename
- Check the actual request URL
- Look at the "Request URL" field

### 3. Verify Environment Variables
Check `.env` file:
```bash
# Should be (NO trailing slash):
VITE_SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co

# Should NOT be:
VITE_SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co/
```

### 4. Verify Database Values
Run this SQL query in Supabase Dashboard:
```sql
SELECT 
  id,
  storage_bucket,
  storage_path,
  image_url,
  category
FROM public_property_images
WHERE storage_path IS NOT NULL
LIMIT 5;
```

Expected `storage_path` format: `rooms/v3-grand-rooms-deluxe-01.jpg`
- Should NOT have leading `/`
- Should NOT include `storage/v1/object/public/`
- Should be: `{category}/{filename}`

### 5. Test URL Generation
Open browser console on any page and run:
```javascript
// Check Supabase client URL
console.log('Supabase URL:', window.location.origin);

// Check if images are loading
document.querySelectorAll('img[src*="supabase"]').forEach(img => {
  console.log('Image URL:', img.src);
});
```

## Potential Issues

1. **Supabase URL has trailing slash** - Should not have trailing `/`
2. **storage_path includes full path** - Should only be `{category}/{filename}`
3. **Browser caching old URLs** - Clear cache and hard reload (Cmd+Shift+R / Ctrl+Shift+R)
4. **Supabase client misconfiguration** - Verify client initialization

## Solution Applied

Added path normalization in `src/lib/images/storageUrl.ts`:
- Removes leading/trailing slashes from `storage_path`
- Adds debug logging in development mode
- Proper error handling

## Next Steps

1. Check browser console for debug logs
2. Verify `.env` file has correct `VITE_SUPABASE_URL` (no trailing slash)
3. Clear browser cache and hard reload
4. Check database `storage_path` values are correctly formatted
5. If issue persists, check Network tab for actual request URLs
