# Public Portal Architecture

## Overview

This document describes the architecture for customer-facing public portals in the HMS system. The portals enable:
1. **Public browsing** without authentication (tenant/property discovery, room browsing, menu viewing)
2. **Guest self-service** after signup/login (bookings, check-in/out, folio, requests, loyalty, messages)
3. **Public hotel & restaurant portals** for non-patrons (marketing, discovery, booking, ordering)

All operational data feeds into the core HMS and respects multi-tenancy and RLS policies.

## Architecture Principles

### Security & Tenancy (Non-Negotiable)
- **NO "disable RLS"** - All queries must respect Row Level Security
- **NO service-role usage in client** - Only anon key for public, authenticated key for logged-in users
- **NO unsafe RPCs** - All RPCs must enforce tenant/property isolation
- **NO direct table writes that bypass policy** - All writes must go through RLS-protected paths
- **Tenant isolation** - Every data call must be tenant-safe and property-safe
- **Public data only** - Public pages may read ONLY what policies allow for "anon" role
- **No PII leakage** - Avoid leaking email/phone/address in public responses
- **Rate limiting** - Public endpoints must be rate-limited
- **Audit logging** - All write actions must log minimal audit events

### Technology Stack
- **Frontend**: Vite + React (existing), React Router for routing
- **Backend**: Supabase (PostgreSQL + RLS)
- **Styling**: Tailwind CSS + shadcn/ui components
- **State Management**: TanStack Query (React Query)
- **Type Safety**: TypeScript (strict mode)
- **Accessibility**: WCAG 2.1 AA compliance target
- **Performance**: Lighthouse targets: Performance > 90, Accessibility > 95, SEO > 90

## URL Routing Structure

### Public Portal Routes
```
/{brandSlug}                          # Tenant brand landing
/{brandSlug}/{propertySlug}           # Property landing
/{brandSlug}/{propertySlug}/rooms     # Room types listing
/{brandSlug}/{propertySlug}/rooms/{roomTypeSlug}  # Room type detail
/{brandSlug}/{propertySlug}/dining    # Restaurant listing
/{brandSlug}/{propertySlug}/dining/{restaurantSlug}  # Restaurant detail
/{brandSlug}/{propertySlug}/events    # Events listing
/{brandSlug}/{propertySlug}/book      # Booking flow
/{brandSlug}/{propertySlug}/order     # Restaurant ordering
/{brandSlug}/{propertySlug}/support   # Ticket creation
```

### Guest Account Routes
```
/account                              # Profile
/account/bookings                     # My bookings
/account/checkin                     # Digital check-in
/account/folio                       # Folio and invoices
/account/requests                    # Service requests
/account/messages                    # Messages with property
```

## Data Model

### Slug Resolution
- **Tenants**: `brand_slug` field (unique, URL-safe) - added via migration
- **Properties**: `property_slug` field (unique per tenant, URL-safe) - added via migration
- **Room Types**: `slug` field (unique per property) - added via migration
- **Restaurants**: `slug` field (unique per property) - added via migration

Slugs are resolved via `src/lib/tenant/resolveContext.ts` to ensure:
1. Tenant exists and is active (`tenants.status = 'active'`)
2. Property belongs to tenant (`properties.tenant_id = tenant.id`)
3. Property is active (`properties.status = 'active'`)
4. Property has public portal enabled (if `properties.settings.public_portal_enabled` is set, must be `true`)

### Public-Safe Data Tables
- `tenants` (public fields: id, name, brand_slug, settings.branding)
- `properties` (public fields: id, name, property_slug, address, city, amenities, images)
- `room_types` (public fields: id, name, slug, description, base_price, max_occupancy, amenities, images)
- `restaurants` (public fields: id, name, slug, cuisine_type, opening_time, closing_time)
- `menu_items` (public fields: id, name, description, price, category, dietary_info, images)

