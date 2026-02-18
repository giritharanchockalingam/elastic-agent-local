# Restaurant Harvest CLI - Troubleshooting Guide

## Common Issues

### HTTP 404: Not Found

**Problem**: The URL returns a 404 error.

**Solutions**:
1. **Verify URL is correct**: Open the URL in your browser to confirm it's accessible
2. **Use the right page**: For Marriott hotels, try:
   - Hotel overview page: `https://www.marriott.com/en-us/hotels/[hotel-code]/overview/`
   - Dining page: `https://www.marriott.com/en-us/hotels/[hotel-code]/dining/`
   - Restaurant page: `https://www.marriott.com/en-us/hotels/[hotel-code]/dining/[restaurant-name]/`
3. **Check URL format**: Ensure it starts with `https://` (not `http://` or missing protocol)
4. **Try a different site**: Use any publicly accessible restaurant website for testing

**Example Valid URLs**:
- Marriott hotel dining: `https://www.marriott.com/en-us/hotels/ixmcy-courtyard-madurai/dining/`
- Any public restaurant website (must be in allowlist)

### HTTP 403: Forbidden

**Problem**: The website blocks programmatic access.

**Solutions**:
1. Some sites require authentication or have anti-bot protection
2. Try a different restaurant website that's more accessible
3. The harvester uses a standard User-Agent, but some sites may still block it

### Domain Not in Allowlist

**Problem**: Domain is not in `config/harvest.allowlist.json`.

**Solution**: Add the domain to the allowlist:
```json
{
  "allowedDomains": [
    "thethangamgrand.com",
    "marriott.com",
    "your-restaurant-site.com"
  ]
}
```

### Network Errors

**Problem**: Connection timeout or network errors.

**Solutions**:
1. Check your internet connection
2. Verify the website is accessible from your network
3. Some corporate networks may block certain websites

## Testing Recommendations

### For Development/Testing

Instead of using Marriott (which may require specific URLs), you can:

1. **Use the seed data**: The seed migration already creates demo content
2. **Test with any public restaurant site**: Add it to allowlist and test
3. **Use local/test HTML**: Create a test HTML file and serve it locally

### Finding Valid Marriott Restaurant URLs

1. Go to https://www.marriott.com/
2. Search for a hotel (e.g., "Courtyard Madurai")
3. Navigate to the hotel's page
4. Look for "Dining" or "Restaurants" section
5. Copy the full URL from the browser address bar

## Example Usage

```bash
# Dry-run with a valid URL
npm run harvest:restaurant:benchmark:npm -- \
  --url "https://www.example-restaurant.com" \
  --dry-run

# If URL is valid, apply to database
npm run harvest:restaurant:benchmark:npm -- \
  --url "https://www.example-restaurant.com" \
  --apply \
  --tenant "00000000-0000-0000-0000-000000000001" \
  --property "00000000-0000-0000-0000-000000000011" \
  --outlet "<outlet-uuid>"
```

## Finding Outlet ID

To find the outlet ID for the `--outlet` parameter:

```sql
SELECT id, name, outlet_slug, property_id 
FROM restaurants 
WHERE property_id = '<your-property-id>'
ORDER BY name;
```

Or use the helper script:
```bash
npm run find:ids:npm
```

## Notes

- The harvester extracts **facts only**, not verbatim text
- All content is rewritten to ensure originality
- Images are stored as URLs (full download/upload can be added later)
- Menu items are linked to categories when possible
- Prices are parsed from various formats (₹, $, etc.)

