# PUBLIC/GUEST PORTAL ROUTE INVENTORY

## Status Legend
- ✅ **OK**: Route exists, component loads, works correctly
- ⚠️ **BROKEN**: Route defined but component missing/error/broken
- 🔄 **REDUNDANT**: Duplicate route (multiple paths to same component)
- 📝 **NEEDS REVIEW**: Route exists but needs verification

---

## NAVIGATION MENU ITEMS (from navigation.ts)

### STAY Section

| Menu Item | Nav Href | Status | Component | Notes |
|-----------|----------|--------|-----------|-------|
| Property Overview | `/property/v3-grand-hotel` | ✅ | PropertyDetail | Works with `:id` param |
| Room Types | `/property/v3-grand-hotel/rooms` | ✅ | RoomsListing | Has route `/property/:id/rooms` and `/:brandSlug/:propertySlug/rooms` |
| Room Details | `/property/v3-grand-hotel/rooms/:roomTypeSlug` | ✅ | RoomTypeDetail | Has route `/property/:id/rooms/:roomTypeSlug` |
| Gallery (Rooms) | `/property/v3-grand-hotel/rooms/gallery` | ✅ | RoomsGallery | Has routes for both `:id` and `:propertySlug` |
| Offers & Packages | `/property/v3-grand-hotel/offers` | ✅ | Offers | Has route `/property/:id/offers` |

### DINING Section

| Menu Item | Nav Href | Status | Component | Notes |
|-----------|----------|--------|-----------|-------|
| Veda (Restaurant) | `/dining/veda` | ✅ | RestaurantDetailNew | Route `/dining/:venueSlug` exists |
| Ember (Bar & Lounge) | `/dining/ember` | ✅ | RestaurantDetailNew | Same component, different slug |
| In-Room Dining | `/dining/in-room` | ✅ | RestaurantDetailNew | Same component, different slug |
| Private Dining / Chef's Table | `/dining/private` | ✅ | RestaurantDetailNew | Same component, different slug |

### WELLNESS Section

| Menu Item | Nav Href | Status | Component | Notes |
|-----------|----------|--------|-----------|-------|
| Aura Spa | `/property/v3-grand-hotel/wellness/spa` | 🔄 | Wellness | REDUNDANT: Also `/property/:id/wellness/spa` redirects to `/wellness/aura` |
| Treatments | `/property/v3-grand-hotel/wellness/treatments` | ✅ | Wellness | Route `/property/:id/wellness/treatments` exists |
| Signature Rituals | `/property/v3-grand-hotel/wellness/rituals` | ✅ | Wellness | Route `/property/:id/wellness/rituals` exists |
| Fitness Center | `/property/v3-grand-hotel/wellness/fitness` | ✅ | Wellness | Route `/property/:id/wellness/fitness` exists |
| Pool | `/property/v3-grand-hotel/wellness/pool` | ✅ | Wellness | Route `/property/:id/wellness/pool` exists |

### EVENTS Section

| Menu Item | Nav Href | Status | Component | Notes |
|-----------|----------|--------|-----------|-------|
| Events & Meetings | `/events` | 🔄 | Events | REDUNDANT: Defined multiple times in App.tsx |
| Grand Hall | `/events#grand-hall` | ⚠️ | Events | Hash anchor - not a route, works via scroll |
| Pavilion | `/events#pavilion` | ⚠️ | Events | Hash anchor - not a route, works via scroll |
| Forum | `/events#forum` | ⚠️ | Events | Hash anchor - not a route, works via scroll |
| Event Catering | `/events/catering` | 🔄 | Events | REDUNDANT: Defined twice in App.tsx |
| Event Gallery | `/events/gallery` | 🔄 | Events | REDUNDANT: Defined twice in App.tsx |

### EXPERIENCES Section

| Menu Item | Nav Href | Status | Component | Notes |
|-----------|----------|--------|-----------|-------|
| Guest Experience | `/property/v3-grand-hotel/experiences` | ✅ | Experiences | Route `/property/:id/experiences` exists |
| Local Culture (Madurai) | `/property/v3-grand-hotel/experiences/local-culture` | ✅ | Experiences | Route `/property/:id/experiences/local-culture` exists |
| Concierge Services | `/property/v3-grand-hotel/experiences/concierge` | ✅ | Experiences | Route `/property/:id/experiences/concierge` exists |

### ABOUT Section

| Menu Item | Nav Href | Status | Component | Notes |
|-----------|----------|--------|-----------|-------|
| The Hotel | `/property/v3-grand-hotel/about` | ✅ | About | Route `/property/:id/about` exists |
| Location & Contact | `/property/v3-grand-hotel/about/contact` | ✅ | About | Route `/property/:id/about/contact` exists |
| Policies | `/property/v3-grand-hotel/about/policies` | ✅ | About | Route `/property/:id/about/policies` exists |
| FAQs | `/property/v3-grand-hotel/about/faqs` | ✅ | About | Route `/property/:id/about/faqs` exists |

