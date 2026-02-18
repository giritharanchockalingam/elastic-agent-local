# AI Assistant Refactor Summary

## Overview

The AI assistant has been refactored from a monolithic 3239-line file into a modular, maintainable architecture with clear separation of concerns.

## Key Changes

### 1. Architecture

**Before:**
- Single large file (`index.ts` - 3239 lines)
- Scattered logic
- Hard to maintain and test

**After:**
- Centralized orchestrator (`lib/orchestrator.ts`)
- Separate clients for Groq, Supabase DB, and Supabase AI
- Query planner for intelligent query building
- Clear intent → tool → answer flow

### 2. New File Structure

```
supabase/functions/unified-ai-assistant/
├── lib/
│   ├── orchestrator.ts          # Main orchestration logic
│   ├── groqClient.ts            # Groq client wrapper
│   ├── supabaseDBClient.ts      # Safe DB query helpers
│   ├── supabaseAIClient.ts      # Supabase AI (RAG/SQL) client
│   └── queryPlanner.ts          # Dynamic query planning
├── groq-client.ts               # Core Groq client (existing)
├── prompts.ts                   # System prompts (existing)
├── index.ts                     # Main edge function (existing - to be updated)
└── index.refactored.ts          # Refactored main function (example)
```

### 3. Core Components

#### Orchestrator (`lib/orchestrator.ts`)
- **Responsibilities:**
  - Intent detection
  - Tool planning
  - Execution pipeline
  - Answer synthesis
  - Word limit enforcement (≤40 words)

#### Query Planner (`lib/queryPlanner.ts`)
- **Responsibilities:**
  - Entity extraction from natural language
  - Date normalization ("last month" → actual dates)
  - Query plan building
  - Safe query execution

#### Supabase DB Client (`lib/supabaseDBClient.ts`)
- **Responsibilities:**
  - Safe table queries with validation
  - Common query helpers (reservations, guests, financial data)
  - Filter building
  - Limit enforcement

#### Supabase AI Client (`lib/supabaseAIClient.ts`)
- **Responsibilities:**
  - RAG search over documentation/schema
  - AI SQL generation (with constraints)
  - Safe SQL execution (placeholder - use query builder in production)

#### Groq Client Wrapper (`lib/groqClient.ts`)
- **Responsibilities:**
  - Simplified interface for chat and JSON generation
  - Consistent defaults (temperature=0, optimized tokens)
  - Fast responses

### 4. Smart Fallback Strategy

**Ladder:**
1. **Local Reasoning** - Answer from knowledge/logic alone (fast, no DB needed)
2. **Structured DB Query** - Direct database queries with query planner
3. **Supabase AI (RAG)** - Documentation/schema search when structured queries fail
4. **Supabase AI (SQL)** - AI-generated SQL (constrained) for complex queries
5. **Partial Answer** - Use partial data when available ("I found X and Y; Z isn't available")
6. **Graceful "Don't Know"** - Only as last resort: "I don't have enough data in this system to answer that reliably."

**Key Improvement:** No more lazy "Unsure" responses. System actively tries multiple paths before giving up.

### 5. Answer Style

- **≤40 words enforced** via post-processor
- **Direct and factual** - no greetings, no unnecessary apologies
- **Bullet points** when listing
- **Acknowledge limitations** when appropriate
- **System prompt** enforces brevity explicitly

### 6. Performance Optimizations

- **Fast model**: `llama-3.1-8b-instant` (optimized for speed)
- **Short timeouts**: 8 seconds for Groq calls
- **Token limits**: 128 tokens for chat (~40 words), 256 for JSON
- **Parallel execution**: Tools can run in parallel when appropriate
- **Early exit**: Stop trying other tools if one succeeds with data

### 7. Dynamic Query Building

The query planner intelligently:
- Extracts entities (guest, booking, property, dates, amounts)
- Normalizes relative dates ("last month" → actual date range)
- Builds safe Supabase queries with proper filters
- Handles aggregations (count, sum, avg, min, max)
- Enforces limits (max 500 rows, default 100)

