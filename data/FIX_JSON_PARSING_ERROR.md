# Fix: JSON Parsing Error in send-guest-communication

## Error
```
[send-guest-communication] Fatal error: SyntaxError: Unexpected end of JSON input
```

## Root Cause
The `send-guest-communication` function is receiving an empty or invalid JSON request body, causing the JSON parser to fail.

## Fix Applied

### 1. Better Error Handling
Added proper error handling for:
- Empty request body
- Invalid JSON
- Failed body reading

### 2. Request Validation
Added validation in `process-communication-queue` to ensure valid request body before sending.

## Deploy Fix

### Step 1: Deploy Fixed Functions

```bash
# Deploy the fixed send-guest-communication function
supabase functions deploy send-guest-communication

# Deploy the fixed process-communication-queue function  
supabase functions deploy process-communication-queue
```

### Step 2: Reset Failed Items

After deploying, reset failed items:

```sql
-- Reset failed items
UPDATE communication_queue
SET status = 'pending', attempts = 0, error_message = NULL, processed_at = NULL
WHERE status = 'failed';
```

### Step 3: Process Queue Again

```bash
./scripts/process-communication-queue-now.sh
```

## What Changed

1. **send-guest-communication/index.ts:**
   - Added proper error handling for empty/invalid JSON
   - Returns clear error messages instead of crashing

2. **process-communication-queue/index.ts:**
   - Added request body validation before sending
   - Better error logging

## Expected Behavior After Fix

- ✅ Empty requests return proper error (400 Bad Request)
- ✅ Invalid JSON returns proper error (400 Bad Request)
- ✅ Valid requests process normally
- ✅ Better error messages in logs for debugging

## Verification

After deploying and processing:

1. Check Edge Function logs - should NOT see JSON parsing errors
2. Check queue status - items should process successfully
3. Check Resend dashboard - emails should be sent

