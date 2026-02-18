# Fix .env.local - Replace Placeholder Values

## Issue

Your `.env.local` file contains placeholder values that need to be replaced with actual Supabase credentials.

## Quick Fix

Open `.env.local` and replace:

```bash
# ❌ WRONG (placeholder):
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# ✅ CORRECT (your actual values):
SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... (your full key)
```

## Your Current Values

Based on your setup, you should use:

```bash
SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co
VITE_SUPABASE_URL=https://qnwsnrfcnonaxvnithfv.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFud3NucmZjbm9uYXh2bml0aGZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMxODA2OTgsImV4cCI6MjA3ODc1NjY5OH0.lMe0GLivF_bnQImk_CULy2-OrlaSzC1ptNV_KlsLr2Q
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFud3NucmZjbm9uYXh2bml0aGZ2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MzE4MDY5OCwiZXhwIjoyMDc4NzU2Njk4fQ.JOJOlBN1WUHdptHKyKn9cO93uSCpxEYDxC3U_jtWyyI
```

## How to Get Service Role Key

1. Go to: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/settings/api
2. Scroll to "Project API keys"
3. Find **"service_role"** key (NOT the anon key)
4. Click **"Reveal"** to show it
5. Copy the entire key (it's very long, starts with `eyJ...`)
6. Paste it as `SUPABASE_SERVICE_ROLE_KEY` in `.env.local`

## After Updating

Run the harvester again:

```bash
npm run harvest:thangamgrand:npm -- --tenant grand-hospitality --property airport-hotel --apply
```

The script will now automatically:
- Skip placeholder values
- Use `VITE_SUPABASE_URL` if `SUPABASE_URL` is a placeholder
- Use `VITE_SUPABASE_ANON_KEY` if `SUPABASE_SERVICE_ROLE_KEY` is a placeholder (though service role key is preferred for writes)

