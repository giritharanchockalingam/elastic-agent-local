# Oracle Cloud Infrastructure (OCI) Deployment Guide

Complete deployment guide for HMS on Oracle Cloud Infrastructure - **$0 Cost** (Always Free Tier)

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Architecture](#architecture)
4. [Step-by-Step Deployment](#step-by-step-deployment)
5. [Database Migration](#database-migration)
6. [Application Deployment](#application-deployment)
7. [Edge Functions Migration](#edge-functions-migration)
8. [Configuration](#configuration)
9. [Verification](#verification)
10. [Troubleshooting](#troubleshooting)

## Overview

This guide will help you deploy the entire HMS application to Oracle Cloud Infrastructure using the **Always Free Tier**, which includes:

- **2 Always Free Autonomous Databases** (up to 20GB each)
- **2 Always Free Compute VMs** (AMD-based, 1/8 OCPU, 1GB RAM each)
- **10TB Always Free Object Storage**
- **10GB Always Free Block Storage**
- **Oracle Functions** (serverless)
- **Load Balancer** (10Mbps)

### Cost: $0/month (Always Free Tier)

## Prerequisites

1. **Oracle Cloud Account**
   - Sign up at: https://cloud.oracle.com
   - Free tier includes $300 credit for 30 days + Always Free resources

2. **OCI CLI** (Optional but recommended)
   ```bash
   # Install OCI CLI
   bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
   ```

3. **Terraform** (Optional, for Infrastructure as Code)
   ```bash
   # Install Terraform
   brew install terraform  # macOS
   # or download from https://www.terraform.io/downloads
   ```

4. **Docker** (for containerized deployment)
   ```bash
   # Install Docker
   brew install docker  # macOS
   ```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Oracle Cloud Infrastructure              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐      ┌──────────────┐                    │
│  │  Load       │      │  Compute     │                    │
│  │  Balancer   │──────│  Instance    │                    │
│  │  (10Mbps)   │      │  (Frontend)  │                    │
│  └──────────────┘      └──────┬───────┘                    │
│                               │                             │
│  ┌──────────────┐      ┌──────▼───────┐                    │
│  │  Object      │      │  Oracle      │                    │
│  │  Storage     │      │  Functions   │                    │
│  │  (Static)    │      │  (Backend)   │                    │
│  └──────────────┘      └──────┬───────┘                    │
│                               │                             │
│                        ┌──────▼───────┐                    │
│                        │  Autonomous  │                    │
│                        │  Database    │                    │
│                        │  (PostgreSQL)│                    │
│                        └──────────────┘                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Step-by-Step Deployment

### Step 1: Set Up OCI Resources

#### 1.1 Create Compartment

1. Log in to Oracle Cloud Console: https://cloud.oracle.com
2. Navigate to **Identity & Security** → **Compartments**
3. Click **Create Compartment**
4. Name: `hms-production`
5. Click **Create**

#### 1.2 Create Virtual Cloud Network (VCN)

1. Navigate to **Networking** → **Virtual Cloud Networks**
2. Click **Create VCN**
3. Select **VCN with Internet Connectivity**
4. Name: `hms-vcn`
5. Compartment: `hms-production`
6. CIDR Block: `10.0.0.0/16`
7. Click **Create VCN**

#### 1.3 Create Autonomous Database

1. Navigate to **Oracle Database** → **Autonomous Database**
2. Click **Create Autonomous Database**
3. Configuration:
   - **Compartment**: `hms-production`
   - **Display Name**: `hms-db`
   - **Database Type**: **Shared Infrastructure**
   - **Workload Type**: **Transaction Processing**
   - **Deployment Type**: **Serverless**
   - **Always Free**: ✅ **Enable** (This is the free tier!)
   - **Database Name**: `HMSDB`
   - **Password**: Set a strong password (save it!)
   - **License Type**: **License Included**
4. Click **Create Autonomous Database**
5. Wait for provisioning (~5 minutes)

**Note**: Save the connection details (TNS name, wallet, password)

### Step 2: Database Migration

#### 2.1 Export Data from Supabase

```bash
# Run the export script
cd /Users/giritharanchockalingam/Desktop/GitHub/hms-gcp-refactor
./scripts/export-supabase-data.sh
```

#### 2.2 Convert PostgreSQL to Oracle SQL

```bash
# Run the conversion script
./scripts/convert-postgres-to-oracle.sh
```

#### 2.3 Import to Oracle Database

```bash
# Connect to Oracle DB and run migrations
./scripts/import-to-oracle.sh
```

### Step 3: Deploy Frontend

#### Option A: Compute Instance (Recommended for Free Tier)

1. **Create Compute Instance**:
   ```bash
   # Use the provided script
   ./scripts/oci/create-compute-instance.sh
   ```

2. **Deploy Application**:
   ```bash
   # Build and deploy
   npm run build
   ./scripts/oci/deploy-frontend.sh
   ```

#### Option B: Object Storage + CDN (Static Hosting)

1. **Upload to Object Storage**:
   ```bash
   ./scripts/oci/upload-to-object-storage.sh
   ```

2. **Configure Pre-Authenticated Request** (for public access)

### Step 4: Deploy Edge Functions (Oracle Functions)

1. **Set Up Oracle Functions**:
   ```bash
   ./scripts/oci/setup-functions.sh
   ```

2. **Deploy Functions**:
   ```bash
   ./scripts/oci/deploy-functions.sh
   ```

### Step 5: Configure Integrations

1. **Update Environment Variables**:
   ```bash
   ./scripts/oci/update-env-vars.sh
   ```

2. **Configure Third-Party Integrations**:
   - Email: Resend, SendGrid, AWS SES
   - SMS: Twilio, MSG91, AWS SNS
   - WhatsApp: Twilio WhatsApp API

## Database Migration

### PostgreSQL to Oracle Conversion

Key differences to handle:

1. **Data Types**:
   - `SERIAL` → `NUMBER GENERATED ALWAYS AS IDENTITY`
   - `TEXT` → `VARCHAR2(4000)` or `CLOB`
   - `TIMESTAMP` → `TIMESTAMP`
   - `JSONB` → `JSON` or `CLOB` with `JSON` constraint
   - `UUID` → `RAW(16)` or `VARCHAR2(36)`

2. **Functions**:
   - `gen_random_uuid()` → `SYS_GUID()` or `SYSDBMS_RANDOM.UUID()`
   - `NOW()` → `SYSTIMESTAMP`
   - `COALESCE()` → `NVL()`

3. **Constraints**:
   - `CHECK` constraints work similarly
   - Foreign keys work similarly

### Migration Scripts

See `scripts/oci/migrate-database/` directory for:
- `01-convert-schema.sql` - Schema conversion
- `02-migrate-data.sql` - Data migration
- `03-create-indexes.sql` - Index creation
- `04-verify-migration.sql` - Verification

## Application Deployment

### Environment Variables

Create `.env.production`:

```bash
# Oracle Database
ORACLE_DB_URL=your-oracle-connection-string
ORACLE_DB_USER=hms_user
ORACLE_DB_PASSWORD=your-password

# Oracle Functions
ORACLE_FUNCTIONS_ENDPOINT=https://your-region.functions.oci.oraclecloud.com
ORACLE_FUNCTIONS_NAMESPACE=your-namespace

# Third-Party Integrations
RESEND_API_KEY=your-resend-key
TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token
MSG91_API_KEY=your-msg91-key

# Application
VITE_API_URL=https://your-functions-endpoint
```

### Build and Deploy

```bash
# Build production bundle
npm run build

# Deploy to OCI
./scripts/oci/deploy-all.sh
```

## Edge Functions Migration

### Convert Supabase Functions to Oracle Functions

Oracle Functions use Docker containers. Each function needs:

1. **Dockerfile**
2. **func.yaml** (function configuration)
3. **Code** (Node.js/TypeScript/Python)

Example structure:
```
oracle-functions/
├── send-guest-communication/
│   ├── Dockerfile
│   ├── func.yaml
│   └── index.js
```

### Deploy Function

```bash
# Navigate to function directory
cd oracle-functions/send-guest-communication

# Deploy
fn deploy --app hms-app
```

## Configuration

### Update Application Code

1. **Replace Supabase Client**:
   - Replace `@supabase/supabase-js` with Oracle DB client
   - Use `oracledb` npm package

2. **Update API Calls**:
   - Replace Supabase Edge Function calls with Oracle Functions endpoints

3. **Update Environment Variables**:
   - Replace `VITE_SUPABASE_URL` with `VITE_API_URL`
   - Replace `VITE_SUPABASE_PUBLISHABLE_KEY` with Oracle auth tokens

## Verification

### Check Deployment

```bash
# Run verification script
./scripts/oci/verify-deployment.sh
```

### Test Endpoints

1. **Frontend**: `https://your-load-balancer-ip`
2. **API**: `https://your-functions-endpoint`
3. **Database**: Connect and verify tables

## Troubleshooting

### Common Issues

1. **Database Connection**:
   - Check security lists (firewall rules)
   - Verify wallet is downloaded
   - Check connection string format

2. **Function Deployment**:
   - Verify Docker is running
   - Check function logs: `fn logs get <app-name> <function-name>`

3. **Frontend Not Loading**:
   - Check Object Storage bucket is public
   - Verify Load Balancer health checks
   - Check security list rules

## Next Steps

1. Set up monitoring and alerts
2. Configure backup strategy
3. Set up CI/CD pipeline
4. Configure custom domain
5. Set up SSL certificates

## Support

For issues:
- OCI Documentation: https://docs.oracle.com/en-us/iaas/
- Oracle Functions: https://docs.oracle.com/en-us/iaas/Content/Functions/Concepts/functionsoverview.htm


