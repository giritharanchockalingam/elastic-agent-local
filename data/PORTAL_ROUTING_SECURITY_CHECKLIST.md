# Portal Routing & Security Checklist

This document provides a comprehensive guide to all routes under `/portal*`, their data access patterns, security requirements, and common failure modes.

## Table of Contents

1. [Route Inventory](#route-inventory)
2. [Data Access Patterns](#data-access-patterns)
3. [Security Requirements](#security-requirements)
4. [Common Failure Modes](#common-failure-modes)
5. [Developer Guidelines](#developer-guidelines)

---

## Route Inventory

All routes under `/portal/*` require:
- ✅ Authentication (via `ProtectedRoute`)
- ✅ Property context (via `PropertyContext`)
- ✅ RBAC permissions (via `ROUTE_PERMISSIONS`)

### Core Hotel Operations

| Route | Component | Auth Level | Required Scope | Data Tables |
|-------|-----------|------------|----------------|-------------|
| `/portal/dashboard` | Dashboard | Staff/Admin | `property_id` | `reservations`, `rooms`, `guests`, `staff` |
| `/portal/front-desk` | FrontDesk | Staff/Admin | `property_id` | `reservations`, `guests`, `rooms` |
| `/portal/reservations` | Reservations | Staff/Admin | `property_id` | `reservations`, `guests`, `rooms` |
| `/portal/check-in-out` | CheckInOut | Staff/Admin | `property_id` | `reservations`, `guests`, `rooms` |
| `/portal/rooms-inventory` | RoomsInventory | Staff/Admin | `property_id` | `rooms`, `room_types` |
| `/portal/housekeeping` | Housekeeping | Staff/Admin | `property_id` | `housekeeping_tasks`, `rooms` |
| `/portal/room-service` | RoomService | Staff/Admin | `property_id` | `food_orders`, `rooms` |
| `/portal/lost-found` | LostFound | Staff/Admin | `property_id` | `lost_found_items` |
| `/portal/guest-feedback` | GuestFeedback | Staff/Admin | `property_id` | `guest_feedback` |

### Revenue & Finance

| Route | Component | Auth Level | Required Scope | Data Tables |
|-------|-----------|------------|----------------|-------------|
| `/portal/revenue` | Revenue | Staff/Admin | `property_id` | `reservations`, `invoices`, `payments` |
| `/portal/invoicing` | Invoicing | Staff/Admin | `property_id` | `invoices`, `reservations` |
| `/portal/payments` | Payments | Staff/Admin | `property_id` | `payments`, `invoices` |
| `/portal/accounting` | Accounting | Staff/Admin | `property_id` | `accounting_transactions` |
| `/portal/budgeting` | Budgeting | Staff/Admin | `property_id` | `budgets`, `expenses` |
| `/portal/expense-tracking` | ExpenseTracking | Staff/Admin | `property_id` | `expenses` |
| `/portal/payroll` | PayrollManagement | Admin | `property_id` | `payroll_records`, `staff` |
| `/portal/tax-compliance` | TaxCompliance | Admin | `property_id` | `tax_records` |
| `/portal/financial-reports` | FinancialReports | Admin | `property_id` | `reports` |

### Food & Beverage

| Route | Component | Auth Level | Required Scope | Data Tables |
|-------|-----------|------------|----------------|-------------|
| `/portal/restaurant` | Restaurant | Staff/Admin | `property_id` | `restaurant_orders`, `tables` |
| `/portal/bar` | Bar | Staff/Admin | `property_id` | `bar_orders`, `inventory` |
| `/portal/kitchen` | Kitchen | Staff/Admin | `property_id` | `kitchen_orders`, `inventory` |
| `/portal/menu` | MenuManagement | Admin | `property_id` | `menu_items`, `categories` |
| `/portal/food-orders` | FoodOrders | Staff/Admin | `property_id` | `food_orders`, `rooms` |
| `/portal/procurement` | Procurement | Admin | `property_id` | `purchase_orders`, `suppliers` |
| `/portal/inventory-fb` | InventoryFB | Staff/Admin | `property_id` | `inventory_items` |
| `/portal/wastage` | WastageManagement | Staff/Admin | `property_id` | `wastage_records` |

### Guest Services

| Route | Component | Auth Level | Required Scope | Data Tables |
|-------|-----------|------------|----------------|-------------|
| `/portal/guests` | Guests | Staff/Admin | `property_id` | `guests`, `reservations` |
| `/portal/concierge` | Concierge | Staff/Admin | `property_id` | `concierge_requests` |
| `/portal/spa` | Spa | Staff/Admin | `property_id` | `spa_bookings`, `treatments` |
| `/portal/activities` | Activities | Staff/Admin | `property_id` | `activities`, `bookings` |
| `/portal/transportation` | TransportationBooking | Staff/Admin | `property_id` | `transportation_bookings` |
| `/portal/vip-services` | VIPServices | Staff/Admin | `property_id` | `vip_requests` |
| `/portal/loyalty-program` | LoyaltyProgram | Staff/Admin | `property_id` | `loyalty_members`, `transactions` |
| `/portal/guest-communication` | GuestCommunication | Staff/Admin | `property_id` | `messages`, `notifications` |
| `/portal/laundry` | LaundryManagement | Staff/Admin | `property_id` | `laundry_orders` |

### Service Operations

| Route | Component | Auth Level | Required Scope | Data Tables |
|-------|-----------|------------|----------------|-------------|
| `/portal/service-operations` | ServiceOperations | Staff/Admin | `property_id` | `bar_orders`, `spa_bookings`, `event_bookings` |

### Staff & HR

| Route | Component | Auth Level | Required Scope | Data Tables |
|-------|-----------|------------|----------------|-------------|
| `/portal/staff-management` | StaffManagement | Admin | `property_id` | `staff`, `user_property_assignments` |
| `/portal/attendance` | AttendanceTracking | Admin | `property_id` | `staff_attendance` |
| `/portal/shift-scheduling` | ShiftScheduling | Admin | `property_id` | `shifts`, `shift_assignments` |
| `/portal/leave-management` | LeaveManagement | Admin | `property_id` | `leave_requests` |
| `/portal/recruitment` | Recruitment | Admin | `property_id` | `job_postings`, `applications` |
| `/portal/performance-reviews` | PerformanceReviews | Admin | `property_id` | `performance_reviews` |
| `/portal/training` | TrainingDevelopment | Admin | `property_id` | `training_programs` |

### Compliance

| Route | Component | Auth Level | Required Scope | Data Tables |
|-------|-----------|------------|----------------|-------------|
| `/portal/frro` | FRRO | Admin | `property_id` | `frro_records`, `guests` |
| `/portal/gst-compliance` | GSTCompliance | Admin | `property_id` | `gst_records` |
| `/portal/safety-compliance` | SafetyCompliance | Admin | `property_id` | `safety_records` |
| `/portal/audit-logs` | AuditLogs | Admin | `property_id` | `audit_logs` |
| `/portal/data-privacy` | DataPrivacy | Admin | `property_id` | `data_privacy_records` |
| `/portal/policy-management` | PolicyManagement | Admin | `property_id` | `policies` |
| `/portal/regulatory-reporting` | RegulatoryReporting | Admin | `property_id` | `regulatory_reports` |

### Analytics

| Route | Component | Auth Level | Required Scope | Data Tables |
|-------|-----------|------------|----------------|-------------|
| `/portal/analytics` | Analytics | Staff/Admin | `property_id` | Various aggregated views |
| `/portal/occupancy-analytics` | OccupancyAnalytics | Staff/Admin | `property_id` | `reservations`, `rooms` |
| `/portal/revenue-analytics` | RevenueAnalytics | Staff/Admin | `property_id` | `reservations`, `invoices` |
| `/portal/revenue-forecasting` | RevenueForecasting | Admin | `property_id` | `reservations`, `rate_plans` |
| `/portal/demand-analytics` | DemandAnalytics | Admin | `property_id` | `reservations`, `market_data` |
| `/portal/guest-insights` | GuestInsights | Staff/Admin | `property_id` | `guests`, `reservations`, `feedback` |
| `/portal/performance-metrics` | PerformanceMetrics | Admin | `property_id` | Various metrics |
| `/portal/operational-metrics` | OperationalMetrics | Staff/Admin | `property_id` | Operational data |
| `/portal/marketing-analytics` | MarketingAnalytics | Admin | `property_id` | Marketing data |
| `/portal/custom-reports` | CustomReports | Admin | `property_id` | Custom report definitions |
| `/portal/dashboards` | Dashboards | Staff/Admin | `property_id` | Dashboard configurations |

### Helpdesk

| Route | Component | Auth Level | Required Scope | Data Tables |
|-------|-----------|------------|----------------|-------------|
| `/portal/helpdesk` | Helpdesk | Staff/Admin | `property_id` | `tickets` |
| `/portal/ticket-management` | TicketManagement | Staff/Admin | `property_id` | `tickets` |
| `/portal/public-portal-inquiries` | PublicPortalInquiries | Staff/Admin | `tenant_id`, `property_id` | `leads`, `booking_requests` |
| `/portal/knowledge-base` | KnowledgeBase | Staff/Admin | `property_id` | `knowledge_base_articles` |
| `/portal/service-catalog` | ServiceCatalog | Staff/Admin | `property_id` | `service_catalog_items` |
| `/portal/live-chat` | LiveChat | Staff/Admin | `property_id` | `chat_messages` |

### Admin

| Route | Component | Auth Level | Required Scope | Data Tables |
|-------|-----------|------------|----------------|-------------|
| `/portal/admin` | Admin | Admin | `property_id` | Various admin tables |
| `/portal/user-management` | UserManagement | Admin | `property_id` | `users`, `user_roles` |
| `/portal/role-management` | RoleManagement | Admin | `property_id` | `roles`, `permissions` |
| `/portal/property-settings` | PropertySettings | Admin | `property_id` | `properties` |
| `/portal/property-management` | PropertyManagement | Super Admin | `tenant_id` | `properties`, `tenants` |
| `/portal/room-types-management` | RoomTypesManagement | Admin | `property_id` | `room_types` |
| `/portal/hotel-amenities-management` | HotelAmenitiesManagement | Admin | `property_id` | `amenities` |
| `/portal/restaurant-menu-management` | RestaurantMenuManagement | Admin | `property_id` | `menu_items` |
| `/portal/system-config` | SystemConfiguration | Admin | `property_id` | `system_settings` |
| `/portal/notifications` | Notifications | Admin | `property_id` | `notifications` |
| `/portal/i18n` | Internationalization | Admin | `property_id` | `translations` |
| `/portal/theme-customization` | ThemeCustomization | Admin | `property_id` | `themes` |
| `/portal/backup-restore` | BackupRestore | Admin | `property_id` | Backup operations |
| `/portal/pricing-rules` | PricingRules | Admin | `property_id` | `pricing_rules` |
| `/portal/email-templates` | EmailTemplates | Admin | `property_id` | `email_templates` |
| `/portal/workflows` | Workflows | Admin | `property_id` | `workflows` |
| `/portal/activity-logs` | ActivityLogs | Admin | `property_id` | `user_activity_logs` |

### Facilities

| Route | Component | Auth Level | Required Scope | Data Tables |
|-------|-----------|------------|----------------|-------------|
| `/portal/facilities` | Facilities | Staff/Admin | `property_id` | `facilities` |
| `/portal/maintenance` | MaintenanceManagement | Staff/Admin | `property_id` | `maintenance_work_orders` |
| `/portal/asset-management` | AssetManagement | Admin | `property_id` | `assets` |
| `/portal/vendor-management` | VendorManagement | Admin | `property_id` | `vendors` |
| `/portal/preventive-maintenance` | PreventiveMaintenance | Staff/Admin | `property_id` | `preventive_maintenance` |
| `/portal/energy-management` | EnergyManagement | Admin | `property_id` | `energy_consumption` |
| `/portal/space-utilization` | SpaceUtilization | Admin | `property_id` | `space_utilization` |

### Security

| Route | Component | Auth Level | Required Scope | Data Tables |
|-------|-----------|------------|----------------|-------------|
| `/portal/security` | Security | Admin | `property_id` | Security data |
| `/portal/access-control` | AccessControl | Admin | `property_id` | `access_control_logs` |
| `/portal/video-surveillance` | VideoSurveillance | Admin | `property_id` | `surveillance_logs` |
| `/portal/incident-management` | IncidentManagement | Admin | `property_id` | `incidents` |
| `/portal/rbac` | RBAC | Admin | `property_id` | `user_roles`, `permissions` |
| `/portal/threat-detection` | ThreatDetection | Admin | `property_id` | `threat_logs` |
| `/portal/data-protection` | DataProtection | Admin | `property_id` | `data_protection_logs` |
| `/portal/vulnerability-management` | VulnerabilityManagement | Admin | `property_id` | `vulnerabilities` |
| `/portal/security-audits` | SecurityAudits | Admin | `property_id` | `security_audits` |

### Integration

| Route | Component | Auth Level | Required Scope | Data Tables |
|-------|-----------|------------|----------------|-------------|
| `/portal/integration` | Integration | Admin | `property_id` | Integration configs |
| `/portal/api-management` | APIManagement | Admin | `property_id` | `api_keys`, `webhooks` |
| `/portal/data-integration` | DataIntegration | Admin | `property_id` | `data_sync_jobs` |
| `/portal/third-party` | ThirdPartyIntegrations | Admin | `property_id` | `third_party_configs` |
| `/portal/message-queue` | MessageQueue | Admin | `property_id` | `message_queue_configs` |

### Platform & DevOps

| Route | Component | Auth Level | Required Scope | Data Tables |
|-------|-----------|------------|----------------|-------------|
| `/portal/platform-devops` | PlatformDevOps | Super Admin | N/A | Infrastructure configs |
| `/portal/infrastructure` | Infrastructure | Super Admin | N/A | Infrastructure data |
| `/portal/monitoring` | Monitoring | Super Admin | N/A | Monitoring data |
| `/portal/logging` | Logging | Super Admin | N/A | Log data |
| `/portal/alerting` | Alerting | Super Admin | N/A | Alert configs |
| `/portal/containers` | ContainerOrchestration | Super Admin | N/A | Container configs |
| `/portal/cicd` | CICD | Super Admin | N/A | CI/CD configs |
| `/portal/performance-optimization` | PerformanceOptimization | Super Admin | N/A | Performance data |
| `/portal/disaster-recovery` | DisasterRecovery | Super Admin | N/A | DR configs |
| `/portal/load-balancing` | LoadBalancing | Super Admin | N/A | LB configs |
| `/portal/devsecops` | DevSecOps | Super Admin | N/A | Security configs |
| `/portal/finops` | FinOps | Super Admin | N/A | Cost data |

### External Tools

| Route | Component | Auth Level | Required Scope | Data Tables |
|-------|-----------|------------|----------------|-------------|
| `/portal/booking-engine` | BookingEngine | Admin | `property_id` | Booking engine configs |
| `/portal/channel-manager` | ChannelManager | Admin | `property_id` | Channel configs |
| `/portal/payment-gateway` | PaymentGateway | Admin | `property_id` | Payment configs |
| `/portal/ota-portal` | OTAPortal | Admin | `property_id` | OTA configs |

---

## Data Access Patterns

### Standard Pattern for Portal Pages

All portal pages should follow this pattern:

```typescript
import { useProperty } from '@/contexts/PropertyContext';
import { supabase } from '@/integrations/supabase/client';
import { withPropertyScope, handleRLSError } from '@/lib/supabase/scopedQueries';

export default function MyPortalPage() {
  const { propertyId, loading: propertyLoading } = useProperty();
  
  const { data, error } = useQuery({
    queryKey: ['my-data', propertyId],
    queryFn: async () => {
      if (!propertyId) return [];
      
      // Always scope queries with property_id
      const { data, error } = await supabase
        .from('my_table')
        .select('*')
        .eq('property_id', propertyId); // CRITICAL: Always include property_id
      
      if (error) {
        const friendlyError = handleRLSError(error);
        throw new Error(friendlyError);
      }
      
      return data || [];
    },
    enabled: !propertyLoading && !!propertyId,
  });
  
  // ... rest of component
}
```

### CRUD Operations Pattern

```typescript
// CREATE
const createMutation = useMutation({
  mutationFn: async (data: MyData) => {
    if (!propertyId) throw new Error('Property context required');
    
    const { data: result, error } = await supabase
      .from('my_table')
      .insert([{ ...data, property_id: propertyId }]) // Always include property_id
      .select()
      .single();
    
    if (error) {
      throw new Error(handleRLSError(error));
    }
    
    return result;
  },
});

// UPDATE
const updateMutation = useMutation({
  mutationFn: async ({ id, data }: { id: string; data: Partial<MyData> }) => {
    if (!propertyId) throw new Error('Property context required');
    
    const { data: result, error } = await supabase
      .from('my_table')
      .update({ ...data, property_id: propertyId }) // Preserve property_id
      .eq('id', id)
      .eq('property_id', propertyId) // CRITICAL: Scope update to property
      .select()
      .single();
    
    if (error) {
      throw new Error(handleRLSError(error));
    }
    
    return result;
  },
});

// DELETE
const deleteMutation = useMutation({
  mutationFn: async (id: string) => {
    if (!propertyId) throw new Error('Property context required');
    
    const { error } = await supabase
      .from('my_table')
      .delete()
      .eq('id', id)
      .eq('property_id', propertyId); // CRITICAL: Scope delete to property
    
    if (error) {
      throw new Error(handleRLSError(error));
    }
  },
});
```

---

## Security Requirements

### 1. Authentication

All `/portal/*` routes are wrapped in `<ProtectedRoute>` which:
- ✅ Checks for authenticated user
- ✅ Redirects to `/auth` if not authenticated
- ✅ Checks RBAC permissions via `ROUTE_PERMISSIONS`

### 2. Property Scoping

**CRITICAL**: All queries must include `property_id` filter:

```typescript
// ✅ CORRECT
.eq('property_id', propertyId)

// ❌ WRONG - RLS will block
.select('*') // Missing property_id filter
```

### 3. RLS Policies

RLS policies enforce:
- ✅ `property_id` isolation (users only see data for their assigned properties)
- ✅ `tenant_id` isolation (for tenant-level data)
- ✅ Guest user isolation (guests only see their own data)

### 4. RBAC Checks

Routes check permissions via `ROUTE_PERMISSIONS` config:
- Staff: Can view/edit data for their property
- Admin: Can manage settings and configurations
- Super Admin: Can access all properties

---

## Common Failure Modes

### 1. Missing Property ID

**Symptom**: Empty results, RLS errors
**Fix**: Always check `propertyId` before queries:
```typescript
if (!propertyId) return [];
```

### 2. Missing property_id in Queries

**Symptom**: RLS blocks all results
**Fix**: Always include `.eq('property_id', propertyId)`

### 3. Missing property_id in Inserts

**Symptom**: RLS blocks insert
**Fix**: Always include `property_id` in insert data:
```typescript
.insert([{ ...data, property_id: propertyId }])
```

### 4. Missing property_id in Updates/Deletes

**Symptom**: RLS blocks operation
**Fix**: Always scope with property_id:
```typescript
.update(data).eq('id', id).eq('property_id', propertyId)
.delete().eq('id', id).eq('property_id', propertyId)
```

### 5. Navigation Links to Non-Existent Routes

**Symptom**: 404 errors
**Fix**: Verify all links in `AppSidebar` match routes in `App.tsx`

### 6. Legacy Route Names

**Symptom**: Broken links, confusion
**Fix**: Use redirects for backward compatibility:
```typescript
<Route path="/old-route" element={<Navigate to="/portal/new-route" replace />} />
```

---

## Developer Guidelines

### Before Adding a New Portal Route

1. ✅ Define route in `App.tsx` under `<ProtectedRoute>`
2. ✅ Add route to `ROUTE_PERMISSIONS` in `@/config/rbac`
3. ✅ Add route to `AppSidebar` menu (if needed)
4. ✅ Ensure component uses `useProperty()` hook
5. ✅ All queries include `property_id` filter
6. ✅ All mutations include `property_id` in data
7. ✅ Handle RLS errors with `handleRLSError()`
8. ✅ Test with different user roles

### Code Review Checklist

- [ ] Route is protected with `<ProtectedRoute>`
- [ ] Component uses `useProperty()` hook
- [ ] All queries filter by `property_id`
- [ ] All inserts include `property_id`
- [ ] All updates scope with `property_id`
- [ ] All deletes scope with `property_id`
- [ ] RLS errors are handled gracefully
- [ ] Navigation link exists in `AppSidebar`
- [ ] Route is documented in this checklist

### Testing Checklist

- [ ] Route loads with valid property context
- [ ] Route redirects if property context missing
- [ ] Queries return data scoped to property
- [ ] CRUD operations work correctly
- [ ] RLS errors show user-friendly messages
- [ ] Navigation link works
- [ ] Route works with different user roles

---

## Route Validation

All routes in `AppSidebar` have been validated against `App.tsx` routes. If you add a new route:

1. Add it to `App.tsx` first
2. Then add it to `AppSidebar` menu
3. Update this checklist

---

## Last Updated

- **Date**: 2025-01-XX
- **Audit Version**: 1.0
- **Total Routes Audited**: 100+
