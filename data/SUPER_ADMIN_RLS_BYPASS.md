# Super Admin RLS Bypass Setup

## Overview

This document describes how super_admin users are granted full CRUD access to all tables, bypassing all Row Level Security (RLS) policies.

## How It Works

PostgreSQL RLS policies use **OR logic** - if ANY policy allows access, the user gets access. By creating separate `super_admin` policies for all tables, super_admin users automatically bypass all other RLS restrictions.

## Implementation

### 1. Helper Function

The `is_super_admin()` function checks if a user has the `super_admin` role:

```sql
CREATE OR REPLACE FUNCTION public.is_super_admin(_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = 'super_admin'
  )
$$;
```

### 2. Super Admin Policies

For each table with RLS enabled, we create 4 policies:
- `super_admin_select_<table>` - Full SELECT access
- `super_admin_insert_<table>` - Full INSERT access
- `super_admin_update_<table>` - Full UPDATE access
- `super_admin_delete_<table>` - Full DELETE access

All policies check: `public.is_super_admin(auth.uid())`

### 3. Dynamic Table Discovery

The script automatically discovers all tables with RLS enabled and creates policies for them. This ensures:
- No tables are missed
- New tables automatically get super_admin policies
- Works with any schema configuration

## Usage

### Apply Super Admin Policies

```bash
psql $DATABASE_URL -f db-scripts/ensure-super-admin-full-access.sql
```

### Verify Policies

```sql
-- Check how many super_admin policies exist
SELECT COUNT(*) 
FROM pg_policies
WHERE schemaname = 'public'
  AND policyname LIKE 'super_admin_%';

-- List all super_admin policies
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND policyname LIKE 'super_admin_%'
ORDER BY tablename, cmd;
```

### Test Super Admin Access

```sql
-- Check if current user is super_admin
SELECT public.is_super_admin(auth.uid());

-- Test access (should work for super_admin)
SELECT * FROM maintenance_requests LIMIT 1;
INSERT INTO maintenance_requests (property_id, description, status) 
VALUES ('...', 'Test', 'open');
```

## Policy Evaluation

PostgreSQL evaluates RLS policies with **OR logic**:

1. All policies for an operation are evaluated
2. If ANY policy returns `true`, access is granted
3. Super_admin policies always return `true` for super_admin users
4. Therefore, super_admin users bypass all other restrictions

## Example Policy Structure

For `maintenance_requests` table:

```sql
-- Super admin can SELECT all
CREATE POLICY "super_admin_select_maintenance_requests"
  ON public.maintenance_requests FOR SELECT
  TO authenticated
  USING (public.is_super_admin(auth.uid()));

-- Super admin can INSERT all
CREATE POLICY "super_admin_insert_maintenance_requests"
  ON public.maintenance_requests FOR INSERT
  TO authenticated
  WITH CHECK (public.is_super_admin(auth.uid()));

-- Super admin can UPDATE all
CREATE POLICY "super_admin_update_maintenance_requests"
  ON public.maintenance_requests FOR UPDATE
  TO authenticated
  USING (public.is_super_admin(auth.uid()))
  WITH CHECK (public.is_super_admin(auth.uid()));

-- Super admin can DELETE all
CREATE POLICY "super_admin_delete_maintenance_requests"
  ON public.maintenance_requests FOR DELETE
  TO authenticated
  USING (public.is_super_admin(auth.uid()));
```

## Tables Covered

The script automatically creates policies for all tables with RLS enabled, including:

- `maintenance_requests`
- `spa_services`
- `concierge_requests`
- `housekeeping_tasks`
- `food_orders`
- `bar_orders`
- `reservations`
- `guests`
- `payments`
- `invoices`
- `rooms`
- `properties`
- `staff`
- And all other tables with RLS enabled

## Security Notes

1. **Super Admin is Powerful**: Super admin can access ALL data and perform ALL operations
2. **Use Sparingly**: Only assign super_admin role to trusted users
3. **Audit Logging**: Consider adding audit logging for super_admin actions
4. **Regular Review**: Periodically review who has super_admin role

## Troubleshooting

### Super Admin Still Blocked

1. **Check Role Assignment**:
   ```sql
   SELECT * FROM user_roles WHERE role = 'super_admin';
   ```

2. **Verify Function**:
   ```sql
   SELECT public.is_super_admin('user-uuid-here');
   ```

3. **Check Policies**:
   ```sql
   SELECT * FROM pg_policies 
   WHERE tablename = 'table_name' 
     AND policyname LIKE 'super_admin_%';
   ```

4. **Re-run Script**:
   ```bash
   psql $DATABASE_URL -f db-scripts/ensure-super-admin-full-access.sql
   ```

## Related Files

- `db-scripts/ensure-super-admin-full-access.sql` - Main script
- `supabase/migrations/20251117093138_*.sql` - RBAC setup
- `src/config/rbac.ts` - Frontend role definitions