### Operational Tables (Write-Only for Public)
- `reservations` - Created via booking flow (columns: `property_id`, `guest_id`, `room_id`, `check_in_date`, `check_out_date`, `adults`, `children`, `total_amount`, `status`, `special_requests`, `reservation_number`)
- `guests` - Created during booking/checkout (columns: `user_id`, `first_name`, `last_name`, `email`, `phone`, etc.)
- `food_orders` - Created via restaurant ordering (columns: `reservation_id`, `room_id`, `order_type`, `items` JSONB, `total_amount`, `status`)
- `pos_transactions` - Created for restaurant orders (columns: `property_id`, `outlet_type`, `outlet_id`, `guest_id`, `room_id`, `total_amount`, `payment_status`)
- `pos_transaction_items` - Order line items (columns: `transaction_id`, `menu_item_id`, `quantity`, `unit_price`, `total_price`)
- `helpdesk_tickets` - Created via support portal (columns: `property_id`, `ticket_number`, `subject`, `description`, `category`, `priority`, `reported_by` (guest_id), `status`)

## Data Flow Architecture

### Public Data Fetching Layer

```
lib/
├── tenant/
│   └── resolveContext.ts  # Resolve slugs to tenant/property context with validation
└── domain/
    ├── public.ts          # Typed fetchers for public-safe reads (anon role)
    ├── guest.ts           # Typed fetchers/mutations for logged-in guests
    └── ordering.ts        # Ordering flow (restaurant, room service)
```

### Context Resolver (`src/lib/tenant/resolveContext.ts`)
```typescript
// Main resolver: brandSlug + propertySlug → full context
resolveContext({ brandSlug, propertySlug? }): Promise<ResolvedContext | null>

// Returns: { tenant, property, timezone, currency, theme }
```

**Validation Rules:**
- Tenant must exist and have `tenants.status = 'active'`
- Property must belong to tenant (`properties.tenant_id = tenant.id`) - CRITICAL CHECK
- Property must have `properties.status = 'active'`
- Property must have `properties.settings.public_portal_enabled != false` (if configured)

### Public Fetchers (`lib/domain/public.ts`)

All fetchers:
- Accept `ResolvedContext` (contains tenant + property info)
- Context already validated (property belongs to tenant)
- Use anon key (public client)
- Never return PII
- Cache results where safe (React Query)

**Key Functions:**
```typescript
// Tenant & Property
getBrandLanding(ctx: ResolvedContext): Promise<TenantPublicInfo>
getPropertyLanding(ctx: ResolvedContext): Promise<PropertyPublicInfo>

// Rooms
listRoomTypes(ctx: ResolvedContext, filters?: RoomFilters): Promise<RoomTypePublic[]>
getRoomTypeBySlug(ctx: ResolvedContext, slug: string): Promise<RoomTypePublic | null>
checkRoomAvailability(ctx: ResolvedContext, roomTypeId: string, checkIn: Date, checkOut: Date): Promise<AvailabilityResult>

// Restaurants
listRestaurants(ctx: ResolvedContext): Promise<RestaurantPublic[]>
getRestaurantBySlug(ctx: ResolvedContext, slug: string): Promise<RestaurantPublic | null>
getMenu(ctx: ResolvedContext, restaurantId: string): Promise<MenuItemPublic[]>
```

### Guest Portal Fetchers (`lib/domain/guest.ts`)

All fetchers:
- Require authenticated user
- Use authenticated Supabase client
- Filter by user's guest record
- Respect RLS policies

**Key Functions:**
```typescript
// Bookings
getGuestBookings(userId: string): Promise<Reservation[]>
getBookingById(bookingId: string, userId: string): Promise<Reservation | null>
updateBooking(bookingId: string, userId: string, updates: Partial<Reservation>): Promise<void>
cancelBooking(bookingId: string, userId: string): Promise<void>

// Folio
getGuestFolio(reservationId: string, userId: string): Promise<FolioItem[]>
downloadInvoice(invoiceId: string, userId: string): Promise<Blob>

// Requests
getGuestRequests(userId: string): Promise<ServiceRequest[]>
createServiceRequest(userId: string, request: CreateRequestInput): Promise<string>

// Messages
getGuestMessages(userId: string): Promise<Message[]>
sendMessage(userId: string, message: SendMessageInput): Promise<void>
```

