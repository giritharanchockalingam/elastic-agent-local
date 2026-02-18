# Setup .env.local for Harvester

## Quick Setup

Create or update `.env.local` in the project root with the following:

```bash
# ============================================================================
# Supabase Configuration for HMS
# ============================================================================

# Frontend App Configuration (Vite)
VITE_SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here

# Backend/CLI Configuration (Harvester, Scripts)
SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
```

## How to Get Your Keys

### Step 1: Get Anon Key (for frontend)

1. Go to: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/settings/api
2. Find **"Project API keys"** section
3. Copy the **"anon" "public"** key
4. Paste it as `VITE_SUPABASE_ANON_KEY`

### Step 2: Get Service Role Key (for harvester)

1. Same page: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/settings/api
2. Find **"service_role"** key (NOT the anon key)
3. Click **"Reveal"** to show it
4. Copy the entire key (it's very long, starts with `eyJ...`)
5. Paste it as `SUPABASE_SERVICE_ROLE_KEY`

⚠️ **Security Warning:** The service role key has admin privileges. Never commit it to git!

## Quick Command

Run this in your terminal (replace the placeholders):

```bash
cat > .env.local << 'EOF'
# Supabase Configuration
VITE_SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co
VITE_SUPABASE_ANON_KEY=PASTE_YOUR_ANON_KEY_HERE
SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co
SUPABASE_SERVICE_ROLE_KEY=PASTE_YOUR_SERVICE_ROLE_KEY_HERE
EOF
```

## Verify Setup

After creating `.env.local`, verify it works:

```bash
# Check if file exists and has content
cat .env.local

# Test harvester (dry-run should work without service role key)
npm run harvest:thangamgrand:npm -- --tenant 00000000-0000-0000-0000-000000000001 --property 00000000-0000-0000-0000-000000000010 --dry-run
```

## Next Steps

Once `.env.local` is set up:

1. ✅ Run the migration: `20250121000007_public_property_content_tables.sql`
2. ✅ Test harvester dry-run (works without service role key)
3. ✅ Add service role key to `.env.local`
4. ✅ Run harvester in apply mode to upload content

