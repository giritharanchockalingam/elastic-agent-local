# Public Portal Enhancement Plan

## Overview
This document outlines the comprehensive plan to enhance the public portal to achieve world-class UI/UX standards with real database data.

## Current State Analysis

### ✅ Strengths
- Solid foundation with proper RLS and security
- Public views and domain functions exist
- Basic pages are implemented
- Navigation structure is in place

### ⚠️ Areas for Improvement
1. **Hardcoded Content**: Some pages use hardcoded hero images, text, and placeholders
2. **Pricing Data**: Property cards show prices from properties table, but prices should come from room_types
3. **Images**: Some pages use fallback images, need to ensure all use real DB images
4. **Navigation**: Needs to be consistent across all pages and use real data
5. **Data Completeness**: Some properties may be missing amenities, descriptions, or images
6. **Search & Filters**: Need to ensure all filters work with real data

## Enhancement Roadmap

### Phase 1: Core Data Enhancements (Priority: Critical)

#### 1.1 Index.tsx (Home Page)
- [x] Add function to get default tenant content
- [ ] Replace hardcoded hero image with tenant content or smart defaults
- [ ] Replace hardcoded text with tenant content
- [ ] Add function to get minimum price from room_types for each property
- [ ] Ensure all property cards use real images from DB
- [ ] Improve location text to use real property data

#### 1.2 Property Pricing
- [ ] Create helper function to get minimum price per property from room_types
- [ ] Update all property cards to use minimum room type price
- [ ] Cache pricing data appropriately

#### 1.3 Images
- [ ] Ensure all pages use images from:
  1. Database (public_property_images, room_images, media_library)
  2. Harvested content
  3. Smart defaults (only as last resort)

### Phase 2: Page-by-Page Review (Priority: High)

#### 2.1 TenantLanding.tsx
- [x] Already uses real tenant data ✅
- [ ] Verify all content comes from DB
- [ ] Ensure images are from DB

#### 2.2 PropertyLanding.tsx
- [x] Uses real property data ✅
- [ ] Ensure all sections use real data
- [ ] Verify amenities display correctly
- [ ] Check services section uses hotel_amenities

#### 2.3 RoomsListing.tsx
- [x] Uses real room types ✅
- [ ] Verify filtering works with real data
- [ ] Ensure pricing is accurate

#### 2.4 RoomTypeDetail.tsx
- [x] Uses real room type data ✅
- [ ] Verify images display correctly
- [ ] Ensure amenities are shown

#### 2.5 RestaurantListing.tsx
- [ ] Verify uses real restaurant data
- [ ] Ensure images are from DB

#### 2.6 RestaurantDetail.tsx
- [ ] Verify uses real restaurant data
- [ ] Ensure menu preview works

#### 2.7 RestaurantMenu.tsx
- [ ] Verify uses real menu items
- [ ] Ensure pricing is correct
- [ ] Check images display

#### 2.8 SearchResults.tsx
- [x] Uses real properties ✅
- [ ] Fix hardcoded filter options (stars, amenities)
- [ ] Ensure filters work with real data
- [ ] Add real pricing from room_types

#### 2.9 BookingFlow.tsx
- [ ] Verify availability checking works
- [ ] Ensure pricing calculations are correct
- [ ] Check booking submission works

#### 2.10 BookingConfirmation.tsx
- [ ] Verify displays real booking data
- [ ] Ensure all details are accurate

### Phase 3: Navigation & UX (Priority: Medium)

#### 3.1 Navigation Components
- [ ] Review TenantHeader - ensure uses real data
- [ ] Ensure navigation links work correctly
- [ ] Add breadcrumbs where helpful
- [ ] Ensure mobile navigation works

#### 3.2 Consistency
- [ ] Ensure all pages use same component library
- [ ] Verify consistent styling
- [ ] Check loading states are consistent
- [ ] Ensure error states are user-friendly

### Phase 4: Database Schema Enhancements (Priority: Medium)

#### 4.1 Missing Data
- [ ] Review what data is missing for properties
- [ ] Add seed data for missing properties
- [ ] Ensure all properties have:
  - Images
  - Descriptions
  - Amenities
  - Pricing (via room_types)

#### 4.2 Performance
- [ ] Consider materialized view for property minimum prices
- [ ] Optimize queries
- [ ] Add indexes where needed

### Phase 5: Advanced Features (Priority: Low)

#### 5.1 Search
- [ ] Enhance search functionality
- [ ] Add autocomplete
- [ ] Improve filters

#### 5.2 Personalization
- [ ] Track user preferences
- [ ] Show recommended properties

## Implementation Status

### Completed
- [x] Added `getDefaultTenantContent()` function
- [x] Added `listPublicTenants()` function
- [x] Fixed error handling for missing tables
- [x] Enhanced BookingWidget date picker

### In Progress
- [ ] Enhancing Index.tsx with real tenant content
- [ ] Creating property pricing helper function

### Pending
- [ ] All other items in roadmap

## Notes
- Always use public views for security
- Never expose PII
- Ensure RLS is properly configured
- Use proper loading and error states
- Test all pages with real data
- Ensure responsive design on all pages