### Ordering Flow (`lib/domain/ordering.ts`)

**Restaurant Ordering:**
```typescript
createRestaurantOrder(
  propertyId: string,
  restaurantId: string,
  order: OrderInput,
  idempotencyKey: string
): Promise<OrderResult>
```

**Validation:**
- Restaurant must belong to property
- Menu items must be available
- Idempotency key prevents duplicate orders
- Writes to `pos_transactions` and `pos_transaction_items` tables

## RLS Policy Strategy

### Public Read Policies (anon role)

```sql
-- Tenants (public info only)
CREATE POLICY "Public can view active tenants"
ON public.tenants FOR SELECT
TO anon
USING (status = 'active');

-- Properties (public info only, no PII)
CREATE POLICY "Public can view active properties"
ON public.properties FOR SELECT
TO anon
USING (status = 'active' AND (settings->>'public_portal_enabled')::boolean = true);

-- Room Types (property-scoped)
CREATE POLICY "Public can view room types for active properties"
ON public.room_types FOR SELECT
TO anon
USING (
  EXISTS (
    SELECT 1 FROM public.properties
    WHERE properties.id = room_types.property_id
    AND properties.status = 'active'
    AND (properties.settings->>'public_portal_enabled')::boolean = true
  )
);

-- Restaurants (property-scoped)
CREATE POLICY "Public can view restaurants for active properties"
ON public.restaurants FOR SELECT
TO anon
USING (
  status = 'active'
  AND EXISTS (
    SELECT 1 FROM public.properties
    WHERE properties.id = restaurants.property_id
    AND properties.status = 'active'
    AND (properties.settings->>'public_portal_enabled')::boolean = true
  )
);

-- Menu Items (restaurant-scoped)
CREATE POLICY "Public can view menu items for active restaurants"
ON public.menu_items FOR SELECT
TO anon
USING (
  is_available = true
  AND EXISTS (
    SELECT 1 FROM public.restaurants
    WHERE restaurants.id = menu_items.restaurant_id
    AND restaurants.status = 'active'
    AND EXISTS (
      SELECT 1 FROM public.properties
      WHERE properties.id = restaurants.property_id
      AND properties.status = 'active'
    )
  )
);
```

### Public Write Policies (anon role)

```sql
-- Guest creation (minimal PII for booking)
CREATE POLICY "Public can create guests for bookings"
ON public.guests FOR INSERT
TO anon
WITH CHECK (true);

-- Reservation creation (property-scoped)
CREATE POLICY "Public can create reservations for active properties"
ON public.reservations FOR INSERT
TO anon
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.properties
    WHERE properties.id = reservations.property_id
    AND properties.status = 'active'
  )
);

-- Restaurant orders (property-scoped)
CREATE POLICY "Public can create restaurant orders"
ON public.pos_transactions FOR INSERT
TO anon
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.properties
    WHERE properties.id = pos_transactions.property_id
    AND properties.status = 'active'
  )
);
```

### Authenticated Guest Policies

```sql
-- Guests can view their own records
CREATE POLICY "Guests can view own profile"
ON public.guests FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Reservations (own + property-scoped)
CREATE POLICY "Guests can view own reservations"
ON public.reservations FOR SELECT
TO authenticated
USING (
  guest_id IN (SELECT id FROM public.guests WHERE user_id = auth.uid())
);

-- Folio (own reservations)
CREATE POLICY "Guests can view own folio"
ON public.invoices FOR SELECT
TO authenticated
USING (
  reservation_id IN (
    SELECT id FROM public.reservations
    WHERE guest_id IN (SELECT id FROM public.guests WHERE user_id = auth.uid())
  )
);
```

## Rate Limiting & Abuse Prevention

### Strategy
1. **Client-side throttling**: Debounce search inputs, disable buttons after submit
2. **Server-side rate limiting**: Use Supabase Edge Functions or middleware
3. **Idempotency keys**: Required for all write operations
4. **CAPTCHA**: Only if abuse detected (not by default)

