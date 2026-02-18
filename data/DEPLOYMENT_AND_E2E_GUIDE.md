# Deployment and E2E Testing Guide

**Status:** ✅ Ready for Deployment and E2E Testing

---

## 🎯 Overview

This guide covers:
1. **Local Deployment** with E2E testing
2. **GCP Deployment** with E2E validation
3. **Playwright E2E Tests** for OAuth (Google & GitHub)
4. **CI/CD Integration** with automated testing

---

## 📋 Prerequisites

### For Local Deployment:
- Node.js 20+
- npm installed
- Port 8080 available

### For GCP Deployment:
- Google Cloud SDK (`gcloud`) installed
- Docker installed
- GCP project configured
- Cloud Run API enabled
- Container Registry access

### For E2E Testing:
- Playwright installed (via npm)
- Chromium browser (installed automatically)

---

## 🚀 Local Deployment with E2E Testing

### Quick Start

```bash
cd /Users/giritharanchockalingam/Desktop/GitHub/hms-gcp-refactor
./scripts/deploy-local.sh
```

### What It Does:

1. ✅ Installs dependencies
2. ✅ Builds the application
3. ✅ Installs Playwright browsers
4. ✅ Starts local preview server
5. ✅ Runs E2E tests
6. ✅ Runs OAuth-specific tests
7. ✅ Generates test reports

### Manual Steps:

```bash
# 1. Install dependencies
npm install

# 2. Install Playwright
npx playwright install chromium --with-deps

# 3. Build application
npm run build

# 4. Start preview server
npm run preview

# 5. In another terminal, run E2E tests
export BASE_URL=http://localhost:8080
npm run test:e2e:local

# 6. Run OAuth tests
npm run test:e2e:oauth
```

---

## ☁️ GCP Deployment with E2E Testing

### Quick Start

```bash
cd /Users/giritharanchockalingam/Desktop/GitHub/hms-gcp-refactor

# Set GCP project ID
export GCP_PROJECT_ID="your-gcp-project-id"

# Run deployment script
./scripts/deploy-gcp.sh
```

### What It Does:

1. ✅ Builds Docker image
2. ✅ Pushes to Container Registry
3. ✅ Deploys to Cloud Run
4. ✅ Waits for service to be ready
5. ✅ Runs E2E tests against deployed service
6. ✅ Runs OAuth-specific tests
7. ✅ Generates test reports

### Manual Steps:

```bash
# 1. Set GCP project
gcloud config set project YOUR_PROJECT_ID

# 2. Build and push image
docker build -t gcr.io/YOUR_PROJECT_ID/hms-portal:latest .
docker push gcr.io/YOUR_PROJECT_ID/hms-portal:latest

# 3. Deploy to Cloud Run
gcloud run deploy hms-portal \
  --image gcr.io/YOUR_PROJECT_ID/hms-portal:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080

# 4. Get service URL
SERVICE_URL=$(gcloud run services describe hms-portal \
  --region us-central1 \
  --format 'value(status.url)')

# 5. Run E2E tests
export BASE_URL=$SERVICE_URL
export GCP_URL=$SERVICE_URL
npm run test:e2e:gcp
```

---

## 🧪 E2E Test Commands

### Run All Tests
```bash
npm run test:e2e
```

### Run Local Tests
```bash
npm run test:e2e:local
```

### Run GCP Tests
```bash
npm run test:e2e:gcp
```

### Run OAuth Tests Only
```bash
npm run test:e2e:oauth
```

### Run with UI
```bash
npm run test:e2e:ui
```

### Debug Tests
```bash
npm run test:e2e:debug
```

### View Test Report
```bash
npm run test:e2e:report
```

---

## 📊 Test Configuration

### Environment Variables

Create `.env.test` file:

```bash
# Base URL for testing
BASE_URL=http://localhost:8080

# GCP deployment URL (for GCP tests)
GCP_URL=https://hms-portal-XXXXX.run.app

# OAuth test credentials (optional, for full OAuth flow tests)
TEST_GOOGLE_EMAIL=your-test-email@gmail.com
TEST_GOOGLE_PASSWORD=your-test-password
TEST_GITHUB_EMAIL=your-github-email@example.com
TEST_GITHUB_PASSWORD=your-github-password
```

### Playwright Configuration

Located in: `playwright.config.ts`

