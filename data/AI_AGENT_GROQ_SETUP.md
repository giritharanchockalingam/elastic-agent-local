# AI Agent Setup with Groq API - Step-by-Step Guide

This guide will walk you through setting up the AI Assistant for both the HMS Portal and Public Portal using Groq's free API.

## Prerequisites

- A Supabase project (already set up)
- Supabase CLI installed (optional, for local deployment)
- Access to your Supabase project dashboard

---

## Step 1: Get Your Groq API Key

### 1.1 Sign Up for Groq

1. **Visit Groq Console:**
   - Go to [https://console.groq.com](https://console.groq.com)

2. **Create an Account:**
   - Click **"Sign Up"** or **"Get Started"**
   - Sign up with your email or use Google/GitHub OAuth
   - Verify your email if required

3. **Complete Profile:**
   - Fill in any required profile information
   - Accept terms and conditions

### 1.2 Generate API Key

1. **Navigate to API Keys:**
   - Once logged in, go to **"API Keys"** in the left sidebar
   - Or visit: [https://console.groq.com/keys](https://console.groq.com/keys)

2. **Create New API Key:**
   - Click **"Create API Key"** button
   - Give it a name (e.g., "HMS Aurora AI Assistant")
   - Click **"Submit"** or **"Create"**

3. **Copy Your API Key:**
   - **⚠️ IMPORTANT:** Copy the API key immediately
   - It will only be shown once
   - Format: `gsk_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
   - Store it securely (password manager, secure note, etc.)

4. **Note Your Limits:**
   - Free tier: **14,400 requests per day**
   - No credit card required
   - Very fast inference (up to 300 tokens/second)

---

## Step 2: Set API Key in Supabase

You have two options: **Supabase Dashboard** (recommended) or **Supabase CLI**.

### Option A: Using Supabase Dashboard (Recommended)

1. **Open Your Supabase Project:**
   - Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
   - Select your project

2. **Navigate to Edge Functions Secrets:**
   - Click **"Project Settings"** (gear icon in left sidebar)
   - Click **"Edge Functions"** in the settings menu
   - Click **"Secrets"** tab

3. **Add New Secret:**
   - Click **"Add new secret"** or **"New Secret"** button
   - **Name:** `GROQ_API_KEY`
   - **Value:** Paste your Groq API key (starts with `gsk_`)
   - Click **"Save"** or **"Add Secret"**

4. **Verify:**
   - You should see `GROQ_API_KEY` listed in the secrets table
   - Status should show as active/configured

### Option B: Using Supabase CLI

1. **Install Supabase CLI** (if not already installed):
   ```bash
   npm install -g supabase
   ```

2. **Login to Supabase:**
   ```bash
   supabase login
   ```

3. **Link Your Project:**
   ```bash
   supabase link --project-ref your-project-ref
   ```
   - Find your project ref in Supabase Dashboard → Project Settings → General

4. **Set the Secret:**
   ```bash
   supabase secrets set GROQ_API_KEY=your_groq_api_key_here
   ```
   - Replace `your_groq_api_key_here` with your actual Groq API key

5. **Verify:**
   ```bash
   supabase secrets list
   ```
   - You should see `GROQ_API_KEY` in the list

---

## Step 3: Deploy Edge Functions

The AI Assistant uses 4 Edge Functions. Deploy them all:

### Option A: Deploy via Supabase Dashboard

1. **Navigate to Edge Functions:**
   - In Supabase Dashboard, go to **"Edge Functions"** in the left sidebar

2. **Deploy Each Function:**
   - For each function below, click **"Deploy"** or use the CLI method

### Option B: Deploy via Supabase CLI (Recommended)

1. **Navigate to Project Root:**
   ```bash
   cd /Users/giritharanchockalingam/Projects/hms-aurora-portal-clean
   ```

2. **Deploy All AI Functions:**
   ```bash
   # Deploy HMS Portal AI Assistant
   supabase functions deploy ai-assistant

   # Deploy Public Portal AI Assistant
   supabase functions deploy public-ai-assistant

   # Deploy Helpdesk AI
   supabase functions deploy helpdesk-ai

   # Deploy Revenue Forecast AI
   supabase functions deploy revenue-forecast-ai
   ```

3. **Verify Deployment:**
   - Check Supabase Dashboard → Edge Functions
   - All 4 functions should show as "Active" or "Deployed"
   - Status should be green/healthy

---

## Step 4: Test the AI Assistant

### 4.1 Test HMS Portal AI Assistant

1. **Start Your Dev Server:**
   ```bash
   npm run dev
   ```

2. **Open HMS Portal:**
   - Navigate to `http://localhost:8080` (or your dev port)
   - Log in as a staff/admin user

3. **Find AI Assistant Button:**
   - Look for a floating chat button in the bottom-right corner
   - Or navigate to any page in the HMS portal

4. **Test the Assistant:**
   - Click the AI Assistant button
   - Ask a question like: "How do I check in a guest?"
   - You should see a response from the AI

5. **Check for Errors:**
   - Open browser DevTools (F12)
   - Check Console tab for any errors
   - Check Network tab for failed requests to `/functions/v1/ai-assistant`

### 4.2 Test Public Portal AI Assistant

1. **Open Public Portal:**
   - Navigate to `http://localhost:8080/property/v3-grand-hotel`
   - Or the public homepage

2. **Find AI Assistant Button:**
   - Look for a floating chat button in the bottom-right corner
   - Should be visible on all public pages

3. **Test the Assistant:**
   - Click the AI Assistant button
   - Ask a question like: "What amenities does the hotel offer?"
   - You should see a response from the AI

4. **Check for Errors:**
   - Open browser DevTools (F12)
   - Check Console tab for any errors
   - Check Network tab for failed requests to `/functions/v1/public-ai-assistant`

---

## Step 5: Troubleshooting

### Issue: "AI Assistant is not configured"

**Symptoms:**
- Error message: "AI Assistant is not configured. Please set GROQ_API_KEY..."
- 503 error in browser console

**Solution:**
1. Verify the secret is set:
   - Supabase Dashboard → Project Settings → Edge Functions → Secrets
   - Ensure `GROQ_API_KEY` exists and is correct

2. Redeploy Edge Functions:
   ```bash
   supabase functions deploy ai-assistant
   supabase functions deploy public-ai-assistant
   ```

3. Wait 1-2 minutes for changes to propagate

### Issue: "Rate limit exceeded"

**Symptoms:**
- Error: "Rate limit exceeded. Please try again later."
- 429 status code

**Solution:**
- Free tier allows 14,400 requests/day
- Wait a few minutes and try again
- Consider upgrading to paid tier if needed

### Issue: AI Assistant button not visible

**Symptoms:**
- No floating chat button appears

**Solution:**
1. Check component is imported:
   - HMS Portal: `src/components/layout/MainLayout.tsx` should import `<AIAssistant />`
   - Public Portal: `src/components/layout/PublicLayout.tsx` should import `<PublicAIAssistant />`

2. Check browser console for JavaScript errors

3. Verify the components exist:
   - `src/components/AIAssistant.tsx`
   - `src/components/public/PublicAIAssistant.tsx`

### Issue: Edge Function deployment fails

**Symptoms:**
- `supabase functions deploy` returns an error

**Solution:**
1. Check you're logged in:
   ```bash
   supabase projects list
   ```

2. Verify project is linked:
   ```bash
   supabase link --project-ref your-project-ref
   ```

3. Check function files exist:
   - `supabase/functions/ai-assistant/index.ts`
   - `supabase/functions/public-ai-assistant/index.ts`
   - `supabase/functions/helpdesk-ai/index.ts`
   - `supabase/functions/revenue-forecast-ai/index.ts`

---

## Step 6: Verify Everything Works

### Quick Checklist

- [ ] Groq API key obtained and copied
- [ ] `GROQ_API_KEY` secret set in Supabase
- [ ] All 4 Edge Functions deployed successfully
- [ ] HMS Portal AI Assistant responds to questions
- [ ] Public Portal AI Assistant responds to questions
- [ ] No errors in browser console
- [ ] No 503/429 errors in network tab

### Test Questions

**HMS Portal:**
- "How do I create a new reservation?"
- "What are the check-in procedures?"
- "How do I view guest history?"

**Public Portal:**
- "What room types are available?"
- "What amenities does the hotel have?"
- "What is the cancellation policy?"

---

## Additional Configuration (Optional)

### Use OpenAI as Fallback

If you want to use OpenAI as a fallback (when Groq is unavailable):

1. **Get OpenAI API Key:**
   - Sign up at [https://platform.openai.com](https://platform.openai.com)
   - Navigate to API Keys
   - Create a new key

2. **Set in Supabase:**
   ```bash
   supabase secrets set OPENAI_API_KEY=your_openai_api_key_here
   ```

3. **Priority:**
   - The system will use Groq if `GROQ_API_KEY` is set
   - Falls back to OpenAI if only `OPENAI_API_KEY` is set
   - Requires at least one API key to be configured

### Monitor Usage

1. **Groq Console:**
   - Visit [https://console.groq.com/usage](https://console.groq.com/usage)
   - View daily request count
   - Monitor usage trends

2. **Supabase Logs:**
   - Supabase Dashboard → Edge Functions → Logs
   - View function execution logs
   - Check for errors or rate limits

---

## Cost Information

### Groq Free Tier
- **14,400 requests per day**
- **No credit card required**
- **Ultra-fast inference** (up to 300 tokens/second)
- **No expiration** (as long as account is active)

### If You Exceed Free Tier
- Consider upgrading to paid tier
- Or set up OpenAI as fallback (has $5 free credits for new users)
- Or implement rate limiting in your app

---

## Support

If you encounter issues:

1. **Check Supabase Logs:**
   - Dashboard → Edge Functions → Logs
   - Look for error messages

2. **Check Browser Console:**
   - Open DevTools (F12)
   - Check Console and Network tabs

3. **Verify API Key:**
   - Test API key directly: [https://console.groq.com/docs/quickstart](https://console.groq.com/docs/quickstart)

4. **Review Documentation:**
   - Groq API Docs: [https://console.groq.com/docs](https://console.groq.com/docs)
   - Supabase Edge Functions: [https://supabase.com/docs/guides/functions](https://supabase.com/docs/guides/functions)

---

## Summary

✅ **Step 1:** Get Groq API key from [console.groq.com](https://console.groq.com)  
✅ **Step 2:** Set `GROQ_API_KEY` secret in Supabase  
✅ **Step 3:** Deploy 4 Edge Functions (`ai-assistant`, `public-ai-assistant`, `helpdesk-ai`, `revenue-forecast-ai`)  
✅ **Step 4:** Test both HMS and Public Portal AI Assistants  
✅ **Step 5:** Troubleshoot if needed  
✅ **Step 6:** Verify everything works  

**You're all set!** The AI Assistant should now be fully functional in both portals. 🎉
