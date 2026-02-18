# Architecture: Public Portal vs HMS Portal

## Clear Separation of Concerns

### Public Landing Page (`/`)
**Purpose**: All guest-related front-end actions
**Audience**: Unauthenticated visitors and authenticated guests
**Scope**: Guest-facing booking, ordering, reservations

**Routes**:
- `/` - Home page
- `/property/:id` - Property detail
- `/booking/:propertyId` - Booking flow
- `/dining/:propertyId` - Restaurant listing
- `/dining/:propertyId/:outletSlug` - Restaurant detail
- `/dining/:propertyId/:outletSlug/order` - Restaurant order
- `/dining/:propertyId/:outletSlug/reserve` - Table reservation

**Features**:
- Browse properties and rooms
- Book rooms (create reservations)
- Order from restaurants
- Reserve restaurant tables
- View own bookings (when authenticated)

### Account Portal (`/account/*`)
**Purpose**: Authenticated guest self-service
**Audience**: Authenticated guests only
**Scope**: Own bookings, orders, preferences

**Routes**:
- `/account` - Guest dashboard
- `/account/bookings` - My bookings (view, cancel, modify)
- `/account/orders` - My restaurant orders
- `/account/reservations` - My table reservations
- `/account/preferences` - Guest preferences

**Features**:
- View own bookings with filters
- Cancel/modify bookings
- View order history
- Manage preferences
- Download confirmations

### HMS Portal (`/dashboard`, `/reservations`, etc.)
**Purpose**: Core HMS for back office and operations
**Audience**: Staff, managers, admins only
**Scope**: All reservations, all orders, analytics, operations

**Routes**:
- `/dashboard` - Staff dashboard
- `/reservations` - All reservations (staff view)
- `/restaurant` - Restaurant operations (POS, analytics)
- `/food-orders` - Food orders (room service)
- `/guests` - Guest management
- `/front-desk` - Front desk operations

**Features**:
- View all reservations (not just own)
- Create/edit/delete reservations
- Bulk operations
- Analytics and reporting
- POS transactions
- Staff management

## Data Flow

### Public Portal → Database
- Creates: `reservations`, `restaurant_orders`, `restaurant_reservation_requests`
- Reads: `public_properties`, `public_room_types`, `public_restaurant_outlets`
- RLS: Can only create own records, view public data

### Account Portal → Database
- Reads: Own `reservations`, `restaurant_orders`, `restaurant_reservation_requests`
- Updates: Own `reservations` (cancel/modify), `guests` (preferences)
- RLS: Can only access own records

### HMS Portal → Database
- Full CRUD: All `reservations`, `restaurant_orders`, `guests`, etc.
- Analytics: Aggregated data across all properties
- RLS: Staff/admin roles grant access to all records within property scope

## Component Reuse Strategy

### Shared Components (Public + Account)
- `BookingSummary.tsx` - Display booking details
- `OrderSummary.tsx` - Display order details
- `PaymentForm.tsx` - Payment processing
- `DatePicker.tsx` - Date selection

### Public-Only Components
- `PropertyCard.tsx` - Property listing
- `RoomTypeCard.tsx` - Room type display
- `RestaurantCard.tsx` - Restaurant listing

### Account-Only Components
- `BookingList.tsx` - List of own bookings
- `OrderHistory.tsx` - Order history
- `PreferencesForm.tsx` - Guest preferences

### Portal-Only Components
- `ReservationsTable.tsx` - All reservations table
- `RestaurantAnalytics.tsx` - Restaurant analytics
- `BulkOperations.tsx` - Bulk actions

## Hooks Strategy

### Public Hooks (`hooks/public/`)
- `usePublicProperty()` - Get public property data
- `usePublicRoomTypes()` - Get public room types
- `useCreatePublicReservation()` - Create reservation (guest)
- `useCreateRestaurantOrder()` - Create restaurant order (guest)

### Account Hooks (`hooks/account/`)
- `useGuestBookings()` - Get own bookings
- `useGuestOrders()` - Get own orders
- `useCancelBooking()` - Cancel own booking
- `useModifyBooking()` - Modify own booking

### Portal Hooks (`hooks/portal/` or existing)
- `useReservations()` - Get all reservations (staff)
- `useRestaurantTransactions()` - Get all transactions (staff)
- `useBulkOperations()` - Bulk operations (staff)

## Benefits

1. **Clear Mental Model**: Guests know where to go for their actions
2. **Security**: RLS ensures guests can only access their own data
3. **Maintainability**: Clear separation makes code easier to maintain
4. **Scalability**: Easy to add new guest-facing or staff-facing features
5. **User Experience**: Optimized UI for each audience

