# STEP 0: Reconnaissance Summary

## Findings

### Table Structures Identified

#### `public.tenants` Table
- **Primary Key**: `id` (UUID)
- **Key Columns**:
  - `name` (TEXT NOT NULL) - Human-readable tenant name
  - `code` (TEXT UNIQUE NOT NULL) - Short code (e.g., 'GHG')
  - `status` (TEXT DEFAULT 'active')
  - `settings` (JSONB) - Contains branding, features, etc.
- **Current State**: No `brand_slug` or `is_public` columns (will be added in migration)

#### `public.properties` Table
- **Primary Key**: `id` (UUID)
- **Foreign Key**: `tenant_id` → `tenants.id` (ON DELETE CASCADE)
- **Key Columns**:
  - `name` (TEXT NOT NULL) - Property name
  - `code` (TEXT NOT NULL) - Property code (unique per tenant)
  - `tenant_id` (UUID) - Links to tenant
  - `status` (TEXT DEFAULT 'active')
  - `city`, `state`, `country` - Location info
  - `phone`, `email`, `website` - Contact (PII - must not expose on public pages)
  - `star_rating` (INTEGER) - Hotel rating
  - `currency`, `timezone` - Localization
  - `settings` (JSONB) - Property-specific settings
- **Current State**: No `property_slug` or `is_public` columns (will be added in migration)

### Existing Slug Migration
- Found: `supabase/migrations/20250120000000_add_public_portal_slugs.sql`
- **Status**: Incomplete
  - Adds `brand_slug` and `property_slug` columns
  - Generates slugs from `code` field
  - Creates unique indexes
  - **Missing**:
    - NOT NULL constraints
    - `is_public` flags
    - Public views
    - Proper conflict resolution

### RLS Policies
- Found existing policies for tenants/properties
- Some allow `anon` access directly to tables (security risk)
- **Action**: Will create public views and restrict direct table access

### Current Public Portal Code
- `src/lib/tenant/resolveContext.ts` - Queries `tenants` and `properties` directly
- `src/lib/domain/public.ts` - Queries tables directly
- **Security Issue**: Direct table queries may expose PII or non-public data

## Migration Plan

1. **Add slug columns** (if not exists) with proper backfill
2. **Add `is_public` flags** for visibility control
3. **Add `public_metadata` JSONB** for safe display fields
4. **Create public views** (`public_tenants`, `public_properties`) with only safe fields
5. **Update RLS policies** to restrict direct table access, allow view access
6. **Update code** to use public views instead of direct table queries

## Files to Create/Modify

### Migrations
- `supabase/migrations/20250121000000_public_portal_slugs_complete.sql` ✅
- `supabase/migrations/20250121000001_public_portal_leads_booking_requests.sql` ✅
- `supabase/migrations/20250121000002_seed_public_portal_demo.sql` ✅

### Code Updates
- `src/lib/tenant/resolveContext.ts` - Use public views ✅
- `src/lib/domain/public.ts` - Use public views ✅
- `src/lib/domain/leads.ts` - New file for lead/booking request submission ✅
- `src/lib/utils/rateLimitServer.ts` - Server-side rate limiting ✅

