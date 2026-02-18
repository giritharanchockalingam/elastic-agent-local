# Fix Vercel GitHub Auto-Deployment

## Problem

GitHub merges/pushes were not triggering Vercel deployments automatically.

## Solution

Created a GitHub Actions workflow (`.github/workflows/vercel-deploy.yml`) that automatically deploys to Vercel when code is pushed to `main`, `master`, or `develop` branches.

## Setup Instructions

### Quick Setup (2 minutes)

1. **Get Vercel Token:**
   - Visit: https://vercel.com/account/tokens
   - Create a new token
   - Copy the token value

2. **Add to GitHub Secrets:**
   - Go to: GitHub Repository → Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `VERCEL_TOKEN`
   - Value: Paste the token from step 1
   - Click "Add secret"

3. **Test:**
   - Push a commit to `main` branch
   - Check GitHub Actions tab for deployment status

### Optional: Add Project/Org IDs (for better control)

If you want to specify which project to deploy to:

1. Go to: Vercel Dashboard → Your Project → Settings → General
2. Copy "Team ID" (or "Org ID")
3. Copy "Project ID"
4. Add to GitHub Secrets:
   - `VERCEL_ORG_ID` = Your Team/Org ID
   - `VERCEL_PROJECT_ID` = Your Project ID

**Note:** If these aren't provided, the workflow will auto-detect from your Vercel account.

## How It Works

1. **Trigger:** When code is pushed to `main`, `master`, or `develop`
2. **Build:** Runs `npm ci` and `npm run build`
3. **Deploy:** Uses Vercel CLI to deploy to production
4. **Result:** Your Vercel site is updated automatically

## Files Created

- `.github/workflows/vercel-deploy.yml` - GitHub Actions workflow

## Verification

After setup, test by:
1. Making a commit: `git commit -m "Test Vercel deployment"`
2. Pushing: `git push origin main`
3. Checking: GitHub Repository → Actions tab
4. You should see "Vercel Deployment" workflow running

## Troubleshooting

### Issue: "VERCEL_TOKEN not found"
**Solution:** Add `VERCEL_TOKEN` to GitHub Secrets (Settings → Secrets and variables → Actions)

### Issue: "Workflow not running"
**Solution:** 
- Make sure you pushed to `main`, `master`, or `develop` branch
- Check if workflow file exists: `.github/workflows/vercel-deploy.yml`
- Check workflow file syntax is valid

### Issue: "Build failed"
**Solution:**
- Check workflow logs in GitHub Actions tab
- Verify environment variables are set if needed
- Check for build errors in the code

### Issue: "Deployment failed"
**Solution:**
- Verify VERCEL_TOKEN is valid (not expired)
- Check Vercel account has access to the project
- Try regenerating the token if needed

## Alternative: Vercel GitHub Integration

If you prefer Vercel's built-in integration:

1. Go to: Vercel Dashboard → Add New Project
2. Import your GitHub repository
3. Configure build settings
4. Enable auto-deploy for your branches

**Note:** The GitHub Actions workflow provides more control and visibility, so both methods can work together.

