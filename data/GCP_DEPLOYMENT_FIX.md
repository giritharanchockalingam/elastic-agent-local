# GCP Deployment Fix - 412 Precondition Failed

**Error:** `412 Precondition Failed` when pushing to Container Registry

**Cause:** GCP Project ID was not set (using placeholder `your-gcp-project-id`)

---

## ✅ Fix Applied

The deployment script has been updated to:
1. ✅ Automatically detect GCP project ID from `gcloud config`
2. ✅ Validate project ID format
3. ✅ Provide clear error messages
4. ✅ Configure Docker authentication automatically

---

## 🚀 How to Deploy Now

### Option 1: Automatic (Recommended)

The script will now automatically use your gcloud project:

```bash
# Make sure gcloud is configured
gcloud config set project YOUR_ACTUAL_PROJECT_ID

# Run deployment
./scripts/deploy-gcp.sh
```

### Option 2: Environment Variable

```bash
export GCP_PROJECT_ID="your-actual-project-id"
./scripts/deploy-gcp.sh
```

### Option 3: Inline

```bash
GCP_PROJECT_ID="your-actual-project-id" ./scripts/deploy-gcp.sh
```

---

## 🔍 Find Your GCP Project ID

### Method 1: From gcloud CLI

```bash
gcloud config get-value project
```

### Method 2: From GCP Console

1. Go to: https://console.cloud.google.com
2. Select your project
3. Project ID is shown in the top bar

### Method 3: List All Projects

```bash
gcloud projects list
```

---

## ✅ Prerequisites Checklist

Before deploying, ensure:

- [ ] **GCP Project ID is set**
  ```bash
  gcloud config set project YOUR_PROJECT_ID
  ```

- [ ] **You're authenticated**
  ```bash
  gcloud auth login
  gcloud auth application-default login
  ```

- [ ] **Docker is authenticated for GCR**
  ```bash
  gcloud auth configure-docker
  ```

- [ ] **Container Registry API is enabled**
  ```bash
  gcloud services enable containerregistry.googleapis.com
  ```

- [ ] **Cloud Run API is enabled**
  ```bash
  gcloud services enable run.googleapis.com
  ```

- [ ] **Docker is running**
  ```bash
  docker ps
  ```

---

## 🚨 Common Issues

### Issue: "Project ID not found"

**Solution:**
```bash
gcloud config set project YOUR_PROJECT_ID
```

### Issue: "Authentication required"

**Solution:**
```bash
gcloud auth login
gcloud auth configure-docker
```

### Issue: "API not enabled"

**Solution:**
```bash
gcloud services enable containerregistry.googleapis.com
gcloud services enable run.googleapis.com
```

### Issue: "Docker daemon not running"

**Solution:**
- Start Docker Desktop (Mac/Windows)
- Or start Docker service (Linux)

---

## 📝 Updated Script Features

The updated `deploy-gcp.sh` now:

1. ✅ **Auto-detects project ID** from gcloud config
2. ✅ **Validates project ID** (rejects placeholders)
3. ✅ **Checks authentication** automatically
4. ✅ **Configures Docker** for GCR
5. ✅ **Provides clear error messages** with solutions

---

## 🎯 Quick Start

```bash
# 1. Set your project
gcloud config set project YOUR_PROJECT_ID

# 2. Authenticate
gcloud auth login
gcloud auth configure-docker

# 3. Enable APIs (if needed)
gcloud services enable containerregistry.googleapis.com
gcloud services enable run.googleapis.com

# 4. Deploy
./scripts/deploy-gcp.sh
```

---

**The deployment script is now fixed and ready to use!** 🚀

