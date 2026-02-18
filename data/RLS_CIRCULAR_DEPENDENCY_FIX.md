# RLS Circular Dependency Fix - 500 Errors

## Problem
The application is getting 500 Internal Server Errors when querying tables like:
- `user_roles`
- `guests`
- `reservations`
- `payments`

## Root Cause
**Circular Dependency in RLS Policies**: The `user_roles` table has an RLS policy that queries the `user_roles` table itself to check if a user has a role. This creates an infinite loop:

1. User tries to SELECT from `user_roles`
2. RLS policy checks: "Does user have admin role?"
3. Policy queries `user_roles` to check
4. Query triggers RLS policy again → Infinite loop → 500 error

## Solution
Use `SECURITY DEFINER` functions that **bypass RLS** to check roles.

### Step 1: Ensure `has_role()` Function Exists
The `has_role()` function must be `SECURITY DEFINER` to bypass RLS:

```sql
CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role app_role)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER  -- CRITICAL: This bypasses RLS!
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = _role
  )
$$;
```

### Step 2: Update Policies to Use `has_role()`

**❌ WRONG (causes circular dependency):**
```sql
CREATE POLICY "staff_view_all_roles"
ON public.user_roles FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles  -- ❌ Queries user_roles in user_roles policy!
    WHERE user_id = auth.uid()
    AND role IN ('super_admin', 'admin', 'manager')
  )
);
```

**✅ CORRECT (uses SECURITY DEFINER function):**
```sql
CREATE POLICY "staff_view_all_roles"
ON public.user_roles FOR SELECT
USING (
  public.has_role(auth.uid(), 'super_admin'::app_role) OR  -- ✅ Uses function that bypasses RLS
  public.has_role(auth.uid(), 'admin'::app_role) OR
  public.has_role(auth.uid(), 'manager'::app_role)
);
```

## Quick Fix Script

Run `db-scripts/fix-user-roles-circular-dependency.sql` first to fix the immediate issue, then run the full RLS script.

## Verification

After applying the fix, test these queries:

```sql
-- Should work without 500 error
SELECT * FROM user_roles WHERE user_id = auth.uid();

-- Should work without 500 error
SELECT * FROM guests WHERE user_id = auth.uid();

-- Should work without 500 error
SELECT * FROM reservations LIMIT 10;
```

## Why This Works

1. **SECURITY DEFINER**: Functions marked as `SECURITY DEFINER` run with the privileges of the function creator (usually superuser), bypassing RLS
2. **No Circular Dependency**: The function can query `user_roles` without triggering RLS policies
3. **Safe**: The function still respects the database structure and only returns valid role checks

## Important Notes

- All policies that check roles should use `has_role()` function
- Never directly query `user_roles` in an RLS policy on `user_roles` table
- The function must be `SECURITY DEFINER` or it won't bypass RLS
- The function should be `STABLE` for performance (doesn't change within a transaction)
