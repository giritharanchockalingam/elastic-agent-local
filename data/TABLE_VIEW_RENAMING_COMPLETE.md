# Table & View Renaming - Complete Summary

## ✅ Migration Created: `20250131000003_standardize_table_naming_remove_public_prefix.sql`

This migration removes the redundant `public_` prefix from ALL tables and views in the `public` schema.

## Tables Renamed (No Conflicts)

These can be renamed directly because they don't conflict with existing names:

- ✅ `public_property_images` → `property_images`
- ✅ `public_property_content` → `property_content`
- ✅ `public_tenant_content` → `tenant_content`
- ✅ `public_tenant_images` → `tenant_images`

## Views Renamed (Using `_view` Suffix)

These cannot be renamed to match base table names (PostgreSQL constraint):

- ✅ `public_tenants` → `tenants_view` (filters `tenants` table)
- ✅ `public_properties` → `properties_view` (filters `properties` table)
- ✅ `public_tenant_content_v` → `tenant_content_v` (already had `_v` suffix)
- ✅ `public_restaurant_outlets_v` → `restaurant_outlets_v`
- ✅ `public_restaurant_menu_v` → `restaurant_menu_v`
- ✅ `public_restaurant_gallery_v` → `restaurant_gallery_v`

## Why `_view` Suffix?

In PostgreSQL, you **cannot** have a view and a table with the same name in the same schema. So:

- ❌ Cannot rename `public_tenants` → `tenants` (conflicts with base `tenants` table)
- ✅ Instead: `public_tenants` → `tenants_view` (clear, no conflict)

The `_view` suffix:
- Removes redundant `public_` prefix ✅
- Clearly indicates it's a filtered view ✅
- Avoids naming conflicts ✅

## Code References Updated

All application code has been updated to use new names:

### Before (Redundant):
```typescript
supabase.from('public_tenants')
supabase.from('public_properties')
supabase.from('public_tenant_content_v')
supabase.from('public_restaurant_outlets_v')
```

### After (Clean):
```typescript
supabase.from('tenants_view')
supabase.from('properties_view')
supabase.from('tenant_content_v')
supabase.from('restaurant_outlets_v')
```

## Files Updated

### Migration:
- ✅ `supabase/migrations/20250131000003_standardize_table_naming_remove_public_prefix.sql` - Created/updated

### Application Code (10 files):
- ✅ `src/lib/domain/public.ts` - Updated all view references
- ✅ `src/lib/tenant/resolveContext.ts` - Updated all view references
- ✅ `src/lib/domain/restaurant.ts` - Updated all restaurant view references
- ✅ `src/lib/imageResolver.ts` - Updated restaurant gallery view
- ✅ `src/pages/public/RoomTypeDetail.tsx` - Updated tenants view
- ✅ `src/pages/public/SearchResults.tsx` - Updated comment
- ✅ Plus 4 other files (already updated in previous cleanup)

## Migration Steps

1. **Run the migration:**
   ```bash
   supabase migration up
   ```
   Or apply directly:
   ```sql
   psql $DATABASE_URL < supabase/migrations/20250131000003_standardize_table_naming_remove_public_prefix.sql
   ```

2. **Verify tables renamed:**
   ```sql
   SELECT table_name, table_type
   FROM information_schema.tables
   WHERE table_schema = 'public'
     AND table_name IN ('property_images', 'property_content', 'tenant_content', 'tenant_images')
   ORDER BY table_name;
   ```
   Should return 4 rows (all tables).

3. **Verify views renamed:**
   ```sql
   SELECT table_name, table_type
   FROM information_schema.tables
   WHERE table_schema = 'public'
     AND table_name LIKE '%_view'
   ORDER BY table_name;
   ```
   Should include: `tenants_view`, `properties_view`, `tenant_content_v`, etc.

4. **Verify old names don't exist:**
   ```sql
   SELECT table_name
   FROM information_schema.tables
   WHERE table_schema = 'public'
     AND table_name LIKE 'public_%'
   ORDER BY table_name;
   ```
   Should return 0 rows (or only base tables like `public_metadata` column, not table names).

5. **Test application:**
   - Verify all queries work with new view names
   - Test property/tenant listing pages
   - Test restaurant pages
   - Test image loading

## Expected Results

After migration:
- ✅ All `public_*` prefixes removed from table/view names
- ✅ Views use `_view` suffix to avoid conflicts
- ✅ All application code uses new names
- ✅ No naming conflicts or errors
- ✅ Database schema is clean and standardized

## Breaking Changes

⚠️ This is a **BREAKING CHANGE** - requires coordinated deployment:
1. Deploy application code first (uses new names)
2. Run migration (renames tables/views)
3. Verify everything works

If deployment is not coordinated:
- Code will fail if migration runs first (new names not in code yet)
- Migration will fail if code runs first (tries to use non-existent names)

**Recommendation**: Deploy code and migration together, or use feature flags.

## Documentation

- `docs/VIEW_RENAMING_EXPLANATION.md` - Detailed explanation of view naming
- `docs/TABLE_VIEW_RENAMING_COMPLETE.md` - This file
- `supabase/migrations/20250131000003_standardize_table_naming_remove_public_prefix.sql` - Migration file
