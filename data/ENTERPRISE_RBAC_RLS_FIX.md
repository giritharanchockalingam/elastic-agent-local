# Enterprise RBAC and RLS Fix

## Overview

This document describes the comprehensive fix for RBAC (Role-Based Access Control) and RLS (Row Level Security) issues to ensure enterprise-grade compliance and security.

## Problems Identified

1. **RLS Policies Not Checking Property Access**: Many RLS policies allowed access to all data without checking if the user has access to the specific property.
2. **Inconsistent RLS Policies**: Multiple conflicting policies existed for the same tables.
3. **RBACGuard Showing Error Messages**: The RBACGuard component was showing error messages for UI elements (like buttons) instead of hiding them.
4. **Lost & Found Empty**: Users couldn't see lost & found items due to RLS policy issues.

## Solutions Implemented

### 1. Comprehensive RLS Migration

Created `supabase/migrations/20251228_enterprise_rbac_rls_fix.sql` which:

- **Guests Table**: 
  - All staff roles can view guests (needed for reservations, check-in, etc.)
  - Staff can create and update guests
  - Only admins can delete guests
  - Note: Guests don't have property_id directly, so we use role-based access

- **Reservations Table**:
  - Users can view reservations for properties they have access to
  - Staff can create/update reservations for their properties
  - Only admins/managers can delete reservations
  - Uses `user_has_property_access(property_id)` function

- **Rooms Table**:
  - Users can view rooms for properties they have access to
  - Only admins/managers can create rooms
  - Staff can update rooms for their properties
  - Only admins can delete rooms
  - Uses `user_has_property_access(property_id)` function

- **Payments Table**:
  - Finance staff and admins can view payments for properties they have access to
  - Payments are checked via reservation.property_id
  - Uses `user_has_property_access(property_id)` function

- **Lost & Found Items Table**:
  - Users can view/manage items for properties they have access to
  - Uses `user_has_property_access(property_id)` function
  - Restricted to appropriate staff roles

### 2. RBACGuard Component Update

Updated `src/components/RBACGuard.tsx` to:

- Add `hideOnDeny` prop to hide content instead of showing error messages
- Useful for UI elements like buttons, icons, etc.
- Still shows error messages for page-level content areas

**Usage:**
```tsx
// Hide button if user doesn't have access
<RBACGuard allowedRoles={ADMIN_ROLES} hideOnDeny={true}>
  <Button>Delete</Button>
</RBACGuard>

// Show error message if user doesn't have access (default)
<RBACGuard allowedRoles={ADMIN_ROLES}>
  <SensitiveContent />
</RBACGuard>
```

### 3. Guests Page Update

Updated `src/pages/Guests.tsx` to:

- Use `hideOnDeny={true}` for delete button to hide it instead of showing error
- Maintain STAFF_ROLES access for viewing guests
- Keep ADMIN_ROLES restriction for delete operations

## Key Security Principles

1. **Property-Level Isolation**: All tables with `property_id` check `user_has_property_access()` to ensure users can only access data for properties they're assigned to.

2. **Role-Based Access**: Different operations require different roles:
   - **View**: Most staff roles can view data
   - **Create/Update**: Staff can create/update within their department
   - **Delete**: Only admins/managers can delete

3. **Super Admin Access**: Super admins have access to all properties automatically via `user_has_property_access()` function.

4. **Consistent Policy Naming**: All policies follow naming convention: `{table}_{operation}_policy`

## Migration Application

To apply the fix:

```bash
# Apply the migration
supabase db push

# Or run manually in Supabase SQL Editor
# Copy contents of: supabase/migrations/20251228_enterprise_rbac_rls_fix.sql
```

## Verification

After applying the migration, verify:

1. **RLS Policies**:
   ```sql
   SELECT tablename, policyname 
   FROM pg_policies 
   WHERE schemaname = 'public' 
   AND tablename IN ('guests', 'reservations', 'rooms', 'payments', 'lost_found_items')
   ORDER BY tablename, policyname;
   ```

2. **RLS Enabled**:
   ```sql
   SELECT tablename, rowsecurity 
   FROM pg_tables 
   WHERE schemaname = 'public' 
   AND tablename IN ('guests', 'reservations', 'rooms', 'payments', 'lost_found_items');
   ```

3. **Function Access**:
   ```sql
   SELECT routine_name, routine_type
   FROM information_schema.routines
   WHERE routine_schema = 'public'
   AND routine_name = 'user_has_property_access';
   ```

## Testing Checklist

- [ ] Staff users can view guests
- [ ] Staff users can create/update guests
- [ ] Only admins can delete guests
- [ ] Users can only see reservations for their assigned properties
- [ ] Users can only see rooms for their assigned properties
- [ ] Finance staff can only see payments for their assigned properties
- [ ] Lost & Found items are visible to users with property access
- [ ] Delete buttons are hidden (not showing errors) for non-admin users
- [ ] Super admins can access all properties
- [ ] Property isolation works correctly across all tables

## Dependencies

This migration depends on:

1. `user_has_property_access()` function (created in `20251218000001_add_user_id_to_staff.sql`)
2. `user_roles` table with proper role assignments
3. `user_property_assignments` table for property access

Ensure these are in place before applying this migration.

## Rollback

If you need to rollback:

1. The migration drops all existing policies, so you'll need to recreate them
2. Keep a backup of your current policies before applying
3. Original policies can be found in previous migrations if needed

## Related Files

- `supabase/migrations/20251228_enterprise_rbac_rls_fix.sql` - Main migration
- `src/components/RBACGuard.tsx` - Updated RBAC guard component
- `src/pages/Guests.tsx` - Updated Guests page
- `supabase/migrations/20251227_fix_lost_found_rls_property_access.sql` - Lost & Found fix (previously applied)
- `supabase/migrations/20251218000001_add_user_id_to_staff.sql` - Property access functions

