# Step-by-Step Integration Scripts Guide

## 🎯 Overview

I've created comprehensive step-by-step scripts to help you complete the remaining External Tools integration tasks. These scripts provide interactive guidance and check your progress.

## 🚀 Quick Start

Run the main script to see all available tasks:

```bash
bash scripts/complete-external-tools-integration.sh
```

## 📋 Available Scripts

### 1. **Main Menu Script**
**File:** `scripts/complete-external-tools-integration.sh`

Interactive menu to access all integration tasks:
- Update BookingEngine.tsx
- Enhance PaymentGateway.tsx
- Test all integrations
- Deploy Edge Functions
- Check integration status

**Usage:**
```bash
bash scripts/complete-external-tools-integration.sh
```

---

### 2. **Booking Engine Enhancement**
**File:** `scripts/enhance-booking-engine.sh`

Step-by-step guide to add external booking provider support.

**What it provides:**
- ✅ Checks current state
- ✅ Shows required code changes
- ✅ Creates enhancement template
- ✅ Provides SQL configuration examples
- ✅ Testing instructions

**Usage:**
```bash
bash scripts/enhance-booking-engine.sh
```

**Output:**
- Creates `scripts/booking-engine-enhancement-template.md` with code examples

---

### 3. **Payment Gateway Enhancement**
**File:** `scripts/enhance-payment-gateway.sh`

Step-by-step guide to add Razorpay integration.

**What it provides:**
- ✅ Checks current state
- ✅ Creates RazorpayPaymentForm component
- ✅ Shows required code changes
- ✅ Configuration instructions
- ✅ Testing guide

**Usage:**
```bash
bash scripts/enhance-payment-gateway.sh
```

**Output:**
- Creates `src/components/RazorpayPaymentForm.tsx` component

---

### 4. **Integration Testing**
**File:** `scripts/test-integrations.sh`

Interactive testing guide for all integrations.

**What it provides:**
- ✅ Checks dev server status
- ✅ Step-by-step testing for Channel Manager
- ✅ Step-by-step testing for Booking Engine
- ✅ Step-by-step testing for Payment Gateway
- ✅ Testing checklist

**Usage:**
```bash
bash scripts/test-integrations.sh
```

---

### 5. **Edge Functions Deployment**
**File:** `scripts/deploy-edge-functions.sh`

Guide to deploy Edge Functions to Supabase.

**What it provides:**
- ✅ Checks Supabase CLI
- ✅ Verifies Edge Functions exist
- ✅ Guides project linking
- ✅ Deploys functions
- ✅ Manual deployment instructions

**Usage:**
```bash
bash scripts/deploy-edge-functions.sh
```

---

### 6. **Integration Status Checker**
**File:** `scripts/check-integration-status.sh`

Checks the status of all integration components.

**What it checks:**
- ✅ Service files exist
- ✅ Edge Functions exist
- ✅ Pages are integrated
- ✅ Components exist
- ✅ Provides summary

**Usage:**
```bash
bash scripts/check-integration-status.sh
```

---

## 📖 Recommended Workflow

### Step 1: Check Current Status
```bash
bash scripts/check-integration-status.sh
```

This shows what's already done and what needs work.

### Step 2: Enhance Booking Engine
```bash
bash scripts/enhance-booking-engine.sh
```

Follow the interactive guide to:
1. Review required changes
2. Get code templates
3. Implement changes
4. Configure providers
5. Test

### Step 3: Enhance Payment Gateway
```bash
bash scripts/enhance-payment-gateway.sh
```

Follow the interactive guide to:
1. Create RazorpayPaymentForm component
2. Update PaymentGateway.tsx
3. Configure Razorpay
4. Test

### Step 4: Deploy Edge Functions
```bash
bash scripts/deploy-edge-functions.sh
```

Deploy all Edge Functions to Supabase:
- booking-engine-api
- channel-manager-api
- razorpay-api

### Step 5: Test Everything
```bash
bash scripts/test-integrations.sh
```

Test all integrations in sandbox mode.

---

## 🎓 What Each Script Does

### `enhance-booking-engine.sh`
1. Checks if BookingEngine.tsx exists
2. Verifies service files are present
3. Shows required code changes
4. Creates enhancement template
5. Provides SQL for provider configuration
6. Guides through testing

**Key Output:**
- Template file with code examples
- SQL configuration examples
- Step-by-step implementation guide

### `enhance-payment-gateway.sh`
1. Checks if PaymentGateway.tsx exists
2. Verifies Razorpay service exists
3. Creates RazorpayPaymentForm component
4. Shows required code changes
5. Provides configuration instructions
6. Testing guide

**Key Output:**
- RazorpayPaymentForm.tsx component
- Code integration examples
- Configuration steps

### `test-integrations.sh`
1. Checks dev server status
2. Guides Channel Manager testing
3. Guides Booking Engine testing
4. Guides Payment Gateway testing
5. Provides testing checklist

**Key Features:**
- Interactive prompts
- Step-by-step instructions
- Testing checklist

### `deploy-edge-functions.sh`
1. Checks Supabase CLI installation
2. Verifies Edge Functions exist
3. Guides project linking
4. Deploys functions via CLI
5. Provides manual deployment fallback

**Key Features:**
- Automatic deployment
- Manual deployment instructions
- Verification steps

### `check-integration-status.sh`
1. Checks all service files
2. Checks all Edge Functions
3. Checks page integrations
4. Provides summary

**Key Features:**
- Comprehensive status check
- Clear summary
- Next steps guidance

---

## 📝 Example Usage

### Complete Integration Workflow

```bash
# 1. Check what's done
bash scripts/check-integration-status.sh

# 2. Enhance Booking Engine
bash scripts/enhance-booking-engine.sh
# Follow prompts, implement changes

# 3. Enhance Payment Gateway
bash scripts/enhance-payment-gateway.sh
# Follow prompts, implement changes

# 4. Deploy Edge Functions
bash scripts/deploy-edge-functions.sh
# Enter project ref, deploy

# 5. Test everything
bash scripts/test-integrations.sh
# Follow testing steps
```

---

## 🔧 Troubleshooting

### Scripts won't execute
```bash
chmod +x scripts/*.sh
```

### Supabase CLI not found
The deployment script will guide you through installation.

### Edge Functions deployment fails
The script provides manual deployment instructions as fallback.

### Integration not working
1. Check status: `bash scripts/check-integration-status.sh`
2. Review browser console
3. Verify Edge Functions are deployed
4. Check API credentials

---

## 📚 Additional Resources

- **Integration Guide**: `EXTERNAL_TOOLS_INTEGRATION_GUIDE.md`
- **Implementation Status**: `EXTERNAL_TOOLS_IMPLEMENTATION_STATUS.md`
- **Completion Status**: `NEXT_STEPS_COMPLETION_STATUS.md`
- **Scripts README**: `scripts/README-EXTERNAL-TOOLS.md`

---

## ✅ What's Already Done

- ✅ All service files created
- ✅ All Edge Functions created
- ✅ Channel Manager page integrated
- ✅ Configuration management system
- ✅ Step-by-step scripts created

---

## 🎯 What's Next

1. Run the scripts to complete remaining integrations
2. Follow the interactive guides
3. Test in sandbox mode
4. Deploy to production when ready

---

**All scripts are ready to use!** Start with:
```bash
bash scripts/complete-external-tools-integration.sh
```