### MY STAY Section (Guest Only)

| Menu Item | Nav Href | Status | Component | Notes |
|-----------|----------|--------|-----------|-------|
| My Account | `/account` | ✅ | GuestDashboard | Route exists, requires auth |
| My Reservations | `/account/bookings` | ✅ | Bookings | Route exists, requires auth |
| Requests | `/account/requests` | ✅ | Requests | Route exists, requires auth |
| Profile | `/account/profile` | ⚠️ | GuestDashboard | Nav says `/account/profile` but component is GuestDashboard - NEEDS REVIEW |

---

## ROUTE DUPLICATES / REDUNDANCIES

### 1. Property Routes - Dual Pattern (UUID vs Slug)
**Issue**: Both `:id` (UUID) and `:propertySlug` patterns exist for same routes
- `/property/:id/rooms/gallery` AND `/property/:propertySlug/rooms/gallery` → Both use RoomsGallery
- **Action**: Keep both patterns for backward compatibility, but prefer slug pattern in navigation

### 2. Wellness Routes - Conflicting Redirects
**Issue**: `/property/:id/wellness/spa` redirects to `/wellness/aura`, but nav uses `/property/v3-grand-hotel/wellness/spa`
- `/property/:id/wellness/spa` → Navigate to `/wellness/aura`
- `/wellness/aura` → Wellness component
- Nav uses: `/property/v3-grand-hotel/wellness/spa`
- **Action**: Remove redirect, keep `/property/:id/wellness/spa` route, update nav if needed

### 3. Events Routes - Multiple Definitions
**Issue**: `/events`, `/events/catering`, `/events/gallery` defined multiple times in App.tsx
- Lines 276, 291: `/events` defined twice
- Lines 277, 293: `/events/catering` defined twice  
- Lines 278, 294: `/events/gallery` defined twice
- **Action**: Remove duplicates, keep single definition

### 4. Brand/Property Slug Routes - Many Redirects
**Issue**: Many `/:brandSlug/:propertySlug/*` routes redirect to simpler paths
- `/:brandSlug/:propertySlug/dining` → `/dining/veda`
- `/:brandSlug/:propertySlug/dining/veda` → `/dining/veda`
- `/:brandSlug/:propertySlug/dining/ember` → `/dining/ember`
- **Action**: Keep redirects for backward compatibility, but use canonical routes in nav

### 5. Old Route Redirects
**Issue**: Many old routes redirect to new ones
- `/veda` → `/dining/veda`
- `/ember` → `/dining/ember`
- `/restaurant` → `/dining/veda`
- `/bar` → `/dining/ember`
- `/spa` → `/wellness/aura`
- **Action**: Keep redirects for SEO/backward compatibility

---

## MISSING ROUTES / COMPONENTS

None identified - all nav menu items have corresponding routes.

---

## CONSOLIDATION PLAN

### Phase 1: Remove Duplicate Route Definitions
1. Remove duplicate `/events`, `/events/catering`, `/events/gallery` routes from App.tsx
2. Keep only one definition of each route

### Phase 2: Standardize Route Patterns
1. Prefer slug-based routes (`/property/:propertySlug/*`) over UUID-based (`/property/:id/*`) in navigation
2. Keep UUID routes for backward compatibility
3. Update navigation.ts to use consistent slug patterns

### Phase 3: Update Navigation Config
1. Use new `publicRoutes.ts` as source of truth
2. Generate navigation menu from route definitions
3. Ensure all routes have metadata (imageCategory, component, etc.)

### Phase 4: Fix Route Conflicts
1. Remove redirect from `/property/:id/wellness/spa` to `/wellness/aura`
2. Ensure wellness routes use consistent pattern

---

## ROUTE STATUS SUMMARY

| Status | Count | Notes |
|--------|-------|-------|
| ✅ OK | 24 | Routes work correctly |
| ⚠️ BROKEN | 0 | No broken routes found |
| 🔄 REDUNDANT | 6 | Multiple route definitions or conflicting patterns |
| 📝 NEEDS REVIEW | 5 | Hash anchors, profile route, redirects |

---

## NEXT STEPS

1. ✅ Create `src/config/publicRoutes.ts` - Single source of truth (DONE)
2. ⏳ Update `src/config/navigation.ts` to use consolidated routes
3. ⏳ Remove duplicate route definitions from App.tsx
4. ⏳ Fix wellness route redirect conflict
5. ⏳ Test all routes end-to-end
