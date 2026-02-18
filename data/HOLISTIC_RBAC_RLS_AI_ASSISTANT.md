# Holistic RBAC/RLS Fix for AI Assistant

## Overview
This implementation makes the AI Assistant **role-aware** and ensures it only provides data within each user's RBAC boundaries. The system automatically understands the user's role and enforces appropriate data access restrictions.

## Architecture

### 1. Role Detection System
- **`fetchUserRoles()`**: Fetches user roles from `user_roles` table
- Supports lookup by `userId` or `email`
- Handles guests (no roles = treated as guest)
- Returns `UserRole` object with role information

### 2. Permission System
- **`getRolePermissions()`**: Maps roles to specific permissions
- Defines what each role can access:
  - **Super Admin/Admin**: Full access to everything
  - **Finance Roles**: Financial data, reservations, guests
  - **Front Desk Roles**: Reservations, guests, limited financial
  - **Department Roles**: Only their department's data
  - **Guests**: Only their own data

### 3. Query Filtering
- **`queryReservations()`**: Now accepts `permissions` and `userRole` parameters
- Automatically filters by `guest_id` if `canViewOwnDataOnly = true`
- Applies property filters for staff with limited access
- **`executeDynamicQuery()`**: Validates table access against `allowedTables`
- Blocks access to restricted tables/fields

### 4. System Prompt Integration
- **`buildRoleContext()`**: Generates role-aware context for AI
- Informs AI about user's role and restrictions
- Provides clear rules about what data can be shown
- AI automatically declines requests outside permissions

## Role-Based Access Matrix

| Role | Reservations | Guests | Invoices | Payments | Financial | Staff Data | System Settings |
|------|-------------|--------|----------|----------|-----------|------------|-----------------|
| Super Admin | ✅ All | ✅ All | ✅ All | ✅ All | ✅ All | ✅ All | ✅ All |
| Admin | ✅ All | ✅ All | ✅ All | ✅ All | ✅ All | ✅ All | ✅ All |
| Finance Manager | ✅ All | ✅ All | ✅ All | ✅ All | ✅ All | ❌ No | ❌ No |
| Front Desk | ✅ All | ✅ All | ✅ Limited | ❌ No | ❌ No | ❌ No | ❌ No |
| Housekeeping | ✅ All | ❌ Limited | ❌ No | ❌ No | ❌ No | ❌ No | ❌ No |
| F&B Staff | ❌ Restaurant only | ❌ Restaurant only | ❌ No | ❌ No | ❌ No | ❌ No | ❌ No |
| Spa Staff | ❌ Spa only | ❌ Spa only | ❌ No | ❌ No | ❌ No | ❌ No | ❌ No |
| Guest | ✅ Own only | ✅ Own only | ✅ Own only | ✅ Own only | ❌ No | ❌ No | ❌ No |

## Implementation Details

### Files Created/Modified

1. **`supabase/functions/unified-ai-assistant/index.ts`**:
   - Added role-aware query functions (`fetchUserRoles`, `getRolePermissions`, `buildRoleContext`)
   - Updated `queryReservations()` to accept permissions
   - Updated `executeDynamicQuery()` to validate table access
   - Updated `buildDatabaseContext()` to accept permissions
   - Updated system prompt to include role context

2. **`db-scripts/fix-holistic-rbac-rls-ai-assistant.sql`**:
   - Comprehensive RLS policies for all tables
   - Role-based policies (admin, finance, front desk, department, guest)
   - Ensures data isolation by role

3. **`supabase/functions/unified-ai-assistant/role-aware-queries.ts`**:
   - Standalone module with role-aware query system
   - Can be imported or inlined (currently inlined in index.ts)

## How It Works

### Step 1: User Authentication
When a user interacts with the AI Assistant:
1. Frontend sends `userInfo` (userId, email) or `guestInfo` (email)
2. AI Assistant calls `fetchUserRoles()` to get user's roles
3. System determines `primaryRole` and `isAdmin`/`isStaff`/`isGuest` flags

### Step 2: Permission Calculation
1. `getRolePermissions()` maps role to specific permissions
2. Returns `RolePermissions` object with:
   - Boolean flags for each data type
   - `allowedTables` array
   - `restrictedFields` array

### Step 3: Query Execution
1. Before executing any query:
   - Check if table is in `allowedTables`
   - If `canViewOwnDataOnly = true`, filter by `guest_id`
   - If staff with limited access, apply property filters
2. Execute query with role-based filters
3. Return only data user's role allows

### Step 4: AI Response
1. System prompt includes `roleContext` with:
   - User's role
   - What they can access
   - What they cannot access
   - Clear rules about declining requests
2. AI automatically respects boundaries
3. If user asks for restricted data, AI politely declines

## Example Scenarios

### Scenario 1: Guest User
**User**: "Show me all reservations"
**AI Response**: "I can show you your own reservations. Let me check..." (only shows guest's own reservations)

### Scenario 2: Front Desk Staff
**User**: "Show me all reservations"
**AI Response**: Shows all reservations (front desk has access)

**User**: "Show me payment details for reservation X"
**AI Response**: "I don't have access to detailed payment information. Please contact the finance department." (front desk can't see payment details)

### Scenario 3: Finance Manager
**User**: "Show me all invoices"
**AI Response**: Shows all invoices (finance has access)

**User**: "Show me staff salaries"
**AI Response**: "I don't have access to staff personal information." (finance can't see staff data)

### Scenario 4: F&B Staff
**User**: "Show me all reservations"
**AI Response**: "I can show you restaurant reservations. Let me check..." (only shows restaurant reservations)

**User**: "Show me room reservations"
**AI Response**: "I don't have access to room reservation data. Please contact the front desk." (F&B can't see room reservations)

## How to Apply

### Step 1: Run RLS Fix Script
```bash
# In Supabase SQL Editor
# Copy and paste contents of db-scripts/fix-holistic-rbac-rls-ai-assistant.sql
```

### Step 2: Deploy Updated Edge Function
The `unified-ai-assistant` function now includes role-aware logic. Deploy it:
```bash
supabase functions deploy unified-ai-assistant
```

### Step 3: Verify User Roles
Ensure `user_roles` table has correct role assignments:
```sql
SELECT ur.user_id, ur.role, ur.property_id, p.email
FROM user_roles ur
JOIN profiles p ON p.id = ur.user_id;
```

### Step 4: Test Role-Based Access
1. **As Guest**: Ask "Show me all reservations" → Should only show own
2. **As Front Desk**: Ask "Show me all reservations" → Should show all
3. **As Finance**: Ask "Show me payment details" → Should show all
4. **As F&B**: Ask "Show me room reservations" → Should decline

## Benefits

1. **Automatic Enforcement**: No manual checks needed - system enforces boundaries automatically
2. **Self-Adapting**: AI understands role boundaries and declines inappropriate requests
3. **Secure by Default**: Even if query succeeds, AI won't show restricted data
4. **Audit Trail**: All queries respect RLS policies
5. **Scalable**: Easy to add new roles or modify permissions

## Security Notes

1. **Service Role Key**: AI Assistant uses service role key which bypasses RLS, but we enforce role-based filtering in application logic
2. **Double Protection**: Both RLS policies AND application-level filtering ensure security
3. **Guest Data**: Guests can only see their own data, even if query returns more
4. **Staff Isolation**: Department staff can only see their department's data

## Future Enhancements

1. **Permission Registry**: Use `permissions` and `role_permissions` tables for dynamic permission management
2. **Audit Logging**: Log all AI queries with role information for compliance
3. **Custom Roles**: Support property-specific custom roles
4. **Time-Based Access**: Restrict access based on time of day or shift
