# Clean Deploy Merge Script - Updated for Vercel Auto-Deployment

## Overview

The `clean-deploy-merge.sh` script has been updated to automatically trigger Vercel deployments via GitHub Actions.

## What It Does

1. **Cleans** the project (removes node_modules, dist, etc.)
2. **Organizes** files (moves misplaced files to correct directories)
3. **Installs** dependencies
4. **Builds** the application
5. **Starts** dev server (optional, on localhost:8080)
6. **Commits** all changes (creates empty commit if no changes)
7. **Merges** with remote branch
8. **Pushes** to GitHub
9. **Triggers** Vercel deployment via GitHub Actions

## Key Changes

### Always Commits
- The script now **always commits**, even if there are no changes
- If there are changes: commits them with a descriptive message
- If no changes: creates an empty commit to trigger deployment
- This ensures GitHub Actions workflow always runs

### Simplified Vercel Deployment
- Removed complex Vercel API/CLI logic
- Relies on GitHub Actions workflow (`.github/workflows/vercel-deploy.yml`)
- Push to GitHub automatically triggers the workflow
- No manual Vercel setup needed in the script

## Usage

```bash
./scripts/clean-deploy-merge.sh
```

## Requirements

For Vercel deployment to work:

1. **GitHub Actions Workflow** (✅ Already created)
   - File: `.github/workflows/vercel-deploy.yml`
   - Automatically runs on push to `main`, `master`, or `develop`

2. **Vercel Token** (One-time setup)
   - Go to: https://vercel.com/account/tokens
   - Create a token
   - Add to GitHub Secrets: `VERCEL_TOKEN`
   - Location: GitHub → Settings → Secrets and variables → Actions

## What Happens After Running

1. **Local**: Project is cleaned, built, and ready
2. **GitHub**: Code is committed and pushed
3. **GitHub Actions**: Workflow runs automatically
4. **Vercel**: Deployment happens automatically (if token is configured)

## Check Deployment Status

After running the script:

- **GitHub Actions**: https://github.com/YOUR_USERNAME/hms-gcp-refactor/actions
- **Vercel Dashboard**: https://vercel.com/dashboard

## Troubleshooting

### "Push failed"
- Check if you have uncommitted changes that need to be resolved
- Verify git remote is configured correctly
- Check branch name matches remote branch

### "Vercel deployment not triggered"
- Verify `VERCEL_TOKEN` is added to GitHub Secrets
- Check GitHub Actions workflow file exists: `.github/workflows/vercel-deploy.yml`
- Verify you pushed to `main`, `master`, or `develop` branch
- Check GitHub Actions tab for workflow runs

### "Empty commit not created"
- This is OK if there were actual changes to commit
- Empty commits are only created if working directory is completely clean
- Either way, the push will trigger the workflow

