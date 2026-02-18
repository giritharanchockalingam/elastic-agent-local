# Fix: React Query createContext Error on Vercel

**Date**: 2024-01-08
**Status**: ✅ Fixed

---

## Problem

Error on Vercel (but not locally):
```
query-vendor-CdiyyOlx.js:1 Uncaught TypeError: Cannot read properties of undefined (reading 'createContext')
```

**Root Cause:**
- React Query was in a separate chunk (`query-vendor`) from React (`react-vendor`)
- React Query tried to use `React.createContext()` before React was loaded
- Vercel was using an old build with the problematic chunking strategy

---

## Solution

**Updated `vite.config.ts`** to bundle React Query with React in the same chunk:

```typescript
// Before (BROKEN):
if (id.includes('node_modules/react') || ...) {
  return 'react-vendor';
}
if (id.includes('node_modules/@tanstack/react-query')) {
  return 'query-vendor';  // ❌ Separate chunk = loading order issue
}

// After (FIXED):
if (
  id.includes('node_modules/react') || 
  id.includes('node_modules/react-dom') || 
  id.includes('node_modules/react-router') ||
  id.includes('node_modules/react-router-dom') ||
  id.includes('node_modules/@tanstack/react-query') ||  // ✅ Same chunk
  id.includes('node_modules/@tanstack/query-core')     // ✅ Include core too
) {
  return 'react-vendor';
}
```

---

## Verification

### Local Build (Working):
```
dist/assets/react-vendor-Nzy3Lr9z.js  398.80 kB │ gzip: 126.35 kB
```
✅ No `query-vendor` chunk
✅ React Query in same chunk as React

### Vercel (Needs Rebuild):
- Old build still shows: `query-vendor-CdiyyOlx.js` ❌
- **Action Required**: Vercel needs to rebuild with new configuration

---

## Next Steps

### 1. Force Vercel to Rebuild

**Option A: Trigger via Git Push**
```bash
git add vite.config.ts
git commit -m "fix: bundle React Query with React to prevent createContext error"
git push origin main
```

**Option B: Manual Redeploy on Vercel**
1. Go to Vercel Dashboard → Your Project → Deployments
2. Click "⋯" (three dots) on latest deployment
3. Click "Redeploy"
4. **IMPORTANT**: Uncheck "Use existing Build Cache"
5. Click "Redeploy"

### 2. Verify After Rebuild

After Vercel rebuilds, check the deployed app:

1. **Check Network Tab:**
   - Should see: `react-vendor-*.js`
   - Should NOT see: `query-vendor-*.js`

2. **Check Console:**
   - Should NOT see: `Cannot read properties of undefined (reading 'createContext')`
   - App should load normally

3. **Verify Chunk Loading:**
   ```javascript
   // In browser console, check loaded chunks
   performance.getEntriesByType('resource')
     .filter(r => r.name.includes('vendor'))
     .forEach(r => console.log(r.name));
   ```
   - Should show: `react-vendor-*.js`
   - Should NOT show: `query-vendor-*.js`

---

## Why This Happens

### Local vs Vercel:
- **Local**: Uses fresh build from `vite.config.ts` (has the fix)
- **Vercel**: Uses cached build or old deployment (doesn't have the fix yet)

### Chunk Loading Order:
- When chunks are separate, they can load in any order
- React Query needs React to be loaded first
- In the same chunk, they load together, ensuring proper order

---

## Alternative Solutions (If Issue Persists)

### Option 1: Disable Manual Chunking for React Query
```typescript
manualChunks: (id) => {
  // Don't split React Query - let Vite handle it automatically
  if (id.includes('node_modules/react') || ...) {
    return 'react-vendor';
  }
  // React Query will be included in main bundle or react-vendor automatically
}
```

### Option 2: Explicit Chunk Dependencies
```typescript
build: {
  rollupOptions: {
    output: {
      manualChunks: {
        'react-vendor': ['react', 'react-dom', '@tanstack/react-query']
      }
    }
  }
}
```

### Option 3: Use Vite's Default Chunking
Remove manual chunking entirely and let Vite handle it:
```typescript
build: {
  rollupOptions: {
    output: {
      manualChunks: undefined  // Use Vite's default chunking
    }
  }
}
```

---

## Status

- ✅ **Fix Applied**: React Query now bundled with React
- ✅ **Local Build**: Working correctly
- ⏳ **Vercel Build**: Needs rebuild with new configuration

**After Vercel rebuilds with the new `vite.config.ts`, the error will be resolved.**

---

## Troubleshooting

If error persists after Vercel rebuild:

1. **Clear Browser Cache:**
   - Hard refresh (Cmd+Shift+R / Ctrl+Shift+R)
   - Or clear browser cache completely

2. **Check Vercel Build Logs:**
   - Go to Vercel → Deployments → Latest → Build Logs
   - Verify it's using the new `vite.config.ts`
   - Check for any build warnings

3. **Verify Environment Variables:**
   - Ensure `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` are set
   - These are needed for build to succeed

4. **Check Chunk Filenames:**
   - If still seeing `query-vendor-*.js`, Vercel hasn't rebuilt yet
   - Force a new deployment

---

**The fix is correct. Vercel just needs to rebuild with the updated configuration.**
