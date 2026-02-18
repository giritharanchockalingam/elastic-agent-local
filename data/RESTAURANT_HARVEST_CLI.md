# Restaurant Harvest CLI - Step 4 Complete ✅

## Overview

The Restaurant Harvest CLI extracts structured facts from public restaurant websites (e.g., Marriott) and rewrites them into original marketing copy for the restaurant portal.

## Files Created

1. **`scripts/harvest-restaurant-benchmark.ts`** - Main CLI script
2. **`src/lib/ingestion/restaurantTypes.ts`** - Type definitions for restaurant extraction
3. **`src/lib/ingestion/rewriteRestaurant.ts`** - Rewrite engine for restaurant content

## Usage

### Dry-Run Mode (Preview Only)
```bash
npm run harvest:restaurant:benchmark:npm -- --url "https://www.marriott.com/en-us/hotels/ixmcy-courtyard-madurai/overview/" --dry-run
```

### Apply Mode (Write to Database)
```bash
npm run harvest:restaurant:benchmark:npm -- \
  --url "https://www.marriott.com/en-us/hotels/ixmcy-courtyard-madurai/overview/" \
  --apply \
  --tenant <tenantId> \
  --property <propertyId> \
  --outlet <outletId>
```

## What It Extracts

### Restaurant Facts
- **Outlet Name** - Restaurant name from page headings
- **Description** - Meta description or hero text
- **Cuisine Type** - Primary cuisine (e.g., "South Indian", "Continental")
- **Cuisine Tags** - Array of cuisine keywords
- **Hours** - Operating hours by day of week
- **Phone** - Contact phone number
- **Address** - Physical address
- **Location** - City, state, country

### Menu Data
- **Menu Categories** - Category names and descriptions
- **Menu Items** - Item names, descriptions, prices, dietary tags

### Gallery Images
- **Images** - Restaurant images with alt text and categorization
- **Categories** - interior, exterior, food, ambiance, events, general

## What It Writes (Apply Mode)

1. **Updates Restaurant Outlet**:
   - `description_public`
   - `hours_json`
   - `phone_public`
   - `address_public`
   - `cuisine_type`
   - `cuisine_tags`

2. **Creates/Updates Menu Categories**:
   - Checks if category exists, updates or inserts

3. **Creates/Updates Menu Items**:
   - Links items to categories
   - Parses prices (₹, $, etc.) to cents
   - Extracts dietary tags and spice levels

4. **Creates Gallery Images**:
   - Stores image URLs (placeholder - full download/upload can be added later)

## Safety Features

✅ **Allowlist Enforcement** - Only allowed domains (marriott.com already added)
✅ **Dry-Run by Default** - No writes unless `--apply` flag
✅ **Rate Limiting** - 750ms delay between requests (configurable)
✅ **Max Pages** - Limited to 10 pages per run
✅ **Originality Checks** - Rewrite engine ensures no >6 consecutive words reused
✅ **Legal Compliance** - Extracts facts only, generates original copy

## Rewrite Engine Rules

The `rewriteRestaurantContent()` function:
- Never reuses >6 consecutive words from source
- Generates premium, conversion-focused copy
- Brand-neutral (works if tenant rebrands)
- No trademark claims
- Infers dietary tags and spice levels intelligently
- Parses prices from various formats (₹, $, etc.)

## Example Output

```json
{
  "heroTitle": "Experience Madurai Kitchen",
  "heroSubtitle": "Discover South Indian & Chettinad in an elegant setting",
  "description": "Nestled in Madurai, Veda offers...",
  "menuCategories": [
    {
      "name": "Breakfast",
      "description": "Start your day with our selection of morning favorites..."
    }
  ],
  "menuItems": [
    {
      "name": "Masala Dosa",
      "description": "A carefully prepared masala dosa...",
      "priceCents": 25000,
      "currency": "INR",
      "dietaryTags": ["vegetarian"]
    }
  ]
}
```

## Configuration

Edit `config/harvest.allowlist.json` to add/remove allowed domains:

```json
{
  "allowedDomains": [
    "thethangamgrand.com",
    "marriott.com"
  ],
  "maxPages": 10,
  "delayMs": 750
}
```

## Finding IDs

Use the helper script to find tenant/property/outlet IDs:

```bash
npm run find:ids:npm
```

Or query directly:
```sql
SELECT id, name, outlet_slug FROM restaurants WHERE property_id = '<propertyId>';
```

## Next Steps

The harvester is ready to use! You can:
1. Test with dry-run mode on Marriott URL
2. Apply to existing restaurant outlet
3. Enhance with image download/upload to Supabase Storage (optional)
4. Add more sophisticated menu item → category matching (optional)

