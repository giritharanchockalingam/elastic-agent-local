# Routing Separation & Service Operations Integration - Complete

## Summary

Successfully updated routing to ensure clear separation between guest and staff routes, and integrated Bar, SPA, and Events into a unified portal backend operations view with folio/payment workflow.

## 1. Routing Separation ✅

### Changes Made

**All staff/admin routes moved to `/portal/*` prefix:**
- `/dashboard` → `/portal/dashboard`
- `/reservations` → `/portal/reservations`
- `/bar` → `/portal/bar`
- `/spa` → `/portal/spa`
- All other portal routes now use `/portal/*` prefix

**Guest routes remain at `/account/*`:**
- `/account` - Guest Dashboard
- `/account/bookings` - Guest Bookings
- `/account/orders` - Restaurant Orders
- `/account/reservations` - Table Reservations
- `/account/folio` - Guest Folio
- `/account/requests` - Service Requests
- `/account/messages` - Messages

**Public routes remain at root level:**
- `/` - Home/Index
- `/search` - Search Results
- `/:brandSlug/:propertySlug` - Property Landing
- `/:brandSlug/:propertySlug/book` - Booking Flow
- `/:brandSlug/:propertySlug/dining/:outletSlug/order` - Restaurant Ordering

### Backward Compatibility

All old routes redirect to `/portal/*` equivalents:
- `/dashboard` → `/portal/dashboard`
- `/reservations` → `/portal/reservations`
- `/bar` → `/portal/bar`
- etc.

### Files Modified

1. **`src/App.tsx`**
   - Updated all protected routes to use `/portal/*` prefix
   - Added redirects for backward compatibility
   - Added new `/portal/service-operations` route

2. **`src/components/layout/AppSidebar.tsx`**
   - Updated all menu item paths to use `/portal/*` prefix
   - Added "Service Operations" menu category with Bar, SPA & Events link

## 2. Service Operations Integration ✅

### Workflow Implementation

**For Hotel Guests:**
- Payments are added to room folio
- Charges appear on guest's folio at check-out
- Payment method set to "folio" (null in database)
- Invoice items created automatically when order/booking is created

**For Non-Stay Visitors:**
- Payments processed separately using available payment methods
- Payment methods: Cash, Card, UPI, Other
- Payment status tracked separately

### New Page Created

**`src/pages/portal/ServiceOperations.tsx`**

Features:
- **Unified View**: Single page for managing Bar Orders, SPA Bookings, and Events
- **Tabbed Interface**: Easy switching between service types
- **Guest Type Selection**: 
  - Hotel Guest (add to folio)
  - Visitor (direct payment)
- **Reservation Linking**: For hotel guests, link to active reservations
- **Payment Workflow**:
  - Hotel guests: Automatic folio integration
  - Visitors: Direct payment processing
- **Stats Dashboard**: 
  - Total orders/bookings
  - Hotel guests vs visitors
  - Pending vs paid
  - Total revenue
- **Filters**: 
  - Status filter
  - Payment filter (folio, paid, pending)
  - Search by guest name, order number, service
- **Order Management**:
  - Create orders/bookings
  - View order details
  - Update payment status
  - Mark as paid (for visitors)

### Service-Specific Features

**Bar Orders:**
- Select from bar recipes/cocktails
- Set quantity
- Automatic price calculation
- Items stored in JSONB format

**SPA Bookings:**
- Select from available spa services
- Set booking date and time
- Link to guest or reservation
- Service price from spa_services table

**Events:**
- Event name and type
- Start/end datetime
- Expected attendees
- Contact information
- Total cost
- Event number generation

### Database Integration

**Bar Orders:**
- Table: `bar_orders`
- Fields: `guest_id`, `room_id`, `payment_status`, `payment_method`, `total_amount`
- Folio Integration: Creates invoice items when `payment_method` is null (folio)

