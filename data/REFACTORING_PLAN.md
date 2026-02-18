# Comprehensive Refactoring Plan

**Date**: 2024-01-08
**Status**: In Progress

---

## STEP 0: Backup ✅

Backup commands created in `BACKUP_COMMANDS.sh`

---

## STEP 1: Dependency & Config Cleanup

### Analysis

**Dependencies Status**:
- All dependencies appear to be in use
- `openai`, `sharp`, `cheerio`, `dotenv` are used in scripts (keep as devDependencies)
- No obvious unused dependencies to remove

**Config Files**:
- `tsconfig.json`: Has relaxed settings (`noImplicitAny: false`, `strictNullChecks: false`)
- `eslint.config.js`: Properly configured
- `vite.config.ts`: Clean and minimal

**Action**: Minor improvements to TypeScript config for better type safety without breaking changes.

---

## STEP 2: Architecture & Folder Structure

### Current Structure Analysis

**Good**:
- `src/components/` - UI components
- `src/pages/` - Route-level pages
- `src/hooks/` - React hooks
- `src/lib/` - Pure logic
- `src/config/` - Static config
- `src/contexts/` - React contexts

**Issues Found**:
- `src/router.tsx.deprecated` - Should be removed or moved
- Some hooks might be better organized (finance hooks already created)
- Some lib utilities might be duplicated

**Action**: Clean up deprecated files, ensure consistent organization.

---

## STEP 3: Tech Debt Reduction

### Components to Refactor

1. **Large/Complex Components**:
   - `BookingEngine.tsx` (3000+ lines) - Needs splitting
   - `FinancialReports.tsx` (1600+ lines) - Needs splitting
   - Various public pages - Check for duplication

2. **Hooks Consolidation**:
   - Finance hooks already centralized ✅
   - Image hooks - Check for duplication
   - Data fetching hooks - Check for duplication

**Action**: Refactor incrementally, starting with most critical.

---

## STEP 4: Centralize Cross-Cutting Logic

### Status

1. **Financial Logic**: ✅ Already centralized (from previous work)
2. **Image Resolver**: Need to verify single source
3. **Auth & Routing**: Need to verify consistency

**Action**: Verify and consolidate where needed.

---

## STEP 5: Dead Code & Unused Files

**Files to Check**:
- `src/router.tsx.deprecated`
- Old page variants
- Unused components

**Action**: Identify and remove/deprecate.

---

## STEP 6: Production Readiness

**Areas to Address**:
- TypeScript errors
- Runtime safety (null checks)
- UI consistency
- Error handling

**Action**: Systematic pass through critical flows.

---

## Execution Order

1. ✅ Backup commands
2. ⏳ Config cleanup (minor)
3. ⏳ Remove deprecated files
4. ⏳ Verify folder structure
5. ⏳ Refactor critical components
6. ⏳ Consolidate hooks
7. ⏳ Production readiness pass
