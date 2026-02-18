# Why `public_*` Tables? Naming Convention Explanation

## Overview

The `public_*` table naming convention was **intentionally chosen** for the Public Portal feature to clearly distinguish public-facing content from internal/private data. This is a **security and architectural pattern**, not a deviation from standards.

## Purpose of `public_*` Tables

### 1. **Security Boundary**
The `public_*` prefix signals that these tables/views are:
- ✅ Safe for **anonymous (anon)** access
- ✅ Accessible via **Row-Level Security (RLS)** with public policies
- ✅ Contain **no PII** (Personally Identifiable Information)
- ✅ Only expose **publicly intended** content

### 2. **Separation of Concerns**

**Internal Tables** (no prefix):
- `tenants` - Contains internal data (email, phone, settings, billing info)
- `properties` - Contains PII (contact info, addresses, internal settings)
- `reservations` - Contains guest PII
- `payments` - Contains financial data
- `users`, `user_roles` - Contains authentication/authorization data

**Public Tables** (with `public_` prefix):
- `public_property_images` - Public-facing property images (no sensitive data)
- `public_property_content` - Public-facing marketing content
- `public_tenants` - **View** exposing only safe tenant fields
- `public_properties` - **View** exposing only safe property fields

### 3. **RLS Policy Enforcement**

The naming convention makes it clear which tables have:
- ✅ **Anonymous read access** - `public_*` tables/views
- ❌ **Authenticated only** - Regular tables require authentication

## Table Structure

### `public_property_images`
**Purpose**: Store property images for public portal display

**Columns**:
- `id` (UUID)
- `tenant_id`, `property_id` (Foreign keys)
- `image_key`, `image_url` (Public URLs - safe)
- `alt_text`, `category` (Display text - safe)
- `sort_order` (Display ordering)
- `sha256_hash` (Deduplication)
- `storage_path`, `storage_bucket`, `thumbnail_url` (Storage metadata)

**Why not `property_images`?**
- `property_images` could be confused with internal/protected image storage
- `public_` prefix signals this is for public consumption
- Allows separate internal image tables if needed (e.g., `internal_property_images` for staff-only content)

### `public_tenants` and `public_properties`
**Type**: Views (not tables)

**Purpose**: Expose only safe fields from `tenants` and `properties` tables

**Example**:
```sql
CREATE VIEW public.public_properties AS
SELECT 
  id,
  name,              -- Safe
  property_slug,     -- Safe
  city, state,       -- Safe
  star_rating,       -- Safe
  -- NOT included: email, phone, address (PII)
  -- NOT included: settings (may contain sensitive config)
FROM public.properties
WHERE is_public = TRUE AND status = 'active';
```

**Why views?**
- Views provide a **security boundary** - no direct table access for anonymous users
- Views can filter out PII before exposing data
- Views can add computed columns (e.g., `location_summary`)
- RLS policies on views are easier to manage than on base tables

## Migration History

The `public_*` tables were created as part of the **Public Portal** feature:

1. **Migration**: `20250121000007_public_property_content_tables.sql`
   - Created `public_property_content` table
   - Created `public_property_images` table
   - Created `public-assets` storage bucket

2. **Migration**: `20250121000000_public_portal_slugs_complete.sql`
   - Created `public_tenants` view
   - Created `public_properties` view
   - Set up RLS policies

3. **Migration**: `20250121000012_public_tenant_content.sql`
   - Created `public_tenant_content` table
   - Created `public_tenant_images` table

## Alternative Approaches Considered

### Option 1: Use `portal_*` prefix
- ❌ Rejected: Less clear about security implications
- ✅ `public_` is more explicit about anonymous access

### Option 2: Use schema separation (`public` vs `internal`)
- ❌ Rejected: Supabase uses single `public` schema by default
- ✅ Prefix-based separation is clearer within single schema

### Option 3: Use same table with RLS filtering
- ❌ Rejected: Risk of accidentally exposing PII if RLS policies misconfigured
- ✅ Separate views/tables provide explicit security boundary

## Best Practices

### ✅ DO:
- Use `public_*` prefix for any table/view meant for anonymous access
- Keep PII in non-prefixed tables
- Use views (`public_*`) to expose safe subsets of internal tables
- Apply RLS policies on all `public_*` tables/views

### ❌ DON'T:
- Put PII in `public_*` tables
- Expose internal tables directly to anonymous users
- Mix public and private data in same table without proper filtering

## Example: Image Loading Flow

```typescript
// Frontend code loads from public_property_images (safe for anonymous)
const { data } = await supabase
  .from('public_property_images')  // ✅ Public table - safe for anon
  .select('*')
  .eq('property_id', propertyId);

// Images are rendered from these records
// All URLs are public, no sensitive data exposed
```

## Summary

The `public_*` naming convention is:
- ✅ **Intentional** - Part of security architecture
- ✅ **Clear** - Signals public-facing content
- ✅ **Safe** - Explicit boundary for anonymous access
- ✅ **Standard** - Common pattern in multi-tenant SaaS applications

This is **NOT** a deviation from standards - it's a **security best practice** to clearly distinguish public-facing content from internal data.
