# Fix MFA Session Error

## Problem

The `useMFAEnforcement` hook was calling `supabase.auth.mfa.listFactors()` before a valid session was established, causing:
- `Auth session missing!` error
- `403` error on `/auth/v1/user` endpoint
- Console errors during app initialization

## Root Cause

The hook was checking for `user` existence but not verifying that a valid `session` exists before calling the MFA API. The MFA API requires an active session to function.

## Solution

Updated `src/hooks/useMFAEnforcement.ts` to:
1. Check for both `user` AND `session` before calling MFA API
2. Wait for `authLoading` to complete before checking MFA
3. Handle session-related errors gracefully (don't block the user)
4. Use `session` from `AuthContext` instead of calling `getSession()` again

## Changes Made

### Before:
```typescript
if (!user || rolesLoading) return;
const { data, error } = await supabase.auth.mfa.listFactors();
```

### After:
```typescript
if (authLoading || rolesLoading || !user || !session) {
  setMfaLoading(true);
  return;
}
// ... then check MFA with error handling for session issues
```

## Error Handling

The hook now gracefully handles:
- Missing sessions
- Session expiry
- Auth-related errors
- Defaults to not requiring MFA if check fails (graceful degradation)

## Testing

After this fix:
- ✅ No more "Auth session missing!" errors in console
- ✅ No more 403 errors on auth endpoint
- ✅ MFA check only runs when session is valid
- ✅ Users can still access the app if MFA check fails (graceful degradation)

## Related Issues

- Users without property assignments will still see "no property assignments" error (separate issue)
- This fix only addresses the MFA session check timing issue

