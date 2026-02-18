# Payment Gateway Integration Guide

## Overview

Aurora HMS supports two payment gateway providers:
- **Stripe** - International payments, cards, Apple Pay, Google Pay
- **Razorpay** - Indian payments, UPI, cards, netbanking, wallets

Both providers support **Sandbox/Test Mode** for development and testing without processing real payments.

---

## Sandbox Mode

Sandbox mode is **automatically enabled** when:
- No API keys are configured, OR
- Test/sandbox keys are detected (keys starting with `sk_test_` for Stripe or `rzp_test_` for Razorpay), OR
- Environment variable `STRIPE_SANDBOX=true` or `RAZORPAY_SANDBOX=true` is set

### Testing Without Real Credentials

The system provides **mock data** when in sandbox mode, allowing you to test the complete payment flow without any credentials.

---

## Stripe Setup

### 1. Get Test Credentials

1. Go to [Stripe Dashboard](https://dashboard.stripe.com)
2. Create an account or sign in
3. Toggle to "Test mode" (top right)
4. Go to Developers → API Keys
5. Copy the **Publishable key** (`pk_test_...`) and **Secret key** (`sk_test_...`)

### 2. Configure Environment Variables

Add to your `.env` file:

```env
# Stripe Keys (Test Mode)
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxxxxxxxxx
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxxxxxxxxx

# Optional: Force sandbox mode even with keys
STRIPE_SANDBOX=true
```

### 3. Configure Supabase Edge Function Secrets

```bash
# Set Stripe secret key in Supabase
supabase secrets set STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxxxxxxxxx
```

### Test Cards for Stripe

| Card Number | Description |
|-------------|-------------|
| `4242 4242 4242 4242` | Successful payment |
| `4000 0000 0000 0002` | Card declined |
| `4000 0000 0000 3220` | 3D Secure required |
| `4000 0000 0000 9995` | Insufficient funds |
| `4000 0000 0000 0069` | Expired card |

Use any future expiry date and any 3-digit CVC.

---

## Razorpay Setup

### 1. Get Test Credentials

1. Go to [Razorpay Dashboard](https://dashboard.razorpay.com)
2. Create an account or sign in
3. Go to Settings → API Keys → Generate Test Key
4. Copy the **Key ID** (`rzp_test_...`) and **Key Secret**

### 2. Configure Environment Variables

Add to your `.env` file:

```env
# Razorpay Keys (Test Mode)
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxx
RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxxxxxxxx

# Optional: Force sandbox mode
RAZORPAY_SANDBOX=true
```

### 3. Configure Supabase Edge Function Secrets

```bash
# Set Razorpay secrets in Supabase
supabase secrets set RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxx
supabase secrets set RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxxxxxxxx
```

### Test Credentials for Razorpay

**Cards:**
| Card Number | Description |
|-------------|-------------|
| `4111 1111 1111 1111` | Successful payment |
| `5267 3181 8797 5449` | Mastercard success |

Use any future expiry date and any 3-digit CVV.

**UPI:**
| UPI ID | Description |
|--------|-------------|
| `success@razorpay` | Successful payment |
| `failure@razorpay` | Failed payment |

**Net Banking:**
- Select any bank for testing
- Use test credentials provided in the payment flow

---

## Edge Functions

### Unified Payment Gateway Function

The `payment-gateway` Edge Function handles both providers:

```typescript
// Example: Create Payment
await supabase.functions.invoke('payment-gateway', {
  body: {
    provider: 'stripe', // or 'razorpay'
    action: 'createPayment',
    params: {
      amount: 5000,        // in your currency (not cents/paise)
      currency: 'INR',
      guestName: 'John Doe',
      guestEmail: 'john@example.com',
      reservationId: 'RES-001',
    }
  }
});

// Example: Refund
await supabase.functions.invoke('payment-gateway', {
  body: {
    provider: 'stripe',
    action: 'refund',
    params: {
      paymentId: 'pi_xxxxx',
      amount: 2000, // partial refund (optional)
      reason: 'Customer request'
    }
  }
});

// Example: List Payments
await supabase.functions.invoke('payment-gateway', {
  body: {
    provider: 'razorpay',
    action: 'listPayments',
    params: { limit: 10 }
  }
});
```

### Supported Actions

| Action | Description | Params |
|--------|-------------|--------|
| `createPayment` | Create new payment/order | `amount`, `currency`, `guestName`, `guestEmail`, `reservationId` |
| `capturePayment` | Capture authorized payment | `paymentId`, `amount` |
| `getPayment` | Get payment details | `paymentId` |
| `refund` | Process refund | `paymentId`, `amount?`, `reason?` |
| `listPayments` | List recent payments | `limit?`, `skip?` |
| `verifyWebhook` | Verify webhook signature (Razorpay) | `orderId`, `paymentId`, `signature` |

---

## Webhook Configuration

### Stripe Webhooks

1. Go to Stripe Dashboard → Developers → Webhooks
2. Add endpoint: `https://your-project.supabase.co/functions/v1/stripe-webhook`
3. Select events:
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
   - `charge.refunded`
4. Copy the signing secret and set it:
   ```bash
   supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_xxxxx
   ```

### Razorpay Webhooks

1. Go to Razorpay Dashboard → Settings → Webhooks
2. Add webhook URL: `https://your-project.supabase.co/functions/v1/razorpay-webhook`
3. Select events:
   - `payment.authorized`
   - `payment.captured`
   - `refund.created`
4. Copy the webhook secret and set it:
   ```bash
   supabase secrets set RAZORPAY_WEBHOOK_SECRET=xxxxx
   ```

---

## Testing in the UI

1. Navigate to **Payment Gateway** page
2. Select the **Sandbox Testing** tab
3. Choose your provider (Stripe or Razorpay)
4. Fill in test payment details
5. Click **Create Test Payment**
6. Review the response in the "Last Test Result" section

The system will automatically use sandbox mode and return mock responses without processing real payments.

---

## Going Live

### For Stripe:

1. Complete Stripe account verification
2. Get live API keys from Dashboard (without Test mode toggle)
3. Update environment variables with `pk_live_` and `sk_live_` keys
4. Remove or set `STRIPE_SANDBOX=false`
5. Update webhook endpoint for live mode

### For Razorpay:

1. Complete Razorpay account activation
2. Get live API keys from Dashboard (Generate Live Key)
3. Update environment variables with live `rzp_live_` keys
4. Remove or set `RAZORPAY_SANDBOX=false`
5. Update webhook configuration

---

## Security Checklist

- [ ] Never expose secret keys in frontend code
- [ ] Always use Edge Functions for sensitive operations
- [ ] Enable webhook signature verification
- [ ] Use HTTPS for all payment pages
- [ ] Implement proper error handling
- [ ] Log payment events for audit trail
- [ ] Test refund flow before going live
- [ ] Set up monitoring for payment failures
