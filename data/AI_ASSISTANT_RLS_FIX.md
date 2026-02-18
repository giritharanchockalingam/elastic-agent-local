# AI Assistant RLS Policy Fix

## Problem
The AI Assistant was not providing valid information because RLS (Row Level Security) policies were blocking access to necessary data, even though the service role key should bypass RLS.

## Root Cause
1. **Service Role Key**: The AI Assistant uses `SUPABASE_SERVICE_ROLE_KEY` which should bypass RLS, but queries were failing
2. **Query Structure**: Some queries were using incorrect join syntax (e.g., `guests.email` directly in filter)
3. **RLS Policies**: Some tables had overly restrictive policies that might interfere even with service role

## Solution

### 1. Fixed Query Functions
- **`queryReservations`**: Now properly finds guest_id first when filtering by email, then filters by guest_id
- This ensures queries work correctly regardless of RLS policies

### 2. Updated RLS Policies
Created comprehensive RLS policies in `db-scripts/fix-ai-assistant-rls.sql` that:
- Allow authenticated users to view their own data
- Allow staff to view system-wide data
- Allow anonymous users to view public data (room types, properties)
- **Service role bypasses all RLS** (this is automatic with service role key)

### 3. Verification Script
Created `db-scripts/verify-ai-assistant-access.sql` to verify:
- RLS is enabled on critical tables
- Policies are correctly configured
- Service role can access all tables

## How to Apply

### Step 1: Run RLS Fix Script
```bash
# In Supabase SQL Editor or via CLI
psql -h <your-supabase-host> -U postgres -d postgres -f db-scripts/fix-ai-assistant-rls.sql
```

### Step 2: Verify Service Role Key
Ensure `SUPABASE_SERVICE_ROLE_KEY` is set in Supabase Edge Function secrets:
1. Go to Supabase Dashboard
2. Navigate to Edge Functions → unified-ai-assistant
3. Check Secrets tab
4. Ensure `SUPABASE_SERVICE_ROLE_KEY` is set

### Step 3: Verify Access
```bash
# Run verification script
psql -h <your-supabase-host> -U postgres -d postgres -f db-scripts/verify-ai-assistant-access.sql
```

## Tables Covered

The RLS fix covers these critical tables:
- ✅ `reservations` - Guest reservations
- ✅ `guests` - Guest information
- ✅ `room_types` - Room type details
- ✅ `invoices` - Guest invoices
- ✅ `pos_transactions` - Point of sale transactions
- ✅ `payments` - Payment records
- ✅ `properties` - Property information
- ✅ `rooms` - Room inventory
- ✅ `restaurant_reservation_requests` - Dining reservations
- ✅ `spa_bookings` - Spa appointments

## Important Notes

1. **Service Role Bypasses RLS**: When using `SUPABASE_SERVICE_ROLE_KEY`, all RLS policies are bypassed automatically. The policies are for regular authenticated users.

2. **Query Fixes**: The query functions have been updated to handle joins correctly, especially when filtering by guest email.

3. **Security**: Even though service role bypasses RLS, we maintain proper RLS policies for regular users to ensure data security.

## Testing

After applying the fix, test the AI Assistant with:
- "Check my reservations" (should work for signed-in users)
- "How many open invoices are there?" (should work for HMS staff)
- "What room types are available?" (should work for everyone)
- "What's my total spending this month?" (should work for signed-in users)

## Troubleshooting

If the AI Assistant still doesn't provide valid information:

1. **Check Service Role Key**: Verify it's set correctly in Supabase secrets
2. **Check Query Logs**: Look at Edge Function logs for query errors
3. **Run Verification Script**: Use `verify-ai-assistant-access.sql` to check table access
4. **Check RLS Status**: Ensure RLS is enabled but service role can still access

## Files Modified

- `supabase/functions/unified-ai-assistant/index.ts` - Fixed `queryReservations` function
- `db-scripts/fix-ai-assistant-rls.sql` - Comprehensive RLS policy fix
- `db-scripts/verify-ai-assistant-access.sql` - Verification script
- `docs/AI_ASSISTANT_RLS_FIX.md` - This documentation
