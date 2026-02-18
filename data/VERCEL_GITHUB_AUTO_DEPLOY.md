# Vercel GitHub Auto-Deployment Setup

## Problem

GitHub merges were not triggering Vercel deployments automatically.

## Solution

Two approaches are available:

### Option 1: GitHub Actions Workflow (Recommended)

A GitHub Actions workflow (`.github/workflows/vercel-deploy.yml`) has been created that:
- Triggers on pushes to `main`, `master`, or `develop` branches
- Triggers on pull requests to those branches
- Builds the project
- Deploys to Vercel using the Vercel CLI

#### Setup Steps:

1. **Get Vercel Credentials:**
   - Go to: https://vercel.com/account/tokens
   - Create a new token (copy it)
   - Go to your Vercel project settings
   - Copy `Org ID` and `Project ID`

2. **Add GitHub Secrets:**
   - Go to: GitHub Repository → Settings → Secrets and variables → Actions
   - Add these secrets:
     - `VERCEL_TOKEN` - Your Vercel token from step 1
     - `VERCEL_ORG_ID` - Your Vercel organization ID
     - `VERCEL_PROJECT_ID` - Your Vercel project ID
     - `VITE_SUPABASE_URL` - Your Supabase URL (if not already set)
     - `VITE_SUPABASE_ANON_KEY` - Your Supabase anon key (if not already set)

3. **Test the Workflow:**
   - Make a commit and push to `main` branch
   - Go to: GitHub Repository → Actions
   - You should see "Vercel Deployment" workflow running

### Option 2: Vercel GitHub Integration (Alternative)

If you prefer Vercel's built-in auto-deploy:

1. **Connect GitHub to Vercel:**
   - Go to: https://vercel.com/dashboard
   - Click "Add New..." → "Project"
   - Import your GitHub repository
   - Select the repository: `hms-gcp-refactor`
   - Configure:
     - Framework Preset: Vite
     - Root Directory: `./` (or leave default)
     - Build Command: `npm run build`
     - Output Directory: `dist`
     - Install Command: `npm ci`

2. **Add Environment Variables:**
   - In Vercel project settings → Environment Variables
   - Add:
     - `VITE_SUPABASE_URL`
     - `VITE_SUPABASE_ANON_KEY`

3. **Configure Branch Settings:**
   - In Vercel project settings → Git
   - Enable "Auto-deploy" for:
     - `main` (Production)
     - `develop` (Preview)

4. **Verify Webhook:**
   - Go to: GitHub Repository → Settings → Webhooks
   - You should see a Vercel webhook
   - If not, disconnect and reconnect the repository in Vercel

## Recommended: Use Both

You can use both methods:
- **GitHub Actions**: More control, visible in GitHub Actions tab
- **Vercel Integration**: Simpler, managed by Vercel

The GitHub Actions workflow will deploy regardless of Vercel's integration status.

## Troubleshooting

### Issue: "VERCEL_TOKEN not found"
**Solution:** Add `VERCEL_TOKEN` to GitHub Secrets (Settings → Secrets and variables → Actions)

### Issue: "VERCEL_ORG_ID not found"
**Solution:** Add `VERCEL_ORG_ID` and `VERCEL_PROJECT_ID` to GitHub Secrets

### Issue: "Build failed"
**Solution:** Check build logs in GitHub Actions. Common issues:
- Missing environment variables
- Build errors in the code
- Node version mismatch

### Issue: "Vercel CLI not found"
**Solution:** The workflow installs Vercel CLI automatically. If it fails, check the workflow file.

### Issue: "Vercel integration not deploying"
**Solution:**
1. Check webhook exists in GitHub: Repository → Settings → Webhooks
2. Try disconnecting and reconnecting repository in Vercel
3. Check Vercel project settings → Git → Auto-deploy is enabled
4. Check branch is included in auto-deploy settings

## Quick Checklist

- [ ] GitHub Actions workflow file exists (`.github/workflows/vercel-deploy.yml`)
- [ ] `VERCEL_TOKEN` added to GitHub Secrets
- [ ] `VERCEL_ORG_ID` added to GitHub Secrets
- [ ] `VERCEL_PROJECT_ID` added to GitHub Secrets
- [ ] Environment variables added to GitHub Secrets (if using Actions) or Vercel (if using integration)
- [ ] Test deployment by pushing to `main` branch
- [ ] Check GitHub Actions tab for workflow run

## Files Created

- `.github/workflows/vercel-deploy.yml` - GitHub Actions workflow for Vercel deployment

