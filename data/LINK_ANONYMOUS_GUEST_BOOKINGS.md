# Link Anonymous Guest Bookings to User Accounts

## The Problem

When a user books anonymously and then signs in later with the same email, their bookings don't appear in "My Account" because:
1. Anonymous bookings create guest records with `user_id = null`
2. The "My Account" page looks for guest records with `user_id = user.id`
3. No linking happens automatically

## The Solution

The system now automatically links anonymous guest records to user accounts when:
1. User signs in and views "My Account"
2. System checks for guest record with `user_id = user.id`
3. If not found, system searches for anonymous guest with matching email
4. If found, automatically links the guest record to the user account
5. Bookings then appear in "My Account"

## Implementation

### 1. Enhanced `getGuestBookings()` Function

Located in `src/lib/domain/guest.ts`, this function now:
- Checks for linked guest record first
- If not found, searches for anonymous guest by email
- Automatically links anonymous guest to user account
- Then fetches bookings for the linked guest

### 2. Enhanced `GuestContext`

Located in `src/contexts/GuestContext.tsx`, this context now:
- Automatically links anonymous guests when user signs in
- Refreshes guest data after linking

### 3. RLS Policy

Migration `20251230000002_ensure_guest_linking_policy.sql` ensures:
- Authenticated users can update anonymous guest records (with `user_id = null`)
- Update is allowed if email matches user's email
- After update, `user_id` is set to `auth.uid()`

## How It Works

```typescript
// 1. User books anonymously
// Guest record: { id: 'xxx', email: 'user@example.com', user_id: null }

// 2. User signs in with same email
// User: { id: 'user-123', email: 'user@example.com' }

// 3. User visits "My Account"
// getGuestBookings('user-123') is called

// 4. System checks for linked guest
// SELECT * FROM guests WHERE user_id = 'user-123' → No results

// 5. System searches for anonymous guest
// SELECT * FROM guests WHERE email = 'user@example.com' AND user_id IS NULL → Found!

// 6. System links the guest
// UPDATE guests SET user_id = 'user-123' WHERE id = 'xxx' AND user_id IS NULL

// 7. System fetches bookings
// SELECT * FROM reservations WHERE guest_id = 'xxx' → Returns bookings!
```

## Testing

1. **Book as Anonymous:**
   - Go to booking page
   - Complete booking without signing in
   - Note the confirmation number

2. **Sign In:**
   - Sign in with the same email used for booking
   - Go to "My Account" → "Bookings"
   - Your booking should appear!

## Edge Cases Handled

- ✅ Multiple anonymous bookings with same email (all get linked)
- ✅ User already has a linked guest record (skips linking)
- ✅ Email mismatch (no linking, user creates new guest record)
- ✅ RLS policies allow the update operation

## Related Files

- `src/lib/domain/guest.ts` - `getGuestBookings()` function
- `src/contexts/GuestContext.tsx` - Guest context with auto-linking
- `supabase/migrations/20251230000002_ensure_guest_linking_policy.sql` - RLS policy
