# How to Clear Vercel Build Cache

## Method 1: Force Rebuild via Git Commit (Recommended)

This is the simplest way to force Vercel to rebuild with fresh cache.

### Steps:

1. **Make a small change to trigger rebuild:**
   ```bash
   # Add a comment or whitespace change to any file
   # For example, add a comment to callback.tsx
   ```

2. **Stage and commit:**
   ```bash
   git add .
   git commit -m "fix: force rebuild to clear auth callback cache"
   ```

3. **Push to trigger Vercel rebuild:**
   ```bash
   git push origin main
   # or
   git push origin master
   ```

4. **Vercel will automatically:**
   - Detect the push
   - Start a new build
   - Use fresh cache (or you can manually clear it - see Method 2)

---

## Method 2: Clear Build Cache in Vercel Dashboard

This method clears the cache without needing a new commit.

### Steps:

1. **Go to Vercel Dashboard:**
   - Visit: https://vercel.com/dashboard
   - Sign in if needed

2. **Navigate to Your Project:**
   - Click on your project (e.g., `hms-aurora-portal-clean`)

3. **Go to Settings:**
   - Click on **"Settings"** tab in the top navigation

4. **Find Build & Development Settings:**
   - Scroll down to **"Build & Development Settings"** section

5. **Clear Build Cache:**
   - Look for **"Clear Build Cache"** or **"Rebuild"** option
   - Click **"Clear Build Cache"** button
   - Confirm the action

6. **Trigger a New Deployment:**
   - Go to **"Deployments"** tab
   - Find the latest deployment
   - Click the **"..."** (three dots) menu
   - Select **"Redeploy"**
   - Or click **"Redeploy"** button directly
   - Check **"Use existing Build Cache"** should be **UNCHECKED** (this ensures fresh build)

---

## Method 3: Clear Cache via Vercel CLI (Alternative)

If you have Vercel CLI installed:

```bash
# Install Vercel CLI (if not installed)
npm i -g vercel

# Login to Vercel
vercel login

# Link to your project (if not already linked)
vercel link

# Redeploy with cleared cache
vercel --prod --force
```

---

## Method 4: Add Empty Commit (Quick Git Method)

If you want to force a rebuild without making code changes:

```bash
# Create an empty commit
git commit --allow-empty -m "chore: force Vercel rebuild"

# Push to trigger deployment
git push origin main
```

---

## Recommended Approach

**For immediate fix:** Use Method 2 (Vercel Dashboard) - fastest way to clear cache and redeploy

**For long-term:** Use Method 1 (Git commit) - ensures code changes are tracked in version control

---

## Verify the Fix

After clearing cache and redeploying:

1. Check Vercel deployment logs to ensure build completed successfully
2. Visit your production URL: `https://your-app.vercel.app/auth/callback`
3. Test OAuth login flow
4. Verify `AuthCallback` component loads without errors

---

## Troubleshooting

If the error persists after clearing cache:

1. **Check build logs** in Vercel dashboard for any errors
2. **Verify file exists** in repository: `src/pages/auth/callback.tsx`
3. **Check import path** in `App.tsx`: Should be `import AuthCallback from "./pages/auth/callback";`
4. **Verify export** in callback.tsx: Should have `export default function AuthCallback()`
5. **Check for TypeScript errors** that might prevent build

---

## Quick Command Reference

```bash
# Method 1: Quick commit and push
git add . && git commit -m "fix: clear build cache" && git push

# Method 4: Empty commit (no code changes)
git commit --allow-empty -m "chore: force rebuild" && git push
```