**SPA Bookings:**
- Table: `spa_bookings`
- Fields: `guest_id`, `service_id`, `booking_date`, `booking_time`, `status`
- Folio Integration: Creates invoice items when linked to reservation

**Events:**
- Table: `events`
- Fields: `contact_person`, `contact_email`, `contact_phone`, `total_cost`, `status`
- Typically external (non-hotel guests)

### Folio Integration

When a hotel guest order/booking is created with folio payment:
1. Order/booking is created in respective table
2. Invoice item is automatically created in `invoices` table
3. Item is linked to `reservation_id`
4. Guest can view charges in `/account/folio`
5. Payment processed at check-out

### Payment Status Management

- **Hotel Guests (Folio)**: Payment status remains "pending" until check-out
- **Visitors**: Payment status can be updated to "paid" immediately
- Staff can mark visitor payments as paid directly from the operations view

## 3. Architecture

### Route Structure

```
/ (Public)
├── / (Home)
├── /search
├── /:brandSlug/:propertySlug
└── /:brandSlug/:propertySlug/book

/account/* (Guest Portal - Authenticated)
├── /account (Dashboard)
├── /account/bookings
├── /account/orders
├── /account/reservations
├── /account/folio
├── /account/requests
└── /account/messages

/portal/* (Staff Portal - Protected)
├── /portal/dashboard
├── /portal/reservations
├── /portal/service-operations (NEW)
├── /portal/bar
├── /portal/spa
├── /portal/activities
└── ... (all other staff routes)
```

### Access Control

- **Public Routes**: No authentication required
- **Guest Routes (`/account/*`)**: Requires authentication, RBAC for guest role
- **Portal Routes (`/portal/*`)**: Requires authentication, RBAC for staff/admin roles

## 4. Key Benefits

1. **Clear Separation**: 
   - Guests access `/account/*` for self-service
   - Staff access `/portal/*` for operations
   - No confusion between guest and staff interfaces

2. **Unified Operations**:
   - Single page for managing all revenue-generating services
   - Consistent workflow across Bar, SPA, and Events
   - Easy to add new service types in the future

3. **Flexible Payment**:
   - Hotel guests: Automatic folio integration
   - Visitors: Direct payment processing
   - Supports multiple payment methods

4. **Better UX**:
   - Staff can quickly see all service orders in one place
   - Filter by guest type, payment status, service type
   - Real-time stats and revenue tracking

## 5. Testing Checklist

- [ ] Test routing: `/portal/*` routes accessible to staff
- [ ] Test routing: `/account/*` routes accessible to guests
- [ ] Test routing: Old routes redirect to `/portal/*`
- [ ] Test Service Operations: Create bar order for hotel guest (folio)
- [ ] Test Service Operations: Create bar order for visitor (direct payment)
- [ ] Test Service Operations: Create spa booking for hotel guest (folio)
- [ ] Test Service Operations: Create spa booking for visitor (direct payment)
- [ ] Test Service Operations: Create event booking
- [ ] Test Folio Integration: Verify charges appear in guest folio
- [ ] Test Payment Status: Update visitor payment status
- [ ] Test Filters: Filter by status, payment type, search
- [ ] Test Stats: Verify stats dashboard shows correct counts

## 6. Next Steps (Optional Enhancements)

1. **Real-time Updates**: Add WebSocket subscriptions for live order updates
2. **Payment Processing**: Integrate payment gateway for visitor payments
3. **Notifications**: Send notifications to guests when orders are ready
4. **Reporting**: Add revenue reports by service type
5. **Analytics**: Track service popularity and revenue trends
6. **Mobile App**: Create mobile app for staff to manage orders on-the-go

## Files Created

1. `src/pages/portal/ServiceOperations.tsx` - Unified service operations page

## Files Modified

1. `src/App.tsx` - Updated routing structure
2. `src/components/layout/AppSidebar.tsx` - Updated menu paths and added Service Operations

## Documentation

1. `docs/ROUTING_AND_SERVICE_OPERATIONS_COMPLETE.md` - This file