### 8. Integration with Existing Code

The refactored orchestrator can be integrated into the existing `index.ts` gradually:

1. **Option A:** Replace the main handler with `index.refactored.ts` (recommended for testing)
2. **Option B:** Gradually migrate sections of `index.ts` to use orchestrator functions
3. **Option C:** Keep existing code for backward compatibility, add orchestrator as alternative endpoint

## Migration Path

### Step 1: Test the Refactored Version
```bash
# Deploy index.refactored.ts as a new function for testing
supabase functions deploy unified-ai-assistant-refactored
```

### Step 2: Update Frontend (Optional)
```typescript
// In src/components/AIAssistant.tsx, optionally test new endpoint:
const response = await fetch(
  `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/unified-ai-assistant-refactored`,
  // ... rest of config
);
```

### Step 3: Compare Results
- Test with example queries (see `tests/example-queries.md`)
- Verify ≤40 word limit is enforced
- Check fallback behavior
- Measure performance

### Step 4: Migrate Main Function
- Once validated, update `index.ts` to use orchestrator
- Keep existing code commented for rollback if needed

## Example Usage

### Using the Orchestrator Directly

```typescript
import { orchestrateAssistant } from './lib/orchestrator.ts';

const response = await orchestrateAssistant(
  {
    userMessage: "How many bookings did guest X have last month?",
    conversationHistory: messages,
    context: {
      userId: user.id,
      email: user.email,
      propertyId: property.id,
      isGuest: false,
      isStaff: true,
    },
    scope: 'hms',
  },
  supabaseClient,
  supabaseAIClient, // null if not configured yet
  groqApiKey,
  useGroq
);

console.log(response.answer); // "Guest X had 3 bookings last month."
console.log(response.toolUsed); // "db_query"
```

## Key Files

### New Files Created:
1. `lib/orchestrator.ts` - Main orchestrator (500+ lines)
2. `lib/groqClient.ts` - Groq client wrapper
3. `lib/supabaseDBClient.ts` - DB query helpers (400+ lines)
4. `lib/supabaseAIClient.ts` - Supabase AI integration (200+ lines)
5. `lib/queryPlanner.ts` - Query planning (500+ lines)
6. `index.refactored.ts` - Example refactored main function
7. `tests/example-queries.md` - Test examples
8. `docs/AI_ASSISTANT_CURRENT_STATE.md` - Current state documentation
9. `docs/AI_ASSISTANT_REFACTOR_SUMMARY.md` - This file

### Files Updated:
1. `groq-client.ts` - Updated timeout (10s → 8s) and comments

### Files to Update (Future):
1. `index.ts` - Main edge function (3239 lines - migrate to use orchestrator)

## Benefits

1. **Maintainability**: Modular structure, easier to understand and modify
2. **Testability**: Each component can be tested independently
3. **Performance**: Optimized for fast, concise responses
4. **Smart Fallbacks**: No lazy "I don't know" - tries multiple paths
5. **Word Limit**: Automatic enforcement of ≤40 words
6. **Dynamic Queries**: Intelligent query building from natural language
7. **Extensibility**: Easy to add new tools or modify behavior

## Next Steps

1. ✅ Create orchestrator and supporting libraries
2. ✅ Implement smart fallback strategy
3. ✅ Add word limit enforcement
4. ✅ Create query planner
5. ⏳ Test with example queries
6. ⏳ Integrate into main `index.ts`
7. ⏳ Deploy and monitor
8. ⏳ Add Supabase AI RAG endpoint integration (when available)

## Notes

- The Supabase AI client currently uses Groq as a placeholder for RAG/SQL. When Supabase AI endpoints are available, update `supabaseAIClient.ts` to use actual endpoints.
- The query planner extracts entities using AI, which adds ~200-500ms latency. This is acceptable for the intelligence gained, but can be optimized with caching or heuristics.
- Streaming responses are not yet implemented in the orchestrator. This can be added by modifying `synthesizeAnswer()` to stream intermediate results.
