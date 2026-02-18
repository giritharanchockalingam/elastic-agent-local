# Events Categories Migration - Quick Guide

## Problem
The migration can't run locally because Supabase local instance isn't running.

## Solution: Apply Migration Directly to Remote Database

### Option 1: Using Supabase Dashboard (Easiest)

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor** → **New Query**
3. Copy the contents of `db-scripts/add-events-categories.sql`
4. Paste into the SQL Editor
5. Click **Run**

### Option 2: Using Supabase CLI with Remote Project

First, link to your remote project:

```bash
# Get your project reference ID from your Supabase URL
# Example: https://abcdefghijklmnop.supabase.co → abcdefghijklmnop
export SUPABASE_PROJECT_REF="your-project-ref"

# Link to remote project
supabase link --project-ref $SUPABASE_PROJECT_REF
```

Then run the migration:

```bash
# Apply migration to remote database
supabase migration up --db-url "postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres"
```

### Option 3: Using psql (Direct Database Connection)

```bash
# Get connection string from Supabase Dashboard → Settings → Database
# Format: postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres

psql "postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres" -f db-scripts/add-events-categories.sql
```

### Option 4: Run SQL File Directly in Dashboard

1. Open `db-scripts/add-events-categories.sql` in your editor
2. Copy all SQL content
3. Paste into Supabase Dashboard → SQL Editor
4. Click **Run**

## Verify Migration

After running, verify the constraint was updated:

```sql
SELECT 
  constraint_name,
  check_clause
FROM information_schema.check_constraints
WHERE table_name = 'public_property_images'
  AND constraint_name LIKE '%category%';
```

You should see `'banquet', 'wedding', 'meeting'` in the CHECK clause.

## Next Steps

After the migration is applied:

1. **Generate Images**:
```bash
export OPENAI_API_KEY="your-key"
node scripts/generate-events-images.mjs
```

2. **Upload Images**:
```bash
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
node scripts/upload-events-images.mjs
```

## Troubleshooting

### "Cannot drop constraint because it does not exist"
- This is normal if the constraint was already dropped
- The script will still create the new constraint

### "Constraint already exists"
- The migration may have already been applied
- Check the constraint to verify it includes event categories

### "Permission denied"
- Ensure you're using the service role key or have admin access
- Check RLS policies if needed
