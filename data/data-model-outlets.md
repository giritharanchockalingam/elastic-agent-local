# Data Model: Restaurants/Bar/Spa as Outlets/Revenue Centers

## Overview

This document outlines the data model for restaurants, bars, spas, and other revenue-generating outlets under a main property. This model follows industry-standard practices for hotel revenue center management, where each outlet is a distinct revenue source that rolls up to the parent property for financial reporting.

## Current Implementation

### Property Hierarchy

```
Property (V3 Grand Hotel)
├── Outlets (Revenue Centers)
│   ├── Restaurant (Veda)
│   ├── Bar (Ember)
│   ├── Spa/Wellness (Nirvana Spa)
│   ├── Pool Bar
│   └── Event Space
└── Revenue Attribution
    ├── By Outlet
    └── By Property (Aggregated)
```

### Schema Design

#### 1. Properties Table (`public.properties`)

The main hotel entity:

```sql
CREATE TABLE public.properties (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  property_slug TEXT UNIQUE,
  status TEXT DEFAULT 'active',
  -- ... other property fields
);
```

#### 2. Restaurants Table (`public.restaurants`)

Restaurants are modeled as outlets under a property:

```sql
CREATE TABLE public.restaurants (
  id UUID PRIMARY KEY,
  property_id UUID REFERENCES properties(id) NOT NULL,
  outlet_slug TEXT NOT NULL, -- URL-friendly identifier (e.g., 'veda')
  display_name TEXT NOT NULL,
  is_public BOOLEAN DEFAULT FALSE,
  description_public TEXT,
  cuisine_type TEXT,
  cuisine_tags TEXT[],
  hours_json JSONB, -- Structured operating hours
  phone_public TEXT,
  address_public TEXT,
  seating_capacity INTEGER,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(property_id, outlet_slug)
);
```

**Key Points:**
- `property_id` links the restaurant to the parent property
- `outlet_slug` provides a URL-friendly identifier for public routes
- `is_public` controls visibility on public portal
- Public-facing fields (`description_public`, `phone_public`, `address_public`) separate from internal data

#### 3. Menu Structure

Menu items are linked to restaurants through categories:

