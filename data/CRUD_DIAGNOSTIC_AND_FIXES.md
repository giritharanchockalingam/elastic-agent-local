# CRUD Operations Diagnostic Tool & Fixes

## Overview

This document describes the comprehensive diagnostic tool created to test all CRUD operations across HMS Portal pages and the fixes applied to handle schema mismatches gracefully.

## Diagnostic Tool

### Location
- **TypeScript Tool**: `scripts/diagnose-crud-operations.ts`
- **Shell Wrapper**: `scripts/diagnose-crud-operations.sh`

### Usage

```bash
# Run the diagnostic tool
./scripts/diagnose-crud-operations.sh

# Or directly with Node.js
tsx scripts/diagnose-crud-operations.ts
```

### What It Tests

The diagnostic tool tests CRUD operations for:

1. **Housekeeping Tasks** (`housekeeping_tasks`)
   - Tests with and without `estimated_duration` column
   - Tests CREATE, READ, UPDATE, DELETE operations

2. **Maintenance Requests** (`maintenance_requests`)
   - Tests with different schema variations (title vs request_type)
   - Tests CREATE, READ, UPDATE, DELETE operations

3. **Food Orders** (`food_orders`)
   - Tests room service order creation and updates
   - Tests CREATE, READ, UPDATE, DELETE operations

4. **Spa Services** (`spa_services`)
   - Tests with and without `property_id` column
   - Tests CREATE, READ, UPDATE, DELETE operations

5. **Concierge Requests** (`concierge_requests`)
   - Tests service request creation
   - Tests CREATE, READ, UPDATE, DELETE operations

### Output

The tool generates:
- Console output with test results
- JSON report: `crud-diagnostic-report.json`

## Schema-Safe CRUD Utilities

### Location
`src/lib/utils/schemaSafeCrud.ts`

### Functions

1. **`schemaSafeInsert`** - Safely insert data, handling missing columns
2. **`schemaSafeUpdate`** - Safely update data, handling missing columns
3. **`columnExists`** - Check if a column exists in a table
4. **`getTableColumns`** - Get list of existing columns
5. **`filterToExistingColumns`** - Filter data to only include existing columns

### Usage Example

```typescript
import { schemaSafeInsert, schemaSafeUpdate } from '@/lib/utils/schemaSafeCrud';

// Insert with automatic fallback
const { data, error } = await schemaSafeInsert(
  supabase,
  'housekeeping_tasks',
  {
    property_id: propertyId,
    room_id: roomId,
    task_type: 'cleaning',
    estimated_duration: 30, // Will be skipped if column doesn't exist
  },
  {
    skipColumns: ['estimated_duration'], // Optional: explicitly skip columns
  }
);

// Update with automatic fallback
const { data, error } = await schemaSafeUpdate(
  supabase,
  'housekeeping_tasks',
  taskId,
  {
    status: 'completed',
    estimated_duration: 30, // Will be skipped if column doesn't exist
  }
);
```

## Fixes Applied

### 1. Housekeeping Page (`src/pages/Housekeeping.tsx`)

**Issue**: `estimated_duration` column doesn't exist in all schema versions.

**Fix**: 
- Added fallback logic in `createMutation` and `updateMutation`
- If insert/update fails due to missing `estimated_duration` column, retry without it
- Handles error code `42703` (undefined column) gracefully

**Code Changes**:
```typescript
// Before: Would fail if estimated_duration column doesn't exist
const payload = { ...data, estimated_duration: Number(data.estimated_duration) };
await supabase.from('housekeeping_tasks').insert([payload]);

// After: Gracefully handles missing column
let { error } = await supabase.from('housekeeping_tasks').insert([payload]);
if (error && (error.code === '42703' || error.message?.includes('estimated_duration'))) {
  const { estimated_duration, ...payloadWithoutDuration } = payload;
  await supabase.from('housekeeping_tasks').insert([payloadWithoutDuration]);
}
```

### 2. Guest Domain (`src/lib/domain/guest.ts`)

**Issues Fixed**:
- `maintenance_requests` - Missing `title` column in enterprise schema
- `bar_orders` - Missing `guest_id` column handling
- `spa_services` - Missing `property_id` column handling
- `space_utilization_logs` - Table may not exist (404 handling)

**Fixes**:
- Added fallback queries for all affected functions
- Graceful error handling for schema mismatches
- Returns empty arrays instead of throwing errors

### 3. Service Request Creation

**Issue**: `createServiceRequest` fails when `title` column doesn't exist.

**Fix**:
- Multi-step fallback logic:
  1. Try with `title` and `reported_by`
  2. Try without `title`, with `request_type`
  3. Try with `guest_id` instead of `reported_by`

## Common Schema Variations

### Housekeeping Tasks

**Old Schema**:
- No `estimated_duration`
- No `property_id` (optional)
- `assigned_to` references `profiles`

**New Schema**:
- Has `estimated_duration`
- Requires `property_id`
- `assigned_to` references `staff`

### Maintenance Requests

**Old Schema**:
- Has `title` column
- `reported_by` references `profiles`

**New Schema**:
- No `title` column
- Has `request_type` instead
- `reported_by` references `staff`
- May have `guest_id` column

## Best Practices

1. **Always handle schema mismatches gracefully**
   - Use try-catch with fallback queries
   - Check error codes (`42703` = undefined column)
   - Provide fallback data structures

2. **Use schema-safe utilities**
   - Import from `@/lib/utils/schemaSafeCrud`
   - Let utilities handle column detection

3. **Test with diagnostic tool**
   - Run before deployment
   - Check report for schema issues
   - Fix issues before they reach production

4. **Error messages**
   - Log schema issues in dev mode
   - Show user-friendly messages
   - Don't expose internal schema details

## Running Diagnostics

### Prerequisites
- Node.js installed
- TypeScript runner (tsx or ts-node)
- Supabase credentials in `.env.local`

### Steps

1. **Set up environment**:
   ```bash
   cp env.local.example .env.local
   # Add your Supabase credentials
   ```

2. **Run diagnostic**:
   ```bash
   ./scripts/diagnose-crud-operations.sh
   ```

3. **Review report**:
   ```bash
   cat crud-diagnostic-report.json
   ```

4. **Fix issues**:
   - Review failed operations
   - Check schema mismatches
   - Apply fixes using schema-safe utilities

## Future Improvements

1. **Automated Schema Detection**
   - Query information_schema at runtime
   - Cache column existence
   - Generate type-safe queries

2. **Migration Helper**
   - Detect schema version
   - Suggest migrations
   - Auto-apply schema fixes

3. **Comprehensive Testing**
   - Add to CI/CD pipeline
   - Test all pages automatically
   - Generate coverage reports

## Related Files

- `scripts/diagnose-crud-operations.ts` - Diagnostic tool
- `scripts/diagnose-crud-operations.sh` - Shell wrapper
- `src/lib/utils/schemaSafeCrud.ts` - Schema-safe utilities
- `src/pages/Housekeeping.tsx` - Fixed housekeeping CRUD
- `src/lib/domain/guest.ts` - Fixed guest domain queries
