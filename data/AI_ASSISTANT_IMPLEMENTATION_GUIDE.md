# AI Assistant Implementation Guide

## Complete File List

### New Files Created

1. **Core Orchestrator & Clients:**
   - `supabase/functions/unified-ai-assistant/lib/orchestrator.ts` - Main orchestrator (intent detection, tool planning, execution, answer synthesis)
   - `supabase/functions/unified-ai-assistant/lib/groqClient.ts` - Groq client wrapper for consistent usage
   - `supabase/functions/unified-ai-assistant/lib/supabaseDBClient.ts` - Safe Supabase DB query helpers
   - `supabase/functions/unified-ai-assistant/lib/supabaseAIClient.ts` - Supabase AI (RAG/SQL) client
   - `supabase/functions/unified-ai-assistant/lib/queryPlanner.ts` - Dynamic query planning from natural language

2. **Documentation:**
   - `docs/AI_ASSISTANT_CURRENT_STATE.md` - Analysis of current implementation
   - `docs/AI_ASSISTANT_REFACTOR_SUMMARY.md` - Summary of refactoring
   - `docs/AI_ASSISTANT_IMPLEMENTATION_GUIDE.md` - This file

3. **Examples & Tests:**
   - `supabase/functions/unified-ai-assistant/tests/example-queries.md` - Test query examples
   - `supabase/functions/unified-ai-assistant/index.refactored.ts` - Example refactored main function

### Files Updated

1. `supabase/functions/unified-ai-assistant/groq-client.ts` - Updated timeout and comments

## How It Works: Complete Flow

```
User Message: "How many bookings did guest X have last month?"
  ↓
[Main Edge Function] index.ts or index.refactored.ts
  ↓
[Orchestrator] orchestrateAssistant()
  ├─ Step 1: detectIntent()
  │   └─ Returns: { intent: "data_lookup", confidence: 0.9, entities: {guestEmail: "X", dateFrom: "2024-11-01"}, requiresAuth: true }
  │
  ├─ Step 2: planTools()
  │   └─ Returns: ["db_query"] (skip local_reasoning for pure data queries)
  │
  ├─ Step 3: executeTools()
  │   ├─ executeDBQuery()
  │   │   ├─ planQuery() [Query Planner]
  │   │   │   ├─ extractEntities() - Extracts guest email, dates, "count" aggregation
  │   │   │   └─ buildQueryPlan() - Builds query plan for reservations table
  │   │   │
  │   │   └─ executeQueryPlan()
  │   │       └─ queryReservations() [DB Client]
  │   │           └─ Returns: { data: [3 bookings], error: null }
  │   │
  │   └─ Returns: { tool: "db_query", success: true, data: [3 bookings] }
  │
  ├─ Step 4: synthesizeAnswer()
  │   └─ runGroqChat() [Groq Client]
  │       └─ Returns: "Guest X had 3 bookings last month."
  │
  └─ Step 5: enforceWordLimit()
      └─ Returns: "Guest X had 3 bookings last month." (already ≤40 words)
  ↓
Final Answer: "Guest X had 3 bookings last month."
Tool Used: "db_query"
```

## Fallback Strategy Flow

```
Query: "What's the weather today?"
  ↓
detectIntent() → { intent: "pure_reasoning", confidence: 0.3 }
  ↓
planTools() → ["local_reasoning"]
  ↓
executeTools():
  ├─ canAnswerFromKnowledge() → false (outside hotel domain)
  ├─ executeDBQuery() → skipped (pure reasoning intent)
  └─ executeSupabaseAI() → skipped (not needed)
  ↓
synthesizeAnswer():
  └─ No data available
  └─ Attempts local reasoning
  └─ Returns: "I don't have enough data in this system to answer that reliably."
  ↓
Final Answer: "I don't have enough data in this system to answer that reliably."
```

## Integration Example

### Using the Orchestrator in Your Code

```typescript
import { orchestrateAssistant } from './lib/orchestrator.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// Initialize Supabase client
const supabaseClient = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

// Call orchestrator
const response = await orchestrateAssistant(
  {
    userMessage: "How many bookings did guest john@example.com have last month?",
    conversationHistory: [
      { role: 'user', content: 'Hello' },
      { role: 'assistant', content: 'Hi! How can I help?' },
    ],
    context: {
      userId: 'user-uuid',
      email: 'staff@hotel.com',
      propertyId: 'property-uuid',
      isGuest: false,
      isStaff: true,
      isAdmin: false,
    },
    scope: 'hms',
  },
  supabaseClient,
  null, // Supabase AI client (null if not configured)
  Deno.env.get('GROQ_API_KEY')!,
  true // useGroq
);

console.log(response.answer); // "Guest john@example.com had 3 bookings last month."
console.log(response.toolUsed); // "db_query"
console.log(response.metadata); // { intent: "data_lookup", confidence: 0.9, toolsAttempted: 1 }
```

