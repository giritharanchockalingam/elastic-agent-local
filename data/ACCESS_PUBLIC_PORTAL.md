# How to Access the Public Portal

## Quick Access URLs

Based on your seeded data, here are the direct URLs:

### Tenant Landing Page
```
http://localhost:8080/grand-hospitality
```
This shows all properties for the "Grand Hospitality Group" brand.

### Property Landing Page (with harvested content!)
```
http://localhost:8080/grand-hospitality/airport-hotel
```
This shows the property landing page with:
- ✅ Hero section with harvested title/subtitle
- ✅ Gallery carousel (46 images from thethangamgrand.com)
- ✅ Services section
- ✅ Room cards (8 rooms)
- ✅ Nearby attractions
- ✅ FAQ section
- ✅ Lead capture CTAs

### Other Property Pages

**Rooms Listing:**
```
http://localhost:8080/grand-hospitality/airport-hotel/rooms
```

**Booking Flow:**
```
http://localhost:8080/grand-hospitality/airport-hotel/book
```

**Dining/Restaurants:**
```
http://localhost:8080/grand-hospitality/airport-hotel/dining
```

## Start the Dev Server

If the server isn't running:

```bash
cd /Users/giritharanchockalingam/Desktop/GitHub/hms-gcp-refactor
npm run dev
```

The server will start on: **http://localhost:8080**

## Production URLs

Once deployed to Vercel, the URLs will be:

```
https://your-vercel-domain.vercel.app/grand-hospitality
https://your-vercel-domain.vercel.app/grand-hospitality/airport-hotel
```

## What You'll See

On the property landing page (`/grand-hospitality/airport-hotel`), you should see:

1. **Hero Section**
   - Title: "Experience Our Property" (from harvester)
   - Subtitle and description (rewritten from thethangamgrand.com)

2. **Gallery Carousel**
   - 46 images from the harvested site
   - Auto-rotating carousel

3. **Services Section**
   - Services/amenities extracted from the site

4. **Room Cards**
   - 8 room types displayed as cards
   - Images, descriptions, features

5. **CTA Sections**
   - "Book Your Stay" buttons
   - "Contact Us" forms
   - Lead capture

## Available Properties

From your database:
- **Brand**: Grand Hospitality Group (`grand-hospitality`)
- **Property**: Grand Airport Hotel (`airport-hotel`)
  - ID: `00000000-0000-0000-0000-000000000011`
  - Status: Active, Public
  - Has harvested content: ✅ Yes (46 images, 8 rooms, content)

## Troubleshooting

**404 Error?**
- Check that the tenant/property has `is_public = TRUE` in the database
- Verify slugs match exactly: `grand-hospitality` and `airport-hotel`
- Check browser console for errors

**No Content Showing?**
- Verify the harvester ran successfully (check ingestion run status)
- Check that `public_property_content` table has data
- Check that `public_property_images` table has images

**Images Not Loading?**
- Verify Supabase Storage bucket `public-assets` exists
- Check that images are public (RLS policies allow anon read)
- Check browser console for 403/404 errors on image URLs

## Quick Test

1. Start dev server: `npm run dev`
2. Open: http://localhost:8080/grand-hospitality/airport-hotel
3. You should see the full property landing page with harvested content!

