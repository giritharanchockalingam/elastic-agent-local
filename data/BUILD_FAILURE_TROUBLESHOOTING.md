# Build Failure Troubleshooting

**Date**: 2024-01-08

---

## Problem

The "Build project" step is failing in CI with exit code 1, even though the build succeeds locally.

---

## Common Causes & Solutions

### 1. Missing Environment Variables in GitHub Secrets ⚠️

**Check:**
1. Go to: Repository → Settings → Secrets and variables → Actions
2. Verify these secrets exist:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`

**Fix:**
- Add missing secrets with correct values
- Ensure secret names match exactly (case-sensitive)

---

### 2. TypeScript Compilation Errors

**Check:**
- Look at the build logs in GitHub Actions
- Look for TypeScript errors (TS####)
- Look for import/module resolution errors

**Fix:**
- Fix TypeScript errors
- Check for missing type definitions
- Verify all imports resolve correctly

---

### 3. Missing Dependencies

**Check:**
- Look for "Cannot find module" errors
- Look for "Package not found" errors

**Fix:**
- Ensure `package.json` has all required dependencies
- Run `npm ci` locally to verify
- Check for version mismatches

---

### 4. Build Configuration Issues

**Check:**
- Look for Vite configuration errors
- Check for missing config files
- Verify `vite.config.ts` is valid

**Fix:**
- Fix configuration issues
- Ensure all config files are present
- Verify file paths are correct

---

### 5. Environment-Specific Issues

**Difference between local and CI:**
- CI uses `npm ci` (clean install, no node_modules)
- Local might have cached dependencies
- CI runs in clean Ubuntu environment

**Test locally:**
```bash
# Simulate CI environment
rm -rf node_modules package-lock.json
npm ci
npm run build
```

---

## How to Check Build Logs

1. Go to GitHub Actions tab
2. Click on the failed workflow run
3. Click on "deploy" job
4. Click on "Build project" step
5. Scroll through logs to find the actual error

**Look for:**
- Error messages (red text)
- Stack traces
- TypeScript errors
- Import errors
- Missing module errors

---

## Quick Fixes

### Option 1: Check Actual Error Logs
The error message in the logs will tell you exactly what's wrong. Common issues:
- Missing environment variables → Add to GitHub Secrets
- TypeScript errors → Fix code
- Missing dependencies → Add to package.json
- Build config issues → Fix vite.config.ts

### Option 2: Test Build Locally
```bash
# Clean install (like CI)
rm -rf node_modules package-lock.json
npm ci

# Try build with env vars
export VITE_SUPABASE_URL="https://your-project.supabase.co"
export VITE_SUPABASE_ANON_KEY="your-key"
npm run build
```

### Option 3: Make Build More Resilient
If environment variables are optional for build, you could make them optional:
```yaml
- name: Build project
  run: npm run build
  env:
    VITE_SUPABASE_URL: ${{ secrets.VITE_SUPABASE_URL || 'https://placeholder.supabase.co' }}
    VITE_SUPABASE_ANON_KEY: ${{ secrets.VITE_SUPABASE_ANON_KEY || 'placeholder-key' }}
```

**⚠️ Warning**: Only do this if the build can work without real values (e.g., for static builds).

---

## Next Steps

1. **Check the actual build logs** in GitHub Actions to see the specific error
2. **Add missing environment variables** to GitHub Secrets if needed
3. **Fix any TypeScript/build errors** found in logs
4. **Test locally** with `npm ci && npm run build`

---

**The build logs will show the exact error - check them to identify the root cause.**