**Projects:**
- `local` - Tests against localhost:8080
- `gcp` - Tests against GCP deployment
- `chromium` - Chromium browser tests

---

## 🔐 OAuth E2E Tests

### Test Coverage

**Google OAuth:**
- ✅ Button visibility
- ✅ OAuth redirect flow
- ✅ Complete login flow (with credentials)
- ✅ Error handling

**GitHub OAuth:**
- ✅ Button visibility
- ✅ OAuth redirect flow
- ✅ Complete login flow (with credentials)
- ✅ Error handling

**General:**
- ✅ UI elements present
- ✅ Button styling
- ✅ OAuth cancellation handling

### Running OAuth Tests

```bash
# With test credentials (full flow)
export TEST_GOOGLE_EMAIL="test@gmail.com"
export TEST_GOOGLE_PASSWORD="password"
export TEST_GITHUB_EMAIL="test@example.com"
export TEST_GITHUB_PASSWORD="password"
npm run test:e2e:oauth

# Without credentials (button/redirect tests only)
npm run test:e2e:oauth
```

---

## 📁 Test Files Structure

```
tests/
  e2e/
    oauth.spec.ts          # OAuth-specific tests
    auth-flow.spec.ts      # General auth flow tests
```

**Test Reports:**
- HTML Report: `playwright-report/index.html`
- JSON Report: `test-results/e2e-results.json`
- Screenshots: `test-results/` (on failure)
- Videos: `test-results/` (on failure)

---

## 🔄 CI/CD Integration

### GitHub Actions

Workflow file: `.github/workflows/e2e-tests.yml`

**Triggers:**
- Push to main/develop
- Pull requests
- Manual trigger

**Jobs:**
1. `e2e-local` - Tests local build
2. `e2e-oauth` - Tests OAuth flows

### Cloud Build

Updated `cloudbuild.yaml` includes:
1. Build step
2. Local E2E tests
3. Docker build
4. Deploy to Cloud Run
5. GCP E2E tests

---

## ✅ Validation Checklist

### Local Deployment:
- [ ] Dependencies installed
- [ ] Application builds successfully
- [ ] Preview server starts
- [ ] E2E tests pass
- [ ] OAuth tests pass
- [ ] Test reports generated

### GCP Deployment:
- [ ] Docker image builds
- [ ] Image pushed to registry
- [ ] Cloud Run deployment successful
- [ ] Service URL accessible
- [ ] E2E tests pass against GCP
- [ ] OAuth tests pass against GCP

---

## 🚨 Troubleshooting

### Issue: Playwright browsers not installed
```bash
npx playwright install chromium --with-deps
```

### Issue: Tests fail to connect
- Verify server is running
- Check BASE_URL environment variable
- Verify port 8080 is available

### Issue: OAuth tests fail
- Verify OAuth providers enabled in Supabase
- Check callback URLs are correct
- Verify test credentials (if using)

### Issue: GCP deployment fails
- Check GCP project ID
- Verify Cloud Run API enabled
- Check Docker is running
- Verify gcloud authentication

---

## 📊 Test Reports

### View HTML Report
```bash
npm run test:e2e:report
```

### View JSON Results
```bash
cat test-results/e2e-results.json
```

### Screenshots and Videos
Located in: `test-results/` directory
- Screenshots: On test failure
- Videos: On test failure

---

## 🔗 Quick Links

**Scripts:**
- Local Deployment: `scripts/deploy-local.sh`
- GCP Deployment: `scripts/deploy-gcp.sh`

**Test Files:**
- OAuth Tests: `tests/e2e/oauth.spec.ts`
- Auth Flow Tests: `tests/e2e/auth-flow.spec.ts`

**Configuration:**
- Playwright Config: `playwright.config.ts`
- Cloud Build: `cloudbuild.yaml`
- GitHub Actions: `.github/workflows/e2e-tests.yml`

---

## 🎯 Next Steps

1. **Run local deployment:**
   ```bash
   ./scripts/deploy-local.sh
   ```

2. **Run GCP deployment:**
   ```bash
   ./scripts/deploy-gcp.sh
   ```

3. **Review test reports:**
   ```bash
   npm run test:e2e:report
   ```

4. **Set up CI/CD:**
   - Configure GitHub Actions secrets
   - Set up Cloud Build triggers
   - Configure test credentials

---

**Ready to deploy and test!** 🚀

