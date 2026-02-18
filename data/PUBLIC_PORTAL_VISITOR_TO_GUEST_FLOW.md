# Public Portal - Visitor to Guest Flow

## Overview

This document describes the public portal feature that enables visitors to browse tenant information (hotels, restaurants, etc.) before becoming guests. The flow allows seamless conversion from visitor → guest via authentication.

## Architecture

### Flow Diagram

```
Visitor (No Auth)
    ↓
Browse Public Pages
    ├─ Tenant Landing (/brandSlug)
    ├─ Property Details (/brandSlug/propertySlug)
    ├─ Rooms Listing
    ├─ Restaurant Details
    └─ Menu Browsing
    ↓
Decide to Book/Order
    ↓
Auth Page (/auth?returnTo=...)
    ↓
Guest (Authenticated)
    ├─ Account Dashboard (/account)
    ├─ Bookings Management
    ├─ Folio
    ├─ Requests
    └─ Messages
```

## Route Categories

### 1. Public Routes (No Authentication Required)
Visitors can access these without signing in:

- `/:brandSlug` - Tenant brand landing page
- `/:brandSlug/:propertySlug` - Property landing page
- `/:brandSlug/:propertySlug/rooms` - Room types listing
- `/:brandSlug/:propertySlug/rooms/:roomTypeSlug` - Room type detail
- `/:brandSlug/:propertySlug/dining` - Restaurant listing
- `/:brandSlug/:propertySlug/dining/:outletSlug` - Restaurant detail
- `/:brandSlug/:propertySlug/dining/:outletSlug/menu` - Menu browsing

**Component:** `<PublicRoute>` - Wraps public pages with TenantShell

### 2. Guest Checkout Routes (Optional Auth)
Allow guest checkout without account, but prompt for account creation:

- `/:brandSlug/:propertySlug/book` - Booking flow
- `/:brandSlug/:propertySlug/booking-confirmation` - Booking confirmation
- `/:brandSlug/:propertySlug/order` - Order flow
- `/:brandSlug/:propertySlug/order-confirmation` - Order confirmation

**Component:** `<PublicRoute>` - Allows guest checkout, prompts for account

### 3. Guest Routes (Authentication Required)
Require authentication - visitors must sign in to access:

- `/account` - Guest dashboard
- `/account/bookings` - Booking management
- `/account/folio` - Folio/view charges
- `/account/requests` - Service requests
- `/account/messages` - Guest messages

**Component:** `<GuestRoute>` - Redirects to `/auth` if not authenticated

## Configuration

### Public Portal Config (`src/config/publicPortal.ts`)

```typescript
export const publicPortalConfig: PublicPortalConfig = {
  enabled: true,
  features: {
    tenantLanding: true,
    propertyDetails: true,
    restaurantDetails: true,
    roomBrowsing: true,
    menuBrowsing: true,
    publicInquiries: true,
    leadCapture: true,
  },
  guestFeatures: {
    booking: true,
    reservations: true,
    folio: true,
    requests: true,
    messages: true,
    loyalty: true,
  },
  authFlow: {
    requireAuthForBooking: false, // Allow guest checkout
    allowGuestCheckout: true,
    promptAccountCreation: true, // Prompt after booking
  },
};
```

## Authentication Flow

### Redirect After Auth

The `/auth` page now supports a `returnTo` query parameter:

```
/auth?returnTo=/account/bookings
```

After successful authentication:
1. If `returnTo` is provided and valid → redirect to that path
2. Otherwise → use role-based redirect (staff → dashboard, guest → account)

### Guest Account Creation

After guest checkout:
1. Complete booking/order as guest
2. Prompt: "Create an account to manage your bookings"
3. Redirect to `/auth?mode=signup&returnTo=/account`
4. After signup → redirect to `/account`

## Components

### PublicRoute
- Wraps public pages
- No authentication check
- Uses TenantShell for consistent styling
- Can optionally require auth for specific routes

### GuestRoute
- Wraps guest-only pages
- Checks authentication
- Redirects to `/auth?returnTo=...` if not authenticated
- Uses MainLayout for authenticated users

## Implementation Status

✅ **Completed:**
- Public portal configuration system
- PublicRoute component
- GuestRoute component
- Auth page returnTo support
- Route categorization
- Documentation

🔄 **Future Enhancements:**
- Guest checkout flow with account creation prompt
- Lead capture forms on public pages
- Public inquiry submission
- Social login for faster guest conversion
- Guest loyalty program enrollment

## Usage Examples

### Adding a New Public Route

```tsx
// In App.tsx
<Route 
  path="/:brandSlug/:propertySlug/about" 
  element={<PublicRoute><AboutPage /></PublicRoute>} 
/>
```

### Adding a New Guest Route

```tsx
// In App.tsx
<Route 
  path="/account/loyalty" 
  element={<GuestRoute><LoyaltyProgram /></GuestRoute>} 
/>
```

### Redirecting to Auth with Return Path

```tsx
// In any component
const navigate = useNavigate();
navigate(`/auth?returnTo=${encodeURIComponent('/account/bookings')}`);
```

## Security Considerations

1. **Public Routes:** Only display public information (no PII)
2. **Guest Routes:** Require authentication, respect RLS policies
3. **Guest Checkout:** Allow booking without account, but validate all inputs
4. **Rate Limiting:** Implement rate limiting on public endpoints
5. **CSRF Protection:** All forms must include CSRF tokens

## Testing

Test the visitor → guest flow:

1. Visit `/{brandSlug}` (should load without auth)
2. Browse property details
3. Click "Book Now" → redirects to booking flow
4. Complete booking as guest
5. Prompt for account creation
6. Sign up → redirects to `/account`
7. Access guest features

## Future Features

- [ ] Guest checkout with email verification
- [ ] Social login (Google, Facebook)
- [ ] Guest loyalty enrollment during booking
- [ ] Public reviews and ratings
- [ ] Virtual property tours
- [ ] Live chat for visitors
- [ ] Newsletter signup
- [ ] Special offers for new guests