## Answer Style Examples

### Good Answers (≤40 words, direct, factual)

✅ "Guest john@example.com had 3 bookings last month: Deluxe Suite (Nov 5-7), Standard Room (Nov 15-17), Executive Suite (Nov 22-24)."

✅ "Total revenue this week: ₹1,25,000. Breakdown: Rooms ₹95,000, Dining ₹20,000, Spa ₹10,000."

✅ "You have 2 upcoming reservations: Executive Suite (Jan 12-15) and Standard Room (Jan 20-22)."

✅ "Check-in process: Navigate to Reservations → Find guest → Click Check In → Verify details → Confirm."

❌ "Hi! I'd be happy to help you with that. Let me check our database for information about guest bookings... [too long, >40 words]"

❌ "I don't know." (too lazy - should try tools first)

❌ "Unsure." (too vague - should be more helpful)

## Performance Characteristics

### Expected Response Times

- **Local Reasoning**: 200-500ms (Groq API call only)
- **DB Query**: 300-800ms (Groq intent detection + DB query)
- **Supabase AI**: 500-1500ms (RAG/SQL generation + execution)
- **Word Limit Enforcement**: +100-300ms (if needed, additional Groq call)

**Target**: <2 seconds total for most queries

### Optimization Tips

1. **Cache intent classifications** for similar queries
2. **Use parallel execution** when multiple tools can run simultaneously
3. **Early exit** when a tool succeeds with data
4. **Short timeouts** (8 seconds) to prevent hanging
5. **Token limits** (128 for chat, 256 for JSON) to keep responses fast

## Testing Checklist

Use `tests/example-queries.md` to test:

- [ ] Data lookup queries return accurate results
- [ ] Pure reasoning queries answer from knowledge
- [ ] Mixed queries combine reasoning and data
- [ ] Supabase AI is used for schema/documentation questions
- [ ] Fallback strategy works (no lazy "I don't know")
- [ ] Word limit is enforced (≤40 words)
- [ ] Partial answers are provided when appropriate
- [ ] Performance is acceptable (<2 seconds)
- [ ] Error handling is graceful
- [ ] Authentication is handled correctly

## Deployment Steps

1. **Test Locally:**
   ```bash
   supabase functions serve unified-ai-assistant --no-verify-jwt
   ```

2. **Deploy Refactored Version:**
   ```bash
   # Option 1: Replace main function (after testing)
   supabase functions deploy unified-ai-assistant
   
   # Option 2: Deploy as separate function for A/B testing
   supabase functions deploy unified-ai-assistant-v2
   ```

3. **Monitor:**
   - Check Supabase Edge Function logs
   - Monitor Groq API usage
   - Track response times
   - Verify word limit compliance

4. **Rollback Plan:**
   - Keep old `index.ts` backed up
   - Can revert by redeploying previous version
   - Gradual migration recommended

## Future Enhancements

1. **Streaming Responses**: Modify `synthesizeAnswer()` to stream intermediate results
2. **Caching**: Cache intent classifications and common query results
3. **Supabase AI Integration**: Replace placeholder RAG with actual Supabase AI endpoints
4. **Multi-turn Conversations**: Better context management across turns
5. **Analytics**: Track which tools are used most, response times, success rates
6. **A/B Testing**: Compare old vs new implementation side-by-side

## Troubleshooting

### Issue: "DB query planner not yet implemented"
**Solution**: The query planner is implemented in `lib/queryPlanner.ts`. Make sure it's imported correctly in `orchestrator.ts`.

### Issue: Answers exceed 40 words
**Solution**: Check that `enforceWordLimit()` is being called. The post-processor should automatically trim.

### Issue: "I don't know" appears too often
**Solution**: Verify the fallback strategy is working. Check tool execution order and ensure partial data is being used.

### Issue: Slow responses (>2 seconds)
**Solution**: 
- Check Groq API latency
- Verify database query performance
- Consider caching frequently asked questions
- Reduce token limits if answers are too verbose

### Issue: Supabase AI not working
**Solution**: The Supabase AI client is currently a placeholder. Update `supabaseAIClient.ts` to use actual Supabase AI endpoints when available.

## Support

For issues or questions:
1. Check `docs/AI_ASSISTANT_CURRENT_STATE.md` for understanding current implementation
2. Review `tests/example-queries.md` for test cases
3. Check Supabase Edge Function logs for errors
4. Verify environment variables are set (GROQ_API_KEY, etc.)
