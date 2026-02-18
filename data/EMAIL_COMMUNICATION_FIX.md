# Email Communication Fix - Enterprise Grade

## Issues Fixed

1. **"Hotel Hotel Management" instead of "V3 Grand Hotel Management"**
   - Fixed property name defaulting logic
   - Only uses "Hotel" as fallback if property name is truly missing
   - Properly passes property name through all function calls

2. **"Hotel Hotel Team" in signature**
   - Fixed signature generation to use property name correctly
   - Prevents duplicate "Hotel" when property name is missing

3. **Phone and Email showing "N/A"**
   - Enhanced property data fetching to use enterprise property_settings table
   - Falls back to properties table if settings not available
   - Properly handles empty/null values

4. **Enterprise-Grade Property Settings Structure**
   - Created `property_settings` table linked to tenants
   - Provides master data management for property communication settings
   - Includes RLS policies for security

## Changes Made

### 1. Edge Functions Updated

#### `send-guest-communication/index.ts`
- Enhanced property data fetching to use `get_property_communication_settings()` RPC function
- Falls back to properties table if RPC not available
- Fixed property name defaulting (only uses "Hotel" if truly missing)
- Passes property phone/email through config to provider functions
- Fixed fallback Resend call to include property data

#### `process-communication-queue/index.ts`
- Enhanced property data fetching to use property_settings table
- Fixed signature generation to prevent "Hotel Hotel Team"
- Improved phone/email handling (checks for empty strings, not just "N/A")
- Updated signature pattern matching

### 2. Database Migration

#### `20251228_enterprise_property_settings.sql`
- Creates `property_settings` table linked to tenants and properties
- Stores contact information (phone, email) for communications
- Allows custom email from name and signature
- Includes RLS policies for security
- Creates `get_property_communication_settings()` helper function
- Migrates existing property phone/email data

## Database Structure

### property_settings Table

```sql
CREATE TABLE public.property_settings (
  id UUID PRIMARY KEY,
  tenant_id UUID REFERENCES tenants(id),
  property_id UUID REFERENCES properties(id) UNIQUE,
  
  -- Contact Information
  contact_phone TEXT,
  contact_email TEXT,
  
  -- Email Settings
  email_from_name TEXT,  -- Override for "From" name
  email_signature TEXT,  -- Custom signature
  
  -- Other settings...
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);
```

### Helper Function

`get_property_communication_settings(property_id)` returns:
- `property_name`: From properties.name
- `property_phone`: From property_settings.contact_phone (fallback to properties.phone)
- `property_email`: From property_settings.contact_email (fallback to properties.email)
- `email_from_name`: From property_settings.email_from_name (or generated: property_name + " Hotel Management")
- `email_signature`: From property_settings.email_signature (or generated: property_name + " Hotel Team")
- `email_reply_to`: From property_settings.email_reply_to (fallback to property_email)

## How It Works

1. **Email From Name**: 
   - Uses `property_settings.email_from_name` if set
   - Otherwise generates: `{property.name} Hotel Management`
   - Only uses "Hotel" if property name is truly missing

2. **Email Signature**:
   - Uses `property_settings.email_signature` if set
   - Otherwise generates: `{property.name} Hotel Team`
   - Prevents "Hotel Hotel Team" by checking property name

3. **Contact Information**:
   - Uses `property_settings.contact_phone` and `contact_email` if set
   - Falls back to `properties.phone` and `properties.email`
   - Returns empty string if both are missing (not "N/A")

## Migration Steps

1. **Apply Migration**:
   ```bash
   supabase db push
   ```
   Or copy `supabase/migrations/20251228_enterprise_property_settings.sql` to Supabase SQL Editor

2. **Verify Migration**:
   ```sql
   -- Check table exists
   SELECT * FROM information_schema.tables 
   WHERE table_name = 'property_settings';
   
   -- Check function exists
   SELECT routine_name FROM information_schema.routines
   WHERE routine_name = 'get_property_communication_settings';
   
   -- Test function
   SELECT * FROM get_property_communication_settings('YOUR_PROPERTY_ID');
   ```

3. **Update Property Settings** (via Property Settings page):
   - Go to `/property-settings`
   - Update contact phone and email
   - Optionally set custom email from name and signature

## Testing

1. **Test Email From Name**:
   - Send a test email
   - Verify "From" shows: `{Property Name} Hotel Management`
   - Should NOT show "Hotel Hotel Management"

2. **Test Email Signature**:
   - Check email signature
   - Should show: `{Property Name} Hotel Team`
   - Should NOT show "Hotel Hotel Team"

3. **Test Contact Information**:
   - Verify phone and email are populated
   - Should NOT show "N/A"
   - Should use values from property_settings if set, otherwise from properties table

## Property Settings Page Integration

The Property Settings page (`/property-settings`) should be updated to:
- Display and edit `property_settings` table fields
- Show contact phone/email from property_settings (with fallback to properties)
- Allow setting custom email from name and signature
- Link to tenant for multi-tenant support

## Related Files

- `supabase/functions/send-guest-communication/index.ts` - Email sending function
- `supabase/functions/process-communication-queue/index.ts` - Queue processor
- `supabase/migrations/20251228_enterprise_property_settings.sql` - Database migration
- `src/pages/PropertySettings.tsx` - Property settings UI (needs update to use property_settings table)