```sql
CREATE TABLE public.restaurant_menu_categories (
  id UUID PRIMARY KEY,
  restaurant_id UUID REFERENCES restaurants(id) NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  sort_order INTEGER DEFAULT 0,
  is_public BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.restaurant_menu_items (
  id UUID PRIMARY KEY,
  restaurant_id UUID REFERENCES restaurants(id) NOT NULL,
  category_id UUID REFERENCES restaurant_menu_categories(id),
  name TEXT NOT NULL,
  description_public TEXT,
  price_cents INTEGER, -- Stored as cents for precision
  currency TEXT DEFAULT 'INR',
  dietary_tags TEXT[],
  spice_level TEXT,
  image_url TEXT,
  is_highlight BOOLEAN DEFAULT FALSE, -- Flag for featured items
  is_public BOOLEAN DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Key Points:**
- Menu items are directly linked to `restaurant_id` (the outlet)
- `price_cents` stores prices as integers (cents) for precision
- `is_highlight` flag marks items for "Menu Highlights" display
- Categories provide organization without strict hierarchy

#### 4. Restaurant Orders

Orders link to restaurants for revenue attribution:

```sql
CREATE TABLE public.restaurant_orders (
  id UUID PRIMARY KEY,
  tenant_id UUID REFERENCES tenants(id),
  property_id UUID REFERENCES properties(id) NOT NULL,
  restaurant_id UUID REFERENCES restaurants(id) NOT NULL, -- Links to outlet
  order_number TEXT UNIQUE,
  status TEXT DEFAULT 'pending',
  channel TEXT DEFAULT 'public_portal', -- 'public_portal', 'pos', 'phone', etc.
  fulfillment_type TEXT, -- 'pickup', 'dine-in', 'delivery'
  totals_json JSONB, -- Subtotal, tax, service charge, total
  contact_json JSONB, -- Customer contact info
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.restaurant_order_items (
  id UUID PRIMARY KEY,
  order_id UUID REFERENCES restaurant_orders(id) NOT NULL,
  menu_item_id UUID REFERENCES restaurant_menu_items(id) NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  price_cents INTEGER NOT NULL, -- Snapshot at time of order
  currency TEXT DEFAULT 'INR',
  item_name TEXT, -- Snapshot for historical accuracy
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Key Points:**
- Orders link to both `property_id` and `restaurant_id` (outlet)
- `restaurant_id` enables outlet-level revenue reporting
- `property_id` enables property-level aggregation
- Price snapshots in `order_items` ensure historical accuracy

### ER Diagram

```
┌─────────────┐
│  Properties │
│             │
│  id (PK)    │
│  name       │
│  slug       │
└──────┬──────┘
       │
       │ 1:N
       │
┌──────▼──────────┐
│  Restaurants    │
│  (Outlets)      │
│                 │
│  id (PK)        │
│  property_id(FK)│
│  outlet_slug    │
│  name           │
└──────┬──────────┘
       │
       │ 1:N
       │
┌──────▼──────────────────┐      ┌─────────────────────┐
│ restaurant_menu_items   │      │ restaurant_orders   │
│                         │      │                     │
│ id (PK)                 │      │ id (PK)             │
│ restaurant_id (FK)      │◄─────┤ restaurant_id (FK)  │
│ category_id (FK)        │      │ property_id (FK)    │
│ name                    │      │ order_number        │
│ price_cents             │      │ status              │
│ is_highlight            │      │ totals_json         │
└─────────────────────────┘      └─────────────────────┘
```

## Revenue Attribution

### Outlet-Level Reporting

Revenue can be aggregated by outlet:

```sql
SELECT 
  r.outlet_slug,
  r.display_name,
  SUM(roi.quantity * roi.price_cents) / 100.0 AS total_revenue
FROM restaurant_orders ro
JOIN restaurants r ON r.id = ro.restaurant_id
JOIN restaurant_order_items roi ON roi.order_id = ro.id
WHERE ro.status = 'completed'
  AND ro.property_id = :property_id
GROUP BY r.id, r.outlet_slug, r.display_name;
```

### Property-Level Reporting

Revenue rolls up to the property:

```sql
SELECT 
  p.name AS property_name,
  SUM(roi.quantity * roi.price_cents) / 100.0 AS total_fb_revenue
FROM restaurant_orders ro
JOIN properties p ON p.id = ro.property_id
JOIN restaurant_order_items roi ON roi.order_id = ro.id
WHERE ro.status = 'completed'
  AND p.id = :property_id
GROUP BY p.id, p.name;
```

### Multi-Outlet Comparison

Compare revenue across outlets:

```sql
SELECT 
  r.outlet_slug,
  r.display_name,
  COUNT(DISTINCT ro.id) AS order_count,
  SUM(roi.quantity * roi.price_cents) / 100.0 AS total_revenue
FROM restaurant_orders ro
JOIN restaurants r ON r.id = ro.restaurant_id
JOIN restaurant_order_items roi ON roi.order_id = ro.id
WHERE ro.status = 'completed'
  AND ro.property_id = :property_id
GROUP BY r.id, r.outlet_slug, r.display_name
ORDER BY total_revenue DESC;
```

## Industry Alignment

### Standard Hotel Practice

1. **Property as Parent Entity**
   - All outlets belong to a property
   - Property-level reporting aggregates all outlets
   - Property is the billing/invoicing entity

2. **Outlets as Revenue Centers**
   - Each outlet (restaurant, bar, spa) is a distinct revenue source
   - Outlets have their own:
     - Menu/Services
     - Pricing
     - Operating hours
     - Staff assignments
     - Revenue tracking

3. **Revenue Attribution**
   - Orders/bookings link to specific outlets
   - Revenue aggregates by outlet and property
   - Enables:
     - Outlet profitability analysis
     - Property-level P&L
     - Performance benchmarking

### Current Implementation Status

✅ **Completed:**
- `restaurants` table with `property_id` foreign key
- `restaurant_menu_items` linked to `restaurant_id`
- `restaurant_orders` linked to both `property_id` and `restaurant_id`
- Public views (`restaurant_outlets_v`, `restaurant_menu_v`) for secure access
- RLS policies for anon/staff access

⏳ **Future Considerations:**

1. **Bar Outlets**
   - Current schema supports bars via `restaurants` table (type can be differentiated via `cuisine_type` or a separate `outlet_type` field)
   - Could create separate `bars` table if needed for distinct business logic

2. **Spa/Wellness Outlets**
   - Similar structure to restaurants:
     - `spa_services` table (equivalent to `restaurant_menu_items`)
     - `spa_bookings` table (equivalent to `restaurant_orders`)
     - Link to `property_id` for revenue attribution

3. **Generic Outlets Table**
   - Option to consolidate restaurants, bars, spas into a single `outlets` table with `outlet_type` field
   - Current approach (separate tables) is more flexible for outlet-specific fields
   - Could migrate to generic table if schema similarity increases

## Recommendations

### Maintain Current Structure

The current implementation aligns well with industry practices:

1. **Clear Hierarchy**: Property → Outlets (restaurants, bars, spas)
2. **Revenue Attribution**: Orders link to both property and outlet
3. **Flexible Schema**: Allows outlet-specific fields without over-normalization
4. **Public Portal Ready**: Public views and RLS policies in place

### Future Enhancements

1. **Accounting Integration**
   - Add `revenue_center_code` to outlets for POS/accounting system mapping
   - Add `cost_center_id` for expense allocation

2. **Multi-Property Support**
   - Already supported via `property_id` foreign key
   - Ensure reporting queries handle multi-property scenarios

3. **Outlet Types**
   - Consider adding `outlet_type` field to `restaurants` table if bars need differentiation
   - Or keep separate tables for type-specific business logic

## Conclusion

The current data model effectively represents restaurants, bars, and spas as revenue-generating outlets under a main property. The schema supports:

- ✅ Outlet-level revenue tracking
- ✅ Property-level revenue aggregation
- ✅ Public portal integration
- ✅ Historical accuracy (price snapshots)
- ✅ Industry-standard practices

The implementation is production-ready and aligns with standard hotel management systems.
