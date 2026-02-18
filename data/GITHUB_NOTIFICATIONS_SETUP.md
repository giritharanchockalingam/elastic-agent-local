# GitHub Notifications Setup

## Problem
GitHub Actions sends email notifications for both successful and failed workflow runs, which can be noisy.

## Solution

### Option 1: Configure GitHub Notification Settings (Recommended)

To only receive notifications for failed workflows:

1. Go to GitHub Settings → Notifications
2. Under "Actions", configure:
   - **Uncheck**: "Workflow runs on workflows you subscribe to"
   - **Check**: "Failed workflow runs only"
   - **Check**: "Workflow failures for workflows you subscribe to"

3. Alternatively, go to your repository → Settings → Notifications
   - Configure repository-specific notification settings

### Option 2: Workflow-Level Configuration

The workflow file (`.github/workflows/vercel-deploy.yml`) has been configured to:
- Only send explicit notifications on failure
- Add clear success/failure messaging
- Use `if: failure()` conditions for notification steps

### Option 3: GitHub Repository Settings

1. Go to your repository on GitHub
2. Click "Settings" → "Notifications"
3. Under "Actions", select:
   - "Only notify me about failed workflows"

### Option 4: Unsubscribe from Workflow Notifications

If you don't want any workflow notifications:

1. Go to the workflow file on GitHub
2. Click "Unwatch" or configure notification settings for that specific workflow
3. Or use GitHub's notification settings to filter out workflow emails

## Current Workflow Behavior

The `.github/workflows/vercel-deploy.yml` file now:
- ✅ Explicitly marks success/failure states
- ✅ Only sends error notifications on failure
- ✅ Provides clear success messages (not emailed by default)

## Testing

After configuring:
1. Make a commit that triggers the workflow
2. On success: No email notification should be sent
3. On failure: Email notification will be sent

---

**Note**: GitHub's default behavior sends notifications for all workflow runs. The workflow file changes help, but you should also configure your GitHub notification settings (Option 1) for best results.
