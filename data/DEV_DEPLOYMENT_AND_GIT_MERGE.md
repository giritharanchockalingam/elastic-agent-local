# Dev Deployment and Git Merge Guide

Quick reference for deploying to development and merging code with git.

## 🚀 Quick Commands

### Option 1: Automated Script (Recommended)
```bash
./scripts/deploy-dev-and-merge.sh
```

This script will:
1. Check git status and commit changes if needed
2. Deploy Supabase migrations
3. Deploy Edge Functions
4. Build frontend (optional)
5. Merge branches and push to remote

---

## 📋 Manual Commands

### Step 1: Commit Current Changes
```bash
# Check status
git status

# Stage all changes
git add -A

# Commit
git commit -m "chore: update code before merge"
```

### Step 2: Deploy Supabase Migrations

#### Option A: Via Supabase Dashboard (Recommended)
1. Go to: https://supabase.com/dashboard
2. Select your project
3. Navigate to: **SQL Editor** → **New Query**
4. Run migration files from `supabase/migrations/`:
   - Latest: `20251226_comprehensive_ota_integration.sql`

#### Option B: Via Supabase CLI
```bash
# Login to Supabase
npx supabase login

# Link project (if not already linked)
npx supabase link --project-ref qnwsnrfcnonaxvnithfv

# Deploy migrations
npx supabase db push
```

### Step 3: Deploy Edge Functions
```bash
# Deploy all edge functions
npx supabase functions deploy booking-engine-api --no-verify-jwt
npx supabase functions deploy send-guest-communication --no-verify-jwt
npx supabase functions deploy process-communication-queue --no-verify-jwt
# ... deploy other functions as needed

# Or deploy all at once
for func in $(ls supabase/functions | grep -v "^_"); do
  npx supabase functions deploy "$func" --no-verify-jwt
done
```

### Step 4: Build Frontend (Optional)
```bash
# Install dependencies
npm install

# Build for development
npm run build:dev

# Or build for production
npm run build
```

### Step 5: Git Merge Workflow

#### Merge Current Branch into Main
```bash
# Switch to main
git checkout main

# Pull latest changes
git pull origin main

# Merge your branch
git merge your-branch-name

# Push to remote
git push origin main
```

#### Merge Main into Current Branch
```bash
# Stay on current branch
git pull origin main

# Or explicitly merge
git merge main
```

#### Push Current Branch
```bash
# Push current branch
git push origin $(git branch --show-current)

# Or set upstream
git push -u origin $(git branch --show-current)
```

---

## 🔍 Troubleshooting

### Merge Conflicts
If you encounter merge conflicts:
```bash
# View conflicts
git status

# Resolve conflicts manually in files
# Then stage resolved files
git add .

# Complete merge
git commit
```

### Supabase CLI Not Found
```bash
# Install globally
npm install -g supabase

# Or use npx (no install needed)
npx supabase --version
```

### Edge Function Deployment Fails
1. Check you're logged in: `npx supabase login`
2. Verify project is linked: `npx supabase projects list`
3. Check function exists: `ls supabase/functions/function-name/`
4. Deploy manually via Supabase Dashboard

---

## 📝 Common Workflows

### Daily Development Workflow
```bash
# 1. Pull latest changes
git pull origin main

# 2. Make changes and test locally
npm run dev

# 3. Commit changes
git add -A
git commit -m "feat: add new feature"

# 4. Deploy to dev
./scripts/deploy-dev-and-merge.sh
```

### Feature Branch Workflow
```bash
# 1. Create feature branch
git checkout -b feature/new-feature

# 2. Make changes and commit
git add -A
git commit -m "feat: implement new feature"

# 3. Deploy to dev
./scripts/deploy-dev-and-merge.sh

# 4. Merge to main when ready
git checkout main
git merge feature/new-feature
git push origin main
```

---

## ✅ Verification Checklist

After deployment, verify:

- [ ] Migrations applied successfully in Supabase Dashboard
- [ ] Edge Functions are active and deployed
- [ ] Frontend builds without errors
- [ ] Git changes are committed and pushed
- [ ] No merge conflicts
- [ ] Application runs correctly in dev environment

---

## 🔗 Related Documentation

- [Supabase Deployment Guide](EXTERNAL_BOOKING_API_SETUP.md)
- [Edge Functions Deployment](scripts/deploy-edge-functions.sh)
- [GCP Deployment Guide](DEPLOYMENT_AND_E2E_GUIDE.md)

