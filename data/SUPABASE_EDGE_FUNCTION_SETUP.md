# Supabase Edge Function Environment Variables Setup

This guide explains how to set environment variables (secrets) for Supabase Edge Functions, specifically for the unified AI Assistant.

## Method 1: Using Supabase CLI (Recommended)

### Prerequisites
1. Install Supabase CLI if you haven't already:
   ```bash
   npm install -g supabase
   ```

2. Login to Supabase:
   ```bash
   supabase login
   ```

3. Link your project:
   ```bash
   supabase link --project-ref YOUR_PROJECT_REF
   ```
   - You can find your project ref in your Supabase project settings URL: `https://supabase.com/dashboard/project/YOUR_PROJECT_REF`
   - Or in your Supabase dashboard → Settings → General → Reference ID

### Set Environment Variables

Set the required secrets for the unified AI Assistant:

```bash
# Set Groq API Key (free, fast) - Recommended
supabase secrets set GROQ_API_KEY=your_groq_api_key_here

# OR set OpenAI API Key (as fallback)
supabase secrets set OPENAI_API_KEY=your_openai_api_key_here

# Supabase credentials (usually auto-set, but verify)
supabase secrets set SUPABASE_URL=https://your-project-ref.supabase.co
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

### Get API Keys

#### Groq API Key (Free, Fast - Recommended)
1. Go to https://console.groq.com
2. Sign up or log in
3. Navigate to API Keys section: https://console.groq.com/keys
4. Click "Create API Key"
5. Copy the key and use it in the command above

#### OpenAI API Key (Alternative)
1. Go to https://platform.openai.com
2. Sign up or log in
3. Navigate to API Keys: https://platform.openai.com/api-keys
4. Click "Create new secret key"
5. Copy the key and use it in the command above

#### Supabase Service Role Key
1. Go to your Supabase Dashboard: https://supabase.com/dashboard
2. Select your project
3. Go to Settings → API
4. Find "service_role" key under "Project API keys"
5. Copy the key (keep it secret - it has admin privileges)

#### Supabase URL
1. In the same Settings → API page
2. Find "Project URL" 
3. Copy the URL (usually: `https://YOUR_PROJECT_REF.supabase.co`)

## Method 2: Using Supabase Dashboard (Web UI)

### Steps
1. Go to your Supabase Dashboard: https://supabase.com/dashboard
2. Select your project
3. Navigate to **Edge Functions** → **Settings** (or **Settings** → **Edge Functions**)
4. Find **"Secrets"** or **"Environment Variables"** section
5. Click **"Add Secret"** or **"New Secret"**
6. Add each secret:
   - Name: `GROQ_API_KEY`, Value: `your_groq_api_key`
   - Name: `OPENAI_API_KEY`, Value: `your_openai_api_key` (optional, if not using Groq)
   - Name: `SUPABASE_URL`, Value: `https://your-project-ref.supabase.co` (usually auto-set)
   - Name: `SUPABASE_SERVICE_ROLE_KEY`, Value: `your_service_role_key` (usually auto-set)

**Note:** `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are usually automatically available to Edge Functions, but you can set them explicitly if needed.

## Method 3: Using Supabase Dashboard (Project Settings)

### Alternative Path
1. Go to your Supabase Dashboard
2. Select your project
3. Go to **Settings** → **Edge Functions**
4. Look for **"Secrets"** or **"Environment Variables"**
5. Add the secrets as described above

## Verify Secrets are Set

### Using Supabase CLI
```bash
# List all secrets (will show names but not values for security)
supabase secrets list
```

### Using Supabase Dashboard
1. Go to Edge Functions → Settings
2. View the "Secrets" section
3. You should see the secret names listed (values are hidden for security)

## Test the Setup

After setting the secrets and deploying the edge function, test it:

### Deploy the Unified AI Assistant Function
```bash
cd /Users/giritharanchockalingam/Projects/hms-aurora-portal-clean
supabase functions deploy unified-ai-assistant
```

### Test the Function
```bash
# Test with a simple request
curl -X POST https://YOUR_PROJECT_REF.supabase.co/functions/v1/unified-ai-assistant \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "What rooms do you have?"}],
    "context": "public"
  }'
```

## Troubleshooting

### Error: "AI Assistant is not configured"
- **Issue**: `GROQ_API_KEY` or `OPENAI_API_KEY` is not set
- **Solution**: Verify secrets are set using `supabase secrets list` or check the dashboard

### Error: "Invalid API key"
- **Issue**: API key is incorrect or expired
- **Solution**: Regenerate the API key from Groq/OpenAI console and update the secret

### Error: "Property not found" or database errors
- **Issue**: `SUPABASE_SERVICE_ROLE_KEY` might be incorrect
- **Solution**: Verify the service role key in Settings → API and update if needed

### Secret not available in function
- **Issue**: Secrets might not be synced after deployment
- **Solution**: 
  1. Redeploy the function after setting secrets
  2. Wait a few minutes for secrets to propagate
  3. Check function logs: `supabase functions logs unified-ai-assistant`

## Security Best Practices

1. **Never commit secrets to Git**: These should only exist in Supabase secrets
2. **Use separate keys for dev/staging/prod**: Create different projects or use different secrets per environment
3. **Rotate keys regularly**: Update API keys periodically for security
4. **Use least privilege**: The service role key has admin access - use carefully
5. **Monitor usage**: Check Groq/OpenAI usage dashboards to monitor API consumption

## Quick Setup Script

Save this as `setup-ai-assistant-secrets.sh`:

```bash
#!/bin/bash

# Supabase Edge Function Secrets Setup
# Run this script after linking your Supabase project

echo "Setting up Supabase Edge Function secrets for Unified AI Assistant..."
echo ""

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found. Install it with: npm install -g supabase"
    exit 1
fi

# Get Groq API Key
echo "Enter your Groq API Key (get it from https://console.groq.com/keys):"
read -s GROQ_KEY
if [ -z "$GROQ_KEY" ]; then
    echo "⚠️  Groq API Key not provided. Skipping..."
else
    supabase secrets set GROQ_API_KEY="$GROQ_KEY"
    echo "✅ GROQ_API_KEY set"
fi

echo ""
echo "Enter your OpenAI API Key (optional, as fallback, get it from https://platform.openai.com/api-keys):"
echo "Press Enter to skip..."
read -s OPENAI_KEY
if [ -n "$OPENAI_KEY" ]; then
    supabase secrets set OPENAI_API_KEY="$OPENAI_KEY"
    echo "✅ OPENAI_API_KEY set"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Deploy the unified-ai-assistant function:"
echo "   supabase functions deploy unified-ai-assistant"
echo ""
echo "2. Test the function using the Supabase dashboard or curl"
```

Make it executable:
```bash
chmod +x setup-ai-assistant-secrets.sh
./setup-ai-assistant-secrets.sh
```
