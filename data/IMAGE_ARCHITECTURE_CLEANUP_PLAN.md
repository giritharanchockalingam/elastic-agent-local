# Image Architecture Cleanup & Standardization Plan

## 🚨 Current Problems

### 1. **Confusing `public_*` Naming in `public` Schema**
- Tables like `public_property_images` in the `public` schema is redundant
- `public` schema is PostgreSQL's default schema
- `public_` prefix suggests "public-facing" but being in `public` schema is confusing
- **This is indeed a band-aid solution**

### 2. **Multiple Fallback Chains (Terrible Design)**
Images are loaded from multiple sources with complex fallbacks:
```
Database (public_property_images) 
  → public_metadata.images (JSONB)
  → property.images (array)
  → Bundled static files (/images/v3-grand-hotel-hero-01.jpg)
  → getPropertyMainImage() (hardcoded mappings)
  → Placeholder
```

**Problem**: Even after deleting all DB records, images still render from hardcoded fallbacks!

### 3. **Hardcoded Image Paths**
- `src/pages/public/Index.tsx`: Hardcoded hero image candidates
- `src/assets/hotels/index.ts`: Hardcoded property image mappings
- Multiple components have fallback image paths

## ✅ Proposed Solution

### Phase 1: Standardize Table Naming

**Option A: Remove `public_` prefix (Recommended)**
- Rename `public_property_images` → `property_images`
- Rename `public_property_content` → `property_content`
- Rename `public_tenant_content` → `tenant_content`
- Keep views as `public_tenants`, `public_properties` (these are fine - they're views)

**Option B: Move to dedicated schema**
- Create `portal` schema
- Move all public-facing tables there
- `portal.property_images`, `portal.tenant_content`, etc.

**Recommendation**: **Option A** - simpler, less migration overhead

### Phase 2: Remove ALL Fallbacks

**Principle**: Database is the **ONLY** source of truth. No fallbacks.

**Changes Required**:

1. **Remove hardcoded image paths**:
   - `src/pages/public/Index.tsx`: Remove `heroImageCandidates` array
   - `src/assets/hotels/index.ts`: Remove all hardcoded mappings
   - All components: Remove fallback image URLs

2. **Update image loading functions**:
   - `getPropertyImages()`: Return empty array if no DB images (no fallback)
   - `getPropertyHeroImage()`: Return `null` if no DB images (no fallback)
   - All image resolvers: Remove fallback chains

3. **Update components to show empty states**:
   - If `heroImages.length === 0`: Show empty state component
   - If `galleryImages.length === 0`: Show "No images available" message
   - Never render placeholder images as "content"

### Phase 3: Database Schema Cleanup

**Migration Plan**:

1. **Rename tables** (if going with Option A):
   ```sql
   ALTER TABLE public.public_property_images 
   RENAME TO property_images;
   
   ALTER TABLE public.public_property_content 
   RENAME TO property_content;
   
   ALTER TABLE public.public_tenant_content 
   RENAME TO tenant_content;
   
   ALTER TABLE public.public_tenant_images 
   RENAME TO tenant_images;
   ```

2. **Update all references**:
   - Update RLS policies
   - Update views
   - Update application code
   - Update migration scripts

3. **Keep views as-is** (they're fine):
   - `public_tenants` view (filters `tenants` table)
   - `public_properties` view (filters `properties` table)

## 📋 Implementation Checklist

### Step 1: Remove Hardcoded Fallbacks
- [ ] Remove `heroImageCandidates` from `Index.tsx`
- [ ] Remove all hardcoded paths from `assets/hotels/index.ts`
- [ ] Remove `getPropertyMainImage()` fallback calls
- [ ] Remove `public_metadata?.images` fallbacks
- [ ] Remove `property.images` array fallbacks

### Step 2: Update Image Loading Functions
- [ ] Update `getPropertyImages()` to return empty array (no fallback)
- [ ] Update `getPropertyHeroImage()` to return null (no fallback)
- [ ] Update `imageResolver.ts` to remove all fallback logic
- [ ] Update all image hooks to not use fallbacks

### Step 3: Update Components
- [ ] Add empty state components for missing images
- [ ] Remove placeholder image rendering
- [ ] Show "No images available" messages
- [ ] Update all pages to handle empty image arrays gracefully

### Step 4: Database Schema Cleanup (Optional)
- [ ] Decide: Option A (remove prefix) or Option B (new schema)
- [ ] Create migration to rename tables
- [ ] Update all code references
- [ ] Update RLS policies
- [ ] Test thoroughly

## 🎯 Expected Behavior After Cleanup

### Before (Current - Bad):
```typescript
// Multiple fallback chains
const image = 
  dbImages[0] || 
  property.public_metadata?.images?.[0] || 
  property.images?.[0] || 
  getPropertyMainImage(slug) || 
  '/images/fallback.jpg' || 
  '/placeholder.svg';
```

### After (Clean - Good):
```typescript
// Database ONLY - no fallbacks
const { data: images } = useQuery({
  queryKey: ['property-images', propertyId],
  queryFn: () => getPropertyImages(propertyId),
});

// Show empty state if no images
if (!images || images.length === 0) {
  return <EmptyState message="No images available" />;
}

// Use first image
const heroImage = images[0];
```

## 🔍 Files to Update

### Critical (Remove Fallbacks):
1. `src/pages/public/Index.tsx` - Remove hardcoded hero images
2. `src/pages/public/SearchResults.tsx` - Remove fallback chains
3. `src/pages/public/PropertyReservations.tsx` - Remove fallback chains
4. `src/lib/domain/public.ts` - Remove fallback logic
5. `src/lib/images/imageResolver.ts` - Remove fallback logic
6. `src/assets/hotels/index.ts` - Remove all hardcoded mappings

### Database (If Renaming):
1. Create migration to rename tables
2. Update all RLS policies
3. Update all views
4. Update all application code references

## ⚠️ Breaking Changes

This cleanup will:
- ❌ Remove all hardcoded fallback images
- ❌ Pages will show empty states if no DB images exist
- ❌ No more "fake" images from static files

**This is intentional** - forces proper data management!

## 🚀 Migration Strategy

1. **Phase 1**: Remove fallbacks (non-breaking if DB has images)
2. **Phase 2**: Rename tables (requires coordinated deployment)
3. **Phase 3**: Update documentation

## 📝 Notes

- The `public_*` prefix was added to distinguish public-facing content from internal data
- However, being in the `public` schema already implies this
- Better approach: Use proper RLS policies and views (which already exist)
- The fallback chains were added as "safety nets" but create confusion
- **Single source of truth (database) is the correct approach**
