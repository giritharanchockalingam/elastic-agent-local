# View Renaming Explanation

## Why Views Can't Have Same Names as Base Tables

In PostgreSQL, you **cannot** have a view and a table with the same name in the same schema. This is why:

- ❌ `public_tenants` view cannot be renamed to `tenants` (conflicts with base `tenants` table)
- ❌ `public_properties` view cannot be renamed to `properties` (conflicts with base `properties` table)

## Solution: Use `_view` Suffix

Views are renamed to remove the redundant `public_` prefix while maintaining clarity:

- ✅ `public_tenants` → `tenants_view`
- ✅ `public_properties` → `properties_view`
- ✅ `public_tenant_content_v` → `tenant_content_v` (already had `_v` suffix, just removed prefix)
- ✅ `public_restaurant_outlets_v` → `restaurant_outlets_v`
- ✅ `public_restaurant_menu_v` → `restaurant_menu_v`
- ✅ `public_restaurant_gallery_v` → `restaurant_gallery_v`

## Tables: Full Prefix Removal

Tables CAN have their prefix removed because they don't conflict:

- ✅ `public_property_images` → `property_images`
- ✅ `public_property_content` → `property_content`
- ✅ `public_tenant_content` → `tenant_content`
- ✅ `public_tenant_images` → `tenant_images`

## Updated Code References

All code references have been updated:

```typescript
// BEFORE (redundant prefix):
supabase.from('public_tenants')
supabase.from('public_properties')
supabase.from('public_tenant_content_v')
supabase.from('public_restaurant_outlets_v')

// AFTER (clean names):
supabase.from('tenants_view')
supabase.from('properties_view')
supabase.from('tenant_content_v')
supabase.from('restaurant_outlets_v')
```

## Migration Impact

The migration `20250131000003_standardize_table_naming_remove_public_prefix.sql`:
1. ✅ Drops old views (CASCADE to handle dependencies)
2. ✅ Renames tables (removes `public_` prefix)
3. ✅ Recreates views with new names (using `_view` suffix)
4. ✅ Updates grants on new views
5. ✅ Updates view definitions to reference renamed tables/views

## Files Updated

- `src/lib/domain/public.ts` - Updated all view references
- `src/lib/tenant/resolveContext.ts` - Updated all view references
- `src/lib/domain/restaurant.ts` - Updated all view references
- `src/lib/imageResolver.ts` - Updated restaurant gallery view
- `src/pages/public/RoomTypeDetail.tsx` - Updated tenants view

## Next Steps

1. Run the migration:
   ```bash
   supabase migration up
   ```

2. Verify views exist:
   ```sql
   SELECT table_name, table_type
   FROM information_schema.tables
   WHERE table_schema = 'public'
     AND table_name LIKE '%_view'
   ORDER BY table_name;
   ```

3. Verify old views don't exist:
   ```sql
   SELECT table_name
   FROM information_schema.tables
   WHERE table_schema = 'public'
     AND table_name LIKE 'public_%'
   ORDER BY table_name;
   ```

4. Test application queries work with new view names
