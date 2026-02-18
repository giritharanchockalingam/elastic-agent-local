# Shared Engine Architecture

## Overview

The shared engine architecture allows the same page configurations and UI building blocks to be used in both the internal (admin/staff) portal and the public (guest) portal, without duplicating logic.

## Core Components

### 1. Engine Layer (`src/engines/`)

- **`types.ts`**: Type definitions for page configs, sections, fields, actions
- **`filter.ts`**: Filters page configs based on portal mode and user role
- **`renderer.tsx`**: Renders filtered page configs
- **`context.ts`**: Utilities to create engine context from app state

### 2. Data Services Layer (`src/services/data/`)

- **`propertyService.ts`**: Property data access
- **`roomService.ts`**: Room types and images
- **`diningService.ts`**: Restaurants and menus (uses brand config)
- **`spaService.ts`**: Spa services and bookings (uses brand config)
- **`eventsService.ts`**: Event venues and bookings (uses brand config)

All services:
- Respect RLS policies
- Support both internal and public modes
- Use brand config for venue names

### 3. Brand Configuration (`src/config/brand.ts`)

Centralized venue names:
- Hotel: "V3 Grand Hotel"
- Restaurant: "Veda"
- Bar: "Ember"
- Spa: "Aura"
- Events: "The Grand Hall", "The Pavilion", "The Forum"

## Usage

### Creating Engine Context

```typescript
import { useEngineContext } from "@/engines/context";

function MyPage() {
  const context = useEngineContext("public"); // or "internal"
  // context.mode, context.role, context.propertyId, context.userId
}
```

### Filtering Page Config

```typescript
import { filterConfigForMode } from "@/engines/filter";
import type { PageConfig, EngineContext } from "@/engines/types";

const config: PageConfig = { /* ... */ };
const context: EngineContext = { mode: "public", role: "guest", ... };
const filtered = filterConfigForMode(config, context);
```

### Using Data Services

```typescript
import { getPublicRoomTypes } from "@/services/data/roomService";

const roomTypes = await getPublicRoomTypes(propertyId);
```

## Portal Modes

### Internal Mode
- Full CRUD operations
- Admin/staff navigation
- All sections visible
- All actions available (based on role)

### Public Mode
- Read-only by default
- Guest navigation only
- Filtered sections (admin-only hidden)
- Limited actions (inquiry, booking request, etc.)

## RBAC Enforcement

1. **Client-side**: Engine filters configs based on role
2. **Server-side**: Supabase RLS policies enforce access
3. **Service layer**: All queries respect RLS

## Policy Matrix

See `docs/POLICY_MATRIX.md` for detailed action matrix.
