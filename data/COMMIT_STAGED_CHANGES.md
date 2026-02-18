# Commit Staged Changes

## Current Situation

You have **94 files staged** for commit that need to be committed and pushed to trigger Vercel deployment.

## Quick Fix - Commit and Push

### Option 1: Using the Script (Recommended)

The `clean-deploy-merge` script should handle this, but if it didn't commit, run it again:

```bash
npm run clean-deploy-merge
```

This will:
- Commit all staged changes
- Push to GitHub
- Trigger Vercel deployment

### Option 2: Manual Commit

If you want to commit manually:

```bash
# Review what's staged
git status

# Commit all staged files
git commit -m "feat: Add public portal, harvester, and deployment fixes

- Add public portal architecture and implementation
- Add content harvester with rewrite engine
- Add RLS fixes for service role
- Add deployment script improvements
- Add ingestion run checker
- Add comprehensive documentation

$(date '+%Y-%m-%d %H:%M:%S')"

# Push to GitHub
git push origin main
```

### Option 3: Commit via VS Code / GitHub Desktop

If you're using VS Code (which appears to be the case from the screenshot):

1. **In the Commit interface you're seeing:**
   - Fill in the "Summary" field (required)
   - Optionally add a "Description"
   - Click "Commit 94 files to main"

2. **Then push:**
   - Click the "Sync" button or push icon
   - Or run: `git push origin main` in terminal

## What Files Are Staged?

The staged files include:
- ✅ New public portal components (SEOHead, LeadCaptureForm, etc.)
- ✅ Public portal architecture documentation
- ✅ Harvester scripts and documentation
- ✅ Database migrations for public content
- ✅ RLS fixes and ingestion run tracking
- ✅ Deployment script improvements
- ✅ Various documentation files

These are all legitimate changes that should be committed.

## After Committing

Once you commit and push:

1. **GitHub will receive the commit**
2. **Vercel webhook will trigger** (if properly connected)
3. **Deployment will start** within 1-2 minutes
4. **You'll see it in Vercel Dashboard**

## If Vercel Still Doesn't Deploy

After committing, if Vercel still doesn't deploy automatically:

1. **Check webhook connection** (see `docs/VERCEL_DEPLOYMENT_NOT_TRIGGERING.md`)
2. **Reconnect Git repository** in Vercel Settings
3. **Trigger manual deployment** to verify build works

## Recommended Commit Message

```
feat: Public portal, content harvester, and deployment improvements

- Add public portal architecture with slug resolution
- Add content harvester CLI with rewrite engine
- Add public portal pages (tenant landing, property landing)
- Add database migrations for public content tables
- Add RLS fixes for service role access
- Add deployment script improvements
- Add comprehensive documentation
- Add ingestion run tracking and checker script

Date: 2025-12-27
```

This describes all the major work done in this session.

