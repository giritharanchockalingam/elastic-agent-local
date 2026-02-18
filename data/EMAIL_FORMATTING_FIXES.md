# Email Formatting Fixes

## Issues Fixed

1. **Special Requests Showing as Raw JSON**: Special requests were displaying as raw JSON objects instead of formatted text
2. **Double Currency Symbol (₹₹)**: Currency amounts were showing with duplicate currency symbols
3. **Plain Text Emails**: Emails were being sent as plain text without HTML formatting

## Changes Made

### 1. Special Requests Formatting (`templateVariables.ts`)

Added `formatSpecialRequests()` function that:
- Parses JSON special requests objects
- Formats them as readable text (e.g., "Early Check-in, Extra Bed, Expected Arrival: 14:00")
- Handles various request types (boolean flags, other requests, preferences, etc.)

### 2. Currency Symbol Handling (`templateVariables.ts`)

Fixed currency symbol duplication by:
- Checking the original template for existing currency symbols before variables
- Only adding currency symbol if template doesn't already have it
- Applied to: `total_amount`, `refund_amount`, `amount`, `outstanding_amount`

### 3. HTML Email Conversion (`process-communication-queue/index.ts`)

Added automatic HTML conversion for plain text templates:
- Detects if template is plain text (no HTML tags)
- Converts newlines to `<br>` tags
- Converts double newlines to paragraphs
- Wraps content in proper HTML email structure with styling

## Deployment

Deploy the updated Edge Functions:

```bash
# Deploy updated functions
supabase functions deploy process-communication-queue
supabase functions deploy send-guest-communication
```

The shared `templateVariables.ts` module is automatically included when deploying functions that use it.

## Testing

After deployment:
1. Create a new booking or trigger an email
2. Verify emails have:
   - Proper HTML formatting (not plain text)
   - Formatted special requests (not JSON)
   - Single currency symbol (₹22,681.00, not ₹₹22,681.00)

## Template Format

Templates should use:
- `₹{{total_amount}}` - Currency symbol in template, variable provides number
- OR `{{total_amount}}` - Variable provides number with currency symbol

Both formats are now supported automatically.

