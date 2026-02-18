# AI Assistant Query Architecture: Current vs. Dynamic Approach

## Current Architecture (Semi-Dynamic)

**How it works:**
1. **Intent Classification** (AI-powered, dynamic) ✅
   - Uses AI to classify user intent into predefined categories
   - Extracts entities (dates, emails, IDs, etc.)
   - Can detect variations of known intents without code changes

2. **Database Queries** (Hardcoded, requires code changes) ❌
   - Each intent type has a dedicated hardcoded query function
   - Examples: `queryRoomTypes()`, `queryGuestSpending()`, `queryReservations()`
   - To add new query types, you must:
     - Add new intent to enum
     - Write new query function
     - Add case in `buildDatabaseContext()`

**Pros:**
- ✅ Safe (no SQL injection risk)
- ✅ Predictable performance
- ✅ Easy to debug
- ✅ Can optimize queries

**Cons:**
- ❌ Requires code changes for new query types
- ❌ Limited to predefined intents
- ❌ Can't handle novel queries without deployment

---

## Proposed Dynamic Architecture (AI-Generated Queries)

**How it would work:**
1. **Intent Analysis** (AI-powered)
   - AI analyzes user query and determines what data is needed
   - Extracts entities and query parameters

2. **Query Generation** (AI-powered, dynamic) ✅
   - AI generates Supabase query based on:
     - Database schema (provided as context)
     - User's intent and entities
     - RLS policies and constraints
   - Uses Supabase client library (type-safe, no raw SQL)

3. **Query Execution & Validation** (Safe wrapper)
   - Validates query structure before execution
   - Enforces RLS automatically (Supabase handles this)
   - Catches errors and provides fallback

**Pros:**
- ✅ Zero code changes for new query types
- ✅ Handles novel queries dynamically
- ✅ More flexible and extensible
- ✅ Can adapt to schema changes

**Cons:**
- ⚠️ Requires robust error handling
- ⚠️ Needs schema documentation in context
- ⚠️ Slightly more complex
- ⚠️ May generate suboptimal queries

---

## Recommended Hybrid Approach

**Best of both worlds:**

1. **Common queries**: Keep hardcoded functions (performance, safety)
   - Room types, reservations, bookings, spending, etc.
   - These are frequently used and benefit from optimization

2. **Novel queries**: Use AI-generated queries (flexibility)
   - Ad-hoc questions like "What's my average room rate?"
   - Complex filters like "Show me all bookings in suite rooms last month"
   - One-off analytical queries

3. **Fallback mechanism**:
   - Try hardcoded function first (if intent matches)
   - If no match, generate query dynamically
   - Log generated queries for review and potential optimization

---

## Implementation Options

### Option A: Pure Dynamic (Most Flexible)
- AI generates Supabase queries using function calling
- Requires comprehensive schema documentation
- Best for: Maximum flexibility, rapid iteration

### Option B: Hybrid (Recommended)
- Keep common queries hardcoded
- Use AI for novel/uncommon queries
- Best for: Balance of safety and flexibility

### Option C: Enhanced Intent System (Current + Improvements)
- Expand intent classification with better NLP
- Add more granular intent categories
- Keep all queries hardcoded but cover more cases
- Best for: Maximum safety and predictability

---

## Recommendation

**Start with Option B (Hybrid)** because:
1. Common queries (80% of use cases) remain fast and safe
2. Novel queries (20%) can be handled dynamically
3. Gradually move optimized dynamic queries to hardcoded functions
4. Provides flexibility without sacrificing safety
