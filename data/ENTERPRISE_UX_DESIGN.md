# Enterprise SaaS UX Design - HMS Portal

**Version:** 1.0  
**Date:** 2025-01-XX  
**Status:** Implementation-Ready Design Specification

---

## Table of Contents

1. [Enterprise UX Flows (Multi-tenant, Multi-role)](#1-enterprise-ux-flows-multi-tenant-multi-role)
2. [Wireframes & Page Structure (SaaS-ready)](#2-wireframes--page-structure-saas-ready)
3. [Component Hierarchy, Contracts, and Reuse](#3-component-hierarchy-contracts-and-reuse)
4. [State & UX Models (Hardened)](#4-state--ux-models-hardened)
5. [Observability, Analytics, and Audit UX](#5-observability-analytics-and-audit-ux)

---

## 1. Enterprise UX Flows (Multi-tenant, Multi-role)

### 1.1 Hotel Guest (Visitor) Flow

**Context:** `[Tenant: Hotel Group A] [Role: Visitor] [State: Anonymous]`

#### Primary Happy Path

```
[Tenant Brand Landing] 
  → User sees tenant branding (logo, colors, featured properties)
  → Primary CTA: "Find Your Perfect Stay"
  → Secondary CTAs: Browse properties, View offers, Learn more

[Property Selection / Search]
  → User selects property from list OR uses search bar
  → Context: tenantId is resolved from URL slug (brandSlug)
  → Property list filtered by tenant boundary (RLS enforced)

[Property Landing]
  → Display property details (images, amenities, location)
  → Date & Guest Selector (check-in, check-out, adults, children)
  → Availability check performed (real-time, no cache)
  → Primary CTA: "Check Availability"

[Search Results / Room Listing]
  → Filtered rooms based on dates/guests
  → Each room card shows: images, name, description, amenities, price, availability badge
  → Filters panel: price range, room type, amenities, bed type
  → Sorting: price (low-high, high-low), popularity, rating
  → State: BROWSING

[Room Detail View]
  → User clicks on room card
  → Full room details: gallery, amenities list, policies, reviews
  → Real-time availability status (Available / Limited / Sold Out)
  → Pricing breakdown: base rate, taxes, fees, total
  → Minimum stay rules displayed
  → Primary CTA: "Book This Room"
  → State: SELECTING_ROOM

[Booking Flow - Step 1: Guest Details]
  → Guest information form (if not logged in)
  → Fields: first name, last name, email, phone, special requests
  → Optional: "Create account" checkbox (pre-checked)
  → Continue button (validation: email format, required fields)
  → State: FILLING_GUEST_DETAILS

[Booking Flow - Step 2: Review & Payment]
  → Booking summary card: dates, room, guests, pricing breakdown
  → Terms & conditions checkbox (required)
  → Cancellation policy summary
  → Payment method selector (credit card, debit card, wallet)
  → Payment form (PCI-compliant, tokenized)
  → "Complete Booking" button
  → State: REVIEWING → PAYMENT_IN_PROGRESS

[Booking Confirmation]
  → Success message with booking reference number
  → Booking details card (downloadable PDF)
  → Email confirmation sent notification
  → Primary CTA: "View My Bookings" (if authenticated) or "Create Account"
  → State: CONFIRMED

[Post-Booking Actions]
  → Add to calendar (iCal download)
  → Share booking link
  → Modify booking (if policy allows)
  → Cancel booking (if policy allows)
```

#### Alternate Paths & Error Handling

**No Results / Sold Out:**
```
[Search Results] → No rooms available
  → Empty state illustration
  → Message: "No rooms available for selected dates"
  → Suggestions: modify dates, view alternative properties
  → "Modify Search" button → Returns to date selector
```

**Price Changes During Flow:**
```
[Review Step] → Price validation check (before payment)
  → If price changed: show notification banner
  → Display: "Price updated: Previous $X → New $Y"
  → Require user acknowledgment ("Accept new price" checkbox)
  → If user declines: redirect to room selection with updated prices
```

**Payment Failure:**
```
[Payment Step] → Payment declined
  → Error message (non-technical): "Payment could not be processed"
  → Show payment form with error highlight
  → Retry button (max 3 attempts)
  → Alternative payment methods offered
  → "Contact Support" link with booking reference
  → State: PAYMENT_FAILED
```

**Session Expiration:**
```
[Any Step] → Session timeout detected
  → Modal dialog: "Your session has expired"
  → Options: "Extend Session" (if < 5 min expired) or "Start Over"
  → If extended: preserve booking data (stored in localStorage with expiration)
  → If start over: clear booking data, redirect to property landing
  → State: EXPIRED
```

**Network Error / Timeout:**
```
[Any Step] → Network request fails
  → Toast notification: "Connection issue. Retrying..."
  → Auto-retry (exponential backoff, max 3 attempts)
  → If fails: show "Unable to connect" error
  → "Try Again" button (retries from last successful step)
  → "Save Progress" button (saves to localStorage, email link sent)
```

**Rate Limiting:**
```
[Search / Availability Check] → Rate limit exceeded
  → Toast: "Too many requests. Please wait a moment."
  → Disable search button for 60 seconds (countdown shown)
  → No CAPTCHA required (unless abuse pattern detected)
```

---

### 1.2 Restaurant Guest (Visitor) Flow

**Context:** `[Tenant: Restaurant Brand B] [Role: Visitor] [State: Anonymous]`

#### Primary Happy Path

```
[Tenant Brand Landing / Restaurant Listing]
  → Display tenant restaurants (if multiple) OR single restaurant
  → Service mode selector: "Dine In" | "Takeaway" | "Delivery" (if enabled)
  → Each restaurant card: image, name, cuisine type, rating, opening hours
  → Primary CTA: "View Menu" or "Order Now"

[Restaurant Detail / Menu]
  → Restaurant info: hours, location, contact, dietary options (vegan, gluten-free)
  → Menu categories: Appetizers, Main Courses, Desserts, Beverages, etc.
  → Each menu item card: image, name, description, price, dietary tags, allergen info (expandable)
  → Availability badge (Available / Limited / Sold Out - real-time)
  → Cart icon in header (shows item count)
  → State: BROWSING_MENU

[Add Item to Cart]
  → User clicks "Add to Cart" on menu item
  → Customization modal opens (if item has options)
  → Options: size, add-ons, special instructions, quantity
  → "Add to Cart" button (item added, modal closes)
  → Toast notification: "Item added to cart"
  → Cart sidebar updates (quantity badge increments)
  → State: BUILDING_ORDER

[Cart Review]
  → User clicks cart icon
  → Cart sidebar slides in from right
  → Cart contents: items, quantities, prices, customization notes
  → Subtotal, tax, service charge (if applicable), total
  → Tip selector (if enabled for tenant)
  → "Review Order" button

[Order Review & Time Selection]
  → Full order summary
  → For Dine In: Table reservation time picker (available slots)
  → For Takeaway: Pickup time selector (next available slots)
  → For Delivery: Delivery address form + time selector
  → Contact information (pre-filled if logged in)
  → Special instructions textarea
  → "Place Order" button
  → State: SUBMITTING_ORDER → WAITING_CONFIRMATION

[Order Confirmation]
  → Success message with order number
  → Order details card (items, total, time)
  → Real-time status tracking link (if authenticated)
  → SMS/Email confirmation sent notification
  → State: CONFIRMED → IN_PREPARATION (real-time updates)

[Order Status Updates (Real-time)]
  → Status badges: Confirmed → In Preparation → Ready → Served/Delivered
  → Estimated ready time countdown
  → For dine-in: "Your table is ready" notification
  → For takeaway: "Your order is ready for pickup" notification
  → For delivery: "Your order is out for delivery" + tracking link
```

#### Alternate Paths & Error Handling

**Item Availability Changes:**
```
[Menu View] → Item becomes unavailable mid-session
  → Real-time update: item card shows "Sold Out" badge
  → If item in cart: notification banner in cart
  → "Item no longer available" message
  → Remove button auto-highlighted
  → User must remove before proceeding
```

**Menu Item Unavailable at Checkout:**
```
[Order Review] → Validation check before submission
  → If any item unavailable: error banner
  → List unavailable items
  → "Remove Unavailable Items" button
  → Update cart, recalculate total
  → User can proceed with updated cart
```

**Time Slot Unavailable:**
```
[Time Selection] → Selected slot becomes unavailable
  → Toast: "This time slot is no longer available"
  → Time picker refreshes (unavailable slots grayed out)
  → User selects new slot
  → Cart preserved, order continues
```

**Order Submission Failure:**
```
[Submit Order] → API error / timeout
  → Error message: "Unable to place order. Please try again."
  → Retry button (with idempotency key to prevent duplicates)
  → Cart preserved
  → "Contact Restaurant" link with order details
```

**Allergen Information:**
```
[Menu Item Detail] → Allergen disclosure
  → Expandable "Allergen Information" section
  → List allergens: Contains: Nuts, Dairy, Gluten, etc.
  → Disclaimer: "Please inform staff of allergies"
  → Dietary tags visible on card (vegan, vegetarian, gluten-free)
```

---

### 1.3 Visitor → Authenticated User Transition

**Context:** `[Tenant: Any] [Role: Visitor → Guest] [State: Anonymous → Authenticated]`

#### Anonymous Session with Active Cart/Booking

```
[During Booking/Order Flow] → User clicks "Sign In" or "Create Account"
  → Modal dialog opens (doesn't interrupt flow)
  → Tabs: "Sign In" | "Sign Up" | "Continue as Guest"

[Sign In Flow]
  → Email/password form OR SSO buttons (Google, Apple, configured providers)
  → If SSO: redirect to provider → callback → return to modal
  → Loading state: "Signing you in..."
  → On success: modal closes

[Sign Up Flow]
  → Email, password, confirm password
  → Terms acceptance checkbox
  → Optional: phone number, marketing preferences
  → "Create Account" button
  → Email verification sent (if required by tenant)
  → On success: modal closes, user authenticated

[Session Merge Process]
  → Backend detects: anonymous session ID + authenticated user ID
  → Merge logic:
    1. Anonymous cart/booking data retrieved (by session UUID/cookie)
    2. Check tenant boundaries (ensure data belongs to same tenant)
    3. Merge into user profile (guest record created/linked)
    4. Preserve in-progress state (booking step, cart contents)
    5. Clear anonymous session data
  → Frontend: seamless transition (no page reload)
  → Toast: "Welcome back! Your booking/order has been saved."

[Cross-Tenant Protection]
  → If user tries to merge data from different tenant:
    1. Detect tenant mismatch
    2. Clear anonymous session data
    3. Show notification: "Your session has been cleared for security."
    4. User starts fresh with authenticated session
  → Audit log: cross-tenant merge attempt logged (for security monitoring)

[Preserve Context]
  → After merge: redirect to exact step user was on
  → Booking flow: return to current step (guest details, payment, etc.)
  → Order flow: return to cart with all items intact
  → URL parameters preserved (property, dates, etc.)
```

#### Authentication States

```
[ANONYMOUS]
  → Session: UUID in cookie/localStorage
  → Data stored: cart, booking progress, recent searches (tenant-scoped)
  → Expiration: 7 days (configurable per tenant)

[AUTH_PENDING]
  → User clicked "Sign In" but hasn't completed
  → Modal open, loading states
  → Timeout: 5 minutes (then revert to ANONYMOUS)

[AUTHENTICATED]
  → User has valid session token
  → Guest record exists (linked to user_id)
  → Data stored: user profile, preferences, booking history
  → Session expiration: 30 days (configurable, with refresh token)

[SESSION_EXPIRED]
  → Token expired but refresh available
  → Auto-refresh attempt (silent)
  → If refresh fails: show "Session expired" dialog
  → User can extend or re-authenticate
  → Unsaved work preserved where possible

[IMPERSONATION] (Admin/Support only)
  → Staff member impersonates guest (for support)
  → Banner: "You are viewing as [Guest Name]"
  → All actions logged with staff ID + guest ID
  → "Exit Impersonation" button (always visible)
  → Time-limited: auto-exit after 1 hour
  → Audit log entry created on enter/exit
```

---

### 1.4 Backoffice Staff Flow (Hotel + Restaurant)

**Context:** `[Tenant: Hotel Group A] [Role: Front Desk Agent] [State: Authenticated]`

#### Staff Login & Dashboard

```
[Staff Login]
  → Tenant-scoped login (tenant selector if user belongs to multiple)
  → Email/password OR SSO (if configured)
  → MFA verification (if required by tenant policy)
  → Role-based redirect:
     - Front Desk → /front-desk/dashboard
     - F&B → /restaurant/dashboard
     - Reservations → /reservations/dashboard

[Role-Based Dashboard - Front Desk]
  → Today's Arrivals (count, list)
  → Today's Departures (count, list)
  → In-House Guests (current count)
  → Pending Check-ins (overdue, requiring attention)
  → Room Status Summary (available, occupied, out-of-order)
  → Quick Actions: New Booking, Check-in, Check-out, Guest Lookup

[Role-Based Dashboard - F&B / Restaurant]
  → Today's Reservations (count, upcoming slots)
  → Active Orders (in-progress, ready for pickup)
  → Table Status (occupied, available, reserved)
  → Revenue Today (current vs. target)
  → Quick Actions: New Order, New Reservation, Menu Update
```

#### View & Manage Reservations

```
[Reservations List]
  → Filter bar: dates, status, room type, guest name
  → Sort: check-in date, booking date, total amount
  → Table columns: guest name, room, check-in, check-out, status, actions
  → Permission check: user has 'view_reservations' permission

[Reservation Detail]
  → Full guest information (name, contact, preferences)
  → Booking details (dates, room type, guests, special requests)
  → Payment information (deposit, balance, payment method)
  → Folio summary (charges, payments, balance)
  → Timeline: booking created, modified, check-in, check-out
  → Actions menu: Modify, Check-in, Check-out, Cancel, Send Message

[Modify Booking]
  → Permission check: user has 'modify_reservations' permission
  → Editable fields: dates, room, guests, special requests
  → Price recalculation (if dates/room changed)
  → Validation: room availability, minimum stay rules
  → If concurrent edit detected: show conflict dialog
     - "Another user modified this booking. View changes?"
     - Options: "Overwrite" (with warning) or "Refresh & Edit"
  → On save: audit log entry (who, when, what changed, before/after)
  → Email notification to guest (if enabled)

[Check-in Flow]
  → Permission check: 'view_check_in_out' permission
  → Verify guest identity (ID scan, manual entry)
  → Confirm room assignment
  → Collect payment (if balance due)
  → Issue room keys (if integrated)
  → Update reservation status: CONFIRMED → CHECKED_IN
  → Room status: AVAILABLE → OCCUPIED
  → Trigger: welcome email/SMS, housekeeping notification
  → Audit log: check-in timestamp, staff ID, payment details

[Check-out Flow]
  → Permission check: 'view_check_in_out' permission
  → Review folio (all charges, payments)
  → Generate final invoice
  → Process payment (if balance due)
  → Collect feedback (optional)
  → Update reservation status: CHECKED_IN → CHECKED_OUT
  → Room status: OCCUPIED → DIRTY (housekeeping queue)
  → Trigger: receipt email, loyalty points credit, survey email
  → Audit log: check-out timestamp, staff ID, final payment

[Send Notification to Guest]
  → Permission check: 'view_guests' permission
  → Notification composer: email or SMS
  → Template selector (pre-filled messages)
  → Personalization: guest name, booking details
  → Preview before send
  → On send: audit log (who, to whom, message type, timestamp)
```

#### Concurrent Edit Handling

```
[Edit Conflict Detection]
  → Before save: check `updated_at` timestamp
  → If changed since load: show conflict dialog
  → Display: "Booking was modified by [User Name] at [Time]"
  → Show diff (what changed: before → after)
  → Options:
    1. "Refresh & Edit" → Reload latest data, user edits again
    2. "Overwrite" → Save anyway (with confirmation: "This will overwrite recent changes")
    3. "Cancel" → Discard changes, return to detail view
  → Audit log: conflict detected, resolution chosen
```

#### Permission-Based UI Visibility

```
[UI Rendering Logic]
  → Components check permissions before rendering:
     - Buttons: disabled if no permission (tooltip: "You don't have permission")
     - Menu items: hidden if no permission
     - Table columns: hidden if no permission
     - Actions: grayed out with explanation
  → Permission checks: client-side (UX) + server-side (security, RLS)
  → Example: "Modify Booking" button only visible if 'modify_reservations' permission
```

---

### 1.5 Manager / Tenant Admin / Global Admin Flows

**Context:** `[Tenant: Hotel Group A] [Role: Tenant Admin] [State: Authenticated]`

#### Tenant Admin Flow

```
[Tenant Admin Dashboard]
  → Overview metrics: properties, staff, revenue, bookings
  → Recent activity feed (bookings, payments, staff actions)
  → Alerts: low inventory, payment issues, system warnings
  → Quick actions: Add Property, Manage Staff, Configure Settings

[Manage Staff Accounts]
  → Staff list table: name, email, role, property, status, last login
  → Filters: role, property, status (active/inactive)
  → Actions: Add Staff, Edit Role, Deactivate, Reset Password
  → Permission check: 'view_staff_management' + 'view_user_management'

[Add Staff Member]
  → Form: email, full name, role selector, property assignment
  → Role selector: filtered by tenant's enabled roles
  → Property selector: only tenant's properties
  → Invitation email sent (if user doesn't exist)
  → On creation: audit log (created by, user ID, role, property)

[Edit Role / Permissions]
  → Permission check: 'view_role_management'
  → Role selector (cannot assign higher role than self)
  → Permission matrix view (if tenant allows custom permissions)
  → Save button → confirmation dialog: "Update [User]'s role to [Role]?"
  → On save: audit log (who, target user, old role, new role)
  → Email notification to user (role changed)

[Configure Property Settings]
  → Property detail page → Settings tab
  → Sections: General, Booking Policies, Payment, Branding, Integrations
  → Editable fields: name, address, contact, timezone, currency
  → Booking policies: cancellation rules, deposit requirements, check-in/out times
  → Branding: logo upload, primary color, secondary color, favicon
  → Save button → confirmation: "Update property settings?"
  → On save: audit log (property ID, settings changed, before/after values)

[Configure Branding]
  → Tenant Settings → Branding tab
  → Brand logo upload (with validation: size, format, dimensions)
  → Color picker: primary color, secondary color, accent color
  → Typography: font family selector (from approved list)
  → Preview pane: live preview of branded components
  → Save button → confirmation: "Update branding for all properties?"
  → Warning: "This will update branding across all properties in this tenant."
  → On save: audit log (tenant ID, branding changes)
```

#### Global Admin Flow (Platform Operator)

**Context:** `[Tenant: Platform] [Role: Global Admin] [State: Authenticated]`

```
[Global Admin Dashboard]
  → Platform-wide metrics: total tenants, active users, bookings today, revenue
  → Tenant health overview: status (active/suspended), error rates, usage trends
  → Recent tenant activity: signups, issues, support tickets
  → Quick actions: Add Tenant, View Tenant, System Settings

[Manage Tenant Lifecycle]
  → Tenant list table: name, status, properties count, users count, created date
  → Filters: status, plan, region
  → Actions: View Tenant, Suspend Tenant, Delete Tenant, Impersonate Tenant

[Provision New Tenant]
  → Form: tenant name, admin email, plan, region, initial property
  → On submit: create tenant record, admin user, default settings
  → Welcome email sent to admin
  → Audit log: tenant created, created by, admin user ID

[Suspend Tenant]
  → Permission check: global admin only
  → Confirmation dialog: "Suspend [Tenant Name]?"
  → Warning: "This will prevent all users from accessing the system."
  → Reason field (required): dropdown (billing issue, violation, maintenance)
  → On suspend: update tenant status, revoke all sessions, send notification email
  → Audit log: tenant suspended, reason, suspended by

[Delete Tenant (Offboarding)]
  → Permission check: global admin only
  → Multi-step confirmation (destructive action):
     1. "Are you sure? This action cannot be undone."
     2. Type tenant name to confirm
     3. Final confirmation checkbox: "I understand all data will be deleted"
  → On delete: soft delete (mark as deleted, retain for 90 days for recovery)
  → Data retention: PII anonymized, business data retained per policy
  → Audit log: tenant deleted, deleted by, data retention policy applied

[View Platform Metrics]
  → Dashboard: error rates, performance metrics, usage trends
  → Error rates by tenant (identify problematic tenants)
  → Performance: API response times, database query times
  → Usage: API calls per tenant, storage usage, feature adoption
  → Export: CSV/PDF reports for stakeholders

[Feature Adoption per Tenant]
  → Table: tenant, feature, adoption rate, usage count
  → Features: OTA integration, loyalty program, analytics, etc.
  → Filters: feature, tenant, date range
  → Export: usage report

[Audit Visibility]
  → Audit log viewer: platform-wide (all tenants, filtered by tenant)
  → Columns: timestamp, tenant, user, action, resource, before/after
  → Filters: tenant, user, action type, date range
  → Export: CSV/PDF (for compliance)
  → Search: by user email, resource ID, action type
```

#### Safe-guard UX for Destructive Actions

```
[Destructive Action Pattern]
  → All destructive actions follow this pattern:
     1. Action button (e.g., "Delete") is styled as danger (red)
     2. Click opens confirmation dialog (modal, not just alert)
     3. Dialog shows: action description, affected resources, consequences
     4. Required confirmation: checkbox ("I understand...") or text input (type to confirm)
     5. Two buttons: "Cancel" (primary, safe) and "Confirm [Action]" (danger, secondary)
     6. On confirm: loading state, success/error message
     7. Audit log entry created

[Examples]
  - Delete Staff: "Delete [Name]? This will revoke access and cannot be undone."
  - Suspend Tenant: "Suspend [Tenant]? All users will lose access."
  - Delete Tenant: Multi-step confirmation with data retention notice
  - Cancel Booking: "Cancel booking? Refund policy: [Policy]. This cannot be undone."
```

---

## 2. Wireframes & Page Structure (SaaS-ready)

### 2.1 Multi-tenant Entry & Tenant-branded Landing

**Page:** Tenant-Branded Hotel Landing  
**Route:** `/{brandSlug}`  
**Context:** `[Tenant: Hotel Group A] [Role: Visitor] [State: Anonymous]`

```
┌─────────────────────────────────────────────────────────────┐
│ TenantShell (tenant-aware wrapper)                          │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ TenantHeader                                            │ │
│ │ ├─ Tenant Logo (from tenant.settings.branding.logo)    │ │
│ │ ├─ Tenant Name                                         │ │
│ │ ├─ Navigation: Properties | Dining | Offers | About    │ │
│ │ ├─ Language Switcher (if i18n enabled)                │ │
│ │ └─ Profile/Sign-in Button (top right)                 │ │
│ │                                                         │ │
│ │ [For Admins]: Environment Indicator (badge)            │ │
│ │   - "Production" | "Staging" | "Development"           │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Hero Section                                            │ │
│ │ ├─ Background Image (tenant-branded)                   │ │
│ │ ├─ Headline (tenant-configurable text)                 │ │
│ │ ├─ Subheadline                                         │ │
│ │ └─ Search Widget (HotelSearchBar component)            │ │
│ │    ├─ Property Selector (dropdown)                     │ │
│ │    ├─ Date Range Picker (check-in, check-out)          │ │
│ │    ├─ Guests Selector (adults, children)               │ │
│ │    └─ Primary CTA: "Search Stays"                      │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Secondary Content                                       │ │
│ │                                                         │ │
│ │ Featured Properties Section                             │ │
│ │ ├─ Section Header: "Featured Properties"               │ │
│ │ └─ PropertyCard[] (grid layout)                        │ │
│ │    └─ PropertyCard                                     │ │
│ │       ├─ Property Image                                │ │
│ │       ├─ Property Name                                 │ │
│ │       ├─ Location                                      │ │
│ │       ├─ Rating                                        │ │
│ │       ├─ Starting Price                                │ │
│ │       └─ "View Details" CTA                            │ │
│ │                                                         │ │
│ │ Offers / Promotions Section                            │ │
│ │ ├─ Section Header: "Special Offers"                    │ │
│ │ └─ OfferCard[] (carousel or grid)                      │ │
│ │    └─ OfferCard                                        │ │
│ │       ├─ Offer Image                                   │ │
│ │       ├─ Title                                         │ │
│ │       ├─ Description                                   │ │
│ │       ├─ Valid Dates                                   │ │
│ │       └─ "Learn More" CTA                              │ │
│ │                                                         │ │
│ │ Loyalty / Membership Teaser                            │ │
│ │ (if tenant.enableLoyalty === true)                     │ │
│ │ ├─ Section Header: "Join Our Rewards Program"          │ │
│ │ ├─ Benefits List                                       │ │
│ │ └─ "Sign Up" CTA                                       │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ TenantFooter                                            │ │
│ │ ├─ Tenant Contact Info (address, phone, email)         │ │
│ │ ├─ Links: About | Policies | Privacy | Terms           │ │
│ │ ├─ Social Media Links (if configured)                  │ │
│ │ └─ Data & Cookie Preferences Entry Point               │ │
│ │    └─ "Cookie Settings" link                           │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

Responsive Behavior:
- Mobile: Navigation collapses to hamburger menu
- Mobile: Hero search widget stacks vertically
- Mobile: Property cards stack (1 column)
- Mobile: Footer collapses to accordion sections

Accessibility:
- Skip to main content link (keyboard navigation)
- ARIA landmarks: <header>, <main>, <footer>, <nav>
- Focus management: tab order, visible focus indicators
- Screen reader: alt text for images, aria-labels for buttons
```

**Shared Components Used:**
- `TenantShell` (layout wrapper, tenant context provider)
- `TenantHeader` (tenant branding, navigation, auth state)
- `TenantFooter` (tenant contact info, links)
- `HotelSearchBar` (search widget, reusable)
- `PropertyCard` (property display, reusable)
- `OfferCard` (promotion display, reusable)

**Tenant-Customizable Elements:**
- Logo (image URL)
- Primary/secondary colors (CSS variables)
- Typography (font family)
- Hero headline/subheadline (text)
- Featured properties (selected property IDs)
- Footer contact info (text)

---

### 2.2 Hotel Search, Property List & Filters

**Page:** Property Search Results  
**Route:** `/{brandSlug}/{propertySlug}/rooms?checkIn=...&checkOut=...&guests=...`  
**Context:** `[Tenant: Hotel Group A] [Property: Property X] [Role: Visitor] [State: Anonymous]`

```
┌─────────────────────────────────────────────────────────────┐
│ TenantShell                                                 │
│ ├─ TenantHeader (same as landing)                           │
│ └─ Main Content                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Page Header                                           │ │
│    │ ├─ Breadcrumbs: Home > [Property Name] > Rooms       │ │
│    │ ├─ Property Name (H1)                                 │ │
│    │ └─ Search Summary: "[Check-in] to [Check-out], [N] guests" │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌─────────────────────┬─────────────────────────────────┐ │
│    │ Filters Sidebar     │ Results Area                    │ │
│    │ (sticky on desktop) │                                 │ │
│    │                     │ ┌─────────────────────────────┐ │ │
│    │ PropertyFilterPanel │ │ Results Header              │ │
│    │ ├─ Price Range      │ │ ├─ Results Count: "N rooms found" │ │
│    │ │  └─ Slider        │ │ ├─ Sort Dropdown            │ │
│    │ │                   │ │ │  └─ Price (Low-High), ... │ │
│    │ ├─ Room Type        │ │ └─ View Toggle (Grid/List)  │ │
│    │ │  └─ Checkboxes    │ └─────────────────────────────┘ │ │
│    │ │                   │                                 │ │
│    │ ├─ Amenities        │ ┌─────────────────────────────┐ │ │
│    │ │  └─ Checkboxes    │ │ RoomCard[] (grid or list)   │ │
│    │ │                   │ │                             │ │
│    │ ├─ Bed Type         │ │ RoomCard                    │ │
│    │ │  └─ Checkboxes    │ │ ├─ Room Image Gallery       │ │
│    │ │                   │ │ ├─ Room Name                │ │
│    │ ├─ Max Occupancy    │ │ ├─ Description              │ │
│    │ │  └─ Number input  │ │ ├─ Amenities List (icons)   │ │
│    │ │                   │ │ ├─ AvailabilityStatusBadge  │ │
│    │ └─ "Apply Filters"  │ │ │  └─ "Available" | "Limited" | "Sold Out" │ │
│    │    Button           │ │ ├─ Price Display            │ │
│    │                     │ │ │  └─ Base price, taxes, total │ │
│    │                     │ │ └─ "View Details" CTA        │ │
│    │                     │ │                             │ │
│    │                     │ │ [Repeat for each room]      │ │
│    │                     │ └─────────────────────────────┘ │ │
│    │                     │                                 │ │
│    │                     │ ┌─────────────────────────────┐ │ │
│    │                     │ │ Pagination Controls         │ │
│    │                     │ │ ├─ Previous Button          │ │
│    │                     │ │ ├─ Page Numbers             │ │
│    │                     │ │ └─ Next Button              │ │
│    │                     │ └─────────────────────────────┘ │ │
│    └─────────────────────┴─────────────────────────────────┘ │
│                                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Empty State (if no results)                           │ │
│    │ ├─ Illustration                                       │ │
│    │ ├─ Message: "No rooms available for your dates"       │ │
│    │ ├─ Suggestions: "Try different dates"                 │ │
│    │ └─ "Modify Search" Button                             │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│ └─ TenantFooter                                             │
└─────────────────────────────────────────────────────────────┘

Responsive Behavior:
- Mobile: Filters sidebar becomes drawer (slide-in from left)
- Mobile: Filters button in header toggles drawer
- Mobile: Room cards stack (1 column)
- Mobile: Sort/view toggle moves to header

Accessibility:
- Filters sidebar: ARIA expanded state, keyboard navigation
- Room cards: semantic HTML (<article>), keyboard focusable
- Pagination: ARIA labels, keyboard navigation (arrow keys)
```

**Shared Components Used:**
- `PropertyFilterPanel` (filters sidebar, reusable)
- `RoomCard` (room display, reusable)
- `AvailabilityStatusBadge` (status indicator, reusable)
- `PaginationControls` (pagination, reusable)
- `EmptyState` (empty state, reusable)

---

### 2.3 Hotel Property Detail & Room Selection

**Page:** Room Type Detail  
**Route:** `/{brandSlug}/{propertySlug}/rooms/{roomTypeSlug}`  
**Context:** `[Tenant: Hotel Group A] [Property: Property X] [Role: Visitor] [State: BROWSING → SELECTING_ROOM]`

```
┌─────────────────────────────────────────────────────────────┐
│ TenantShell                                                 │
│ ├─ TenantHeader                                             │
│ └─ Main Content                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Breadcrumbs: Home > [Property] > Rooms > [Room Type] │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Room Image Gallery (carousel)                         │ │
│    │ ├─ Main Image (large)                                 │ │
│    │ └─ Thumbnail Strip (scrollable)                       │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌─────────────────────┬─────────────────────────────────┐ │
│    │ Room Details        │ Booking Widget (sticky)         │ │
│    │                     │                                 │ │
│    │ ├─ Room Name (H1)   │ ┌─────────────────────────────┐ │ │
│    │ ├─ Rating           │ │ Date & Guests Selector      │ │
│    │ ├─ Location         │ │ ├─ Check-in Date            │ │
│    │ │                   │ │ ├─ Check-out Date           │ │
│    │ ├─ Description      │ │ └─ Guests (adults, children)│ │
│    │ │  (long text)      │ │                             │ │
│    │ │                   │ │ "Check Availability" Button │ │
│    │ ├─ Amenities List   │ │                             │ │
│    │ │  (icons + labels) │ │ [If available]              │ │
│    │ │                   │ │ ┌─────────────────────────┐ │ │
│    │ ├─ Policies         │ │ │ Pricing Breakdown       │ │
│    │ │  ├─ Check-in/out  │ │ │ ├─ Base Rate: $X        │ │
│    │ │  ├─ Cancellation  │ │ │ ├─ Taxes: $Y            │ │
│    │ │  ├─ Minimum stay  │ │ │ ├─ Fees: $Z             │ │
│    │ │  └─ Pet policy    │ │ │ └─ Total: $TOTAL        │ │
│    │ │                   │ │ └─────────────────────────┘ │ │
│    │ ├─ Reviews Section  │ │                             │ │
│    │ │  ├─ Average Rating│ │ AvailabilityStatusBadge     │ │
│    │ │  ├─ Review Count  │ │ "Available" | "Limited"     │ │
│    │ │  └─ ReviewCard[]  │ │                             │ │
│    │ │     └─ ReviewCard │ │ "Book This Room" Button     │ │
│    │ │        ├─ Guest   │ │ (primary CTA)               │ │
│    │ │        ├─ Rating  │ │                             │ │
│    │ │        ├─ Date    │ │ [If sold out]               │ │
│    │ │        └─ Comment │ │ "Sold Out" Message          │ │
│    │ │                   │ │ "Notify Me" Button          │ │
│    │ └─ Similar Rooms    │ │                             │ │
│    │    └─ RoomCard[]    │ └─────────────────────────────┘ │
│    │       (horizontal)  │                                 │
│    └─────────────────────┴─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

State Transitions:
- BROWSING: Initial load, availability checked, booking widget active
- SELECTING_ROOM: User clicked "Book This Room", transitions to booking flow

Responsive Behavior:
- Mobile: Booking widget moves to bottom (sticky), becomes full-width
- Mobile: Image gallery full-width, thumbnails below
- Mobile: Room details stack vertically
```

**Shared Components Used:**
- `BookingWidget` (availability check, pricing, CTA)
- `AvailabilityStatusBadge` (status indicator)
- `ReviewCard` (review display)
- `RoomCard` (similar rooms)

---

### 2.4 Booking Flow (Modal or Multi-step Page)

**Page:** Booking Flow  
**Route:** `/{brandSlug}/{propertySlug}/book?roomType=...&checkIn=...&checkOut=...`  
**Context:** `[Tenant: Hotel Group A] [Property: Property X] [Role: Visitor/Guest] [State: FILLING_GUEST_DETAILS → REVIEWING → PAYMENT_IN_PROGRESS → CONFIRMED]`

```
┌─────────────────────────────────────────────────────────────┐
│ BookingStepper (progress indicator)                         │
│ ├─ Step 1: Guest Details (current)                          │
│ ├─ Step 2: Review & Payment                                 │
│ └─ Step 3: Confirmation                                     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ BookingFlow Container                                       │
│                                                             │
│ ┌─────────────────────┬───────────────────────────────────┐ │
│ │ Main Form Area      │ Booking Summary Sidebar (sticky)  │ │
│ │                     │                                    │ │
│ │ Step 1: Guest Details│ ┌──────────────────────────────┐ │ │
│ │ ├─ Form Fields:     │ │ BookingSummary Card           │ │
│ │ │  - First Name *   │ │ ├─ Property Name              │ │
│ │ │  - Last Name *    │ │ ├─ Room Type                  │ │
│ │ │  - Email *        │ │ ├─ Check-in Date              │ │
│ │ │  - Phone *        │ │ ├─ Check-out Date             │ │
│ │ │  - Special Req.   │ │ ├─ Guests (adults, children)  │ │
│ │ │                   │ │ ├─ Duration (nights)          │ │
│ │ │  [If not logged in]│ │                              │ │
│ │ │  ☑ Create Account │ │ Pricing Breakdown             │ │
│ │ │    (pre-checked)  │ │ ├─ Base Rate                  │ │
│ │ │                   │ │ ├─ Taxes                      │ │
│ │ │ "Continue" Button │ │ ├─ Service Charge             │ │
│ │ │                   │ │ └─ Total                      │ │
│ │                     │ │                              │ │
│ │                     │ │ Cancellation Policy           │ │
│ │                     │ │ └─ Summary text               │ │
│ │                     │ └──────────────────────────────┘ │ │
│ │                     │                                    │ │
│ │ Step 2: Review & Payment │                              │ │
│ │ ├─ Guest Details Review │                              │ │
│ │ │  (read-only, editable link)                          │ │
│ │ │                       │                              │ │
│ │ ├─ Booking Details Review │                            │ │
│ │ │  (read-only)        │                                │ │
│ │ │                       │                              │ │
│ │ ├─ Terms & Conditions │                                │ │
│ │ │  ☑ I agree to terms (required) │                    │ │
│ │ │                       │                              │ │
│ │ ├─ Payment Method Selector │                          │ │
│ │ │  ○ Credit Card      │                                │ │
│ │ │  ○ Debit Card       │                                │ │
│ │ │  ○ Wallet (if enabled) │                            │ │
│ │ │                       │                              │ │
│ │ ├─ PaymentForm (PCI-compliant) │                      │ │
│ │ │  ├─ Card Number     │                                │ │
│ │ │  ├─ Expiry Date     │                                │ │
│ │ │  ├─ CVV             │                                │ │
│ │ │  └─ Cardholder Name │                                │ │
│ │ │                       │                              │ │
│ │ └─ "Complete Booking" Button │                        │ │
│ │    (loading state during payment) │                    │ │
│ │                       │                                │ │
│ │ Step 3: Confirmation  │                                │ │
│ │ ├─ Success Icon       │                                │ │
│ │ ├─ Confirmation Message │                             │ │
│ │ │  "Your booking is confirmed!" │                      │ │
│ │ ├─ Booking Reference Number │                         │ │
│ │ │  "Booking #ABC123"  │                                │ │
│ │ ├─ BookingDetailsCard (full summary) │                │ │
│ │ ├─ "Download PDF" Button │                            │ │
│ │ ├─ "Add to Calendar" Button │                         │ │
│ │ └─ Primary CTA: "View My Bookings" │                  │ │
│ │    (if authenticated) or "Create Account" │            │ │
│ └─────────────────────┴──────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

State Management:
- FILLING_GUEST_DETAILS: Form active, validation on blur
- REVIEWING: All fields valid, payment form visible
- PAYMENT_IN_PROGRESS: Payment processing, button disabled, loading spinner
- CONFIRMED: Success state, confirmation message, next actions

Error Handling:
- Validation errors: inline messages below fields
- Payment failure: error banner above payment form, retry button
- Network error: toast notification, retry button
- Session expiry: modal dialog, extend or start over

Responsive Behavior:
- Mobile: Booking summary sidebar becomes collapsible accordion
- Mobile: Steps stack vertically
- Mobile: Payment form full-width
```

**Shared Components Used:**
- `BookingStepper` (step indicator, reusable)
- `BookingSummary` (summary card, reusable)
- `PaymentForm` (payment input, PCI-compliant, reusable)
- `BookingDetailsCard` (confirmation display, reusable)

---

### 2.5 Restaurant Landing, Menu & Order Flow

**Page:** Restaurant Detail / Menu  
**Route:** `/{brandSlug}/{propertySlug}/dining/{restaurantSlug}`  
**Context:** `[Tenant: Restaurant Brand B] [Property: Property X] [Role: Visitor] [State: BROWSING_MENU → BUILDING_ORDER]`

```
┌─────────────────────────────────────────────────────────────┐
│ TenantShell                                                 │
│ ├─ TenantHeader                                             │
│ └─ Main Content                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Breadcrumbs: Home > Dining > [Restaurant Name]       │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Restaurant Hero Section                               │ │
│    │ ├─ Restaurant Image                                   │ │
│    │ ├─ Restaurant Name (H1)                               │ │
│    │ ├─ Cuisine Type                                       │ │
│    │ ├─ Rating & Review Count                              │ │
│    │ ├─ Opening Hours                                      │ │
│    │ └─ Location                                           │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌─────────────────────┬─────────────────────────────────┐ │
│    │ Service Mode Toggle  │ Cart Sidebar (sticky, shows count)│ │
│    │ (if multiple modes)  │                                 │ │
│    │ ○ Dine In            │ ┌─────────────────────────────┐ │ │
│    │ ○ Takeaway           │ │ CartSidebar                 │ │
│    │ ○ Delivery           │ │ ├─ Cart Header              │ │
│    │                      │ │ │  └─ "Your Order (N items)"│ │ │
│    │ Menu Categories      │ │ │                           │ │ │
│    │ ├─ Category Tabs     │ │ ├─ Cart Items List          │ │ │
│    │ │  (horizontal,      │ │ │  └─ CartItem[]            │ │ │
│    │ │   scrollable)      │ │ │     ├─ Item Name          │ │ │
│    │ │                    │ │ │     ├─ Quantity (+/-)     │ │ │
│    │ │  - All             │ │ │     ├─ Price              │ │ │
│    │ │  - Appetizers      │ │ │     └─ Remove Button      │ │ │
│    │ │  - Main Courses    │ │ │                           │ │ │
│    │ │  - Desserts        │ │ │ ├─ Subtotal               │ │ │
│    │ │  - Beverages       │ │ │ ├─ Tax                    │ │ │
│    │ │                    │ │ │ ├─ Service Charge         │ │ │
│    │ │                    │ │ │ ├─ Tip (if enabled)       │ │ │
│    │ │ Menu Items Grid    │ │ │ └─ Total                  │ │ │
│    │ │                    │ │ │                           │ │ │
│    │ │ MenuItemCard[]     │ │ │ "Review Order" Button     │ │ │
│    │ │  └─ MenuItemCard   │ │ │ (opens order review modal)│ │ │
│    │ │     ├─ Item Image  │ │ └─────────────────────────────┘ │ │
│    │ │     ├─ Item Name   │ │                                 │ │
│    │ │     ├─ Description │ │                                 │ │
│    │ │     ├─ Price       │ │                                 │ │
│    │ │     ├─ DietaryTag[]│ │                                 │ │
│    │ │     │  (vegan, GF) │ │                                 │ │
│    │ │     ├─ AvailabilityStatusBadge │                     │ │
│    │ │     │  "Available" │ │                                 │ │
│    │ │     └─ "Add to Cart" Button │                        │ │
│    │ │                           │ │                                 │ │
│    │ │ [Clicking "Add"]          │ │                                 │ │
│    │ │ → CustomizationModal opens│ │                                 │ │
│    │ │   ├─ Size Selector        │ │                                 │ │
│    │ │   ├─ Add-ons (checkboxes) │ │                                 │ │
│    │ │   ├─ Special Instructions │ │                                 │ │
│    │ │   ├─ Quantity Selector    │ │                                 │ │
│    │ │   └─ "Add to Cart" Button │ │                                 │ │
│    │ │                           │ │                                 │ │
│    └─────────────────────┴─────────────────────────────────┘ │
│                                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Allergen Disclaimer                                   │ │
│    │ "Please inform staff of allergies. Menu items may    │ │
│    │  contain allergens."                                 │ │
│    └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

Order Review Modal (when "Review Order" clicked):
┌─────────────────────────────────────────────────────────────┐
│ Order Review Modal                                          │
│ ├─ Order Summary (items, quantities, prices)               │
│ ├─ Time Selection                                          │ │
│ │  ├─ For Dine In: Table Reservation Time Picker          │ │
│ │  ├─ For Takeaway: Pickup Time Selector                  │ │
│ │  └─ For Delivery: Address Form + Delivery Time          │ │
│ ├─ Contact Information (email, phone)                      │ │
│ ├─ Special Instructions Textarea                           │ │
│ └─ "Place Order" Button                                    │ │
│    → SUBMITTING_ORDER → WAITING_CONFIRMATION → CONFIRMED   │ │
└─────────────────────────────────────────────────────────────┘

Responsive Behavior:
- Mobile: Service mode toggle full-width, horizontal scroll
- Mobile: Cart sidebar becomes bottom sheet (slides up)
- Mobile: Menu categories tabs scrollable
- Mobile: Menu items grid: 2 columns (tablet), 1 column (mobile)
```

**Shared Components Used:**
- `ServiceModeToggle` (dine-in/takeaway/delivery selector)
- `MenuCategoryList` (category tabs)
- `MenuItemCard` (menu item display)
- `DietaryTag` (vegan, GF, etc. badges)
- `CartSidebar` (cart display, sticky)
- `CustomizationModal` (item customization)
- `OrderSummary` (order review)

---

### 2.6 HMS Backoffice Dashboards

**Page:** Front Desk Dashboard  
**Route:** `/front-desk/dashboard`  
**Context:** `[Tenant: Hotel Group A] [Role: Front Desk Agent/Manager] [State: Authenticated]`

```
┌─────────────────────────────────────────────────────────────┐
│ BackofficeShell (tenant-aware, role-aware)                  │
│                                                             │
│ ┌─────────────────┬───────────────────────────────────────┐ │
│ │ AppSidebar      │ Main Content Area                     │ │
│ │ (collapsible)   │                                       │ │
│ │                 │ ┌───────────────────────────────────┐ │ │
│ │ ├─ Dashboard    │ │ Page Header                       │ │
│ │ ├─ Reservations │ │ ├─ Title: "Front Desk Dashboard"  │ │ │
│ │ ├─ Check-in/out │ │ ├─ Date Selector (today by default)│ │ │
│ │ ├─ Rooms        │ │ └─ Property Selector (if multi)   │ │ │
│ │ ├─ Guests       │ └───────────────────────────────────┘ │ │
│ │ └─ [More...]    │                                       │ │
│ │   (role-filtered│ ┌───────────────────────────────────┐ │ │
│ │    menu items)  │ │ KPITile Grid (4 columns)          │ │ │
│ │                 │ │ ├─ KPITile: Today's Arrivals      │ │ │
│ │                 │ │ │  └─ Count + Trend indicator     │ │ │
│ │                 │ │ ├─ KPITile: Today's Departures    │ │ │
│ │                 │ │ │  └─ Count + Trend               │ │ │
│ │                 │ │ ├─ KPITile: In-House Guests       │ │ │
│ │                 │ │ │  └─ Count                       │ │ │
│ │                 │ │ └─ KPITile: Pending Check-ins     │ │ │
│ │                 │ │    └─ Count (highlighted if >0)   │ │ │
│ │                 │ └───────────────────────────────────┘ │ │
│ │                 │                                       │ │
│ │                 │ ┌───────────────────────────────────┐ │ │
│ │                 │ │ Today's Arrivals Section          │ │ │
│ │                 │ │ ├─ Section Header                 │ │ │
│ │                 │ │ └─ DataTable                      │ │ │
│ │                 │ │    ├─ Columns:                    │ │ │
│ │                 │ │    │  Guest, Room, Check-in,      │ │ │
│ │                 │ │    │  Status, Actions             │ │ │
│ │                 │ │    ├─ FiltersBar (status, room)   │ │ │
│ │                 │ │    └─ Rows (clickable → detail)   │ │ │
│ │                 │ └───────────────────────────────────┘ │ │
│ │                 │                                       │ │
│ │                 │ ┌───────────────────────────────────┐ │ │
│ │                 │ │ Today's Departures Section        │ │ │
│ │                 │ │ (similar structure)               │ │ │
│ │                 │ └───────────────────────────────────┘ │ │
│ │                 │                                       │ │
│ │                 │ ┌───────────────────────────────────┐ │ │
│ │                 │ │ Room Status Summary               │ │ │
│ │                 │ │ └─ RoomStatusCard[] (grid)        │ │ │
│ │                 │ │    └─ RoomStatusCard              │ │ │
│ │                 │ │       ├─ Room Number              │ │ │
│ │                 │ │       ├─ Status Badge             │ │ │
│ │                 │ │       │  (Available/Occupied/Dirty)│ │ │
│ │                 │ │       └─ Guest Name (if occupied) │ │ │
│ │                 │ └───────────────────────────────────┘ │ │
│ │                 │                                       │ │
│ │                 │ ┌───────────────────────────────────┐ │ │
│ │                 │ │ Quick Actions (floating, bottom)  │ │ │
│ │                 │ │ └─ Button Group:                  │ │ │
│ │                 │ │    "New Booking" | "Check-in" |   │ │ │
│ │                 │ │    "Check-out" | "Guest Lookup"   │ │ │
│ │                 │ └───────────────────────────────────┘ │ │
│ └─────────────────┴───────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

Role-Based Visibility:
- Front Desk Agent: View-only dashboards, limited actions
- Front Desk Manager: Full access, modify bookings, reports
- Admin: All features, user management, settings

Responsive Behavior:
- Mobile: Sidebar becomes drawer (slide-in)
- Mobile: KPI tiles stack (2x2 grid)
- Mobile: Tables scroll horizontally
- Mobile: Quick actions become floating action button (FAB)
```

**Page:** F&B / Restaurant Operations Dashboard  
**Route:** `/restaurant/dashboard`  
**Context:** `[Tenant: Restaurant Brand B] [Role: Restaurant Manager/Waiter] [State: Authenticated]`

```
┌─────────────────────────────────────────────────────────────┐
│ BackofficeShell                                             │
│ └─ Main Content                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Page Header: "Restaurant Operations"                  │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ KPITile Grid                                          │ │
│    │ ├─ Revenue Today                                      │ │
│    │ ├─ Active Orders                                      │ │
│    │ ├─ Reservations Today                                 │ │
│    │ └─ Table Occupancy                                    │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌─────────────────────┬─────────────────────────────────┐ │
│    │ Active Orders        │ Table Status                   │ │
│    │ └─ OrderCard[]       │ └─ TableLayoutView             │ │
│    │    └─ OrderCard      │    └─ TableCard[] (grid)       │ │
│    │       ├─ Order #     │       └─ TableCard             │ │
│    │       ├─ Table/Name  │          ├─ Table Number       │ │
│    │       ├─ Items       │          ├─ Status Badge       │ │
│    │       ├─ Status      │          │  (Available/Occupied/Reserved) │ │
│    │       │  (In Prep/   │          └─ Guest Name (if occupied) │ │
│    │       │   Ready)     │                                │ │
│    │       └─ Actions     │                                │ │
│    │          (Update)    │                                │ │
│    └─────────────────────┴─────────────────────────────────┘ │
│                                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Today's Reservations                                  │ │
│    │ └─ DataTable                                          │ │
│    │    ├─ Columns: Time, Guest, Guests, Status, Actions  │ │
│    │    └─ Filters: Time range, status                    │ │
│    └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

**Page:** Finance / Billing Summary Dashboard  
**Route:** `/finance/dashboard`  
**Context:** `[Tenant: Hotel Group A] [Role: Finance Manager/Accountant] [State: Authenticated]`

```
┌─────────────────────────────────────────────────────────────┐
│ BackofficeShell                                             │
│ └─ Main Content                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Page Header: "Finance Dashboard"                      │ │
│    ├─ Date Range Picker (default: this month)              │ │
│    └─ Property Selector (if multi-property)                │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Revenue Summary (Chart)                               │ │
│    │ └─ Line/Bar Chart: Revenue over time                  │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌─────────────────────┬─────────────────────────────────┐ │
│    │ KPITile Grid        │ Recent Transactions             │ │
│    │ ├─ Total Revenue    │ └─ DataTable                    │ │
│    │ ├─ Room Revenue     │    ├─ Columns: Date, Guest,     │ │
│    │ ├─ F&B Revenue      │    │  Type, Amount, Status      │ │
│    │ ├─ Outstanding      │    └─ Filters: Type, status     │ │
│    │ └─ Paid Today       │                                 │ │
│    └─────────────────────┴─────────────────────────────────┘ │
│                                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Outstanding Invoices                                  │ │
│    │ └─ DataTable                                          │ │
│    │    ├─ Columns: Invoice #, Guest, Amount, Due Date,   │ │
│    │    │  Status, Actions                                 │ │
│    │    └─ Actions: View, Send Reminder, Export           │ │
│    └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

**Page:** Tenant Admin Console  
**Route:** `/admin/tenant`  
**Context:** `[Tenant: Hotel Group A] [Role: Tenant Admin] [State: Authenticated]`

```
┌─────────────────────────────────────────────────────────────┐
│ BackofficeShell                                             │
│ └─ Main Content                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Page Header: "Tenant Administration"                  │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Tabs Navigation                                       │ │
│    │ ├─ Overview                                           │ │
│    │ ├─ Properties                                         │ │
│    │ ├─ Staff Management                                   │ │
│    │ ├─ Settings                                           │ │
│    │ ├─ Branding                                           │ │
│    │ └─ Integrations                                       │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Tab: Overview                                         │ │
│    │ ├─ Tenant Summary (name, plan, status)                │ │
│    │ ├─ Properties Count                                   │ │
│    │ ├─ Staff Count                                        │ │
│    │ └─ Usage Metrics (bookings, revenue)                  │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Tab: Staff Management                                 │ │
│    │ ├─ Staff Table                                        │ │
│    │ │  └─ DataTable                                       │ │
│    │ │     ├─ Columns: Name, Email, Role, Property,       │ │
│    │ │     │  Status, Last Login, Actions                 │ │
│    │ │     ├─ FiltersBar: Role, property, status          │ │
│    │ │     └─ Actions: Edit, Deactivate, Reset Password   │ │
│    │ │                                                    │ │
│    │ ├─ "Add Staff" Button                                │ │
│    │ │  → Opens AddStaffModal                             │ │
│    │ │     ├─ Email Input                                 │ │
│    │ │     ├─ Name Input                                  │ │
│    │ │     ├─ Role Selector                               │ │
│    │ │     ├─ Property Selector                           │ │
│    │ │     └─ "Send Invitation" Button                    │ │
│    │ └─ ExportButton (CSV)                                │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Tab: Branding                                         │ │
│    │ ├─ Logo Upload                                        │ │
│    │ ├─ Color Picker (primary, secondary)                  │ │
│    │ ├─ Typography Selector                                │ │
│    │ ├─ Preview Pane (live preview)                        │ │
│    │ └─ "Save Branding" Button                             │ │
│    └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

**Shared Components Used:**
- `BackofficeShell` (layout wrapper, sidebar, header)
- `AppSidebar` (navigation, role-filtered)
- `KPITile` (metric display)
- `DataTable` (sortable, filterable table)
- `FiltersBar` (filter controls)
- `DashboardCard` (section container)
- `ExportButton` (CSV/PDF export, with permission check)

---

### 2.7 Audit Logs & Activity History

**Page:** Audit Logs Viewer  
**Route:** `/admin/audit-logs`  
**Context:** `[Tenant: Hotel Group A] [Role: Admin/Auditor] [State: Authenticated]`

```
┌─────────────────────────────────────────────────────────────┐
│ BackofficeShell                                             │
│ └─ Main Content                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Page Header: "Audit Logs"                             │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ FiltersBar                                            │ │
│    │ ├─ Date Range Picker                                  │ │
│    │ ├─ User Selector (dropdown)                           │ │
│    │ ├─ Action Type Selector                               │ │
│    │ │  └─ Options: Create, Update, Delete, Login, etc.   │ │
│    │ ├─ Resource Type Selector                             │ │
│    │ │  └─ Options: Booking, User, Property, etc.         │ │
│    │ └─ "Apply Filters" Button                             │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ AuditLogTable (virtualized, paginated)                │ │
│    │ ├─ Columns:                                           │ │
│    │ │  Timestamp, User, Action, Resource Type,           │ │
│    │ │  Resource ID, Before/After, IP Address, Actions    │ │
│    │ ├─ Sortable columns                                   │ │
│    │ ├─ Rows (expandable for details)                      │ │
│    │ │  └─ Expand shows:                                  │ │
│    │ │     - Full before/after JSON (formatted)           │ │
│    │ │     - Request metadata (user agent, IP)            │ │
│    │ │     - Related audit entries                        │ │
│    │ └─ Pagination Controls                                │ │
│    └───────────────────────────────────────────────────────┘ │
│                                                             │
│    ┌───────────────────────────────────────────────────────┐ │
│    │ Actions Bar                                           │ │
│    │ ├─ ExportButton (CSV/PDF)                            │ │
│    │ │  └─ Permission check: 'view_audit_logs'            │ │
│    │ └─ "Clear Filters" Button                             │ │
│    └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

Drill-down:
- Clicking resource ID → Navigate to resource detail page
- Clicking user → Navigate to user profile
- Export includes all filtered results (with pagination handling)
```

**Shared Components Used:**
- `AuditLogTable` (audit log display, virtualized)
- `FiltersBar` (filter controls)
- `ExportButton` (CSV/PDF export)

---

### 2.8 Error & Maintenance Experience

**Page:** Error Page (404, 500, etc.)  
**Route:** `/*` (catch-all for errors)  
**Context:** `[Tenant: Any] [Role: Any] [State: Any]`

```
┌─────────────────────────────────────────────────────────────┐
│ Error Page (tenant-branded)                                 │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Error Illustration / Icon                               │ │
│ ├─ Error Title (H1)                                       │ │
│ │  "Page Not Found" | "Something Went Wrong"              │ │
│ ├─ Error Message                                          │ │
│ │  (non-technical, user-friendly)                         │ │
│ ├─ Error Reference ID                                     │ │
│ │  "Reference: ERR-ABC123" (for support)                  │ │
│ │                                                        │ │
│ ├─ Primary CTA: "Go Home"                                 │ │
│ ├─ Secondary CTA: "Go Back" (browser back)                │ │
│ └─ "Contact Support" Link                                 │ │
│    └─ Pre-fills error reference ID                        │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

Error Types:
- 404: "The page you're looking for doesn't exist."
- 403: "You don't have permission to access this page."
- 500: "Something went wrong on our end. We're working on it."
- 503: "Service temporarily unavailable. Please try again soon."
- Network Error: "Unable to connect. Please check your internet."
```

**Page:** Maintenance Mode  
**Route:** `/*` (platform-wide or tenant-specific)  
**Context:** `[Tenant: Hotel Group A] [Role: Any] [State: Any]`

```
┌─────────────────────────────────────────────────────────────┐
│ Maintenance Page (tenant-branded)                           │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Maintenance Illustration                                │ │
│ ├─ Title: "We're Making Improvements"                     │ │
│ ├─ Message                                                │ │
│ │  "We're currently performing maintenance to improve     │ │
│ │   your experience. We'll be back shortly."              │ │
│ ├─ Scheduled Time (if applicable)                         │ │
│ │  "Estimated completion: [Date] at [Time]"               │ │
│ └─ "Check Back Soon" Message                              │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

Tenant-Scoped Maintenance:
- Only affects specific tenant
- Other tenants remain accessible
- Tenant admin can enable/disable via settings

Platform-Wide Maintenance:
- Affects all tenants
- Only global admin can enable
- Shows platform branding (not tenant branding)
```

---

## 3. Component Hierarchy, Contracts, and Reuse

### 3.1 Shell & Layout Components

#### AppShell
**Purpose:** Root layout wrapper for entire application (public + backoffice)

**Props:**
- `children: ReactNode` - Page content
- `tenantId?: string` - Current tenant context
- `tenantContext?: ResolvedContext` - Full tenant context (tenant, property, theme)
- `environment?: 'production' | 'staging' | 'development'` - Environment indicator
- `showEnvironmentBadge?: boolean` - Show environment badge (admin only)

**Events:**
- `onTenantChange?: (tenantId: string) => void` - Tenant context changed
- `onError?: (error: Error) => void` - Global error handler

**Cross-cutting:**
- Telemetry: `onEvent('page_view', { path, tenantId })`
- Feature flags: Reads from tenant context
- Localization: Locale from tenant context

---

#### TenantShell
**Purpose:** Tenant-aware layout wrapper (public-facing pages)

**Props:**
- `tenantContext: ResolvedContext` - Tenant context (required)
- `children: ReactNode` - Page content
- `showHeader?: boolean` - Show tenant header (default: true)
- `showFooter?: boolean` - Show tenant footer (default: true)
- `headerVariant?: 'default' | 'transparent' | 'sticky'` - Header style

**Events:**
- None (presentational wrapper)

**Cross-cutting:**
- Theming: Applies tenant CSS variables (colors, typography)
- Branding: Renders tenant logo, name
- Localization: Locale, currency, timezone from tenant context

---

#### TenantHeader
**Purpose:** Tenant-branded header with navigation and auth state

**Props:**
- `tenantContext: ResolvedContext` - Tenant context
- `logoUrl?: string` - Tenant logo URL (from tenant.settings.branding.logo)
- `tenantName: string` - Tenant name
- `navigationItems?: NavigationItem[]` - Navigation links
- `authState: 'anonymous' | 'authenticated' | 'pending'` - Auth state
- `user?: User` - Authenticated user (if authenticated)
- `onSignIn?: () => void` - Sign in handler
- `onSignOut?: () => void` - Sign out handler
- `showLanguageSwitcher?: boolean` - Show language switcher

**Events:**
- `onNavigate?: (path: string) => void` - Navigation handler

**NavigationItem:**
```typescript
interface NavigationItem {
  label: string;
  href: string;
  external?: boolean;
}
```

**Cross-cutting:**
- Localization: Language switcher (if enabled)
- Telemetry: `onEvent('navigation_click', { item, tenantId })`

---

#### TenantFooter
**Purpose:** Tenant-branded footer with contact info and links

**Props:**
- `tenantContext: ResolvedContext` - Tenant context
- `contactInfo?: ContactInfo` - Contact information
- `links?: FooterLink[]` - Footer links (About, Policies, etc.)
- `socialMedia?: SocialMediaLink[]` - Social media links
- `showCookiePreferences?: boolean` - Show cookie preferences link

**ContactInfo:**
```typescript
interface ContactInfo {
  address?: string;
  phone?: string;
  email?: string;
}
```

**FooterLink:**
```typescript
interface FooterLink {
  label: string;
  href: string;
  external?: boolean;
}
```

---

#### BackofficeShell
**Purpose:** Backoffice layout wrapper (staff/admin pages)

**Props:**
- `tenantId: string` - Current tenant
- `user: User` - Authenticated user
- `userRoles: AppRole[]` - User roles (for permission-based navigation)
- `children: ReactNode` - Page content
- `currentPath?: string` - Current route (for active navigation)

**Events:**
- `onNavigate?: (path: string) => void` - Navigation handler
- `onSignOut?: () => void` - Sign out handler

**Cross-cutting:**
- RBAC: Filters navigation items by permissions
- Telemetry: `onEvent('backoffice_page_view', { path, role, tenantId })`

---

#### AppSidebar
**Purpose:** Navigation sidebar for backoffice (role-aware)

**Props:**
- `userRoles: AppRole[]` - User roles
- `currentPath: string` - Current route
- `navigationItems: NavigationItem[]` - Navigation items (filtered by permissions)
- `collapsible?: boolean` - Allow collapsing (default: true)
- `collapsed?: boolean` - Controlled collapsed state

**Events:**
- `onNavigate?: (path: string) => void` - Navigation handler
- `onCollapseChange?: (collapsed: boolean) => void` - Collapse state changed

**Cross-cutting:**
- RBAC: Filters items by `ROUTE_PERMISSIONS`
- Feature flags: Hides items if feature disabled

---

#### Breadcrumbs
**Purpose:** Breadcrumb navigation trail

**Props:**
- `items: BreadcrumbItem[]` - Breadcrumb items
- `separator?: ReactNode` - Separator element (default: "/")

**BreadcrumbItem:**
```typescript
interface BreadcrumbItem {
  label: string;
  href?: string; // If not provided, item is non-clickable
}
```

---

#### NotificationCenter
**Purpose:** Toast notifications, banners, inline alerts

**Components:**
- `Toast` - Temporary notification (auto-dismiss)
- `Banner` - Persistent banner (until dismissed)
- `Alert` - Inline alert (contextual)

**Toast Props:**
- `title: string` - Toast title
- `description?: string` - Toast description
- `variant?: 'success' | 'error' | 'warning' | 'info'` - Toast type
- `duration?: number` - Auto-dismiss duration (ms)
- `onDismiss?: () => void` - Dismiss handler

**Banner Props:**
- `title: string` - Banner title
- `description?: string` - Banner description
- `variant?: 'success' | 'error' | 'warning' | 'info'`
- `dismissible?: boolean` - Allow dismissal (default: true)
- `onDismiss?: () => void` - Dismiss handler

**Alert Props:**
- `title: string` - Alert title
- `description?: string` - Alert description
- `variant?: 'success' | 'error' | 'warning' | 'info'`

---

#### Modal / Drawer
**Purpose:** Overlay dialogs (modal) and side panels (drawer)

**Modal Props:**
- `open: boolean` - Open state
- `onOpenChange: (open: boolean) => void` - Open state handler
- `title?: string` - Modal title
- `description?: string` - Modal description
- `children: ReactNode` - Modal content
- `size?: 'sm' | 'md' | 'lg' | 'xl' | 'full'` - Modal size
- `closable?: boolean` - Show close button (default: true)

**Drawer Props:**
- `open: boolean` - Open state
- `onOpenChange: (open: boolean) => void` - Open state handler
- `title?: string` - Drawer title
- `side?: 'left' | 'right' | 'top' | 'bottom'` - Drawer side (default: 'right')
- `children: ReactNode` - Drawer content

**Cross-cutting:**
- Accessibility: Focus trap, ESC key handling, ARIA attributes
- Telemetry: `onEvent('modal_open', { title, context })`

---

### 3.2 Identity & Session Components

#### LoginDialog
**Purpose:** Sign-in modal dialog

**Props:**
- `open: boolean` - Open state
- `onOpenChange: (open: boolean) => void` - Open state handler
- `tenantId?: string` - Tenant context (for SSO)
- `providers?: AuthProvider[]` - Available auth providers (email, Google, etc.)
- `onSuccess?: (user: User) => void` - Success handler
- `onError?: (error: Error) => void` - Error handler
- `redirectPath?: string` - Redirect after login

**AuthProvider:**
```typescript
type AuthProvider = 'email' | 'google' | 'apple' | 'sso';
```

**Events:**
- `onSignIn?: (provider: AuthProvider, credentials?: Credentials) => void`

**Cross-cutting:**
- Telemetry: `onEvent('login_attempt', { provider, tenantId })`
- Feature flags: SSO providers based on tenant config

---

#### SignupDialog
**Purpose:** Sign-up modal dialog

**Props:**
- `open: boolean` - Open state
- `onOpenChange: (open: boolean) => void` - Open state handler
- `tenantId?: string` - Tenant context
- `providers?: AuthProvider[]` - Available auth providers
- `onSuccess?: (user: User) => void` - Success handler
- `onError?: (error: Error) => void` - Error handler
- `requireEmailVerification?: boolean` - Require email verification

**Events:**
- `onSignUp?: (provider: AuthProvider, data: SignUpData) => void`

**SignUpData:**
```typescript
interface SignUpData {
  email: string;
  password?: string; // If email provider
  fullName?: string;
  phone?: string;
  acceptTerms: boolean;
  marketingConsent?: boolean;
}
```

**Cross-cutting:**
- Telemetry: `onEvent('signup_attempt', { provider, tenantId })`
- Consent management: Terms acceptance, marketing consent

---

#### SessionTimeoutDialog
**Purpose:** Session expiration warning/expired dialog

**Props:**
- `open: boolean` - Open state
- `secondsRemaining?: number` - Seconds until expiration (for warning)
- `expired?: boolean` - Session already expired
- `onExtend?: () => void` - Extend session handler
- `onSignIn?: () => void` - Re-authenticate handler
- `onDismiss?: () => void` - Dismiss handler (if warning)

**States:**
- Warning: Shows countdown, "Extend Session" button
- Expired: Shows "Session expired", "Sign In" button

---

#### ImpersonationBanner
**Purpose:** Banner shown when admin impersonates user (backoffice only)

**Props:**
- `impersonatedUser: User` - User being impersonated
- `impersonatingUser: User` - Admin user
- `onExit: () => void` - Exit impersonation handler

**Display:**
- Banner: "You are viewing as [User Name]" + "Exit Impersonation" button
- Always visible at top of page
- Time-limited: Auto-exit after 1 hour

**Cross-cutting:**
- Audit logging: Logged on enter/exit

---

#### ConsentBanner
**Purpose:** Cookie/tracking consent banner

**Props:**
- `tenantId: string` - Tenant context
- `consentOptions: ConsentOption[]` - Consent options (required, analytics, marketing)
- `onConsentChange?: (consents: ConsentPreferences) => void` - Consent handler
- `privacyPolicyUrl?: string` - Privacy policy link

**ConsentOption:**
```typescript
interface ConsentOption {
  id: string;
  label: string;
  description: string;
  required?: boolean; // Cannot be disabled
  default?: boolean; // Default checked state
}
```

**ConsentPreferences:**
```typescript
interface ConsentPreferences {
  [key: string]: boolean; // Consent option ID -> accepted
}
```

**Cross-cutting:**
- Privacy compliance: GDPR, CCPA support
- Telemetry: Only track if consent granted

---

### 3.3 Hotel Domain Components

#### HotelSearchBar
**Purpose:** Hotel search widget (destination, dates, guests)

**Props:**
- `propertyId?: string` - Pre-selected property
- `checkIn?: Date` - Pre-selected check-in date
- `checkOut?: Date` - Pre-selected check-out date
- `guests?: { adults: number; children: number }` - Pre-selected guests
- `onSearch?: (params: SearchParams) => void` - Search handler
- `properties?: Property[]` - Available properties (for selector)
- `minDate?: Date` - Minimum selectable date
- `maxDate?: Date` - Maximum selectable date
- `variant?: 'compact' | 'full'` - Display variant

**SearchParams:**
```typescript
interface SearchParams {
  propertyId?: string;
  checkIn: Date;
  checkOut: Date;
  guests: { adults: number; children: number };
}
```

**Events:**
- `onSearchSubmit?: (params: SearchParams) => void`
- `onPropertyChange?: (propertyId: string) => void`
- `onDatesChange?: (checkIn: Date, checkOut: Date) => void`
- `onGuestsChange?: (guests: { adults: number; children: number }) => void`

**Cross-cutting:**
- Telemetry: `onEvent('hotel_search', { propertyId, dates, guests })`
- Validation: Minimum stay rules, date validation

---

#### PropertyCard
**Purpose:** Property display card (list/grid view)

**Props:**
- `property: Property` - Property data
- `variant?: 'grid' | 'list'` - Display variant
- `showPrice?: boolean` - Show starting price (default: true)
- `showRating?: boolean` - Show rating (default: true)
- `onSelect?: (propertyId: string) => void` - Selection handler
- `href?: string` - Link href (if provided, card is clickable)

**Property:**
```typescript
interface Property {
  id: string;
  name: string;
  slug: string;
  imageUrl?: string;
  location: { city: string; state?: string; country: string };
  rating?: number;
  reviewCount?: number;
  startingPrice?: number;
  currency?: string;
  amenities?: string[];
}
```

**Events:**
- `onClick?: (propertyId: string) => void`

---

#### PropertyFilterPanel
**Purpose:** Filters sidebar for property/room search

**Props:**
- `filters: FilterState` - Current filter state
- `onFiltersChange: (filters: FilterState) => void` - Filter change handler
- `availableOptions: FilterOptions` - Available filter options

**FilterState:**
```typescript
interface FilterState {
  priceRange?: [number, number]; // Min, max
  roomTypes?: string[]; // Selected room type IDs
  amenities?: string[]; // Selected amenity IDs
  bedTypes?: string[]; // Selected bed type IDs
  maxOccupancy?: number;
}
```

**FilterOptions:**
```typescript
interface FilterOptions {
  priceRange: [number, number]; // Min, max available
  roomTypes: { id: string; label: string }[];
  amenities: { id: string; label: string }[];
  bedTypes: { id: string; label: string }[];
  maxOccupancyRange: [number, number];
}
```

**Events:**
- `onApplyFilters?: (filters: FilterState) => void`
- `onClearFilters?: () => void`

---

#### RoomCard
**Purpose:** Room type display card

**Props:**
- `room: RoomType` - Room type data
- `availability?: AvailabilityStatus` - Availability status
- `price?: number` - Current price (for selected dates)
- `currency?: string` - Currency code
- `onSelect?: (roomId: string) => void` - Selection handler
- `href?: string` - Link href

**RoomType:**
```typescript
interface RoomType {
  id: string;
  name: string;
  slug: string;
  description?: string;
  images?: string[];
  amenities?: string[];
  maxOccupancy: number;
  bedTypes?: string[];
}
```

**AvailabilityStatus:**
```typescript
type AvailabilityStatus = 'available' | 'limited' | 'sold_out' | 'unknown';
```

---

#### AvailabilityStatusBadge
**Purpose:** Availability status indicator

**Props:**
- `status: AvailabilityStatus` - Availability status
- `variant?: 'badge' | 'text' | 'icon'` - Display variant

---

#### BookingStepper
**Purpose:** Multi-step booking flow indicator

**Props:**
- `currentStep: number` - Current step (1-indexed)
- `steps: Step[]` - Step definitions
- `orientation?: 'horizontal' | 'vertical'` - Layout orientation

**Step:**
```typescript
interface Step {
  id: string;
  label: string;
  description?: string;
  completed?: boolean;
}
```

---

#### GuestDetailsForm
**Purpose:** Guest information form (booking flow)

**Props:**
- `guest?: Guest` - Pre-filled guest data (if authenticated)
- `onSubmit: (data: GuestData) => void` - Submit handler
- `requireEmail?: boolean` - Require email (default: true)
- `requirePhone?: boolean` - Require phone (default: true)
- `showCreateAccount?: boolean` - Show "Create account" checkbox

**GuestData:**
```typescript
interface GuestData {
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  specialRequests?: string;
  createAccount?: boolean; // If showCreateAccount is true
}
```

**Events:**
- `onChange?: (data: Partial<GuestData>) => void` - Form data changed
- `onValidationError?: (errors: ValidationErrors) => void` - Validation errors

---

#### PaymentMethodSelector
**Purpose:** Payment method selection (credit card, debit, wallet)

**Props:**
- `selectedMethod?: PaymentMethod` - Selected method
- `onMethodChange: (method: PaymentMethod) => void` - Method change handler
- `availableMethods?: PaymentMethod[]` - Available methods (default: all)

**PaymentMethod:**
```typescript
type PaymentMethod = 'credit_card' | 'debit_card' | 'wallet' | 'bank_transfer';
```

---

#### PaymentForm
**Purpose:** Payment form (PCI-compliant, tokenized)

**Props:**
- `method: PaymentMethod` - Payment method
- `amount: number` - Payment amount
- `currency: string` - Currency code
- `onSubmit: (token: PaymentToken) => void` - Submit handler (returns token, not card details)
- `onError?: (error: Error) => void` - Error handler

**PaymentToken:**
```typescript
interface PaymentToken {
  token: string; // Payment gateway token
  last4?: string; // Last 4 digits (for display)
  brand?: string; // Card brand (visa, mastercard, etc.)
}
```

**Security:**
- Card details never touch client/server (tokenized via payment gateway)
- PCI-compliant implementation required

---

#### BookingSummary
**Purpose:** Booking summary card (review step)

**Props:**
- `booking: BookingDetails` - Booking details
- `pricing: PricingBreakdown` - Pricing breakdown
- `cancellationPolicy?: CancellationPolicy` - Cancellation policy
- `showModifyLink?: boolean` - Show "Modify" link

**BookingDetails:**
```typescript
interface BookingDetails {
  propertyName: string;
  roomTypeName: string;
  checkIn: Date;
  checkOut: Date;
  guests: { adults: number; children: number };
  duration: number; // Nights
}
```

**PricingBreakdown:**
```typescript
interface PricingBreakdown {
  baseRate: number;
  taxes: number;
  serviceCharge?: number;
  fees?: number;
  total: number;
  currency: string;
}
```

---

#### BookingStatusBadge
**Purpose:** Booking status indicator

**Props:**
- `status: BookingStatus` - Booking status
- `variant?: 'badge' | 'text'` - Display variant

**BookingStatus:**
```typescript
type BookingStatus = 
  | 'pending' 
  | 'confirmed' 
  | 'checked_in' 
  | 'checked_out' 
  | 'cancelled' 
  | 'no_show';
```

---

### 3.4 Restaurant Domain Components

#### RestaurantSelector
**Purpose:** Restaurant selection (if multiple restaurants)

**Props:**
- `restaurants: Restaurant[]` - Available restaurants
- `selectedId?: string` - Selected restaurant ID
- `onSelect: (restaurantId: string) => void` - Selection handler
- `variant?: 'dropdown' | 'cards'` - Display variant

---

#### ServiceModeToggle
**Purpose:** Service mode selector (Dine-in, Takeaway, Delivery)

**Props:**
- `modes: ServiceMode[]` - Available modes
- `selectedMode: ServiceMode` - Selected mode
- `onModeChange: (mode: ServiceMode) => void` - Mode change handler

**ServiceMode:**
```typescript
type ServiceMode = 'dine_in' | 'takeaway' | 'delivery';
```

**Cross-cutting:**
- Feature flags: Modes based on tenant config (`tenant.enableDelivery`, etc.)

---

#### MenuCategoryList
**Purpose:** Menu category tabs/list

**Props:**
- `categories: MenuCategory[]` - Menu categories
- `selectedCategoryId?: string` - Selected category ID
- `onCategorySelect: (categoryId: string) => void` - Category selection handler
- `variant?: 'tabs' | 'list'` - Display variant

**MenuCategory:**
```typescript
interface MenuCategory {
  id: string;
  name: string;
  description?: string;
}
```

---

#### MenuItemCard
**Purpose:** Menu item display card

**Props:**
- `item: MenuItem` - Menu item data
- `availability?: AvailabilityStatus` - Availability status
- `onAddToCart?: (itemId: string) => void` - Add to cart handler

**MenuItem:**
```typescript
interface MenuItem {
  id: string;
  name: string;
  description?: string;
  price: number;
  imageUrl?: string;
  categoryId: string;
  dietaryInfo?: DietaryInfo;
  allergens?: string[];
  customizationOptions?: CustomizationOption[];
}
```

**DietaryInfo:**
```typescript
interface DietaryInfo {
  vegetarian?: boolean;
  vegan?: boolean;
  glutenFree?: boolean;
  halal?: boolean;
  kosher?: boolean;
}
```

---

#### DietaryTag
**Purpose:** Dietary/allergen tag badge

**Props:**
- `type: DietaryType` - Dietary type
- `variant?: 'badge' | 'icon'` - Display variant

**DietaryType:**
```typescript
type DietaryType = 'vegetarian' | 'vegan' | 'gluten_free' | 'halal' | 'kosher';
```

---

#### CartSidebar
**Purpose:** Shopping cart sidebar (restaurant orders)

**Props:**
- `items: CartItem[]` - Cart items
- `subtotal: number` - Subtotal
- `tax: number` - Tax
- `serviceCharge?: number` - Service charge
- `tip?: number` - Tip (if enabled)
- `total: number` - Total
- `currency: string` - Currency code
- `onItemUpdate?: (itemId: string, quantity: number) => void` - Item quantity update
- `onItemRemove?: (itemId: string) => void` - Item removal
- `onReviewOrder?: () => void` - Review order handler
- `tipEnabled?: boolean` - Enable tip selector
- `onTipChange?: (tip: number) => void` - Tip change handler

**CartItem:**
```typescript
interface CartItem {
  id: string;
  menuItemId: string;
  name: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  customization?: Customization; // Selected options
  specialInstructions?: string;
}
```

**Events:**
- `onCheckout?: () => void` - Checkout handler

---

#### TipSelector
**Purpose:** Tip selection (percentage or fixed amount)

**Props:**
- `subtotal: number` - Subtotal (for percentage calculation)
- `selectedTip?: number` - Selected tip amount
- `onTipChange: (tip: number) => void` - Tip change handler
- `presets?: number[]` - Preset percentages (default: [10, 15, 20])
- `allowCustom?: boolean` - Allow custom amount (default: true)

---

#### ReservationTimePicker
**Purpose:** Table reservation or pickup time selector

**Props:**
- `date: Date` - Selected date
- `availableSlots: TimeSlot[]` - Available time slots
- `selectedSlot?: TimeSlot` - Selected slot
- `onSlotSelect: (slot: TimeSlot) => void` - Slot selection handler
- `mode: 'dine_in' | 'takeaway'` - Mode (affects slot availability)

**TimeSlot:**
```typescript
interface TimeSlot {
  time: string; // HH:mm format
  available: boolean;
  capacity?: number; // For dine-in, available tables
}
```

---

#### OrderSummary
**Purpose:** Order summary (review step)

**Props:**
- `order: OrderDetails` - Order details
- `pricing: OrderPricing` - Pricing breakdown
- `timeSlot?: TimeSlot` - Selected time slot
- `contactInfo: ContactInfo` - Contact information
- `specialInstructions?: string` - Special instructions

**OrderDetails:**
```typescript
interface OrderDetails {
  restaurantName: string;
  mode: ServiceMode;
  items: OrderItem[];
  deliveryAddress?: string; // If delivery mode
}
```

---

#### OrderStatusBadge
**Purpose:** Order status indicator

**Props:**
- `status: OrderStatus` - Order status
- `variant?: 'badge' | 'text'` - Display variant

**OrderStatus:**
```typescript
type OrderStatus = 
  | 'pending' 
  | 'confirmed' 
  | 'in_preparation' 
  | 'ready' 
  | 'served' 
  | 'out_for_delivery' 
  | 'delivered' 
  | 'cancelled' 
  | 'no_show';
```

---

### 3.5 Backoffice & Admin Components

#### DashboardCard
**Purpose:** Section container for dashboard content

**Props:**
- `title?: string` - Card title
- `description?: string` - Card description
- `children: ReactNode` - Card content
- `actions?: ReactNode` - Action buttons (top right)
- `variant?: 'default' | 'outline'` - Card variant

---

#### KPITile
**Purpose:** Key Performance Indicator display tile

**Props:**
- `title: string` - KPI title
- `value: string | number` - KPI value
- `unit?: string` - Value unit (e.g., "$", "%")
- `trend?: TrendData` - Trend data (up/down, percentage)
- `variant?: 'default' | 'success' | 'warning' | 'error'` - Color variant

**TrendData:**
```typescript
interface TrendData {
  direction: 'up' | 'down' | 'neutral';
  percentage: number;
  period?: string; // e.g., "vs last week"
}
```

---

#### DataTable
**Purpose:** Sortable, filterable, virtualized data table

**Props:**
- `columns: Column[]` - Table columns
- `data: Row[]` - Table rows
- `loading?: boolean` - Loading state
- `sortable?: boolean` - Enable sorting (default: true)
- `filterable?: boolean` - Enable filtering (default: true)
- `pagination?: PaginationConfig` - Pagination config
- `onRowClick?: (row: Row) => void` - Row click handler
- `onSortChange?: (sort: SortConfig) => void` - Sort change handler
- `onFiltersChange?: (filters: FilterConfig) => void` - Filter change handler

**Column:**
```typescript
interface Column {
  id: string;
  header: string;
  accessor: (row: Row) => any;
  sortable?: boolean;
  filterable?: boolean;
  render?: (value: any, row: Row) => ReactNode; // Custom render
}
```

**Row:**
```typescript
type Row = Record<string, any>;
```

**PaginationConfig:**
```typescript
interface PaginationConfig {
  page: number;
  pageSize: number;
  total: number;
  onPageChange: (page: number) => void;
  onPageSizeChange: (pageSize: number) => void;
}
```

**Cross-cutting:**
- Virtualization: For large datasets (react-window or similar)
- Accessibility: Keyboard navigation, ARIA attributes

---

#### FiltersBar
**Purpose:** Filter controls bar (for tables/lists)

**Props:**
- `filters: FilterConfig[]` - Filter configurations
- `values: FilterValues` - Current filter values
- `onFiltersChange: (values: FilterValues) => void` - Filter change handler
- `onClear?: () => void` - Clear all filters handler

**FilterConfig:**
```typescript
interface FilterConfig {
  id: string;
  label: string;
  type: 'text' | 'select' | 'date' | 'date_range' | 'number';
  options?: { label: string; value: any }[]; // For select type
}
```

---

#### DateRangePicker
**Purpose:** Date range selection

**Props:**
- `startDate?: Date` - Start date
- `endDate?: Date` - End date
- `onDateRangeChange: (start: Date, end: Date) => void` - Date range change handler
- `minDate?: Date` - Minimum selectable date
- `maxDate?: Date` - Maximum selectable date
- `presets?: DateRangePreset[]` - Preset ranges (Today, This Week, etc.)

---

#### TenantSelector
**Purpose:** Tenant selector (for global admins)

**Props:**
- `tenants: Tenant[]` - Available tenants
- `selectedTenantId?: string` - Selected tenant ID
- `onTenantChange: (tenantId: string) => void` - Tenant change handler
- `showStatus?: boolean` - Show tenant status badge

---

#### StaffTable
**Purpose:** Staff list table (admin console)

**Props:**
- `staff: StaffMember[]` - Staff members
- `loading?: boolean` - Loading state
- `onEdit?: (staffId: string) => void` - Edit handler
- `onDeactivate?: (staffId: string) => void` - Deactivate handler
- `onResetPassword?: (staffId: string) => void` - Reset password handler
- `permissions: Permission[]` - Current user permissions (for action visibility)

**StaffMember:**
```typescript
interface StaffMember {
  id: string;
  email: string;
  fullName: string;
  role: AppRole;
  propertyId?: string;
  propertyName?: string;
  status: 'active' | 'inactive';
  lastLogin?: Date;
}
```

**Cross-cutting:**
- RBAC: Action buttons visible based on permissions

---

#### RoleBadge
**Purpose:** Role display badge

**Props:**
- `role: AppRole` - Role
- `variant?: 'badge' | 'text'` - Display variant

---

#### PermissionMatrixView
**Purpose:** Permission matrix display (admin console)

**Props:**
- `roles: AppRole[]` - Roles to display
- `permissions: Permission[]` - Permissions to display
- `rolePermissions: Record<AppRole, Permission[]>` - Role-permission mapping
- `readOnly?: boolean` - Read-only mode (default: true)
- `onPermissionChange?: (role: AppRole, permission: Permission, granted: boolean) => void` - Permission change handler

---

#### AuditLogTable
**Purpose:** Audit log table (specialized DataTable)

**Props:**
- `logs: AuditLogEntry[]` - Audit log entries
- `loading?: boolean` - Loading state
- `onEntryExpand?: (entry: AuditLogEntry) => void` - Entry expand handler (for details)
- `pagination?: PaginationConfig` - Pagination config

**AuditLogEntry:**
```typescript
interface AuditLogEntry {
  id: string;
  timestamp: Date;
  userId: string;
  userName: string;
  action: string;
  resourceType: string;
  resourceId: string;
  before?: Record<string, any>;
  after?: Record<string, any>;
  ipAddress?: string;
  userAgent?: string;
}
```

---

#### ExportButton
**Purpose:** Export button (CSV, PDF) with permission check

**Props:**
- `format: 'csv' | 'pdf'` - Export format
- `data: any[]` - Data to export
- `filename?: string` - Export filename
- `columns?: ExportColumn[]` - Column definitions (for CSV)
- `onExport?: (format: 'csv' | 'pdf') => Promise<void>` - Export handler
- `requiredPermission?: Permission` - Required permission (for visibility)

**ExportColumn:**
```typescript
interface ExportColumn {
  key: string;
  label: string;
  format?: (value: any) => string; // Custom formatter
}
```

**Cross-cutting:**
- RBAC: Button hidden if user lacks permission
- Telemetry: `onEvent('export', { format, filename, rowCount })`

---

## 4. State & UX Models (Hardened)

### 4.1 Booking Flow State Machine

**States:**
- `BROWSING` - User browsing rooms
- `SELECTING_ROOM` - User viewing room details, deciding
- `FILLING_GUEST_DETAILS` - User filling guest information form
- `REVIEWING` - User reviewing booking details before payment
- `PAYMENT_IN_PROGRESS` - Payment processing
- `PAYMENT_FAILED` - Payment failed, retry available
- `CONFIRMED` - Booking confirmed
- `EXPIRED` - Booking expired (session timeout or hold expired)
- `CANCELLED` - Booking cancelled

**State Transitions:**

```
BROWSING 
  → SELECTING_ROOM (user clicks "Book This Room")
  
SELECTING_ROOM 
  → FILLING_GUEST_DETAILS (user clicks "Continue" or availability confirmed)
  → BROWSING (user clicks "Back" or "View Other Rooms")

FILLING_GUEST_DETAILS 
  → REVIEWING (form valid, user clicks "Continue")
  → SELECTING_ROOM (user clicks "Back")

REVIEWING 
  → PAYMENT_IN_PROGRESS (user clicks "Complete Booking", payment form valid)
  → FILLING_GUEST_DETAILS (user clicks "Edit Details")
  → SELECTING_ROOM (user clicks "Change Room")

PAYMENT_IN_PROGRESS 
  → CONFIRMED (payment successful)
  → PAYMENT_FAILED (payment failed)
  → EXPIRED (payment timeout)

PAYMENT_FAILED 
  → REVIEWING (user clicks "Retry Payment")
  → FILLING_GUEST_DETAILS (user clicks "Change Payment Method")
  → EXPIRED (max retries exceeded or timeout)

CONFIRMED 
  → [Terminal state]

EXPIRED 
  → BROWSING (user clicks "Start Over")
  → [Terminal state if not recovered]

CANCELLED 
  → [Terminal state]
```

**State Behaviors:**

**BROWSING:**
- **UI:** Room listing, filters, search
- **Actions:** Select room, modify search
- **Data Persisted:** Search params (dates, guests), filter preferences (localStorage)
- **Telemetry:** `booking_search`, `filter_applied`, `room_viewed`

**SELECTING_ROOM:**
- **UI:** Room detail page, booking widget
- **Actions:** Book room, view similar rooms, modify dates
- **Data Persisted:** Selected room, dates, guests (sessionStorage)
- **Validation:** Availability check (real-time)
- **Telemetry:** `room_detail_viewed`, `availability_checked`

**FILLING_GUEST_DETAILS:**
- **UI:** Guest details form
- **Actions:** Fill form, create account (optional), continue
- **Data Persisted:** Guest data (form state, localStorage)
- **Validation:** Email format, required fields, phone format
- **Tenant Rules:** Required fields based on tenant config
- **Telemetry:** `guest_details_started`

**REVIEWING:**
- **UI:** Booking summary, terms acceptance, payment form
- **Actions:** Complete booking, edit details, change room
- **Data Persisted:** Full booking data (sessionStorage)
- **Validation:** Price validation (check for changes), terms acceptance
- **Tenant Rules:** Cancellation policy display, deposit requirements
- **Telemetry:** `booking_review_started`

**PAYMENT_IN_PROGRESS:**
- **UI:** Loading spinner, payment processing message
- **Actions:** None (disabled)
- **Data Persisted:** Booking data, payment attempt (with idempotency key)
- **Validation:** Payment gateway validation
- **Idempotency:** Idempotency key prevents duplicate charges
- **Telemetry:** `payment_attempted`, `payment_in_progress`

**PAYMENT_FAILED:**
- **UI:** Error message, retry button, change payment method link
- **Actions:** Retry payment (max 3 attempts), change payment method
- **Data Persisted:** Failed attempt log, retry count
- **Telemetry:** `payment_failed`, `payment_retry`

**CONFIRMED:**
- **UI:** Success message, booking confirmation card, next actions
- **Actions:** Download PDF, add to calendar, view booking, create account (if guest)
- **Data Persisted:** Booking record (database), confirmation email sent
- **Telemetry:** `booking_confirmed`, `confirmation_email_sent`

**EXPIRED:**
- **UI:** Expiration message, "Start Over" button
- **Actions:** Start over (clears data, redirects to property landing)
- **Data Persisted:** None (cleared)
- **Recovery:** If expired < 5 minutes, option to extend session
- **Telemetry:** `booking_expired`

---

### 4.2 Restaurant Order State Machine

**States:**
- `BROWSING_MENU` - User browsing menu
- `BUILDING_ORDER` - User adding items to cart
- `SUBMITTING_ORDER` - Order submission in progress
- `WAITING_CONFIRMATION` - Order submitted, waiting for confirmation
- `CONFIRMED` - Order confirmed by restaurant
- `IN_PREPARATION` - Order being prepared
- `READY` - Order ready (for pickup/delivery) or table ready (for dine-in)
- `SERVED` - Order served (dine-in only)
- `OUT_FOR_DELIVERY` - Order out for delivery (delivery only)
- `DELIVERED` - Order delivered (delivery only)
- `CANCELLED` - Order cancelled
- `NO_SHOW` - Reservation no-show (dine-in only)

**State Transitions:**

```
BROWSING_MENU 
  → BUILDING_ORDER (user adds item to cart)

BUILDING_ORDER 
  → BROWSING_MENU (user continues shopping)
  → SUBMITTING_ORDER (user clicks "Place Order")

SUBMITTING_ORDER 
  → WAITING_CONFIRMATION (order submitted, API response received)
  → BUILDING_ORDER (submission failed, error)

WAITING_CONFIRMATION 
  → CONFIRMED (restaurant confirms order)
  → CANCELLED (restaurant rejects order)

CONFIRMED 
  → IN_PREPARATION (restaurant starts preparation)
  → CANCELLED (user or restaurant cancels)

IN_PREPARATION 
  → READY (preparation complete)
  → CANCELLED (cancelled)

READY 
  → SERVED (dine-in: order served to table)
  → OUT_FOR_DELIVERY (delivery: order dispatched)
  → DELIVERED (takeaway: order picked up, considered delivered)
  → CANCELLED (cancelled)

OUT_FOR_DELIVERY 
  → DELIVERED (delivery complete)
  → CANCELLED (cancelled)

SERVED / DELIVERED 
  → [Terminal states]

CANCELLED / NO_SHOW 
  → [Terminal states]
```

**State Behaviors:**

**BROWSING_MENU:**
- **UI:** Menu categories, menu items, cart sidebar
- **Actions:** Add item to cart, view item details, select service mode
- **Data Persisted:** Cart (localStorage, session-scoped)
- **Real-time Updates:** Menu item availability (polling or websocket)
- **Telemetry:** `menu_viewed`, `menu_item_viewed`, `cart_item_added`

**BUILDING_ORDER:**
- **UI:** Cart sidebar, menu items (continue shopping)
- **Actions:** Update quantities, remove items, review order
- **Data Persisted:** Cart state (localStorage)
- **Validation:** Item availability check before checkout
- **Telemetry:** `cart_updated`

**SUBMITTING_ORDER:**
- **UI:** Loading spinner, "Placing order..." message
- **Actions:** None (disabled)
- **Data Persisted:** Order submission (with idempotency key)
- **Validation:** Final availability check, payment (if prepayment required)
- **Idempotency:** Idempotency key prevents duplicate orders
- **Telemetry:** `order_submission_attempted`

**WAITING_CONFIRMATION:**
- **UI:** "Order submitted, waiting for confirmation" message
- **Actions:** Cancel order (if allowed by policy)
- **Data Persisted:** Order record (pending status)
- **Real-time Updates:** Polling or websocket for confirmation
- **Timeout:** Auto-confirm after 5 minutes (if restaurant doesn't respond)
- **Telemetry:** `order_waiting_confirmation`

**CONFIRMED:**
- **UI:** Confirmation message, order details, estimated ready time
- **Actions:** Cancel order (if policy allows), contact restaurant
- **Data Persisted:** Order record (confirmed status)
- **Real-time Updates:** Status polling or websocket
- **Telemetry:** `order_confirmed`, `confirmation_sms_sent`

**IN_PREPARATION:**
- **UI:** "Your order is being prepared" message, estimated ready time countdown
- **Actions:** Cancel order (if policy allows), contact restaurant
- **Data Persisted:** Order status update
- **Real-time Updates:** Status polling or websocket
- **Telemetry:** `order_in_preparation`

**READY:**
- **UI:** "Your order is ready" notification, action buttons
- **Actions:** 
  - Dine-in: "I'm here" button (notifies restaurant)
  - Takeaway: "Pickup Instructions" link
  - Delivery: "Track Delivery" link
- **Data Persisted:** Order status update, ready timestamp
- **Real-time Updates:** Status polling or websocket
- **Telemetry:** `order_ready`, `ready_notification_sent`

**SERVED / DELIVERED:**
- **UI:** "Order complete" message, rating prompt
- **Actions:** Rate order, reorder, view receipt
- **Data Persisted:** Order status (terminal), completion timestamp
- **Telemetry:** `order_completed`, `rating_prompt_shown`

**CANCELLED:**
- **UI:** Cancellation message, refund status (if applicable)
- **Actions:** Reorder (same items)
- **Data Persisted:** Order status (cancelled), cancellation reason
- **Telemetry:** `order_cancelled`, `refund_processed` (if applicable)

---

### 4.3 Session & Identity Model

**States:**
- `ANONYMOUS` - No authenticated user
- `AUTH_PENDING` - Authentication in progress (login/signup modal open)
- `AUTHENTICATED` - User authenticated, valid session
- `SESSION_EXPIRED` - Session expired, refresh available or required
- `IMPERSONATION` - Admin impersonating user (backoffice only)

**State Transitions:**

```
ANONYMOUS 
  → AUTH_PENDING (user clicks "Sign In")
  → AUTHENTICATED (successful login/signup)

AUTH_PENDING 
  → AUTHENTICATED (authentication successful)
  → ANONYMOUS (authentication failed or cancelled)

AUTHENTICATED 
  → SESSION_EXPIRED (token expired, refresh failed)
  → ANONYMOUS (user signs out)

SESSION_EXPIRED 
  → AUTHENTICATED (session refreshed or user re-authenticates)
  → ANONYMOUS (refresh failed, user signs out)

IMPERSONATION 
  → AUTHENTICATED (admin exits impersonation)
  → [Always returns to admin's authenticated state]
```

**State Behaviors:**

**ANONYMOUS:**
- **Session ID:** UUID stored in cookie/localStorage (7-day expiration)
- **Data Storage:** Cart, booking progress, recent searches (localStorage, tenant-scoped)
- **PII:** None (no guest record)
- **Telemetry:** Anonymous session ID, device fingerprint (if consent)

**AUTH_PENDING:**
- **UI:** Login/signup modal, loading states
- **Timeout:** 5 minutes (auto-close modal, revert to ANONYMOUS)
- **Telemetry:** `auth_attempted`, `auth_provider_selected`

**AUTHENTICATED:**
- **Session:** JWT token (30-day expiration, refresh token)
- **Guest Record:** Linked to user_id (created on first booking/login)
- **Data Storage:** User profile, preferences, booking history (database)
- **Data Migration:** Anonymous session data merged on login (tenant-scoped)
- **Telemetry:** `user_id`, `tenant_id`

**SESSION_EXPIRED:**
- **UI:** "Session expired" dialog
- **Auto-refresh:** Silent refresh attempt (if refresh token valid)
- **Recovery:** User can extend session or re-authenticate
- **Unsaved Work:** Preserved in localStorage where possible
- **Telemetry:** `session_expired`, `session_refresh_attempted`

**IMPERSONATION:**
- **Banner:** Always visible, "Viewing as [User Name]"
- **Time Limit:** 1 hour (auto-exit)
- **Audit Logging:** All actions logged with admin ID + impersonated user ID
- **Exit:** "Exit Impersonation" button (always visible)
- **Telemetry:** `impersonation_started`, `impersonation_ended`

---

### 4.4 UI States per View/Component

**Common UI States:**
- `idle` - Initial state, no user interaction
- `loading` - Data fetching or processing
- `empty` - No data available
- `error` - Error state (network, validation, etc.)
- `success` - Success state (action completed)
- `disabled` - Component disabled (permission, validation, etc.)
- `readonly` - Read-only mode (viewing, no edits allowed)

**State Patterns:**

**idle:**
- **UI:** Default component state
- **Actions:** User can interact
- **Telemetry:** None (baseline)

**loading:**
- **UI:** Loading spinner, skeleton loader, or disabled state
- **Actions:** Disabled (cannot interact)
- **Telemetry:** `loading_started`, `loading_completed`

**empty:**
- **UI:** Empty state illustration, message, suggested actions
- **Actions:** "Add Item", "Create New", etc. (context-dependent)
- **Message:** Guidance text (e.g., "No bookings yet. Book your first stay!")
- **Telemetry:** `empty_state_viewed`

**error:**
- **UI:** Error message, error icon, retry button
- **Message:** Non-technical, actionable (e.g., "Unable to load bookings. Please try again.")
- **Actions:** Retry, contact support (with error reference ID)
- **Error Reference:** Unique ID for support (e.g., "ERR-ABC123")
- **Telemetry:** `error_occurred`, `error_type`, `error_context`

**success:**
- **UI:** Success message, success icon, next actions
- **Actions:** "View Details", "Continue", etc.
- **Telemetry:** `action_completed`, `success_message_shown`

**disabled:**
- **UI:** Grayed out, disabled cursor
- **Tooltip:** Explanation (e.g., "You don't have permission", "Form invalid")
- **Telemetry:** `disabled_interaction_attempted` (for permission checks)

**readonly:**
- **UI:** Form fields disabled, "Edit" button available
- **Actions:** Edit (switches to editable mode)
- **Telemetry:** None (viewing mode)

---

## 5. Observability, Analytics, and Audit UX

### 5.1 Public-Facing Telemetry

**Events to Track:**

**Search & Discovery:**
- `hotel_search` - User searches for hotels
  - Properties: `propertyId`, `checkIn`, `checkOut`, `guests`, `tenantId`
- `room_viewed` - User views room detail
  - Properties: `roomId`, `propertyId`, `tenantId`
- `filter_applied` - User applies filters
  - Properties: `filters`, `resultsCount`, `tenantId`
- `property_viewed` - User views property
  - Properties: `propertyId`, `tenantId`

**Menu & Restaurant:**
- `menu_viewed` - User views menu
  - Properties: `restaurantId`, `tenantId`
- `menu_item_viewed` - User views menu item detail
  - Properties: `menuItemId`, `restaurantId`, `tenantId`
- `cart_item_added` - User adds item to cart
  - Properties: `menuItemId`, `quantity`, `restaurantId`, `tenantId`

**Booking & Order Funnel:**
- `booking_started` - User starts booking flow
  - Properties: `roomId`, `propertyId`, `tenantId`
- `booking_abandoned` - User abandons booking (exit without completion)
  - Properties: `step`, `roomId`, `propertyId`, `tenantId`
- `booking_completed` - User completes booking
  - Properties: `bookingId`, `roomId`, `propertyId`, `totalAmount`, `tenantId`
- `order_started` - User starts order flow
  - Properties: `restaurantId`, `mode`, `tenantId`
- `order_completed` - User completes order
  - Properties: `orderId`, `restaurantId`, `totalAmount`, `tenantId`

**Errors:**
- `error_occurred` - Error occurs
  - Properties: `errorType`, `errorMessage`, `errorReference`, `context`, `tenantId`
- `payment_failed` - Payment fails
  - Properties: `bookingId`/`orderId`, `errorType`, `retryCount`, `tenantId`

**UX for Consent & Privacy:**
- Cookie/tracking preferences banner (ConsentBanner component)
- Per-tenant privacy policy links (in footer)
- Data retention disclosure (in privacy policy)
- "Do Not Track" header support (if enabled)

**A/B Testing & Feature Flags:**
- Variants indicated internally (feature flag value in telemetry)
- No visual indication to users (seamless experience)
- Telemetry includes: `featureFlag`, `variant`, `experimentId`

---

### 5.2 Backoffice & Admin Telemetry

**Tenant-Level Dashboards:**

**Conversion Funnels:**
- Hotel: Landing → Search → Room View → Booking Start → Booking Complete
- Restaurant: Landing → Menu View → Cart → Order Start → Order Complete
- Metrics: Conversion rate per step, drop-off points, average time per step

**Channel Breakdown:**
- Channels: Web, Mobile Web, Kiosk, Call Center, OTA
- Metrics: Bookings per channel, revenue per channel, conversion rate per channel

**Operational Metrics:**
- Hotel: Occupancy rate, ADR (Average Daily Rate), RevPAR (Revenue per Available Room)
- Restaurant: Table turn time, average order value, order completion rate
- Real-time: Today's metrics vs. targets, alerts for anomalies

**Dashboard Components:**
- KPI tiles with trend indicators
- Charts (line, bar, pie) for trends and breakdowns
- Date range selector
- Export buttons (CSV, PDF)

**Platform-Level Dashboards (Global Admin):**

**Tenant Health:**
- Metrics: Error rates, API response times, active users, bookings
- Alerts: High error rates, performance degradation, usage anomalies
- View: Per-tenant breakdown, platform-wide summary

**Performance:**
- API response times (p50, p95, p99)
- Database query performance
- Page load times
- Error rates by endpoint

**Usage Trends:**
- Bookings per tenant over time
- Active users per tenant
- Feature adoption rates
- API usage per tenant

**Feature Adoption:**
- Table: Tenant, Feature, Adoption Rate, Usage Count
- Features: OTA integration, loyalty program, analytics, etc.
- Filters: Feature, tenant, date range
- Export: Usage report (CSV/PDF)

---

### 5.3 Audit Logs & Compliance

**Sensitive Operations Logged:**

**Booking Modifications:**
- Who: User ID, user name, role
- When: Timestamp (UTC)
- What: Booking ID, field changed, before value, after value
- Context: IP address, user agent

**Refunds:**
- Who: User ID, user name, role
- When: Timestamp
- What: Booking ID, refund amount, reason, payment method
- Context: Approval workflow (if required)

**Role Changes:**
- Who: Admin user ID, target user ID
- When: Timestamp
- What: Old role, new role, property assignment
- Context: Reason (optional)

**Impersonation:**
- Who: Admin user ID, impersonated user ID
- When: Start timestamp, end timestamp
- What: Actions performed (summary)
- Context: IP address, duration

**Configuration Updates:**
- Who: User ID, role
- When: Timestamp
- What: Setting changed, before value, after value
- Context: Property/tenant scope

**AuditLogTable UX:**

**Filters:**
- Date range (required, default: last 30 days)
- User (dropdown, searchable)
- Action type (multi-select)
- Resource type (multi-select)
- Tenant (for global admin)

**Table Columns:**
- Timestamp (sortable)
- User (clickable → user profile)
- Action (sortable, filterable)
- Resource Type (filterable)
- Resource ID (clickable → resource detail)
- Before/After (expandable for full diff)
- IP Address
- Actions (expand for details)

**Expandable Details:**
- Full before/after JSON (formatted, syntax-highlighted)
- Request metadata (user agent, IP, referrer)
- Related audit entries (e.g., all actions on same resource)

**Export:**
- Format: CSV, PDF
- Includes: All filtered results (with pagination)
- Fields: All columns + full before/after data
- Filename: `audit-logs-[date-range].csv/pdf`

**Drill-down:**
- Clicking resource ID → Navigate to resource detail page
- Clicking user → Navigate to user profile (if permission)
- Clicking action → Filter by action type

**Evidence for Audits:**
- Export includes timestamps, user signatures (digital), before/after snapshots
- Export format: PDF with header/footer (tenant name, export date, exported by)
- Data retention: Configurable per tenant (default: 7 years for financial records)

**Data Retention:**
- UI: Disclosure in audit log viewer ("Logs retained for [X] years per policy")
- PII anonymization: After retention period, PII fields anonymized
- Business data: Retained per tenant policy (configurable)

---

## Summary

This document provides a comprehensive, implementation-ready design specification for an enterprise-grade, multi-tenant SaaS HMS Portal. Key highlights:

1. **Multi-tenant, multi-role flows** with explicit tenant boundaries and security considerations
2. **Detailed wireframes** with tenant-aware layouts and responsive behavior
3. **Component hierarchy** with clear contracts, props, and cross-cutting concerns
4. **Hardened state machines** for booking and ordering flows with error handling
5. **Observability & audit** embedded into UX design for compliance and analytics

All designs are suitable for direct implementation in React/TypeScript with Supabase backend, respecting RLS policies, RBAC, and tenant isolation requirements.

