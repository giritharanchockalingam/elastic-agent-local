# Fix Lost & Found RLS Policy Issue

## Problem

The Lost & Found page was showing empty results even though data existed in the database. This was caused by RLS (Row Level Security) policies that only checked user roles but did **not verify property access**.

## Root Cause

The existing RLS policies for `lost_found_items` table only checked:
```sql
USING (
  has_role(auth.uid(), 'admin') OR 
  has_role(auth.uid(), 'manager') OR 
  has_role(auth.uid(), 'staff')
)
```

This meant any user with those roles could see ALL lost & found items across ALL properties, but the frontend was filtering by `property_id`. However, if RLS policies don't check property access, users might see no results due to how RLS filtering works with the database query.

## Solution

Updated the RLS policies to use the `user_has_property_access(property_id)` function, which ensures users can only see items for properties they have been assigned to.

**New Policy (SELECT):**
```sql
USING (public.user_has_property_access(property_id))
```

**New Policy (ALL operations):**
```sql
USING (
  public.user_has_property_access(property_id)
  AND EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid()
    AND role IN ('super_admin', 'admin', 'general_manager', 'front_desk_manager', 'staff')
  )
)
```

## Files Created

1. **`supabase/migrations/20251227_fix_lost_found_rls_property_access.sql`**
   - Migration to fix RLS policies
   - Includes fallback for systems without `user_has_property_access()` function

2. **`scripts/verify-lost-found-rls.sql`**
   - Diagnostic script to verify RLS policies are correctly configured

## How to Apply

1. Run the migration in Supabase SQL Editor:
   ```sql
   -- Copy contents of supabase/migrations/20251227_fix_lost_found_rls_property_access.sql
   ```

2. Verify the fix:
   ```sql
   -- Run scripts/verify-lost-found-rls.sql to check policies
   ```

3. Test in the application:
   - Log in as a user with property access
   - Navigate to Lost & Found page
   - Should now see items for the user's assigned property

## Expected Behavior

After the fix:
- Users can only see lost & found items for properties they have access to
- Property access is determined by:
  - `user_property_assignments` table (primary)
  - `staff` table (fallback for legacy data)
  - Super admins have access to all properties
- Staff with appropriate roles can manage items for their assigned properties

## Related Functions

The fix relies on the `user_has_property_access()` function defined in:
- `supabase/migrations/20251218000001_add_user_id_to_staff.sql`

This function checks:
1. If user is super_admin → access to all properties
2. If user has assignment in `user_property_assignments` → access to that property
3. If user has staff record with property_id → access to that property (fallback)

