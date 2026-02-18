# AI Assistant Current State

## Entry Points

1. **Frontend Component**: `src/components/AIAssistant.tsx`
   - Calls: `supabase/functions/unified-ai-assistant` (Edge Function)
   - Sends: `messages`, `currentPage`, `context`, `userInfo`

2. **Edge Function**: `supabase/functions/unified-ai-assistant/index.ts` (3239 lines)
   - Main handler for all AI assistant requests
   - Uses Groq API (with OpenAI fallback)
   - Handles both HMS portal and public portal contexts

## Current Tooling

### 1. Groq Client (`supabase/functions/unified-ai-assistant/groq-client.ts`)
- ✅ Good: Has retry logic, timeout handling, metrics logging
- ❌ Issue: Uses `llama-3.1-8b-instant` (outdated model name - should be `llama-3.3-70b-versatile`)
- ✅ Good: Has JSON repair on parse failures
- ✅ Good: Light metrics logging

### 2. Supabase DB Queries
- **Current State**: Direct queries scattered throughout `index.ts`
- **Tables Queried**: `reservations`, `guests`, `rooms`, `room_types`, `restaurants`, `spa_services`, `payments`, `invoices`, `properties`, `staff`, etc.
- **Issue**: No centralized query builder
- **Issue**: Some queries use hardcoded handlers, others use `generateDynamicQuery()`
- **Issue**: "UNABLE TO QUERY" fallbacks just return "Unsure"

### 3. Supabase AI (RAG / AI SQL)
- ❌ **NOT IMPLEMENTED**: No Supabase AI integration currently
- Missing: RAG for documentation/schema search
- Missing: AI SQL generation assistance

### 4. Intent Classification
- ✅ **Implemented**: `classifyIntent()` function
- Uses Groq with function calling
- Returns: `intent`, `confidence`, `entities`

### 5. Dynamic Query Generation
- ✅ **Partially Implemented**: `generateDynamicQuery()` and `executeDynamicQuery()`
- Issue: Logic is mixed with main handler
- Issue: Not always used as primary path

## Current Fallback Rules

1. **"Unsure" Responses**: System prompt says "If outside hotel/restaurant operations or provided data, respond with exactly: Unsure"
2. **"UNABLE TO QUERY"**: When DB queries fail, context includes "UNABLE TO QUERY DATABASE - Respond with: 'Unsure'"
3. **No Authentication**: "Please sign in to access your personal information" (good)

**Problems**:
- Too defensive: Returns "Unsure" too easily
- No attempt to use Supabase AI when structured queries fail
- No partial answer strategy (e.g., "I found X and Y, but Z isn't available")

## Known Limitations

1. **File Size**: Main `index.ts` is 3239 lines - too large, hard to maintain
2. **No Orchestrator**: Logic is scattered, no clear intent → tool → answer flow
3. **No Supabase AI**: Missing RAG and AI SQL assistance capabilities
4. **Response Length**: System prompt says "under 40 words" but no enforcement
5. **Lazy Fallbacks**: "I don't know" / "Unsure" used too often instead of exploring all options
6. **No Query Planner**: Dynamic queries are generated but not systematically planned
7. **Model Inconsistency**: `groq-client.ts` uses `llama-3.1-8b-instant` but main handler uses `llama-3.3-70b-versatile`

## Current Flow

```
User Message
  ↓
Edge Function Handler
  ↓
Classify Intent (Groq)
  ↓
Build Database Context (Hardcoded handlers OR Dynamic Query)
  ↓
Generate System Prompt (with DB context)
  ↓
Call Groq/OpenAI (streaming response)
  ↓
Return to Frontend
```

**Issues with this flow**:
- No clear decision tree: when to use hardcoded vs dynamic vs Supabase AI
- No post-processing: answer length not enforced
- No graceful degradation: tries one path, gives up if it fails

## Refactoring Goals

1. ✅ Centralize logic in orchestrator
2. ✅ Integrate Supabase AI for RAG/SQL assistance
3. ✅ Enforce ≤40 word responses
4. ✅ Smart fallback ladder: Local → DB → Supabase AI → Partial → "Don't know"
5. ✅ Dynamic query planning with proper tool selection
6. ✅ Consistent model usage
7. ✅ Better error handling and timeouts
