# OTA Rate & Inventory Synchronization Guide

## 🎯 Overview

This guide provides comprehensive strategies for synchronizing rates and inventory between your HMS portal and OTAs (Expedia and Booking.com), including real-time updates, scheduled syncs, and dynamic pricing implementations.

## 📋 Table of Contents

1. [Sync Architecture](#sync-architecture)
2. [Rate Synchronization](#rate-synchronization)
3. [Inventory Synchronization](#inventory-synchronization)
4. [Dynamic Pricing](#dynamic-pricing)
5. [Conflict Resolution](#conflict-resolution)
6. [Performance Optimization](#performance-optimization)
7. [Monitoring & Alerts](#monitoring--alerts)

---

## Sync Architecture

### Synchronization Flow

```
┌──────────────────────────────────────────────────────────┐
│                    HMS Portal                             │
│                                                           │
│  ┌─────────────┐    ┌──────────────┐   ┌─────────────┐  │
│  │   Rates DB  │    │ Inventory DB │   │  Sync Queue │  │
│  └──────┬──────┘    └──────┬───────┘   └──────┬──────┘  │
│         │                  │                   │          │
│         └──────────────────┴───────────────────┘          │
│                            │                              │
│                   ┌────────▼────────┐                     │
│                   │  Sync Service   │                     │
│                   └────────┬────────┘                     │
└────────────────────────────┼──────────────────────────────┘
                             │
                  ┌──────────┴──────────┐
                  │                     │
         ┌────────▼─────────┐  ┌───────▼────────┐
         │  Expedia API     │  │ Booking.com    │
         │  Rate Update     │  │ Rate Update    │
         └──────────────────┘  └────────────────┘
```

### Sync Strategies

1. **Real-time Sync** - Immediate updates on changes
2. **Scheduled Sync** - Periodic batch updates
3. **Hybrid Sync** - Combination of real-time and scheduled
4. **On-demand Sync** - Manual triggers

---

## Rate Synchronization

### 1. Real-Time Rate Updates

Update rates immediately when changed in HMS portal:

```typescript
// services/ota/rate-sync-service.ts
export class RateSyncService {
  async syncRateUpdate(
    propertyId: string,
    roomTypeId: string,
    ratePlanId: string,
    date: string,
    rate: number
  ) {
    // 1. Get OTA mappings
    const mappings = await this.getMappings(propertyId, roomTypeId);

    // 2. Sync to Expedia
    if (mappings.expedia) {
      await this.syncToExpedia({
        propertyId: mappings.expedia.propertyId,
        roomTypeId: mappings.expedia.roomId,
        ratePlanId: mappings.expedia.ratePlanId,
        date,
        rate
      });
    }

    // 3. Sync to Booking.com
    if (mappings.bookingCom) {
      await this.syncToBookingCom({
        hotelId: mappings.bookingCom.hotelId,
        roomId: mappings.bookingCom.roomId,
        ratePlanId: mappings.bookingCom.ratePlanId,
        date,
        rate
      });
    }

    // 4. Log sync
    await this.logSync(propertyId, roomTypeId, date, 'rate', 'success');
  }

  private async syncToExpedia(params: {
    propertyId: string;
    roomTypeId: string;
    ratePlanId: string;
    date: string;
    rate: number;
  }) {
    const expedia = new ExpediaComprehensiveAPI({
      apiKey: process.env.EXPEDIA_API_KEY!,
      apiSecret: process.env.EXPEDIA_API_SECRET!,
      environment: 'production',
      propertyId: params.propertyId
    });

    await expedia.updateRates({
      propertyId: params.propertyId,
      roomTypeId: params.roomTypeId,
      ratePlanId: params.ratePlanId,
      rates: [{
        date: params.date,
        rate: params.rate,
        currency: 'USD'
      }]
    });
  }

  private async syncToBookingCom(params: {
    hotelId: string;
    roomId: string;
    ratePlanId: string;
    date: string;
    rate: number;
  }) {
    const bookingCom = new BookingComComprehensiveAPI({
      apiKey: process.env.BOOKING_COM_API_KEY!,
      partnerId: process.env.BOOKING_COM_PARTNER_ID!,
      environment: 'production',
      hotelId: params.hotelId
    });

    await bookingCom.updateRate({
      hotelId: params.hotelId,
      roomId: params.roomId,
      ratePlanId: params.ratePlanId,
      date: params.date,
      rate: params.rate,
      currency: 'USD',
      availability: undefined // Don't update availability
    });
  }
}
```

### 2. Bulk Rate Synchronization

Sync rates for multiple dates/rooms efficiently:

```typescript
async syncBulkRates(
  propertyId: string,
  startDate: string,
  endDate: string
) {
  // 1. Get all room types for property
  const { data: roomTypes } = await supabase
    .from('room_types')
    .select('id, ota_mappings')
    .eq('property_id', propertyId);

  // 2. Get rates for date range
  const { data: rates } = await supabase
    .from('room_rates')
    .select('*')
    .eq('property_id', propertyId)
    .gte('date', startDate)
    .lte('date', endDate);

  // 3. Group rates by room type and date
  const ratesByRoom = this.groupRates(rates);

  // 4. Sync to each OTA in parallel
  const syncPromises = roomTypes.flatMap(room => [
    this.syncRoomRatesToExpedia(room, ratesByRoom[room.id]),
    this.syncRoomRatesToBookingCom(room, ratesByRoom[room.id])
  ]);

  await Promise.allSettled(syncPromises);

  console.log(`✅ Bulk rate sync complete: ${startDate} to ${endDate}`);
}

private async syncRoomRatesToExpedia(
  room: any,
  rates: any[]
) {
  const expedia = new ExpediaComprehensiveAPI(/* config */);

  await expedia.bulkUpdateRates({
    propertyId: room.ota_mappings.expedia.propertyId,
    roomTypeId: room.ota_mappings.expedia.roomId,
    ratePlanId: 'BAR',
    startDate: rates[0].date,
    endDate: rates[rates.length - 1].date,
    rate: rates[0].rate, // Use first rate or implement logic
    currency: 'USD'
  });
}
```

### 3. Scheduled Rate Sync

Set up periodic synchronization:

```typescript
// Edge Function: scheduled-rate-sync
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

serve(async (req) => {
  const rateSyncService = new RateSyncService();

  // Get all properties with OTA integrations
  const { data: properties } = await supabase
    .from('properties')
    .select('id')
    .eq('ota_enabled', true);

  // Sync rates for next 90 days
  const startDate = new Date();
  const endDate = new Date();
  endDate.setDate(endDate.getDate() + 90);

  for (const property of properties) {
    try {
      await rateSyncService.syncBulkRates(
        property.id,
        startDate.toISOString().split('T')[0],
        endDate.toISOString().split('T')[0]
      );
    } catch (error) {
      console.error(`Error syncing rates for ${property.id}:`, error);
    }
  }

  return new Response(JSON.stringify({ 
    success: true,
    synced: properties.length 
  }));
});
```

Configure cron schedule:
```bash
# Run every 15 minutes
*/15 * * * * curl -X POST https://your-domain.supabase.co/functions/v1/scheduled-rate-sync
```

### 4. Rate Parity Management

Ensure consistent pricing across all channels:

```typescript
async enforceRateParity(
  propertyId: string,
  date: string
) {
  // 1. Get base rate from HMS
  const { data: baseRate } = await supabase
    .from('room_rates')
    .select('rate')
    .eq('property_id', propertyId)
    .eq('date', date)
    .eq('rate_plan', 'BAR')
    .single();

  // 2. Define channel-specific adjustments
  const channelRates = {
    direct: baseRate.rate,
    expedia: baseRate.rate * 1.10, // 10% higher for commission
    bookingCom: baseRate.rate * 1.12 // 12% higher for commission
  };

  // 3. Update all channels
  await Promise.all([
    this.updateExpediaRate(propertyId, date, channelRates.expedia),
    this.updateBookingComRate(propertyId, date, channelRates.bookingCom)
  ]);

  console.log(`✅ Rate parity enforced for ${date}`);
}
```

---

## Inventory Synchronization

### 1. Real-Time Inventory Updates

Update availability immediately when bookings are created or cancelled:

```typescript
export class InventorySyncService {
  async syncInventoryUpdate(
    propertyId: string,
    roomTypeId: string,
    date: string,
    availability: number
  ) {
    // 1. Get current allocation
    const allocation = await this.getInventoryAllocation(
      propertyId,
      roomTypeId,
      date
    );

    // 2. Calculate OTA allocations
    const otaAllocation = this.calculateOTAAllocation(
      availability,
      allocation
    );

    // 3. Sync to Expedia
    await this.updateExpediaInventory(
      propertyId,
      roomTypeId,
      date,
      otaAllocation.expedia
    );

    // 4. Sync to Booking.com
    await this.updateBookingComInventory(
      propertyId,
      roomTypeId,
      date,
      otaAllocation.bookingCom
    );

    // 5. Update allocation record
    await this.updateAllocationRecord(
      propertyId,
      roomTypeId,
      date,
      otaAllocation
    );
  }

  private calculateOTAAllocation(
    totalAvailable: number,
    currentAllocation: any
  ) {
    // Simple percentage-based allocation
    const expediaPercentage = 0.40; // 40% to Expedia
    const bookingComPercentage = 0.40; // 40% to Booking.com
    // 20% reserved for direct bookings

    return {
      expedia: Math.floor(totalAvailable * expediaPercentage),
      bookingCom: Math.floor(totalAvailable * bookingComPercentage),
      direct: totalAvailable - 
              Math.floor(totalAvailable * expediaPercentage) - 
              Math.floor(totalAvailable * bookingComPercentage)
    };
  }
}
```

### 2. Bulk Inventory Synchronization

```typescript
async syncBulkInventory(
  propertyId: string,
  roomTypeId: string,
  startDate: string,
  endDate: string
) {
  // 1. Get inventory for date range
  const { data: inventory } = await supabase
    .from('room_inventory')
    .select('*')
    .eq('property_id', propertyId)
    .eq('room_type_id', roomTypeId)
    .gte('date', startDate)
    .lte('date', endDate);

  // 2. Calculate allocations for all dates
  const allocations = inventory.map(inv => ({
    date: inv.date,
    expedia: Math.floor(inv.available * 0.40),
    bookingCom: Math.floor(inv.available * 0.40)
  }));

  // 3. Sync to Expedia (bulk)
  const expedia = new ExpediaComprehensiveAPI(/* config */);
  await expedia.bulkUpdateInventory({
    propertyId,
    roomTypeId,
    inventory: allocations.map(a => ({
      date: a.date,
      available: a.expedia
    }))
  });

  // 4. Sync to Booking.com (bulk)
  const bookingCom = new BookingComComprehensiveAPI(/* config */);
  await bookingCom.bulkUpdateInventory({
    hotelId: 'mapped_hotel_id',
    roomId: 'mapped_room_id',
    updates: allocations.map(a => ({
      date: a.date,
      availability: a.bookingCom
    }))
  });

  console.log(`✅ Bulk inventory sync: ${allocations.length} dates`);
}
```

### 3. Overbooking Protection

Prevent overselling across all channels:

```typescript
async checkOverbooking(
  propertyId: string,
  roomTypeId: string,
  date: string
): Promise<boolean> {
  // 1. Get total inventory
  const { data: inventory } = await supabase
    .from('room_inventory')
    .select('total_rooms')
    .eq('property_id', propertyId)
    .eq('room_type_id', roomTypeId)
    .eq('date', date)
    .single();

  // 2. Count bookings from all sources
  const { data: bookings } = await supabase
    .from('bookings')
    .select('id')
    .eq('property_id', propertyId)
    .eq('room_type_id', roomTypeId)
    .eq('arrival_date', date)
    .in('status', ['confirmed', 'checked_in']);

  // 3. Count OTA bookings
  const { data: otaBookings } = await supabase
    .from('ota_bookings')
    .select('id')
    .eq('property_id', propertyId)
    .eq('check_in', date)
    .eq('booking_status', 'confirmed');

  const totalBooked = (bookings?.length || 0) + (otaBookings?.length || 0);

  // 4. Check if overbooked
  const isOverbooked = totalBooked > inventory.total_rooms;

  if (isOverbooked) {
    await this.handleOverbooking(
      propertyId,
      roomTypeId,
      date,
      totalBooked,
      inventory.total_rooms
    );
  }

  return isOverbooked;
}

private async handleOverbooking(
  propertyId: string,
  roomTypeId: string,
  date: string,
  booked: number,
  available: number
) {
  console.error(`⚠️ Overbooking detected: ${booked}/${available}`);

  // 1. Close inventory on all OTAs
  await Promise.all([
    this.closeExpediaInventory(propertyId, roomTypeId, date),
    this.closeBookingComInventory(propertyId, roomTypeId, date)
  ]);

  // 2. Create alert
  await supabase
    .from('inventory_alerts')
    .insert({
      property_id: propertyId,
      room_type_id: roomTypeId,
      date,
      alert_type: 'overbooking',
      severity: 'critical',
      message: `Overbooked by ${booked - available} rooms`
    });

  // 3. Notify staff
  // Send email/SMS to management
}
```

### 4. Dynamic Inventory Rebalancing

Automatically adjust inventory allocation based on demand:

```typescript
async rebalanceInventory(
  propertyId: string,
  roomTypeId: string,
  date: string
) {
  // 1. Analyze booking patterns
  const metrics = await this.getBookingMetrics(
    propertyId,
    roomTypeId,
    date
  );

  // 2. Calculate optimal allocation
  const allocation = this.calculateOptimalAllocation(metrics);

  // 3. Update allocation
  await this.updateInventoryAllocation(
    propertyId,
    roomTypeId,
    date,
    allocation
  );

  // 4. Sync to OTAs
  await this.syncInventoryToOTAs(
    propertyId,
    roomTypeId,
    date
  );
}

private calculateOptimalAllocation(metrics: {
  expediaConversion: number;
  bookingComConversion: number;
  directConversion: number;
  expediaRevenue: number;
  bookingComRevenue: number;
  directRevenue: number;
}): {
  expedia: number;
  bookingCom: number;
  direct: number;
} {
  // Simple performance-based allocation
  const totalPerformance = 
    metrics.expediaConversion * metrics.expediaRevenue +
    metrics.bookingComConversion * metrics.bookingComRevenue +
    metrics.directConversion * metrics.directRevenue;

  const expediaScore = 
    (metrics.expediaConversion * metrics.expediaRevenue) / totalPerformance;
  const bookingComScore = 
    (metrics.bookingComConversion * metrics.bookingComRevenue) / totalPerformance;
  const directScore = 
    (metrics.directConversion * metrics.directRevenue) / totalPerformance;

  return {
    expedia: Math.floor(expediaScore * 100) / 100,
    bookingCom: Math.floor(bookingComScore * 100) / 100,
    direct: Math.floor(directScore * 100) / 100
  };
}
```

---

## Dynamic Pricing

### 1. Occupancy-Based Pricing

Adjust rates based on current occupancy:

```typescript
async applyOccupancyPricing(
  propertyId: string,
  date: string
) {
  // 1. Calculate current occupancy
  const occupancy = await this.calculateOccupancy(propertyId, date);

  // 2. Get base rate
  const { data: baseRate } = await supabase
    .from('room_rates')
    .select('rate')
    .eq('property_id', propertyId)
    .eq('date', date)
    .eq('rate_plan', 'BAR')
    .single();

  // 3. Apply pricing rules
  let adjustedRate = baseRate.rate;

  if (occupancy < 30) {
    // Low occupancy - discount
    adjustedRate = baseRate.rate * 0.85; // 15% discount
  } else if (occupancy > 80) {
    // High occupancy - premium
    adjustedRate = baseRate.rate * 1.25; // 25% premium
  } else if (occupancy > 90) {
    // Very high occupancy - max premium
    adjustedRate = baseRate.rate * 1.50; // 50% premium
  }

  // 4. Update rates on all channels
  await this.syncRateUpdate(
    propertyId,
    date,
    adjustedRate
  );

  console.log(`✅ Dynamic pricing applied: ${occupancy}% → $${adjustedRate}`);
}
```

### 2. Time-Based Pricing

Adjust rates based on booking window:

```typescript
async applyTimeBased Pricing(
  propertyId: string,
  checkInDate: string
) {
  const daysUntilCheckin = this.getDaysUntil(checkInDate);

  // Get base rate
  const baseRate = await this.getBaseRate(propertyId, checkInDate);

  let adjustedRate = baseRate;

  if (daysUntilCheckin > 60) {
    // Early bird discount
    adjustedRate = baseRate * 0.90; // 10% off
  } else if (daysUntilCheckin < 3) {
    // Last minute booking
    adjustedRate = baseRate * 1.20; // 20% premium
  } else if (daysUntilCheckin === 0) {
    // Same day booking
    adjustedRate = baseRate * 1.30; // 30% premium
  }

  await this.syncRateUpdate(propertyId, checkInDate, adjustedRate);
}
```

### 3. Event-Based Pricing

Adjust rates for special events:

```typescript
async applyEventPricing(
  propertyId: string,
  date: string
) {
  // 1. Check for events on date
  const { data: events } = await supabase
    .from('local_events')
    .select('*')
    .eq('date', date)
    .eq('impact', 'high');

  if (!events || events.length === 0) {
    return; // No events
  }

  // 2. Get base rate
  const baseRate = await this.getBaseRate(propertyId, date);

  // 3. Apply event pricing
  const eventMultiplier = 1.5; // 50% premium for events
  const adjustedRate = baseRate * eventMultiplier;

  // 4. Update rates
  await this.syncRateUpdate(propertyId, date, adjustedRate);

  console.log(`✅ Event pricing applied: ${events[0].name}`);
}
```

### 4. Competitor-Based Pricing

Adjust rates based on competitor prices:

```typescript
async applyCompetitorPricing(
  propertyId: string,
  date: string
) {
  // 1. Fetch competitor rates (from scraping or API)
  const competitorRates = await this.getCompetitorRates(
    propertyId,
    date
  );

  // 2. Calculate market average
  const avgCompetitorRate = 
    competitorRates.reduce((sum, r) => sum + r.rate, 0) / 
    competitorRates.length;

  // 3. Get our current rate
  const currentRate = await this.getCurrentRate(propertyId, date);

  // 4. Adjust to be competitive
  let targetRate;
  if (currentRate > avgCompetitorRate * 1.10) {
    // We're too expensive
    targetRate = avgCompetitorRate * 1.05; // 5% above market
  } else if (currentRate < avgCompetitorRate * 0.90) {
    // We're too cheap
    targetRate = avgCompetitorRate * 0.95; // 5% below market
  }

  if (targetRate) {
    await this.syncRateUpdate(propertyId, date, targetRate);
    console.log(`✅ Competitor pricing: ${currentRate} → ${targetRate}`);
  }
}
```

---

## Conflict Resolution

### 1. Last-Write-Wins Strategy

```typescript
async resolveRateConflict(
  propertyId: string,
  date: string
) {
  // Get latest rate from all sources
  const [hmsRate, expediaRate, bookingComRate] = await Promise.all([
    this.getHMSRate(propertyId, date),
    this.getExpediaRate(propertyId, date),
    this.getBookingComRate(propertyId, date)
  ]);

  // Use most recently updated rate
  const latestRate = [hmsRate, expediaRate, bookingComRate]
    .sort((a, b) => new Date(b.updated_at).getTime() - 
                     new Date(a.updated_at).getTime())[0];

  // Sync latest rate to all channels
  await this.syncRateToAllChannels(propertyId, date, latestRate.rate);
}
```

### 2. Priority-Based Resolution

```typescript
async resolveInventoryConflict(
  propertyId: string,
  date: string
) {
  // Priority: HMS > Booking.com > Expedia
  
  const hmsInventory = await this.getHMSInventory(propertyId, date);
  
  if (hmsInventory.is_authoritative) {
    // HMS is source of truth
    await this.syncInventoryToAllChannels(
      propertyId,
      date,
      hmsInventory.available
    );
  } else {
    // Use last-write-wins
    await this.resolveLastWrite(propertyId, date);
  }
}
```

---

## Performance Optimization

### 1. Batch Updates

```typescript
// Batch multiple updates into single API call
async batchSyncUpdates() {
  const pendingUpdates = await this.getPendingUpdates();

  // Group by provider and property
  const grouped = this.groupUpdates(pendingUpdates);

  for (const [provider, updates] of Object.entries(grouped)) {
    if (provider === 'expedia') {
      await this.syncExpediaBatch(updates);
    } else if (provider === 'booking.com') {
      await this.syncBookingComBatch(updates);
    }
  }
}
```

### 2. Caching

```typescript
// Cache frequently accessed data
const rateCache = new Map<string, { rate: number; expires: number }>();

async getCachedRate(propertyId: string, date: string): Promise<number> {
  const key = `${propertyId}:${date}`;
  const cached = rateCache.get(key);

  if (cached && cached.expires > Date.now()) {
    return cached.rate;
  }

  const rate = await this.fetchRate(propertyId, date);
  rateCache.set(key, {
    rate,
    expires: Date.now() + 60000 // 1 minute cache
  });

  return rate;
}
```

### 3. Rate Limiting

```typescript
// Respect API rate limits
class RateLimiter {
  private queue: Array<() => Promise<any>> = [];
  private processing = false;

  async add<T>(fn: () => Promise<T>): Promise<T> {
    return new Promise((resolve, reject) => {
      this.queue.push(async () => {
        try {
          const result = await fn();
          resolve(result);
        } catch (error) {
          reject(error);
        }
      });

      if (!this.processing) {
        this.process();
      }
    });
  }

  private async process() {
    this.processing = true;

    while (this.queue.length > 0) {
      const fn = this.queue.shift()!;
      await fn();
      await this.sleep(100); // 100ms between requests
    }

    this.processing = false;
  }

  private sleep(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
```

---

## Monitoring & Alerts

### Sync Status Dashboard

```sql
-- Real-time sync status
SELECT
  provider,
  sync_type,
  COUNT(*) FILTER (WHERE status = 'success') as successful,
  COUNT(*) FILTER (WHERE status = 'failed') as failed,
  COUNT(*) FILTER (WHERE status = 'pending') as pending,
  AVG(EXTRACT(EPOCH FROM (synced_at - created_at))) as avg_sync_time_seconds
FROM ota_sync_logs
WHERE created_at > NOW() - INTERVAL '1 hour'
GROUP BY provider, sync_type;
```

### Alert Configuration

```sql
-- Create alerts for sync issues
INSERT INTO sync_alerts (
  alert_type,
  condition,
  severity,
  notification_channels
)
VALUES
  (
    'high_failure_rate',
    'failed_syncs > 10 in last 15 minutes',
    'critical',
    ARRAY['email', 'sms', 'slack']
  ),
  (
    'slow_sync',
    'avg_sync_time > 30 seconds',
    'warning',
    ARRAY['email', 'slack']
  ),
  (
    'rate_mismatch',
    'rate_difference > 10%',
    'warning',
    ARRAY['email']
  );
```

---

## Next Steps

1. ✅ Configure sync schedules
2. ✅ Set up rate/inventory allocation rules
3. ✅ Implement dynamic pricing
4. ✅ Configure conflict resolution
5. ✅ Set up monitoring and alerts
6. ⏭️ Test sync performance
7. ⏭️ Optimize batch operations

---

**Document Version**: 1.0  
**Last Updated**: December 26, 2024  
**Next Review**: January 26, 2025
