# Fix Storage 400 Error and Vercel Deployment

## Issues Fixed

### 1. ✅ Storage 400 Error for guest-documents

**Problem:** The `guest-documents` bucket is private (`public: false`), so using `getPublicUrl()` returns a URL that fails with 400 when accessed.

**Solution:**
- Updated `uploadDocument()` to store file paths (not URLs) in the database
- Created helper function `getDocumentUrl()` to create signed URLs when needed for viewing
- Added `src/lib/storageUtils.ts` utility module for storage operations

**Note:** Existing records with full URLs will need to be migrated or will fail until we add signed URL generation. New uploads will work correctly.

**Next Steps (Optional):**
- Migrate existing `id_document_url` values to use file paths
- Add UI components to display documents using signed URLs
- Or make the bucket public if privacy isn't required

### 2. ✅ Vercel Deployment Not Triggering

**Problem:** Vercel deployments weren't being triggered after GitHub push.

**Solution:** Updated `scripts/clean-deploy-merge.sh` to:
1. Try Vercel API deployment if `VERCEL_TOKEN` environment variable is set
2. Try Vercel CLI deployment if installed and project is linked
3. Provide clear instructions for setting up auto-deployment

**How to Enable Vercel Deployment:**

#### Option 1: Use Vercel API (Recommended)
```bash
# Get token from: https://vercel.com/account/tokens
export VERCEL_TOKEN=your_vercel_token_here

# Run the script - it will trigger deployment via API
./scripts/clean-deploy-merge.sh
```

#### Option 2: Install Vercel CLI
```bash
npm install -g vercel
vercel link  # Link your project
./scripts/clean-deploy-merge.sh  # Will trigger via CLI
```

#### Option 3: Ensure GitHub Auto-Deploy is Enabled
1. Go to Vercel Dashboard → Your Project → Settings → Git
2. Ensure GitHub repository is connected
3. Check that auto-deploy is enabled for your branch
4. Verify webhook exists in GitHub: Repository → Settings → Webhooks

**If auto-deploy still doesn't work:**
1. Check GitHub webhooks: Repository → Settings → Webhooks
2. Ensure webhook for Vercel exists and is active
3. Try disconnecting and reconnecting the repository in Vercel
4. Check Vercel deployment logs for errors

## Files Changed

- `src/pages/CheckInOut.tsx` - Updated storage upload to use file paths
- `src/lib/storageUtils.ts` - New utility module for storage operations
- `scripts/clean-deploy-merge.sh` - Added Vercel API and CLI deployment triggers