### Implementation
- Rate limit: 100 requests/minute per IP for public endpoints
- Idempotency: Store in `idempotency_keys` table (key, operation, result, expires_at)
- Bot mitigation: Check User-Agent, referrer validation

## Component Structure

```
src/
├── pages/
│   ├── public/
│   │   ├── TenantLanding.tsx
│   │   ├── PropertyLanding.tsx
│   │   ├── RoomsListing.tsx
│   │   ├── RoomTypeDetail.tsx
│   │   ├── RestaurantListing.tsx
│   │   ├── RestaurantDetail.tsx
│   │   ├── BookingFlow.tsx
│   │   └── OrderFlow.tsx
│   └── account/
│       ├── GuestDashboard.tsx
│       ├── Bookings.tsx
│       ├── CheckIn.tsx
│       ├── Folio.tsx
│       ├── Requests.tsx
│       └── Messages.tsx
├── lib/
│   └── domain/
│       ├── slug-resolver.ts
│       ├── public.ts
│       ├── guest.ts
│       └── ordering.ts
└── components/
    └── public/
        ├── RoomCard.tsx
        ├── AvailabilityWidget.tsx
        ├── MenuItemCard.tsx
        └── BookingForm.tsx
```

## Caching Strategy

### Public Data
- **Tenant/Property info**: Cache 5 minutes (ISR-like)
- **Room types**: Cache 10 minutes
- **Restaurant menus**: Cache 15 minutes
- **Availability**: No cache (real-time)

### Implementation
- Use React Query with appropriate `staleTime` and `cacheTime`
- Server-side: Use Supabase query caching where applicable

## Error Handling

### Public Pages
- **404**: Invalid slug → Show "Property not found"
- **403**: Property not public → Show "Property not available"
- **500**: Server error → Show generic error, log details

### Guest Portal
- **401**: Not authenticated → Redirect to login
- **403**: No access → Show "Access denied"
- **404**: Resource not found → Show "Not found"

## Testing Strategy

### Unit Tests
- Slug resolver validation logic
- Public fetcher tenant/property validation
- Guest fetcher user filtering

### Integration Tests
- End-to-end booking flow
- End-to-end ordering flow
- Guest portal workflows

### E2E Tests (Playwright)
- Public browsing flow
- Booking flow (guest checkout)
- Guest account flows

## Migration Plan

1. **Phase 1**: Add slug fields to tenants/properties (migration)
2. **Phase 2**: Implement slug resolver + public fetchers
3. **Phase 3**: Build public pages (tenant landing, property landing, rooms)
4. **Phase 4**: Implement booking flow
5. **Phase 5**: Implement restaurant ordering
6. **Phase 6**: Build guest portal pages
7. **Phase 7**: Add rate limiting + security hardening
8. **Phase 8**: Performance optimization + SEO

## Environment Variables

```env
# Existing
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...

# New (if needed)
VITE_PUBLIC_PORTAL_ENABLED=true
VITE_RATE_LIMIT_ENABLED=true
```

## Security Checklist

- [ ] All public endpoints use anon key only
- [ ] All authenticated endpoints use authenticated client
- [ ] RLS policies enforce tenant/property isolation
- [ ] No PII in public responses
- [ ] Rate limiting on public writes
- [ ] Idempotency keys for all writes
- [ ] Audit logging for write operations
- [ ] Input validation on all forms
- [ ] CSRF protection (Supabase handles this)
- [ ] XSS protection (React escapes by default)

## Performance Targets

- **Lighthouse Performance**: > 90
- **Lighthouse Accessibility**: > 95
- **Lighthouse SEO**: > 90
- **Time to Interactive**: < 3s
- **First Contentful Paint**: < 1.5s

## Future Enhancements

- Multi-language support (i18n)
- Advanced search/filtering
- Real-time availability updates
- Progressive Web App (PWA)
- Mobile app (React Native)
- Advanced analytics integration
- A/B testing framework

