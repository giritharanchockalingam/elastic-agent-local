# Portal Audit - Next Steps & Progress

**Date**: 2025-01-XX  
**Status**: Phase 1 Complete, Phase 2 In Progress

---

## ✅ Phase 1: Foundation (Complete)

### 1. Route Inventory ✅
- ✅ All 100+ `/portal/*` routes inventoried
- ✅ Navigation links validated (115 links verified)
- ✅ All routes properly protected with `<ProtectedRoute>`

### 2. Utilities Created ✅
- ✅ `src/lib/routing/routeGuards.ts` - Route guard utilities
- ✅ `src/lib/supabase/scopedQueries.ts` - Scoped query helpers
- ✅ `src/lib/utils/errorHandling.ts` - Standardized error handling

### 3. Documentation ✅
- ✅ `docs/PORTAL_ROUTING_SECURITY_CHECKLIST.md` - Complete developer guide
- ✅ `docs/PORTAL_AUDIT_SUMMARY.md` - Executive summary

### 4. Example Fixes ✅
- ✅ `Guests.tsx` - Full property_id scoping applied
- ✅ `RoomService.tsx` - Fixed unscoped reservations query + error handling
- ✅ `LostFound.tsx` - Fixed delete mutation scoping + error handling

---

## 🔄 Phase 2: Standardization (In Progress)

### Pages Fixed So Far
1. ✅ `Guests.tsx` - Complete
2. ✅ `RoomService.tsx` - Partial (reservations query fixed)
3. ✅ `LostFound.tsx` - Partial (delete mutation fixed)

### Pages That Need Review

#### High Priority (Core Operations)
- [ ] `Reservations.tsx` - Delete mutation needs property_id scoping
- [ ] `RoomsInventory.tsx` - Delete mutations need property_id scoping
- [ ] `Housekeeping.tsx` - Delete mutation needs property_id scoping
- [ ] `FrontDesk.tsx` - Verify all queries are scoped
- [ ] `CheckInOut.tsx` - Verify all queries are scoped

#### Medium Priority (Revenue & Finance)
- [ ] `Invoicing.tsx` - Already has property_id scoping, verify error handling
- [ ] `Payments.tsx` - Verify property_id scoping
- [ ] `ExpenseTracking.tsx` - Delete mutation needs property_id scoping
- [ ] `Budgeting.tsx` - Delete mutation needs property_id scoping

#### Medium Priority (F&B)
- [ ] `FoodOrders.tsx` - Delete mutation needs property_id scoping
- [ ] `Bar.tsx` - Multiple delete mutations need property_id scoping
- [ ] `Kitchen.tsx` - Verify property_id scoping
- [ ] `MenuManagement.tsx` - Delete mutation needs property_id scoping

#### Lower Priority (Other Services)
- [ ] `Activities.tsx` - Already has property_id scoping ✅
- [ ] `Spa.tsx` - Verify property_id scoping
- [ ] `Concierge.tsx` - Verify property_id scoping
- [ ] `VIPServices.tsx` - Verify property_id scoping

---

## 📋 Standardization Checklist

For each portal page, ensure:

### Queries
- [ ] All `SELECT` queries include `.eq('property_id', propertyId)`
- [ ] Query is disabled when `!propertyId` (use `enabled: !!propertyId`)
- [ ] Error handling uses `handleRLSError()` or `handleSupabaseError()`

### Mutations (Create)
- [ ] Always include `property_id: propertyId` in insert data
- [ ] Check `if (!propertyId) throw new Error('Property ID required')`

### Mutations (Update)
- [ ] Always include `.eq('property_id', propertyId)` in update query
- [ ] Preserve `property_id` in update data

### Mutations (Delete)
- [ ] Always include `.eq('property_id', propertyId)` in delete query
- [ ] Check `if (!propertyId) throw new Error('Property ID required')`

### Error Handling
- [ ] Use `handleRLSError()` or `handleSupabaseError()` for user-friendly messages
- [ ] Log errors with context for debugging

---

## 🔧 Quick Fix Pattern

### For Delete Mutations

**Before**:
```typescript
const deleteMutation = useMutation({
  mutationFn: async (id: string) => {
    const { error } = await supabase
      .from('table')
      .delete()
      .eq('id', id);
    if (error) throw error;
  },
});
```

**After**:
```typescript
const deleteMutation = useMutation({
  mutationFn: async (id: string) => {
    if (!propertyId) throw new Error('Property ID is required');
    const { error } = await supabase
      .from('table')
      .delete()
      .eq('id', id)
      .eq('property_id', propertyId); // Add this
    if (error) {
      throw new Error(handleSupabaseError(error)); // Use error handler
    }
  },
});
```

### For Queries

**Before**:
```typescript
const { data } = await supabase
  .from('table')
  .select('*');
```

**After**:
```typescript
if (!propertyId) return [];
const { data, error } = await supabase
  .from('table')
  .select('*')
  .eq('property_id', propertyId); // Add this

if (error) {
  throw new Error(handleSupabaseError(error)); // Use error handler
}
```

---

## 📊 Progress Metrics

- **Total Portal Pages**: ~100+
- **Pages Audited**: 3 (Guests, RoomService, LostFound)
- **Pages Fixed**: 3
- **Delete Mutations Needing Fix**: ~48 (identified via grep)
- **Estimated Remaining Work**: 2-3 days for complete standardization

---

## 🎯 Recommended Approach

### Option 1: Incremental Fixes (Recommended)
- Fix pages as you work on them
- Use the established patterns
- Add error handling incrementally

### Option 2: Systematic Fix
- Create a script to identify all unscoped queries/mutations
- Fix in batches by priority
- Test each batch before moving on

### Option 3: Code Review Enforcement
- Add ESLint rules to catch unscoped queries
- Require property_id scoping in PR reviews
- Use TypeScript types to enforce scoping

---

## 🚀 Next Actions

1. **Immediate** (This Week):
   - [ ] Fix delete mutations in high-priority pages (Reservations, RoomsInventory, Housekeeping)
   - [ ] Add error handling to all fixed pages

2. **Short-term** (This Month):
   - [ ] Review and fix all F&B pages
   - [ ] Review and fix all Finance pages
   - [ ] Add route guards to critical routes

3. **Long-term** (Ongoing):
   - [ ] Create ESLint rules for property_id scoping
   - [ ] Add integration tests for RLS enforcement
   - [ ] Create shared CRUD hooks

---

## 📝 Notes

- Most pages already have property_id scoping in SELECT queries
- Main gaps are in DELETE mutations (48 identified)
- Error handling is inconsistent but improving
- RLS policies are active and will block unscoped queries automatically

---

**Last Updated**: 2025-01-XX  
**Next Review**: After next batch of fixes
