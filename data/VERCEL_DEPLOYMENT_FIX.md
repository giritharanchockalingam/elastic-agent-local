# Fix: React Query createContext Error on Vercel

**Date**: 2024-01-08
**Status**: ✅ Fixed - Needs Vercel Rebuild

---

## Problem

**Error on Vercel:**
```
query-vendor-CdiyyOlx.js:1 Uncaught TypeError: Cannot read properties of undefined (reading 'createContext')
```

**Root Cause:**
- React Query was in a separate chunk (`query-vendor`) from React (`react-vendor`)
- React Query tried to use `React.createContext()` before React was loaded
- Vercel is serving an **old build** from before the fix

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
- ✅ **Local Build**: Creates `react-vendor-Nzy3Lr9z.js` (includes React + React Query)
- ✅ **No More**: `query-vendor` chunk
- ⏳ **Vercel**: Still serving old build with `query-vendor-CdiyyOlx.js`

---

## Why Vercel Shows Old Chunk

The error shows `query-vendor-CdiyyOlx.js`, which indicates Vercel is using an **old build** from before the fix was applied.

**Current State:**
- ✅ **Fix Applied**: `vite.config.ts` updated correctly
- ✅ **Local Build Works**: Creates `react-vendor-Nzy3Lr9z.js` ✅
- ❌ **Vercel Still Using**: Old build with `query-vendor-CdiyyOlx.js` ❌

---

## Action Required: Force Vercel Rebuild

### Option 1: Push to GitHub (Recommended)

Push the updated `vite.config.ts` to trigger a new Vercel deployment:

```bash
git add vite.config.ts
git commit -m "fix: bundle React Query with React to prevent createContext error"
git push origin main
```

**This will:**
1. ✅ Trigger GitHub Actions workflow
2. ✅ Build with new configuration
3. ✅ Deploy new build to Vercel
4. ✅ Use `react-vendor` chunk (no more `query-vendor`)

### Option 2: Manual Redeploy on Vercel

1. Go to: **Vercel Dashboard** → Your Project → **Deployments**
2. Find the latest deployment
3. Click **"⋯"** (three dots) → **"Redeploy"**
4. **CRITICAL**: Uncheck **"Use existing Build Cache"**
5. Click **"Redeploy"**

This forces Vercel to rebuild from scratch with the new configuration.

### Option 3: Clear Vercel Build Cache

If redeploy doesn't work:

1. Go to: **Vercel Dashboard** → Your Project → **Settings** → **Build & Development Settings**
2. Click **"Clear Build Cache"**
3. Then redeploy (Option 2)

---

## Verification After Rebuild

After Vercel rebuilds, check:

### 1. Browser Console
- ✅ Should NOT see: `Cannot read properties of undefined (reading 'createContext')`
- ✅ Should NOT see: `query-vendor-*.js` in errors

### 2. Network Tab
- ✅ Should see: `react-vendor-*.js` (includes React Query)
- ✅ Should NOT see: `query-vendor-*.js`

### 3. Build Logs (Vercel Dashboard)
- ✅ Should show: `react-vendor-*.js` in build output
- ✅ Should NOT show: `query-vendor-*.js`

### 4. Check Chunk Files
```javascript
// In browser console:
performance.getEntriesByType('resource')
  .filter(r => r.name.includes('vendor'))
  .map(r => r.name)
  .forEach(console.log);
```
- ✅ Should show: `react-vendor-*.js`
- ✅ Should NOT show: `query-vendor-*.js`

---

## Build Comparison

### Old Build (BROKEN - Current on Vercel)
```
dist/assets/react-vendor-*.js
dist/assets/query-vendor-CdiyyOlx.js  ❌ Separate chunk = error
```

### New Build (FIXED - After Rebuild)
```
dist/assets/react-vendor-Nzy3Lr9z.js  ✅ Includes React + React Query
```

---

## Why This Happens

### Chunk Loading Order Issue:

**Old (BROKEN):**
```
1. Browser loads query-vendor.js (React Query)
2. React Query tries: React.createContext()
3. React not loaded yet → ERROR: Cannot read properties of undefined
4. Browser loads react-vendor.js (too late)
```

**New (FIXED):**
```
1. Browser loads react-vendor.js (React + React Query together)
2. React available immediately
3. React Query can use: React.createContext()
4. ✅ Works perfectly
```

---

## Status

- ✅ **Fix Applied**: React Query bundled with React
- ✅ **Local Build**: Working correctly (`react-vendor-Nzy3Lr9z.js`)
- ⏳ **Vercel Build**: Needs rebuild with new configuration

**After Vercel rebuilds with the updated `vite.config.ts`, the error will be resolved.**

---

**Action Required**: Push changes to GitHub or manually redeploy on Vercel without build cache to trigger a new build with the fixed configuration.
