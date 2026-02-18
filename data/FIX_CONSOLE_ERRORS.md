# Fix Console Errors

## Errors Found

1. **analytics_events query 400 error**
   - Location: `src/pages/Dashboard.tsx:174`
   - Query: `select('event_type, timestamp, event_category')`
   - Issue: May be a query format issue or RLS policy blocking

2. **create-payment-intent Edge Function 400 error**
   - Location: `src/pages/BookingEngine.tsx:809`
   - Issue: Request body validation failing

3. **guest-documents storage 400 error**
   - Location: `src/pages/CheckInOut.tsx:205`
   - Issue: Storage bucket access or RLS policy issue

4. **DialogContent accessibility warning**
   - Missing `Description` or `aria-describedby` prop

## Fixes Needed

### 1. Fix analytics_events Query

The query is selecting specific columns. Need to handle errors gracefully and use proper column selection.

### 2. Fix create-payment-intent Call

Ensure request body matches the expected schema in the Edge Function.

### 3. Fix Storage Access

Ensure storage bucket exists and RLS policies allow access.

### 4. Fix Accessibility Warning

Add `Description` component or `aria-describedby` to DialogContent.

