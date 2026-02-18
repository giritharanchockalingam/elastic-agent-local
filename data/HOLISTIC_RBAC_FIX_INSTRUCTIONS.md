# Holistic RBAC/RLS Fix - Instructions

## Problem
The RLS script is failing because it references enum values that don't exist in your `app_role` enum.

## Solution

### Step 1: Check Your Actual Enum Values

Run this in Supabase SQL Editor to see what enum values you have:

```sql
-- Check what values exist in app_role enum
SELECT 
  t.typname AS enum_name,
  e.enumlabel AS enum_value,
  e.enumsortorder AS sort_order
FROM pg_type t 
JOIN pg_enum e ON t.oid = e.enumtypid  
WHERE t.typname = 'app_role'
ORDER BY e.enumsortorder;
```

### Step 2: Choose the Right Script

**Option A: If your enum has ONLY basic values** (`'super_admin', 'admin', 'manager', 'staff', 'guest'`):
- Use: `db-scripts/fix-holistic-rbac-rls-ai-assistant-simplified.sql`
- This version only uses the basic enum values

**Option B: If your enum has extended roles** (like `'front_desk_manager'`, `'finance_manager'`, etc.):
- First, identify which extended roles exist
- Then modify `db-scripts/fix-holistic-rbac-rls-ai-assistant.sql` to remove references to roles that DON'T exist

### Step 3: Run the Script

Copy the appropriate script and run it in Supabase SQL Editor.

## Current Status

I've already updated `fix-holistic-rbac-rls-ai-assistant.sql` to use only basic roles:
- ✅ Removed `'concierge'`
- ✅ Removed `'fb_manager'`  
- ✅ Using only: `'super_admin', 'admin', 'manager', 'staff', 'guest'`

However, if you're still getting errors, please:
1. Run the check script above to see your actual enum values
2. Share the output so I can update the script accordingly

## Simplified Version

I've created `fix-holistic-rbac-rls-ai-assistant-simplified.sql` which:
- Uses ONLY basic enum values: `'super_admin', 'admin', 'manager', 'staff', 'guest'`
- Should work regardless of which extended roles you have
- Is simpler and more maintainable

Try running the simplified version first!
