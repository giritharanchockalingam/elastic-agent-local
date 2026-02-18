# Fix clean-deploy-merge Script - Committing to Main

## Issue

The `clean-deploy-merge.sh` script may not be committing changes to the main branch as expected.

## Current Behavior

The script should:
1. ✅ Stage all changes with `git add -A`
2. ✅ Commit changes (or create empty commit if no changes)
3. ✅ Pull latest from remote
4. ✅ Push to origin/main

## Potential Issues and Fixes

### Issue 1: Branch Detection

**Problem:** Script might not detect main branch correctly.

**Fix:** Ensure the script explicitly checks for main branch:

```bash
# Get current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD)

# Ensure we're on main
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
  echo -e "${YELLOW}⚠️  Not on main branch (currently on: $CURRENT_BRANCH)${NC}"
  echo "Switching to main branch..."
  git checkout main || {
    echo -e "${RED}❌ Failed to switch to main branch${NC}"
    exit 1
  }
  CURRENT_BRANCH="main"
fi
```

### Issue 2: Git Hooks Blocking Commits

**Problem:** Pre-commit hooks might be blocking commits.

**Solution:** The script already uses `--no-verify` flag:
```bash
git commit -m "$COMMIT_MSG" --no-verify
```

This bypasses pre-commit hooks. If you need hooks to run, remove `--no-verify`.

### Issue 3: No Changes Detected

**Problem:** Script might not detect changes properly.

**Fix:** Improve change detection:

```bash
# Stage all changes
git add -A

# Check for changes more reliably
CHANGES=$(git diff --cached --shortstat 2>/dev/null || echo "")
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

if [ -n "$CHANGES" ] || [ "$UNTRACKED" -gt 0 ]; then
  echo "Changes detected - committing..."
  git commit -m "$COMMIT_MSG" --no-verify
else
  echo "No changes - creating empty commit to trigger deployment..."
  git commit --allow-empty -m "$COMMIT_MSG" --no-verify
fi
```

### Issue 4: Remote Tracking Branch Not Set

**Problem:** Local main branch might not track origin/main.

**Fix:** Ensure upstream is set:

```bash
# Ensure main tracks origin/main
git branch --set-upstream-to=origin/main main 2>/dev/null || true
```

### Issue 5: Push Failing Silently

**Problem:** Push might fail but script continues.

**Fix:** Better error handling:

```bash
# Push with explicit error checking
if ! git push origin main 2>&1; then
  echo -e "${RED}❌ Push failed${NC}"
  echo "Attempting to diagnose issue..."
  
  # Check if remote exists
  if ! git remote get-url origin >/dev/null 2>&1; then
    echo "Remote 'origin' not configured"
    exit 1
  fi
  
  # Check authentication
  if ! git ls-remote --heads origin main >/dev/null 2>&1; then
    echo "Cannot access remote - check authentication"
    exit 1
  fi
  
  exit 1
fi
```

## Recommended Updates to Script

Add these improvements to `scripts/clean-deploy-merge.sh`:

1. **Explicit main branch check:**
```bash
# Ensure we're on main branch
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
  echo -e "${YELLOW}⚠️  Currently on branch: $CURRENT_BRANCH${NC}"
  read -p "Switch to main branch? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    git checkout main || exit 1
    CURRENT_BRANCH="main"
  fi
fi
```

2. **Better change detection:**
```bash
# Stage all changes
git add -A

# Check for changes using multiple methods
HAS_STAGED=$(git diff --cached --quiet; echo $?)
HAS_UNSTAGED=$(git diff --quiet; echo $?)
HAS_UNTRACKED=$(git ls-files --others --exclude-standard | head -1)

if [ "$HAS_STAGED" -ne 0 ] || [ "$HAS_UNSTAGED" -ne 0 ] || [ -n "$HAS_UNTRACKED" ]; then
  # Has changes - commit them
  git commit -m "$COMMIT_MSG" --no-verify
else
  # No changes - empty commit for deployment trigger
  git commit --allow-empty -m "$COMMIT_MSG" --no-verify
fi
```

3. **Force push option (if needed):**
```bash
# Add option to force push (use with caution)
FORCE_PUSH=${FORCE_PUSH:-false}
if [ "$FORCE_PUSH" = "true" ]; then
  git push --force-with-lease origin main
else
  git push origin main
fi
```

## Verification

After running the script, verify:

```bash
# Check if commit was made
git log -1 --oneline

# Check if pushed
git log origin/main -1 --oneline

# Check current branch
git branch --show-current

# Check if ahead/behind
git status -sb
```

## Debugging

If script still doesn't commit:

1. **Run with debug output:**
```bash
bash -x scripts/clean-deploy-merge.sh 2>&1 | tee deploy-debug.log
```

2. **Check git status before running:**
```bash
git status
git log -5 --oneline
```

3. **Manual test commit:**
```bash
git add -A
git commit -m "test commit"
git push origin main
```

4. **Check for git hooks:**
```bash
ls -la .git/hooks/
```

## Current Script Status

Based on the script analysis, it should:
- ✅ Commit all staged changes
- ✅ Create empty commit if no changes (to trigger deployment)
- ✅ Push to origin/main
- ✅ Handle errors gracefully

If it's not committing, check:
1. Are there actually changes to commit?
2. Are there git hooks blocking commits?
3. Is the branch detection working correctly?
4. Is authentication working for push?

