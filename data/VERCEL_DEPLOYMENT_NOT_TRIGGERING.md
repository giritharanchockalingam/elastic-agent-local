# Vercel Deployment Not Triggering - Troubleshooting Guide

## Problem

Commits are being pushed to GitHub, but Vercel deployments are not being triggered automatically.

## Common Causes & Solutions

### 1. **Vercel Project Not Connected to GitHub**

**Check:**
- Go to Vercel Dashboard → Project Settings → Git
- Verify the repository is connected: `giritharanchockalingam/hms-gcp-refactor`
- Check if the connection shows as "Connected" (green status)

**Fix:**
1. Go to: https://vercel.com/dashboard
2. Select your project
3. Go to Settings → Git
4. If not connected, click "Connect Git Repository"
5. Select your GitHub repository
6. Authorize Vercel to access your GitHub account

### 2. **Auto-Deploy Disabled**

**Check:**
- Vercel Dashboard → Project Settings → Git
- Look for "Production Branch" setting
- Ensure "Auto-deploy" is enabled for your branch (usually `main`)

**Fix:**
1. Go to Settings → Git
2. Ensure "Production Branch" is set to `main`
3. Enable "Automatic deployments from Git" toggle
4. Save changes

### 3. **Webhook Not Working**

GitHub webhooks might be broken or not configured.

**Check:**
1. Go to GitHub → Repository → Settings → Webhooks
2. Look for Vercel webhook (should show `vercel.com` in URL)
3. Check recent deliveries - are they successful?

**Fix:**
1. In Vercel Dashboard → Project Settings → Git
2. Click "Disconnect" then "Connect" again
3. This will regenerate the webhook

### 4. **Branch Protection Rules**

GitHub branch protection might be blocking deployments.

**Check:**
- GitHub → Repository → Settings → Branches
- Check if `main` branch has protection rules that require PR reviews

**Fix:**
- For automated deployments, you may need to allow direct pushes to `main`
- Or ensure the deployment account has bypass permissions

### 5. **Vercel Build Settings**

Build settings might be incorrect.

**Check:**
- Vercel Dashboard → Project Settings → General
- Build Command: Should be `npm run build` or `vite build`
- Output Directory: Should be `dist`
- Install Command: Should be `npm install` or `npm ci`

**Fix:**
Ensure settings match your `package.json` scripts:
```json
{
  "scripts": {
    "build": "vite build",
    "dev": "vite"
  }
}
```

### 6. **Vercel Project Deleted or Suspended**

**Check:**
- Vercel Dashboard → Check if project exists and is active
- Look for any error messages or warnings

**Fix:**
- If project was deleted, create a new one
- If suspended, check billing/account status

## Quick Diagnostic Steps

### Step 1: Verify GitHub Integration

```bash
# Check if commits are actually on GitHub
git log origin/main --oneline -5

# Check remote URL
git remote -v
# Should show: https://github.com/giritharanchockalingam/hms-gcp-refactor.git
```

### Step 2: Test Manual Deployment

1. Go to Vercel Dashboard
2. Click "Deployments" tab
3. Click "Redeploy" on the latest deployment
4. If this works, the issue is with auto-deploy/webhooks
5. If this fails, the issue is with build settings

### Step 3: Check Vercel Logs

1. Go to Vercel Dashboard → Deployments
2. Click on a deployment (even failed ones)
3. Check "Build Logs" and "Function Logs"
4. Look for errors or warnings

### Step 4: Reconnect Git Repository

**Nuclear Option - Reconnect Repository:**

1. Vercel Dashboard → Project Settings → Git
2. Click "Disconnect" (this won't delete your project)
3. Click "Connect Git Repository"
4. Select: `giritharanchockalingam/hms-gcp-refactor`
5. Select branch: `main`
6. Click "Connect"

This will:
- Regenerate the webhook
- Re-enable auto-deploy
- Fix most connection issues

## Manual Trigger (Workaround)

If auto-deploy isn't working, you can trigger deployments manually:

### Option 1: Vercel CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy
vercel --prod
```

### Option 2: GitHub Actions (Recommended)

Create `.github/workflows/vercel-deploy.yml`:

```yaml
name: Deploy to Vercel

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

Then add secrets to GitHub:
- `VERCEL_TOKEN`: Get from https://vercel.com/account/tokens
- `VERCEL_ORG_ID`: Vercel Dashboard → Settings → General
- `VERCEL_PROJECT_ID`: Vercel Dashboard → Project Settings → General

## Verification Checklist

- [ ] Repository is connected in Vercel Settings → Git
- [ ] Production branch is set to `main`
- [ ] Auto-deploy is enabled
- [ ] GitHub webhook exists and shows successful deliveries
- [ ] Build settings match `package.json`
- [ ] No branch protection rules blocking deployments
- [ ] Vercel project is active (not suspended)
- [ ] Recent commits are on GitHub (check `git log origin/main`)

## Most Likely Fix

**Try this first:**
1. Vercel Dashboard → Project Settings → Git
2. Click "Disconnect" 
3. Click "Connect Git Repository" 
4. Re-select your repository
5. Make a test commit and push

This reconnects everything and usually fixes webhook/auto-deploy issues.

