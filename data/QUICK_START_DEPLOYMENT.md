# Quick Start: Deployment & E2E Testing

**Status:** ✅ Ready to Deploy

---

## 🚀 Quick Commands

### Local Deployment with E2E Tests
```bash
./scripts/deploy-local.sh
```

### GCP Deployment with E2E Tests

**First time setup:**
```bash
# Run setup script (interactive)
./scripts/setup-gcp.sh
```

**Or set project manually:**
```bash
gcloud config set project YOUR_PROJECT_ID
./scripts/deploy-gcp.sh
```

**Or use environment variable:**
```bash
export GCP_PROJECT_ID="your-gcp-project-id"
./scripts/deploy-gcp.sh
```

### Run E2E Tests Only
```bash
# Local
npm run test:e2e:local

# GCP (set GCP_URL first)
export GCP_URL="https://your-service.run.app"
npm run test:e2e:gcp

# OAuth tests
npm run test:e2e:oauth
```

---

## 📋 Prerequisites

**For Local:**
- ✅ Node.js 20+
- ✅ npm installed
- ✅ Port 8080 available

**For GCP:**
- ✅ Google Cloud SDK
- ✅ Docker
- ✅ GCP project configured

---

## ✅ What's Included

1. **Playwright E2E Tests**
   - OAuth tests (Google & GitHub)
   - Auth flow tests
   - UI validation tests

2. **Deployment Scripts**
   - `deploy-local.sh` - Local deployment
   - `deploy-gcp.sh` - GCP deployment

3. **CI/CD Integration**
   - GitHub Actions workflow
   - Cloud Build with E2E tests

---

## 📊 Test Reports

After running tests:
```bash
npm run test:e2e:report
```

Opens HTML report in browser.

---

**See `DEPLOYMENT_AND_E2E_GUIDE.md` for detailed instructions.**

