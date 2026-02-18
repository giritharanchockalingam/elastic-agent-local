# Fix: React Query createContext Error on Vercel

**Date**: 2024-01-08
**Status**: ✅ Fixed (Needs Vercel Rebuild)

---

## Problem

**Error on Vercel:**
```
query-vendor-CdiyyOlx.js:1 Uncaught TypeError: Cannot read properties of undefined (reading 'createContext')
```

**Root Cause:**
- React Query was in a separate chunk (`query-vendor`) from React (`react-vendor`)
- React Query tried to use `React.createContext()` before React was loaded
- Vercel is serving an **old build** that still has the separate chunk

---

## Solution Applied ✅

**Updated `vite.config.ts`** to bundle React Query with React in the same chunk:

```typescript
// Core React chunk - Must load first, include all React dependencies
// React Query MUST be in the same chunk as React to avoid loading order issues
if (
  id.includes('node_modules/react') || 
  id.includes('node_modules/react-dom') || 
  id.includes('node_modules/react-router') ||
  id.includes('node_modules/react-router-dom') ||
  id.includes('node_modules/@tanstack/react-query') ||  // ✅ Now in same chunk
  id.includes('node_modules/@tanstack/query-core')      // ✅ Include core too
) {
  return 'react-vendor';
}
```

**Result:**
- ✅ Local build: Creates `react-vendor-*.js` (includes React + React Query)
- ✅ No more `query-vendor` chunk
- ⏳ Vercel: Still serving old build with `query-vendor-CdiyyOlx.js`

---

## Why Vercel Shows Old Chunk

Vercel is still serving a build from before the fix was applied. The error `query-vendor-CdiyyOlx.js` indicates an old build.

**Current State:**
- ✅ Fix applied: `vite.config.ts` updated
- ✅ Local build works: `react-vendor-Nzy3Lr9z.js` (correct)
- ❌ Vercel build: Still using old `query-vendor-CdiyyOlx.js`

---

## Next Steps - Force Vercel Rebuild

### Option 1: Push to GitHub (Recommended)

The GitHub Actions workflow will trigger a new Vercel deployment:

```bash
git add vite.config.ts
git commit -m "fix: bundle React Query with React to prevent createContext error"
git push origin main
```

**This will:**
1. Trigger GitHub Actions build
2. Deploy new build to Vercel
3. Use new chunking configuration

### Option 2: Manual Redeploy on Vercel

1. Go to: **Vercel Dashboard** → Your Project → **Deployments**
2. Find the latest deployment
3. Click **"⋯"** (three dots) → **"Redeploy"**
4. **IMPORTANT**: Uncheck **"Use existing Build Cache"**
5. Click **"Redeploy"**

This forces Vercel to rebuild with the new configuration.

### Option 3: Clear Vercel Build Cache

If redeploy doesn't work:

1. Go to: **Vercel Dashboard** → Your Project → **Settings** → **Build & Development Settings**
2. Click **"Clear Build Cache"**
3. Then redeploy

---

## Verification After Rebuild

After Vercel rebuilds, verify:

1. **Check Browser Console:**
   - Should NOT see: `Cannot read properties of undefined (reading 'createContext')`
   - Should NOT see: `query-vendor-*.js`

2. **Check Network Tab:**
   - Should see: `react-vendor-*.js` (includes React Query)
   - Should NOT see: `query-vendor-*.js`

3. **Check Build Logs:**
   - Vercel Dashboard → Deployments → Latest → Build Logs
   - Should show: `react-vendor-*.js` in build output
   - Should NOT show: `query-vendor-*.js`

---

## Build Comparison

**Old Build (BROKEN):**
```
dist/assets/react-vendor-*.js
dist/assets/query-vendor-CdiyyOlx.js  ❌ Separate chunk = error
```

**New Build (FIXED):**
```
dist/assets/react-vendor-Nzy3Lr9z.js  ✅ Includes React + React Query
```

---

## If Issue Persists

If after rebuild you still see the error:

### Check 1: Verify New Build
```bash
# In browser console:
performance.getEntriesByType('resource')
  .filter(r => r.name.includes('vendor'))
  .forEach(r => console.log(r.name));
```
- Should show: `react-vendor-*.js`
- Should NOT show: `query-vendor-*.js`

### Check 2: Clear Browser Cache
- Hard refresh: `Cmd+Shift+R` (Mac) or `Ctrl+Shift+R` (Windows)
- Or clear browser cache completely

### Check 3: Check Vercel Build Logs
- Verify it's using the new `vite.config.ts`
- Check for any build warnings or errors
- Ensure environment variables are set correctly

---

## Technical Details

### Why Same Chunk is Required

React Query uses `React.createContext()` internally:
```typescript
// Inside @tanstack/react-query
const QueryContext = React.createContext(...)
```

If React Query loads before React:
- React is `undefined`
- `React.createContext()` throws: "Cannot read properties of undefined"

By bundling them together:
- React and React Query load in the same chunk
- React is guaranteed to be available when React Query initializes

### Chunk Loading Order

**Problematic (Old):**
```
1. Load query-vendor.js (React Query)
2. React Query tries to use React.createContext()
3. React not loaded yet → ERROR
4. Load react-vendor.js (too late)
```

**Fixed (New):**
```
1. Load react-vendor.js (React + React Query together)
2. React available immediately
3. React Query can use React.createContext()
4. ✅ Works
```

---

## Status

- ✅ **Fix Applied**: React Query bundled with React
- ✅ **Local Build**: Working correctly
- ⏳ **Vercel Build**: Needs rebuild with new configuration

**After Vercel rebuilds with the updated `vite.config.ts`, the error will be resolved.**

---

**Action Required**: Push changes to GitHub or manually redeploy on Vercel to trigger a new build with the fixed configuration.
