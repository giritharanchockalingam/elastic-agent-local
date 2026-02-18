# External Tools Integration Scripts

This directory contains step-by-step scripts to complete the External Tools integration.

## Quick Start

Run the main script to see all available tasks:

```bash
bash scripts/complete-external-tools-integration.sh
```

## Available Scripts

### 1. `complete-external-tools-integration.sh`
**Main menu script** - Provides a menu to access all other scripts.

**Usage:**
```bash
bash scripts/complete-external-tools-integration.sh
```

**Options:**
1. Update BookingEngine.tsx with external provider support
2. Enhance PaymentGateway.tsx with Razorpay integration
3. Test all integrations (sandbox mode)
4. Deploy Edge Functions to Supabase
5. View integration status
6. Exit

---

### 2. `enhance-booking-engine.sh`
**Step-by-step guide** to add external booking provider support to BookingEngine.tsx.

**What it does:**
- Checks current state of BookingEngine.tsx
- Shows required code changes
- Creates enhancement template
- Provides SQL for provider configuration
- Guides through testing

**Usage:**
```bash
bash scripts/enhance-booking-engine.sh
```

**Output:**
- Creates `scripts/booking-engine-enhancement-template.md` with code examples

---

### 3. `enhance-payment-gateway.sh`
**Step-by-step guide** to add Razorpay integration to PaymentGateway.tsx.

**What it does:**
- Checks current state of PaymentGateway.tsx
- Creates RazorpayPaymentForm component
- Shows required code changes
- Guides through configuration
- Provides testing instructions

**Usage:**
```bash
bash scripts/enhance-payment-gateway.sh
```

**Output:**
- Creates `src/components/RazorpayPaymentForm.tsx` component

---

### 4. `test-integrations.sh`
**Interactive testing guide** for all integrations in sandbox mode.

**What it does:**
- Checks if dev server is running
- Guides through testing Channel Manager
- Guides through testing Booking Engine
- Guides through testing Payment Gateway
- Provides testing checklist

**Usage:**
```bash
bash scripts/test-integrations.sh
```

---

### 5. `deploy-edge-functions.sh`
**Deployment guide** for Supabase Edge Functions.

**What it does:**
- Checks for Supabase CLI
- Verifies Edge Functions exist
- Guides through project linking
- Deploys functions via CLI
- Provides manual deployment instructions

**Usage:**
```bash
bash scripts/deploy-edge-functions.sh
```

**Requirements:**
- Supabase CLI installed
- Supabase project reference ID

---

### 6. `check-integration-status.sh`
**Status checker** for all integration components.

**What it does:**
- Checks service files exist
- Checks Edge Functions exist
- Checks pages are integrated
- Provides summary and next steps

**Usage:**
```bash
bash scripts/check-integration-status.sh
```

---

## Workflow

### Recommended Order:

1. **Check Status**
   ```bash
   bash scripts/check-integration-status.sh
   ```

2. **Enhance Booking Engine**
   ```bash
   bash scripts/enhance-booking-engine.sh
   ```
   - Follow the guide
   - Implement changes
   - Configure providers

3. **Enhance Payment Gateway**
   ```bash
   bash scripts/enhance-payment-gateway.sh
   ```
   - Follow the guide
   - Implement changes
   - Configure Razorpay

4. **Deploy Edge Functions**
   ```bash
   bash scripts/deploy-edge-functions.sh
   ```
   - Deploy to Supabase
   - Verify deployment

5. **Test Everything**
   ```bash
   bash scripts/test-integrations.sh
   ```
   - Test in sandbox mode
   - Verify all functionality

---

## Troubleshooting

### Scripts won't run
```bash
chmod +x scripts/*.sh
```

### Supabase CLI not found
Install via:
```bash
brew install supabase/tap/supabase
# or
npm install -g supabase
```

### Edge Functions deployment fails
- Check Supabase CLI is installed
- Verify project is linked
- Try manual deployment via Dashboard

### Integration not working
- Check browser console for errors
- Verify Edge Functions are deployed
- Check API credentials are configured
- Ensure test mode is enabled for sandbox

---

## Documentation

- **Integration Guide**: `EXTERNAL_TOOLS_INTEGRATION_GUIDE.md`
- **Implementation Status**: `EXTERNAL_TOOLS_IMPLEMENTATION_STATUS.md`
- **Completion Status**: `NEXT_STEPS_COMPLETION_STATUS.md`

---

## Support

If you encounter issues:
1. Check the status: `bash scripts/check-integration-status.sh`
2. Review the integration guide
3. Check browser console for errors
4. Verify Edge Functions are deployed

---

**Last Updated**: Scripts created for step-by-step integration completion

