# Policy Matrix: Public vs Internal Portal Actions

This document describes which actions are allowed in public mode vs internal mode, and the RBAC requirements for each.

## Portal Modes

- **Internal**: Admin/staff portal with full CRUD capabilities
- **Public**: Guest/public portal with read-only views and limited guest actions

## User Roles

- **super_admin**: Full access in internal mode
- **admin**: Full access in internal mode
- **general_manager**: Full access in internal mode
- **manager**: Limited admin access in internal mode
- **staff**: Read/write access in internal mode (role-specific)
- **guest**: Read-only + limited guest actions in public mode
- **anonymous**: Read-only in public mode

## Action Matrix

| Action Type | Internal Mode | Public Mode | Required Role | RLS Policy |
|------------|---------------|-------------|---------------|------------|
| **Property** |
| View properties | ✅ All roles | ✅ All users | - | `is_public = true` |
| Create property | ✅ Admin only | ❌ | `super_admin`, `admin` | RLS blocks |
| Update property | ✅ Admin only | ❌ | `super_admin`, `admin` | RLS blocks |
| Delete property | ✅ Admin only | ❌ | `super_admin`, `admin` | RLS blocks |
| **Room Types** |
| View room types | ✅ All roles | ✅ All users | - | `is_public = true` |
| Create room type | ✅ Admin only | ❌ | `super_admin`, `admin` | RLS blocks |
| Update room type | ✅ Admin only | ❌ | `super_admin`, `admin` | RLS blocks |
| Delete room type | ✅ Admin only | ❌ | `super_admin`, `admin` | RLS blocks |
| **Restaurants** |
| View restaurants | ✅ All roles | ✅ All users | - | `is_public = true` |
| View menu | ✅ All roles | ✅ All users | - | `is_public = true` |
| Create restaurant | ✅ Admin only | ❌ | `super_admin`, `admin` | RLS blocks |
| Update restaurant | ✅ Admin only | ❌ | `super_admin`, `admin` | RLS blocks |
| Place order | ✅ Staff | ✅ Guest | `staff` (internal), `guest` (public) | RLS allows insert |
| **Spa Services** |
| View spa services | ✅ All roles | ✅ All users | - | `is_available = true` |
| Create spa service | ✅ Admin only | ❌ | `super_admin`, `admin` | RLS blocks |
| Update spa service | ✅ Admin only | ❌ | `super_admin`, `admin` | RLS blocks |
| Book spa service | ✅ Staff | ✅ Guest | `staff` (internal), `guest` (public) | RLS allows insert (status: pending) |
| **Events** |
| View event venues | ✅ All roles | ✅ All users | - | Public data |
| View events | ✅ All roles | ✅ All users | - | `status IN ('planned', 'confirmed')` |
| Create event | ✅ Staff | ❌ | `staff` (internal) | RLS blocks (public) |
| Update event | ✅ Staff | ❌ | `staff` (internal) | RLS blocks (public) |
| Event inquiry | ✅ Staff | ✅ Guest | `staff` (internal), `guest` (public) | RLS allows insert (status: inquiry) |
| **Bookings** |
| View bookings | ✅ Staff | ✅ Guest (own only) | `staff` (internal), `guest` (public) | RLS filters by user |
| Create booking | ✅ Staff | ✅ Guest | `staff` (internal), `guest` (public) | RLS allows insert |
| Update booking | ✅ Staff | ✅ Guest (own only) | `staff` (internal), `guest` (public) | RLS filters by user |
| Cancel booking | ✅ Staff | ✅ Guest (own only) | `staff` (internal), `guest` (public) | RLS filters by user |
| **Inquiries** |
| Create inquiry | ✅ All roles | ✅ All users | - | RLS allows insert |
| View inquiries | ✅ Staff | ❌ | `staff` (internal) | RLS blocks (public) |

## Public Portal Restrictions

### Read-Only by Default
- All data views in public mode are read-only
- No direct update/delete operations from public portal
- All mutations go through safe RLS-protected inserts

### Allowed Guest Actions
1. **Inquiry**: Create inquiry/contact form submission
2. **Booking Request**: Create booking (goes through RLS)
3. **Newsletter**: Subscribe to newsletter
4. **Contact Form**: Submit contact form

### Blocked Actions
- All update operations (except own bookings via RLS)
- All delete operations
- Admin/staff-only CRUD operations
- Internal pricing controls
- Inventory management
- Staff management
- Financial operations

## RLS Policy Requirements

### Public Tables (Read Access)
- `properties` (where `is_public = true`)
- `room_types` (where `is_public = true`)
- `room_images` (public read)
- `restaurants` (where `is_public = true`)
- `restaurant_menu_categories` (where `is_public = true`)
- `restaurant_menu_items` (where `is_public = true`)
- `spa_services` (where `is_available = true`)
- `public_property_images` (public read)

### Protected Tables (Write Access)
- `reservations` (RLS: user can only insert/update own)
- `spa_bookings` (RLS: user can only insert/update own)
- `restaurant_orders` (RLS: user can only insert/update own)
- `events` (RLS: public can only insert with `status = 'inquiry'`)
- `public_inquiries` (RLS: public can insert)

### Admin-Only Tables (No Public Access)
- `staff`
- `user_roles`
- `pricing_rules`
- `inventory`
- `financial_transactions`
- `audit_logs`

## Implementation Notes

1. **Service Layer**: All data access goes through `src/services/data/*` services
2. **RLS Enforcement**: Supabase RLS is the source of truth - never bypass
3. **Mode Detection**: Use `useEngineContext()` hook to determine mode and role
4. **Config Filtering**: Use `filterConfigForMode()` to filter page configs
5. **Action Gating**: Use `isActionAllowed()` to check if action is permitted

## Testing

- Test anonymous user access (read-only)
- Test guest user access (read + limited write)
- Test staff user access (full CRUD in internal mode)
- Test admin user access (full CRUD in internal mode)
- Verify RLS policies block unauthorized access
- Verify public mode never exposes admin operations
