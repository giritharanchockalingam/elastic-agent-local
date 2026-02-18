# Enterprise Pricing Rules Engine

## Overview
A comprehensive, enterprise-grade pricing rules engine for Hotel Management System (HMS) that supports complex pricing scenarios, dynamic rate calculations, and advanced revenue optimization.

## Features

### 1. Advanced Rule Types
- **Seasonal Pricing**: Different rates for different seasons with yearly recurrence
- **Day-of-Week Pricing**: Weekend/weekday pricing variations
- **Length of Stay**: Discounts or premiums based on stay duration
- **Early Bird / Last Minute**: Advance booking and last-minute pricing
- **Group Pricing**: Special rates for group bookings
- **Corporate/Negotiated Rates**: Custom rates for corporate clients
- **Channel-Based Pricing**: Different rates per booking channel (Direct, OTA, etc.)
- **Guest Type Pricing**: Loyalty member, VIP, corporate rates
- **Room Type Specific**: Rules that apply to specific room types
- **Occupancy-Based**: Dynamic pricing based on occupancy levels
- **Package Pricing**: Bundled room + services pricing

### 2. Rule Conditions
The engine supports comprehensive conditions:
- **Date Ranges**: Single dates or recurring patterns (yearly, monthly, weekly)
- **Days of Week**: Apply rules to specific days (e.g., weekends only)
- **Room Types**: Target specific room categories
- **Booking Channels**: Direct, OTA, corporate, travel agent, etc.
- **Guest Segments**: Loyalty, VIP, corporate, group, leisure, business
- **Booking Window**: Minimum/maximum days in advance
- **Length of Stay**: Minimum/maximum nights requirements
- **Number of Rooms**: Group size requirements
- **Occupancy Thresholds**: Based on current occupancy rates
- **Exclude Dates**: Blackout dates when rules don't apply

### 3. Adjustment Types
- **Percentage**: Percentage-based markup or discount
- **Fixed Amount**: Fixed monetary adjustment
- **Override**: Complete rate replacement
- **Minimum/Maximum Rate Constraints**: Cap rates to prevent over-pricing or under-pricing
- **Maximum Adjustment Limits**: Prevent excessive discounts or markups

### 4. Rule Engine Features
- **Priority-Based Evaluation**: Rules processed by priority (lower = higher priority)
- **Stackable Rules**: Multiple rules can be combined
- **Conflict Resolution**: Non-stackable rules take precedence
- **Rule Testing/Simulation**: Test rules against scenarios before activation
- **Rule Templates**: Pre-configured templates for common scenarios
- **Rule Application Logging**: Audit trail of all rule applications
- **Performance Analytics**: Track rule effectiveness and usage

### 5. Database Schema

#### `pricing_rules` Table
Enhanced with:
- `rule_category`: Categorization of rule type
- `rule_subcategory`: Additional classification
- `conditions`: JSONB with comprehensive condition structure
- `max_adjustment_amount`: Maximum adjustment cap
- `min_rate` / `max_rate`: Rate boundaries
- `stackable`: Whether rule can combine with others
- `application_count`: Usage tracking
- `last_applied_at`: Last application timestamp
- `created_by`: Audit field

#### `pricing_rule_templates` Table
Pre-configured templates for:
- Weekend Premium
- Early Bird Discount
- Last Minute Deal
- Length of Stay Discount
- Group Rate
- Corporate Rate
- Loyalty Member Discount
- High/Low Season Pricing
- OTA Channel Fees

#### `pricing_rule_applications` Table
Audit log tracking:
- Rule application history
- Conditions matched
- Rate adjustments applied
- Booking context (dates, channels, segments)
- Performance metrics

### 6. Pricing Engine Service

Located in `src/services/pricingEngine.ts`:

#### Key Functions:
- `evaluateRuleConditions()`: Checks if rule conditions match context
- `calculatePricing()`: Main pricing calculation with all applicable rules
- `simulatePricing()`: Test pricing across multiple scenarios

#### Evaluation Logic:
1. Filters active rules
2. Sorts by priority (ascending)
3. Evaluates each rule's conditions
4. Calculates adjustments sequentially
5. Applies stackable rules when allowed
6. Respects min/max rate constraints
7. Returns final rate with adjustment breakdown

### 7. UI Components

#### RuleBuilder Component (`src/components/pricing/RuleBuilder.tsx`)
Visual builder for configuring rule conditions:
- Date range picker with recurrence options
- Day-of-week selector
- Room type multi-select
- Channel selector
- Guest segment selector
- Booking window configuration
- Length of stay requirements
- Group size requirements

### 8. Usage Example

```typescript
import { calculatePricing, PricingContext } from '@/services/pricingEngine';

const context: PricingContext = {
  property_id: 'property-uuid',
  room_type_id: 'room-type-uuid',
  check_in_date: '2024-06-15',
  check_out_date: '2024-06-18',
  booking_channel: 'direct',
  guest_segment: 'loyalty',
  length_of_stay: 3,
  base_rate: 1000,
  booking_date: '2024-05-01',
};

const result = calculatePricing(rules, context);
// Returns: { base_rate, final_rate, adjustments, matched_rules, conditions_matched }
```

### 9. Best Practices

1. **Priority Management**: Use lower numbers (1-10) for high-priority rules
2. **Stackable Rules**: Mark rules as stackable only when they can safely combine
3. **Rate Constraints**: Always set min/max rates to prevent pricing errors
4. **Testing**: Use simulation before activating new rules
5. **Monitoring**: Review rule application logs regularly
6. **Templates**: Start with templates and customize as needed

### 10. Future Enhancements

- Machine learning-based dynamic pricing
- Competitor rate integration
- Advanced forecasting
- A/B testing framework
- Rule performance dashboards
- Automated rule suggestions
- Real-time rate updates
- Multi-property rule inheritance

## Implementation Status

✅ Database schema enhanced
✅ Pricing engine service created
✅ RuleBuilder component created
✅ Rule templates seeded
⏳ Full UI integration (in progress)
⏳ Rule testing interface (pending)
⏳ Analytics dashboard (pending)
