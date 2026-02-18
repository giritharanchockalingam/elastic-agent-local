# AI Assistant Setup Guide

## Overview

The application includes AI Assistant components that use **Groq** (free, fast) or **OpenAI** (fallback) instead of Lovable API. Both require API keys but offer generous free tiers.

> **📖 For detailed step-by-step instructions, see [AI_AGENT_GROQ_SETUP.md](./AI_AGENT_GROQ_SETUP.md)**

## Setting Up API Keys

### Option 1: Groq (Recommended - Free & Fast)

1. **Get your Groq API Key:**
   - Sign up at [Groq Console](https://console.groq.com) (free)
   - Navigate to API Keys
   - Create a new API key
   - Copy the key

2. **Set the secret in Supabase:**
   ```bash
   supabase secrets set GROQ_API_KEY=your_groq_api_key_here
   ```

### Option 2: OpenAI (Fallback)

1. **Get your OpenAI API Key:**
   - Sign up at [OpenAI Platform](https://platform.openai.com)
   - Navigate to API Keys
   - Create a new API key
   - Copy the key

2. **Set the secret in Supabase:**
   ```bash
   supabase secrets set OPENAI_API_KEY=your_openai_api_key_here
   ```

### Option 3: Using Supabase Dashboard

1. Go to your Supabase project dashboard
2. Navigate to **Project Settings** → **Edge Functions** → **Secrets**
3. Click **Add Secret**
4. Set:
   - **Name:** `GROQ_API_KEY` (or `OPENAI_API_KEY`)
   - **Value:** Your API key
5. Click **Save**

**Note:** The system will use Groq if `GROQ_API_KEY` is set, otherwise it falls back to OpenAI.

## Edge Functions

The following Edge Functions support Groq/OpenAI:

1. **`ai-assistant`** - Internal HMS AI Assistant
   - Route: `/functions/v1/ai-assistant`
   - Purpose: Helps hotel staff with HMS portal questions
   - Model: Groq `llama-3.1-70b-versatile` or OpenAI `gpt-3.5-turbo`

2. **`public-ai-assistant`** - Public Guest AI Assistant
   - Route: `/functions/v1/public-ai-assistant`
   - Purpose: Helps guests with bookings, amenities, and inquiries
   - Model: Groq `llama-3.1-70b-versatile` or OpenAI `gpt-3.5-turbo`

3. **`helpdesk-ai`** - Helpdesk AI Support
   - Route: `/functions/v1/helpdesk-ai`
   - Purpose: Ticket suggestions and chat assistance
   - Model: Groq `llama-3.1-70b-versatile` or OpenAI `gpt-3.5-turbo`

4. **`revenue-forecast-ai`** - Revenue Forecasting AI
   - Route: `/functions/v1/revenue-forecast-ai`
   - Purpose: AI-powered revenue predictions
   - Model: Groq `llama-3.1-70b-versatile` or OpenAI `gpt-3.5-turbo`

## Why Groq?

- **Free Tier:** Generous free tier (14,400 requests/day)
- **Fast:** Ultra-fast inference (up to 300 tokens/second)
- **No Credit Card:** Free tier doesn't require payment method
- **Open Source Models:** Uses Llama 3.1 70B (open-source, powerful)

## Why OpenAI as Fallback?

- **Reliable:** Industry-standard API
- **Free Tier:** $5 free credits for new users
- **Widely Supported:** Extensive documentation and community

## Testing

After setting up the API key:

1. **Test HMS AI Assistant:**
   - Login to the HMS portal
   - Click the floating AI Assistant button (bottom-right)
   - Ask a question about the system

2. **Test Public AI Assistant:**
   - Visit the public portal
   - Click the floating AI Assistant button (bottom-right)
   - Ask about rooms, amenities, or bookings

## Error Handling

If the API key is not configured:
- The Edge Function returns a `503 Service Unavailable` status
- A user-friendly error message is displayed with links to get API keys
- The assistant gracefully degrades without crashing the app

## Troubleshooting

### Error: "AI Assistant is not configured"

**Solution:** Follow the setup steps above to configure `GROQ_API_KEY` or `OPENAI_API_KEY`.

### Error: "Rate limit exceeded"

**Solution:** 
- Groq: Free tier allows 14,400 requests/day. Wait or upgrade.
- OpenAI: Check your usage limits in the dashboard.

### Error: "Insufficient quota"

**Solution:** 
- Groq: Check your account limits
- OpenAI: Add credits to your account

### AI Assistant Not Appearing

**Check:**
1. Component is imported in the layout (MainLayout for HMS, PublicLayout for public)
2. No JavaScript errors in the browser console
3. Edge Functions are deployed: `supabase functions deploy`

## Deployment

After setting up secrets, deploy Edge Functions:

```bash
# Deploy all AI-related functions
supabase functions deploy ai-assistant
supabase functions deploy public-ai-assistant
supabase functions deploy helpdesk-ai
supabase functions deploy revenue-forecast-ai
```

## Cost Comparison

| Provider | Free Tier | Paid Tier |
|----------|-----------|-----------|
| **Groq** | 14,400 requests/day | Pay-as-you-go |
| **OpenAI** | $5 free credits | $0.002/1K tokens (GPT-3.5) |

**Recommendation:** Start with Groq (free, fast), use OpenAI as backup.

## Security Notes

- **Never commit** API keys to version control
- Use environment secrets in Supabase (not environment variables in `.env`)
- The API key is only accessible server-side in Edge Functions
- Public endpoints use Supabase RLS for authentication
- Rotate API keys periodically for security
