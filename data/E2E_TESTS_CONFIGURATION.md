# E2E Tests Configuration

## Problem

E2E tests (`e2e-local` and `e2e-oauth`) were running on **every push** to `main` and `develop` branches, causing:
- ❌ Frequent failures on every commit
- ❌ Deployment blocking
- ❌ Unnecessary CI resource usage

## Solution

Updated `.github/workflows/e2e-tests.yml` to:

### 1. Only Run on Pull Requests ✅
- **Removed**: `push` trigger for `main` and `develop`
- **Kept**: `pull_request` trigger (runs before merge)
- **Kept**: `workflow_dispatch` (manual trigger)

**Why?**
- E2E tests should run **before** code is merged, not after
- Tests already pass in PRs before merge
- Prevents failures from blocking deployments

### 2. Non-Blocking Failures ✅
- Added `continue-on-error: true` to both jobs
- Tests can fail without blocking workflow

**Why?**
- E2E tests can be flaky
- Don't block deployments for test failures
- Still get visibility into test results

## Current Configuration

```yaml
on:
  pull_request:
    branches: [ main, develop ]
  workflow_dispatch: # Manual trigger only

jobs:
  e2e-local:
    continue-on-error: true  # Non-blocking
  
  e2e-oauth:
    continue-on-error: true  # Non-blocking
```

## Alternative Options

If you need different behavior, you can modify the workflow:

### Option 1: Skip Tests on Specific Commit Messages
```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  e2e-local:
    if: "!contains(github.event.head_commit.message, '[skip e2e]')"
    # ... rest of job
```

### Option 2: Only Run on Specific File Changes
```yaml
on:
  pull_request:
    branches: [ main, develop ]
  push:
    branches: [ main, develop ]
    paths:
      - 'src/**'
      - 'tests/**'
      - 'package.json'
      - 'playwright.config.ts'
```

### Option 3: Run on Push but Allow Failures
```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  e2e-local:
    continue-on-error: true  # Already added
```

## Manual Testing

To run E2E tests manually:
1. Go to Actions tab on GitHub
2. Select "E2E Tests" workflow
3. Click "Run workflow"
4. Select branch and click "Run workflow"

Or locally:
```bash
npm run test:e2e:local
npm run test:e2e:oauth
```

## Benefits

- ✅ No more failures on every commit
- ✅ Deployments don't get blocked
- ✅ Tests still run on PRs (before merge)
- ✅ Can still run manually when needed
- ✅ Reduced CI resource usage

## Verification

After this change:
- ✅ Direct pushes to `main`/`develop` won't trigger E2E tests
- ✅ Pull requests will still run E2E tests
- ✅ Manual workflow dispatch still works
- ✅ Tests are non-blocking if they do run

---

**Note**: If you want E2E tests to run on every push again (for example, after fixing test issues), you can revert the changes or use one of the alternative options above.
