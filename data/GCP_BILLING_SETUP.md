# GCP Billing Setup Guide

**Error:** `This API method requires billing to be enabled`

**Project:** `YOUR_GCP_PROJECT_ID`  
**Project Number:** `YOUR_GCP_PROJECT_NUMBER`

---

## ✅ Quick Fix

### Option 1: Enable Billing via Console (Recommended)

1. **Visit the billing enablement page:**
   ```
   https://console.cloud.google.com/billing/enable?project=YOUR_GCP_PROJECT_NUMBER
   ```

2. **Or use the direct link:**
   ```
   https://console.developers.google.com/billing/enable?project=YOUR_GCP_PROJECT_NUMBER
   ```

3. **Select or create a billing account:**
   - If you have a billing account, select it
   - If not, create a new one (requires credit card)

4. **Wait 2-3 minutes** for changes to propagate

5. **Retry deployment:**
   ```bash
   ./scripts/deploy-gcp.sh
   ```

---

### Option 2: Enable Billing via CLI

```bash
# List your billing accounts
gcloud beta billing accounts list

# Link billing account to project
gcloud beta billing projects link YOUR_GCP_PROJECT_ID \
  --billing-account=BILLING_ACCOUNT_ID
```

Replace `BILLING_ACCOUNT_ID` with your actual billing account ID from the list.

---

## 🔍 Verify Billing Status

### Check if billing is enabled:

```bash
gcloud beta billing projects describe YOUR_GCP_PROJECT_ID
```

**Expected output if enabled:**
```
billingAccountName: billingAccounts/01XXXX-XXXXXX-XXXXXX
billingEnabled: true
```

**If not enabled:**
```
billingAccountName: 
billingEnabled: false
```

---

## 💡 Alternative: Use Artifact Registry

**Artifact Registry** is Google's newer container registry (replacing Container Registry). It may have different billing requirements.

### Switch to Artifact Registry:

1. **Create Artifact Registry repository:**
   ```bash
   gcloud artifacts repositories create hms-repo \
     --repository-format=docker \
     --location=us-central1 \
     --project=YOUR_GCP_PROJECT_ID
   ```

2. **Update deployment script** to use Artifact Registry:
   ```bash
   # Instead of: gcr.io/PROJECT_ID/SERVICE_NAME
   # Use: LOCATION-docker.pkg.dev/PROJECT_ID/REPO_NAME/SERVICE_NAME
   
   IMAGE_NAME="us-central1-docker.pkg.dev/YOUR_GCP_PROJECT_ID/hms-repo/hms-portal"
   ```

3. **Configure Docker:**
   ```bash
   gcloud auth configure-docker us-central1-docker.pkg.dev
   ```

---

## 📋 Billing Account Requirements

### To enable billing, you need:

1. **A Google Cloud billing account:**
   - Requires a credit card
   - Free tier available ($300 credit for new users)
   - Pay-as-you-go pricing

2. **Billing account permissions:**
   - You need `Billing Account User` or `Billing Account Administrator` role
   - Or be the owner of the billing account

### Check your permissions:

```bash
# List billing accounts you have access to
gcloud beta billing accounts list

# Check project billing
gcloud beta billing projects describe YOUR_GCP_PROJECT_ID
```

---

## 🚨 Common Issues

### Issue: "Billing account not found"

**Solution:**
- Create a billing account in GCP Console
- Or ask your organization admin to grant you access

### Issue: "Permission denied"

**Solution:**
- Ask your GCP project admin to enable billing
- Or request `Billing Account User` role

### Issue: "Billing enabled but still getting error"

**Solution:**
- Wait 2-3 minutes for propagation
- Verify with: `gcloud beta billing projects describe PROJECT_ID`
- Check API is enabled: `gcloud services enable containerregistry.googleapis.com`

---

## 💰 Cost Information

### Container Registry Pricing:

- **Storage:** $0.026 per GB/month
- **Network egress:** Free (within GCP)
- **Operations:** Free

### Free Tier:

- **First 5 GB storage:** Free
- **First 50 GB network egress:** Free

### Estimated Monthly Cost:

For a typical deployment:
- **Image size:** ~500 MB
- **Storage:** ~$0.01/month
- **Total:** ~$0.01-0.10/month (very low)

---

## ✅ After Enabling Billing

1. **Verify billing is enabled:**
   ```bash
   gcloud beta billing projects describe YOUR_GCP_PROJECT_ID
   ```

2. **Enable required APIs:**
   ```bash
   gcloud services enable containerregistry.googleapis.com --project=YOUR_GCP_PROJECT_ID
   gcloud services enable run.googleapis.com --project=YOUR_GCP_PROJECT_ID
   ```

3. **Retry deployment:**
   ```bash
   ./scripts/deploy-gcp.sh
   ```

---

## 🔗 Quick Links

- **Enable Billing:** https://console.cloud.google.com/billing/enable?project=YOUR_GCP_PROJECT_NUMBER
- **Billing Dashboard:** https://console.cloud.google.com/billing
- **Project Settings:** https://console.cloud.google.com/iam-admin/settings?project=YOUR_GCP_PROJECT_ID

---

**Once billing is enabled, your deployment should work!** 🚀

