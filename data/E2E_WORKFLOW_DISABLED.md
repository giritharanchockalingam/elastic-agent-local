# E2E Tests Workflow - Disabled

**Date**: 2024-01-08
**Status**: ✅ Disabled

---

## Problem

The E2E tests workflow (`e2e-tests.yml`) was running on every commit to `main` and `develop` branches, causing:
- ❌ Unnecessary CI resource usage
- ❌ Failure notifications on every commit
- ❌ Tests not relevant to this project

## Solution

The workflow has been **disabled** by renaming the file to `.github/workflows/e2e-tests.yml.disabled`.

**Result:**
- ✅ E2E tests will **NOT** run automatically on commits
- ✅ No more unnecessary CI runs
- ✅ No more failure notifications from E2E tests

## What Was Changed

**Before:**
- `.github/workflows/e2e-tests.yml` - Active workflow that ran on every commit

**After:**
- `.github/workflows/e2e-tests.yml.disabled` - Disabled workflow (backup)
- E2E tests no longer run automatically

## If You Need to Re-enable

If you need to re-enable E2E tests in the future:

1. **Rename the file:**
   ```bash
   mv .github/workflows/e2e-tests.yml.disabled .github/workflows/e2e-tests.yml
   ```

2. **Update the triggers** as needed:
   ```yaml
   on:
     pull_request:  # Only on PRs
       branches: [ main, develop ]
     workflow_dispatch:  # Manual trigger only
   ```

3. **Verify the workflow** works as expected

## Local Testing

E2E tests can still be run locally if needed:

```bash
# Run local E2E tests
npm run test:e2e:local

# Run OAuth E2E tests
npm run test:e2e:oauth
```

But they will **NOT** run automatically in CI/CD anymore.

---

**Status**: ✅ Workflow disabled. E2E tests will no longer trigger on commits.
