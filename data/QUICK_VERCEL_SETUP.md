# Quick Vercel GitHub Auto-Deployment Setup

## 🚀 Fastest Setup (2 minutes)

### Step 1: Add GitHub Secrets

Go to: **GitHub Repository → Settings → Secrets and variables → Actions → New repository secret**

Add these secrets:

1. **VERCEL_TOKEN**
   - Get from: https://vercel.com/account/tokens
   - Create new token → Copy token value

2. **VERCEL_ORG_ID**
   - Get from: Vercel Dashboard → Your Project → Settings → General
   - Look for "Team ID" or "Org ID"

3. **VERCEL_PROJECT_ID**
   - Get from: Vercel Dashboard → Your Project → Settings → General
   - Look for "Project ID"

### Step 2: Test

Push a commit to `main` branch:
```bash
git add .
git commit -m "Test Vercel deployment"
git push origin main
```

Check deployment:
- GitHub Actions: https://github.com/YOUR_USERNAME/hms-gcp-refactor/actions
- Vercel Dashboard: https://vercel.com/dashboard

## ✅ That's It!

The `.github/workflows/vercel-deploy.yml` workflow will automatically:
1. Build your project
2. Deploy to Vercel
3. Run on every push to `main`, `master`, or `develop`

## 🔍 Verify It Works

After pushing, check:
1. **GitHub Actions tab** → Should see "Vercel Deployment" workflow running
2. **Vercel Dashboard** → Should see new deployment
3. **Your site** → Should be updated

## ❌ Troubleshooting

### "VERCEL_TOKEN not found"
→ Add `VERCEL_TOKEN` to GitHub Secrets

### "Workflow not running"
→ Make sure you pushed to `main`, `master`, or `develop` branch

### "Build failed"
→ Check workflow logs in GitHub Actions tab for error details

