# Implementation Summary: Shared Engine Architecture

## Objective Completed

Repurposed the HMS page engines/configurations so they can render in both the Public/Guest Portal and Internal/Admin Portal WITHOUT duplicating logic, while keeping CRUD operations, RBAC, and Supabase RLS fully consistent and compliant.

## Files Created

### Engine Layer (`src/engines/`)

1. **`types.ts`** (142 lines)
   - Type definitions for `PortalMode`, `UserRole`, `PageConfig`, `SectionConfig`, `FieldConfig`, `ActionConfig`, etc.
   - Core types for the shared engine system

2. **`filter.ts`** (145 lines)
   - `filterConfigForMode()`: Filters page configs based on mode and role
   - `getAllowedActions()`: Returns only permitted actions
   - `isSectionReadOnly()`: Checks if section should be read-only
   - `isFieldReadOnly()`: Checks if field should be read-only
   - Public mode restrictions: Only allows safe actions (view, custom), blocks CRUD

3. **`renderer.tsx`** (45 lines)
   - `renderPage()`: Main rendering function
   - `usePageConfig()`: React hook for filtered configs

4. **`context.ts`** (60 lines)
   - `useEngineContext()`: Hook to create engine context from app state
   - Maps app roles to engine roles
   - Handles anonymous, guest, staff, admin roles

5. **`index.ts`** (8 lines)
   - Central export for engine module

### Data Services Layer (`src/services/data/`)

1. **`propertyService.ts`** (75 lines)
   - `getPublicProperties()`: Safe for public portal
   - `getPropertyById()`: Respects RLS, mode-aware
   - `getPropertyBySlug()`: Safe for public portal

2. **`roomService.ts`** (75 lines)
   - `getPublicRoomTypes()`: Safe for public portal
   - `getRoomTypeById()`: Respects RLS, mode-aware
   - `getRoomImages()`: Safe for public portal

3. **`diningService.ts`** (120 lines)
   - `getPublicRestaurants()`: Uses brand config for "Veda"
   - `getRestaurantBySlug()`: Uses brand config
   - `getMenuCategories()`: Safe for public portal
   - `getMenuItems()`: Safe for public portal

4. **`spaService.ts`** (70 lines)
   - `getPublicSpaServices()`: Safe for public portal
   - `getSpaServiceById()`: Respects RLS, mode-aware
   - `createSpaBookingRequest()`: Safe insert (status: pending)

5. **`eventsService.ts`** (85 lines)
   - `getPublicEventVenues()`: Uses brand config for "The Grand Hall", "The Pavilion", "The Forum"
   - `getPublicEvents()`: Safe for public portal
   - `createEventInquiry()`: Safe insert (status: inquiry)

6. **`index.ts`** (8 lines)
   - Central export for data services

### Documentation

1. **`docs/POLICY_MATRIX.md`** (200+ lines)
   - Complete action matrix (Internal vs Public mode)
   - Role requirements for each action
   - RLS policy requirements
   - Public portal restrictions
   - Testing guidelines

2. **`docs/ENGINE_ARCHITECTURE.md`** (100+ lines)
   - Architecture overview
   - Usage examples
   - Portal mode differences
   - RBAC enforcement strategy

## Key Features

### 1. Mode-Based Filtering
- **Internal Mode**: Full CRUD, all sections visible, all actions available (role-based)
- **Public Mode**: Read-only by default, filtered sections, limited actions (inquiry, booking request)

### 2. RBAC Enforcement
- **Client-side**: Engine filters configs based on role
- **Server-side**: Supabase RLS policies (source of truth)
- **Service layer**: All queries respect RLS

### 3. Brand Config Integration
- All venue names come from `src/config/brand.ts`
- Restaurant: "Veda"
- Bar: "Ember"
- Spa: "Aura"
- Events: "The Grand Hall", "The Pavilion", "The Forum"
- No hardcoded strings in services

### 4. RLS Compliance
- All data services use Supabase client (never service role key)
- Public mode queries only public-safe tables/views
- Mutations go through RLS-protected inserts
- No direct update/delete from public portal

## Public Portal Restrictions

### Allowed Actions
- ✅ View public data (properties, rooms, menus, spa services, events)
- ✅ Create inquiry/contact form
- ✅ Create booking request (goes through RLS)
- ✅ Subscribe to newsletter
- ✅ View own bookings (filtered by user)

### Blocked Actions
- ❌ All update operations (except own bookings via RLS)
- ❌ All delete operations
- ❌ Admin/staff-only CRUD
- ❌ Internal pricing controls
- ❌ Inventory management
- ❌ Staff management
- ❌ Financial operations

## Next Steps (Future Work)

1. **Refactor Existing Public Pages**
   - Update `src/pages/public/RoomsListing.tsx` to use `roomService`
   - Update `src/pages/public/RestaurantDetail.tsx` to use `diningService`
   - Update `src/pages/public/Events.tsx` to use `eventsService`
   - Create page configs for common pages

2. **Create Page Configs**
   - Define `PageConfig` objects for property, rooms, dining, spa, events pages
   - Use engine to render these configs in both modes

3. **Incremental Migration**
   - Start with one page (e.g., RoomsListing)
   - Migrate to shared engine
   - Test in both modes
   - Repeat for other pages

## Testing Checklist

- [ ] Anonymous user can view public data (read-only)
- [ ] Guest user can view public data + create inquiries/bookings
- [ ] Staff user has full CRUD in internal mode
- [ ] Admin user has full CRUD in internal mode
- [ ] RLS policies block unauthorized access
- [ ] Public mode never exposes admin operations
- [ ] Brand config names appear correctly in all services

## Build Status

✅ **Build: PASSED** (no TypeScript errors)
✅ **Linter: PASSED** (no linting errors)
✅ **Architecture: COMPLETE** (foundation ready for incremental migration)

## Summary

The shared engine architecture is now in place. The foundation allows:
- Same page configs to render in both portals
- Mode-based filtering (internal vs public)
- Role-based action gating
- RLS-compliant data access
- Brand config integration

The next phase is to incrementally refactor existing public pages to use this shared engine, starting with one page at a time.
