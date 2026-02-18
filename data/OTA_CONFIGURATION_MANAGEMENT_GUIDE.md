# OTA Configuration Management Guide

## 🎯 Overview

This guide provides comprehensive instructions for configuring and managing OTA integrations (Expedia and Booking.com) in your HMS portal, including credential management, rate plans, inventory settings, and synchronization strategies.

## 📋 Table of Contents

1. [Configuration Architecture](#configuration-architecture)
2. [Credential Management](#credential-management)
3. [Property Mapping](#property-mapping)
4. [Rate Plan Configuration](#rate-plan-configuration)
5. [Inventory Management](#inventory-management)
6. [Sync Strategies](#sync-strategies)
7. [Multi-Property Setup](#multi-property-setup)
8. [Configuration Best Practices](#configuration-best-practices)

---

## Configuration Architecture

### Configuration Hierarchy

```
┌─────────────────────────────────────────────────────────┐
│                   Global Settings                        │
│  - API endpoints, timeouts, retry policies              │
└─────────────────┬───────────────────────────────────────┘
                  │
      ┌───────────┴───────────┐
      │                       │
┌─────▼─────────┐    ┌────────▼────────┐
│    Expedia    │    │  Booking.com    │
│ Configuration │    │  Configuration  │
└─────┬─────────┘    └────────┬────────┘
      │                       │
      ├─ Credentials          ├─ Credentials
      ├─ Property Mappings    ├─ Property Mappings
      ├─ Rate Plans          ├─ Rate Plans
      ├─ Sync Settings       ├─ Sync Settings
      └─ Webhook Config      └─ Webhook Config
```

### Database Schema

The OTA configuration is stored in `third_party_integrations` table:

```sql
CREATE TABLE third_party_integrations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID REFERENCES properties(id),
  integration_name TEXT NOT NULL,
  integration_type TEXT NOT NULL, -- 'ota'
  provider TEXT NOT NULL, -- 'expedia' or 'booking.com'
  credentials JSONB NOT NULL,
  configuration JSONB NOT NULL,
  webhook_url TEXT,
  is_enabled BOOLEAN DEFAULT true,
  status TEXT DEFAULT 'active',
  last_sync_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Credential Management

### Security Best Practices

1. **Never Store in Code**
   - Use environment variables
   - Use Supabase secrets
   - Use encrypted storage

2. **Separate Environments**
   - Sandbox credentials for testing
   - Production credentials for live use
   - Never mix environments

3. **Regular Rotation**
   - Rotate credentials every 90 days
   - Keep audit log of rotations
   - Test new credentials before switching

### Step-by-Step Credential Setup

#### 1. Store Credentials in Environment

Create `.env.production`:

```env
# Expedia Credentials
EXPEDIA_SANDBOX_API_KEY=sandbox_key_here
EXPEDIA_SANDBOX_API_SECRET=sandbox_secret_here
EXPEDIA_PROD_API_KEY=production_key_here
EXPEDIA_PROD_API_SECRET=production_secret_here

# Booking.com Credentials
BOOKING_COM_SANDBOX_API_KEY=sandbox_key_here
BOOKING_COM_SANDBOX_PARTNER_ID=partner_id_here
BOOKING_COM_PROD_API_KEY=production_key_here
BOOKING_COM_PROD_PARTNER_ID=partner_id_here
```

#### 2. Configure in Database

```sql
-- Expedia Integration
INSERT INTO third_party_integrations (
  property_id,
  integration_name,
  integration_type,
  provider,
  credentials,
  configuration
) VALUES (
  'YOUR_PROPERTY_UUID',
  'Expedia Partner Solutions',
  'ota',
  'expedia',
  jsonb_build_object(
    'api_key', 'sandbox_key',
    'api_secret', 'sandbox_secret',
    'production_api_key', 'production_key',
    'production_api_secret', 'production_secret'
  ),
  jsonb_build_object(
    'test_mode', true,
    'property_id', 'expedia_property_id',
    'ean_id', 'expedia_ean_id'
  )
);

-- Booking.com Integration
INSERT INTO third_party_integrations (
  property_id,
  integration_name,
  integration_type,
  provider,
  credentials,
  configuration
) VALUES (
  'YOUR_PROPERTY_UUID',
  'Booking.com Connectivity',
  'ota',
  'booking.com',
  jsonb_build_object(
    'api_key', 'sandbox_key',
    'partner_id', 'partner_id',
    'production_api_key', 'production_key'
  ),
  jsonb_build_object(
    'test_mode', true,
    'hotel_id', 'booking_com_hotel_id'
  )
);
```

#### 3. Credential Rotation Script

```typescript
// scripts/rotate-ota-credentials.ts
import { supabase } from '@/lib/supabase';

async function rotateCredentials(
  provider: 'expedia' | 'booking.com',
  propertyId: string,
  newCredentials: Record<string, string>
) {
  // Backup current credentials
  const { data: current } = await supabase
    .from('third_party_integrations')
    .select('credentials')
    .eq('provider', provider)
    .eq('property_id', propertyId)
    .single();

  // Store backup
  await supabase
    .from('integration_credential_history')
    .insert({
      property_id: propertyId,
      provider,
      credentials: current.credentials,
      rotated_at: new Date().toISOString()
    });

  // Update with new credentials
  const { error } = await supabase
    .from('third_party_integrations')
    .update({
      credentials: newCredentials,
      updated_at: new Date().toISOString()
    })
    .eq('provider', provider)
    .eq('property_id', propertyId);

  if (error) {
    throw new Error(`Failed to rotate credentials: ${error.message}`);
  }

  console.log(`✅ Credentials rotated successfully for ${provider}`);
}
```

---

## Property Mapping

### Internal to External Mapping

Map your internal property/room IDs to OTA IDs:

```sql
-- Create mapping table
CREATE TABLE ota_property_mappings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID REFERENCES properties(id),
  provider TEXT NOT NULL,
  internal_room_type_id UUID REFERENCES room_types(id),
  external_room_id TEXT NOT NULL,
  external_rate_plan_id TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(property_id, provider, internal_room_type_id)
);
```

### Configure Mappings

```sql
-- Example: Map room types
INSERT INTO ota_property_mappings 
  (property_id, provider, internal_room_type_id, external_room_id, external_rate_plan_id)
VALUES
  -- Deluxe King Room mappings
  ('property-uuid', 'expedia', 'room-type-uuid-1', 'EXP_ROOM_001', 'EXP_BAR'),
  ('property-uuid', 'booking.com', 'room-type-uuid-1', 'BDC_ROOM_001', 'BDC_BAR'),
  
  -- Executive Suite mappings
  ('property-uuid', 'expedia', 'room-type-uuid-2', 'EXP_ROOM_002', 'EXP_BAR'),
  ('property-uuid', 'booking.com', 'room-type-uuid-2', 'BDC_ROOM_002', 'BDC_BAR');
```

### Mapping Service

```typescript
// services/ota/mapping-service.ts
export class OTAMappingService {
  async getExternalRoomId(
    provider: 'expedia' | 'booking.com',
    internalRoomTypeId: string
  ): Promise<string> {
    const { data } = await supabase
      .from('ota_property_mappings')
      .select('external_room_id')
      .eq('provider', provider)
      .eq('internal_room_type_id', internalRoomTypeId)
      .eq('is_active', true)
      .single();

    if (!data) {
      throw new Error(`No mapping found for room type ${internalRoomTypeId}`);
    }

    return data.external_room_id;
  }

  async getInternalRoomId(
    provider: 'expedia' | 'booking.com',
    externalRoomId: string
  ): Promise<string> {
    const { data } = await supabase
      .from('ota_property_mappings')
      .select('internal_room_type_id')
      .eq('provider', provider)
      .eq('external_room_id', externalRoomId)
      .eq('is_active', true)
      .single();

    if (!data) {
      throw new Error(`No mapping found for external room ${externalRoomId}`);
    }

    return data.internal_room_type_id;
  }
}
```

---

## Rate Plan Configuration

### Rate Plan Types

1. **Base Rate Plans**
   - BAR (Best Available Rate)
   - Corporate Rate
   - Government Rate
   - AAA/Senior Rate

2. **Package Plans**
   - Bed & Breakfast
   - Half Board
   - Full Board
   - All-Inclusive

3. **Promotional Plans**
   - Early Bird (book 14+ days in advance)
   - Last Minute (book 3 days or less)
   - Long Stay (7+ nights)
   - Non-Refundable

### Configure Rate Plans

```sql
CREATE TABLE ota_rate_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID REFERENCES properties(id),
  provider TEXT NOT NULL,
  room_type_id UUID REFERENCES room_types(id),
  rate_plan_id TEXT NOT NULL,
  rate_plan_name TEXT NOT NULL,
  rate_plan_type TEXT NOT NULL,
  base_rate DECIMAL(10,2),
  currency TEXT DEFAULT 'USD',
  meal_plan TEXT,
  cancellation_policy JSONB,
  min_length_of_stay INTEGER DEFAULT 1,
  max_length_of_stay INTEGER,
  advance_booking_days INTEGER DEFAULT 365,
  is_active BOOLEAN DEFAULT true,
  configuration JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Example Rate Plan Configurations

```sql
-- BAR Rate Plan
INSERT INTO ota_rate_plans (
  property_id,
  provider,
  room_type_id,
  rate_plan_id,
  rate_plan_name,
  rate_plan_type,
  base_rate,
  cancellation_policy
) VALUES (
  'property-uuid',
  'expedia',
  'room-type-uuid',
  'BAR',
  'Best Available Rate',
  'flexible',
  199.00,
  jsonb_build_object(
    'type', 'flexible',
    'deadline_hours', 24,
    'penalty_percentage', 0
  )
);

-- Non-Refundable Rate Plan
INSERT INTO ota_rate_plans (
  property_id,
  provider,
  room_type_id,
  rate_plan_id,
  rate_plan_name,
  rate_plan_type,
  base_rate,
  cancellation_policy,
  configuration
) VALUES (
  'property-uuid',
  'expedia',
  'room-type-uuid',
  'NREF',
  'Non-Refundable Rate',
  'non_refundable',
  169.00, -- 15% discount from BAR
  jsonb_build_object(
    'type', 'non_refundable',
    'deadline_hours', 0,
    'penalty_percentage', 100
  ),
  jsonb_build_object(
    'discount_from_bar', 15
  )
);

-- Bed & Breakfast Plan
INSERT INTO ota_rate_plans (
  property_id,
  provider,
  room_type_id,
  rate_plan_id,
  rate_plan_name,
  rate_plan_type,
  base_rate,
  meal_plan,
  cancellation_policy
) VALUES (
  'property-uuid',
  'expedia',
  'room-type-uuid',
  'BB',
  'Bed & Breakfast',
  'flexible',
  229.00,
  'breakfast',
  jsonb_build_object(
    'type', 'flexible',
    'deadline_hours', 24,
    'penalty_percentage', 0
  )
);
```

---

## Inventory Management

### Inventory Allocation Strategy

```typescript
// Configuration for inventory distribution
const inventoryConfig = {
  totalRooms: 20,
  allocation: {
    direct: 5,        // Reserved for direct bookings
    expedia: 8,       // Allocated to Expedia
    bookingCom: 7,    // Allocated to Booking.com
    overbooking: 2    // Overbooking buffer (10%)
  }
};
```

### Dynamic Inventory Management

```sql
-- Track inventory allocation
CREATE TABLE ota_inventory_allocation (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID REFERENCES properties(id),
  room_type_id UUID REFERENCES room_types(id),
  date DATE NOT NULL,
  total_inventory INTEGER NOT NULL,
  allocated_direct INTEGER DEFAULT 0,
  allocated_expedia INTEGER DEFAULT 0,
  allocated_booking_com INTEGER DEFAULT 0,
  available_inventory INTEGER GENERATED ALWAYS AS (
    total_inventory - (allocated_direct + allocated_expedia + allocated_booking_com)
  ) STORED,
  overbooking_buffer INTEGER DEFAULT 0,
  last_synced_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(property_id, room_type_id, date)
);
```

### Inventory Sync Service

```typescript
// services/ota/inventory-sync-service.ts
export class InventorySyncService {
  async syncInventoryToOTAs(
    propertyId: string,
    roomTypeId: string,
    date: string
  ) {
    // Get current allocation
    const allocation = await this.getInventoryAllocation(
      propertyId,
      roomTypeId,
      date
    );

    // Update Expedia
    await this.updateExpediaInventory(
      propertyId,
      roomTypeId,
      date,
      allocation.allocated_expedia
    );

    // Update Booking.com
    await this.updateBookingComInventory(
      propertyId,
      roomTypeId,
      date,
      allocation.allocated_booking_com
    );

    // Log sync
    await this.logSync(propertyId, roomTypeId, date, 'success');
  }

  async rebalanceInventory(
    propertyId: string,
    roomTypeId: string,
    date: string
  ) {
    // Get current bookings from all channels
    const bookings = await this.getBookingsByChannel(
      propertyId,
      roomTypeId,
      date
    );

    // Calculate new allocation based on demand
    const newAllocation = this.calculateOptimalAllocation(
      bookings,
      this.inventoryConfig
    );

    // Update allocation
    await this.updateInventoryAllocation(
      propertyId,
      roomTypeId,
      date,
      newAllocation
    );

    // Sync to OTAs
    await this.syncInventoryToOTAs(propertyId, roomTypeId, date);
  }
}
```

---

## Sync Strategies

### Real-Time Sync

**Use Cases**: Critical updates that need immediate propagation
- New bookings
- Cancellations
- Last-minute inventory changes

```typescript
// Real-time sync configuration
const realtimeSyncConfig = {
  enabled: true,
  events: [
    'booking_created',
    'booking_cancelled',
    'inventory_updated'
  ],
  maxRetries: 3,
  retryDelayMs: 1000
};
```

### Scheduled Sync

**Use Cases**: Bulk updates, rate changes, inventory rebalancing

```sql
-- Scheduled sync configuration
CREATE TABLE ota_sync_schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_type TEXT NOT NULL,
  schedule_cron TEXT NOT NULL,
  is_enabled BOOLEAN DEFAULT true,
  configuration JSONB,
  last_run_at TIMESTAMPTZ,
  next_run_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Example schedules
INSERT INTO ota_sync_schedules (sync_type, schedule_cron, configuration)
VALUES
  ('rate_sync', '*/15 * * * *', '{"providers": ["expedia", "booking.com"]}'),
  ('inventory_sync', '*/5 * * * *', '{"providers": ["expedia", "booking.com"]}'),
  ('booking_sync', '*/10 * * * *', '{"providers": ["expedia", "booking.com"]}'),
  ('content_sync', '0 2 * * *', '{"providers": ["expedia", "booking.com"]}');
```

### Sync Priority System

```typescript
interface SyncPriority {
  level: 'critical' | 'high' | 'medium' | 'low';
  maxRetries: number;
  retryDelayMs: number;
  timeoutMs: number;
}

const syncPriorities: Record<string, SyncPriority> = {
  booking_created: {
    level: 'critical',
    maxRetries: 5,
    retryDelayMs: 1000,
    timeoutMs: 30000
  },
  booking_cancelled: {
    level: 'critical',
    maxRetries: 5,
    retryDelayMs: 1000,
    timeoutMs: 30000
  },
  inventory_updated: {
    level: 'high',
    maxRetries: 3,
    retryDelayMs: 2000,
    timeoutMs: 15000
  },
  rate_updated: {
    level: 'medium',
    maxRetries: 3,
    retryDelayMs: 5000,
    timeoutMs: 10000
  },
  content_updated: {
    level: 'low',
    maxRetries: 2,
    retryDelayMs: 10000,
    timeoutMs: 30000
  }
};
```

---

## Multi-Property Setup

### Configuration for Multiple Properties

```sql
-- Query to set up multiple properties
WITH property_configs AS (
  SELECT
    p.id as property_id,
    p.name as property_name,
    p.ota_settings->>'expedia_property_id' as expedia_id,
    p.ota_settings->>'booking_com_hotel_id' as booking_com_id
  FROM properties p
  WHERE p.ota_enabled = true
)
INSERT INTO third_party_integrations (
  property_id,
  integration_name,
  integration_type,
  provider,
  credentials,
  configuration
)
SELECT
  pc.property_id,
  'Expedia - ' || pc.property_name,
  'ota',
  'expedia',
  jsonb_build_object(
    'api_key', 'shared_api_key',
    'api_secret', 'shared_api_secret'
  ),
  jsonb_build_object(
    'property_id', pc.expedia_id,
    'test_mode', false
  )
FROM property_configs pc
WHERE pc.expedia_id IS NOT NULL;
```

### Bulk Configuration Management

```typescript
// scripts/bulk-configure-properties.ts
import { supabase } from '@/lib/supabase';

interface PropertyOTAConfig {
  propertyId: string;
  propertyName: string;
  expedia: {
    propertyId: string;
    eanId: string;
  };
  bookingCom: {
    hotelId: string;
  };
}

async function bulkConfigureProperties(
  properties: PropertyOTAConfig[]
) {
  for (const prop of properties) {
    // Configure Expedia
    await supabase.from('third_party_integrations').upsert({
      property_id: prop.propertyId,
      integration_name: `Expedia - ${prop.propertyName}`,
      integration_type: 'ota',
      provider: 'expedia',
      credentials: {
        api_key: process.env.EXPEDIA_API_KEY,
        api_secret: process.env.EXPEDIA_API_SECRET
      },
      configuration: {
        property_id: prop.expedia.propertyId,
        ean_id: prop.expedia.eanId,
        test_mode: false
      }
    });

    // Configure Booking.com
    await supabase.from('third_party_integrations').upsert({
      property_id: prop.propertyId,
      integration_name: `Booking.com - ${prop.propertyName}`,
      integration_type: 'ota',
      provider: 'booking.com',
      credentials: {
        api_key: process.env.BOOKING_COM_API_KEY,
        partner_id: process.env.BOOKING_COM_PARTNER_ID
      },
      configuration: {
        hotel_id: prop.bookingCom.hotelId,
        test_mode: false
      }
    });

    console.log(`✅ Configured OTAs for ${prop.propertyName}`);
  }
}
```

---

## Configuration Best Practices

### 1. Environment Management

**Development**:
```env
OTA_TEST_MODE=true
OTA_DEBUG=true
OTA_SYNC_ENABLED=false
```

**Staging**:
```env
OTA_TEST_MODE=true
OTA_DEBUG=false
OTA_SYNC_ENABLED=true
OTA_SYNC_INTERVAL=60000 # 1 minute
```

**Production**:
```env
OTA_TEST_MODE=false
OTA_DEBUG=false
OTA_SYNC_ENABLED=true
OTA_SYNC_INTERVAL=300000 # 5 minutes
```

### 2. Rate Configuration

- **Set competitive base rates**
- **Create rate parity policies**
- **Implement dynamic pricing rules**
- **Monitor competitor rates**
- **Review rates weekly**

### 3. Inventory Management

- **Reserve buffer for direct bookings**
- **Enable overbooking protection**
- **Sync inventory in real-time**
- **Monitor channel performance**
- **Rebalance allocation based on demand**

### 4. Monitoring & Alerts

```sql
-- Create alerts for configuration issues
CREATE TABLE ota_config_alerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID REFERENCES properties(id),
  provider TEXT NOT NULL,
  alert_type TEXT NOT NULL,
  severity TEXT NOT NULL,
  message TEXT NOT NULL,
  is_resolved BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Example alerts
INSERT INTO ota_config_alerts (property_id, provider, alert_type, severity, message)
SELECT
  property_id,
  provider,
  'credential_expiring',
  'warning',
  'API credentials will expire in 30 days'
FROM third_party_integrations
WHERE created_at < NOW() - INTERVAL '60 days';
```

---

## Next Steps

1. ✅ Configure credentials for both OTAs
2. ✅ Set up property mappings
3. ✅ Configure rate plans
4. ✅ Set up inventory allocation
5. ✅ Configure sync schedules
6. ⏭️ Test configuration in sandbox
7. ⏭️ Deploy to production
8. ⏭️ Monitor and optimize

---

**Document Version**: 1.0  
**Last Updated**: December 26, 2024  
**Next Review**: January 26, 2025
