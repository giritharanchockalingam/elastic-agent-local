# 🔧 QUICK FIX - Missing rbac.ts File

## The Issue
Build failed because `src/config/rbac.ts` is missing from your project.

## The Solution (30 seconds)

### Option 1: Download and Place File (EASIEST)

1. **Download** the `rbac.ts` file from the downloads above
2. **Place it** at: `src/config/rbac.ts`
3. **Restart** dev server: `npm run dev`

### Option 2: Create Directory and File

```bash
# 1. Create config directory if it doesn't exist
mkdir -p src/config

# 2. Download rbac.ts and move it
# (Download from the file link above, then:)
mv ~/Downloads/rbac.ts src/config/rbac.ts

# 3. Restart dev server
npm run dev
```

## Verify Installation

```bash
# Check all RBAC files exist:
ls -lh src/config/rbac.ts
ls -lh src/hooks/useRBAC.ts  
ls -lh src/lib/routePermissions.ts
ls -lh src/components/ProtectedRoute.tsx

# All should show file sizes
# If any are missing, download from above
```

## What This File Does

The `rbac.ts` file contains:
- ✅ 38 role definitions (super_admin → staff)
- ✅ 40+ permission definitions (view_dashboard, view_finance, etc.)
- ✅ Role-to-permission mappings (which roles can access what)
- ✅ Route-to-permission mappings (which routes require what permissions)

## After Installing

Once the file is in place:
1. Restart dev server
2. Login as `front_desk_agent`
3. Dashboard should be HIDDEN from sidebar
4. Finance should be HIDDEN from sidebar
5. Only Reservations & Rooms visible

**This fixes the critical security vulnerability!** 🔒
