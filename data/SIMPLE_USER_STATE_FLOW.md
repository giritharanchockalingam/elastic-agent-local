# Simple User State Flow - Implementation Summary

You're absolutely right - this should be dead simple. Here's how it works:

## The Flow (As Simple As It Gets)

```
VISITOR (no user)
  ↓ Sign In/Sign Up
GUEST (user, no roles)
  ↓ Role Check
STAFF (user, has roles)
  ↓ Sign Out
PUBLIC LANDING PAGE (everyone returns here)
```

## Implementation (3 Simple Functions)

### 1. After Sign In (`src/lib/authRouting.ts`)

```typescript
export async function routeAfterSignIn(returnTo?: string | null): Promise<string> {
  // Get user
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return '/'; // Not logged in → public landing

  // Get roles
  const { data: userRoles } = await supabase
    .from('user_roles')
    .select('role')
    .eq('user_id', user.id);

  const roles = userRoles?.map(r => r.role) || [];

  // If returnTo → use it (user was trying to access something)
  if (returnTo && returnTo.startsWith('/')) return returnTo;

  // No roles → GUEST → Stay on public landing
  if (roles.length === 0) return '/';

  // Has admin role → ADMIN → Go to portal
  const adminRoles = ['super_admin', 'admin', 'general_manager'];
  if (roles.some(r => adminRoles.includes(r))) return '/dashboard';

  // Has any role → STAFF → Stay on public landing (can click Portal button)
  return '/';
}
```

### 2. Header Display (`src/components/layout/TenantHeader.tsx`)

```typescript
const { user } = useAuth(); // Is user logged in?
const { roles } = useUserRole(); // What roles does user have?

// Simple state checks
const hasStaffRole = roles && roles.length > 0; // Has any role = STAFF
const isGuest = user && (!roles || roles.length === 0); // User but no roles = GUEST

// Display logic
{!user && <SignInButton />} // VISITOR
{user && isGuest && <MyAccountDropdown />} // GUEST
{user && hasStaffRole && <PortalButton />} // STAFF
```

### 3. Sign Out (`src/contexts/AuthContext.tsx`)

```typescript
const signOut = async () => {
  await supabase.auth.signOut();
  navigate('/'); // Everyone goes to public landing
};
```

## That's It!

- **VISITOR**: No user → Show "Sign In" button
- **GUEST**: User with no roles → Show "My Account" dropdown
- **STAFF**: User with roles → Show "Portal" button
- **ADMIN**: User with admin roles → Auto-redirect to `/dashboard` (unless returnTo)

All sign out → Public Landing Page (`/`)

Simple, clean, straightforward. ✅

