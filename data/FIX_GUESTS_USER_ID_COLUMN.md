# Fix: guests.user_id column does not exist

## Error

```
Error fetching guest: {code: '42703', details: null, hint: null, message: 'column guests.user_id does not exist'}
```

## Root Cause

The `guests` table is missing the `user_id` column, which is required to link guest records to authenticated users. This column should have been created in the initial migration but may be missing due to:

1. Table created before the migration that included `user_id`
2. Column dropped accidentally
3. Migration not applied correctly

## Solution

A migration has been created to ensure the `user_id` column exists:

**File:** `supabase/migrations/20251229041909_ensure_guests_user_id.sql`

This migration:
- Checks if `user_id` column exists
- Adds the column if missing (with proper foreign key to `auth.users`)
- Creates an index on `user_id` for performance

## Apply the Migration

### Option 1: Using Supabase CLI (Recommended)

```bash
# Link to your Supabase project (if not already linked)
npx supabase link --project-ref qnwsnrfcnonaxvnithfv

# Apply the migration
npx supabase db push
```

### Option 2: Via Supabase Dashboard

1. Go to: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/sql/new
2. Copy the contents of `supabase/migrations/20251229041909_ensure_guests_user_id.sql`
3. Paste into the SQL editor
4. Click "Run"

### Option 3: Direct SQL Execution

Run this SQL in Supabase SQL Editor:

```sql
DO $$
BEGIN
    -- Add user_id column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'guests' 
        AND column_name = 'user_id'
    ) THEN
        ALTER TABLE public.guests 
        ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
        
        RAISE NOTICE '✓ Added user_id column to guests table';
    ELSE
        RAISE NOTICE '✓ user_id column already exists in guests table';
    END IF;

    -- Create index on user_id for performance
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_indexes 
        WHERE schemaname = 'public' 
        AND tablename = 'guests' 
        AND indexname = 'idx_guests_user_id'
    ) THEN
        CREATE INDEX idx_guests_user_id ON public.guests(user_id) WHERE user_id IS NOT NULL;
        RAISE NOTICE '✓ Created index on guests.user_id';
    ELSE
        RAISE NOTICE '✓ Index on guests.user_id already exists';
    END IF;
END $$;
```

## Verify Fix

After applying the migration, verify the column exists:

```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'guests' 
  AND column_name = 'user_id';
```

Should return:
```
column_name | data_type | is_nullable
------------|-----------|-------------
user_id     | uuid      | YES
```

## Expected Behavior After Fix

Once the migration is applied:

1. ✅ `GuestContext.tsx` will successfully query guests by `user_id`
2. ✅ Authenticated users will have their guest records linked
3. ✅ Anonymous guests can be linked to user accounts when they sign up
4. ✅ No more "column guests.user_id does not exist" errors

## Related Code

The following files use `user_id` in the guests table:
- `src/contexts/GuestContext.tsx` - Line 58: `.eq('user_id', user.id)`
- `src/hooks/public/useHMS.ts` - Various guest queries
- `src/lib/domain/booking.ts` - Guest creation and linking

All of these will work correctly once the migration is applied.

