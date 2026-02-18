# Troubleshooting AI Assistant 500 Error

## Problem
Getting a 500 error when trying to use the AI Assistant:
```
qnwsnrfcnonaxvnithfv.supabase.co/functions/v1/ai-assistant:1 Failed to load resource: the server responded with a status of 500 ()
AIAssistant.tsx:115 Chat error: Error: AI service error
```

## Step-by-Step Diagnosis

### Step 1: Check Supabase Edge Function Logs

1. **Go to Supabase Dashboard:**
   - Navigate to: [https://supabase.com/dashboard](https://supabase.com/dashboard)
   - Select your project

2. **View Edge Function Logs:**
   - Click **"Edge Functions"** in the left sidebar
   - Click on **"ai-assistant"** function
   - Click **"Logs"** tab
   - Look for recent error messages

3. **What to Look For:**
   - `AI gateway error:` - Shows the actual error from Groq/OpenAI API
   - `AI assistant error:` - Shows any runtime errors
   - Check the error details (status code, error message, etc.)

### Step 2: Verify API Key is Set

1. **Check Supabase Secrets:**
   - Go to **Project Settings** → **Edge Functions** → **Secrets**
   - Verify `GROQ_API_KEY` exists and is set
   - If missing, add it (see [AI_AGENT_GROQ_SETUP.md](./AI_AGENT_GROQ_SETUP.md))

2. **Test API Key Directly:**
   ```bash
   # Run the test script
   bash scripts/test-groq-api.sh YOUR_GROQ_API_KEY
   ```
   
   This will test if your API key works with Groq's API directly.

### Step 3: Check Common Issues

#### Issue 1: Invalid API Key (401 Error)

**Symptoms:**
- Logs show: `HTTP Status Code: 401`
- Error: "Invalid API key"

**Solution:**
1. Verify API key at [https://console.groq.com/keys](https://console.groq.com/keys)
2. Make sure it starts with `gsk_`
3. Copy the key again and update in Supabase:
   ```bash
   supabase secrets set GROQ_API_KEY=your_new_key_here
   ```
4. Redeploy the function:
   ```bash
   supabase functions deploy ai-assistant
   ```

#### Issue 2: Rate Limit Exceeded (429 Error)

**Symptoms:**
- Logs show: `HTTP Status Code: 429`
- Error: "Rate limit exceeded"

**Solution:**
- Free tier allows 14,400 requests/day
- Wait a few minutes and try again
- Check usage at [https://console.groq.com/usage](https://console.groq.com/usage)

#### Issue 3: Invalid Model Name (400 Error)

**Symptoms:**
- Logs show: `HTTP Status Code: 400`
- Error mentions "model" or "invalid request"

**Solution:**
The model name might be incorrect. Try updating the Edge Function to use a different model:

1. Edit `supabase/functions/ai-assistant/index.ts`
2. Change the model name:
   ```typescript
   const model = useGroq 
     ? 'llama-3.3-70b-versatile'  // Try this instead
     : 'gpt-3.5-turbo';
   ```
3. Or try: `'mixtral-8x7b-32768'` or `'llama-3.1-8b-instant'`
4. Redeploy:
   ```bash
   supabase functions deploy ai-assistant
   ```

#### Issue 4: Network/Connection Error

**Symptoms:**
- Logs show connection errors
- Timeout errors

**Solution:**
1. Check Groq API status: [https://status.groq.com](https://status.groq.com)
2. Check your internet connection
3. Try again in a few minutes

#### Issue 5: Edge Function Not Deployed

**Symptoms:**
- Function doesn't appear in Supabase Dashboard
- 404 errors instead of 500

**Solution:**
1. Deploy the function:
   ```bash
   supabase functions deploy ai-assistant
   ```
2. Verify in Dashboard → Edge Functions

### Step 4: Check Browser Console

1. **Open Browser DevTools:**
   - Press `F12` or right-click → Inspect
   - Go to **Console** tab

2. **Look for Errors:**
   - Check for any JavaScript errors
   - Check Network tab for failed requests
   - Look at the response body for error details

3. **Check Network Request:**
   - Go to **Network** tab
   - Find the request to `/functions/v1/ai-assistant`
   - Click on it
   - Check **Response** tab for error message

### Step 5: Test Edge Function Directly

You can test the Edge Function directly using curl:

```bash
curl -X POST \
  'https://qnwsnrfcnonaxvnithfv.supabase.co/functions/v1/ai-assistant' \
  -H 'Authorization: Bearer YOUR_SUPABASE_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "messages": [
      {"role": "user", "content": "Hello"}
    ]
  }'
```

Replace `YOUR_SUPABASE_ANON_KEY` with your actual anon key from `.env.local`.

## Quick Fix Checklist

- [ ] API key is set in Supabase Secrets (`GROQ_API_KEY`)
- [ ] Edge Function is deployed (`ai-assistant`)
- [ ] API key is valid (test with `scripts/test-groq-api.sh`)
- [ ] Check Supabase Edge Function logs for actual error
- [ ] Check browser console for client-side errors
- [ ] Verify Groq API status is operational
- [ ] Try redeploying the Edge Function

## Most Common Solution

**90% of the time, the issue is:**
1. API key not set or incorrect
2. Edge Function needs to be redeployed after setting the secret

**Quick fix:**
```bash
# 1. Set the API key
supabase secrets set GROQ_API_KEY=your_groq_api_key_here

# 2. Redeploy the function
supabase functions deploy ai-assistant

# 3. Wait 1-2 minutes for changes to propagate

# 4. Test again
```

## Still Not Working?

1. **Check the actual error in Supabase logs** - This is the most important step
2. **Share the error details** from the logs
3. **Verify API key works** using the test script
4. **Check if other Edge Functions work** (to rule out Supabase issues)

## Additional Resources

- [Groq API Documentation](https://console.groq.com/docs)
- [Supabase Edge Functions Docs](https://supabase.com/docs/guides/functions)
- [AI Agent Setup Guide](./AI_AGENT_GROQ_SETUP.md)
