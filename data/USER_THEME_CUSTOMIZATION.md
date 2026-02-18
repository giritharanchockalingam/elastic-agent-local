# User-Based Theme Customization

## Overview

Theme customization has been converted from a system-wide (property-based) setting to a **per-user preference**. Each user can now customize their own theme, and their choice persists across sessions.

## Key Changes

### 1. Database Schema

**New Table**: `user_preferences`
- Stores user-specific preferences including theme settings
- Each user has their own theme preferences
- RLS policies ensure users can only access their own preferences

**Migration**: `supabase/migrations/20251226_user_theme_preferences.sql`

### 2. Theme Storage

**Before**: Stored in `system_settings` table with `property_id`
**After**: Stored in `user_preferences` table with `user_id`

**Structure**:
- `preference_key: 'theme_colors'` → JSONB with color values
- `preference_key: 'theme_active'` → Active theme name

### 3. Access Control

**Before**: Only admins could access theme customization (RBAC restricted)
**After**: All authenticated users can access and customize their own theme

**Permission**: `view_theme` - Added to all roles

### 4. Theme Initialization

**Before**: `useThemeInit` loaded theme from `system_settings` based on `property_id`
**After**: `useThemeInit` loads theme from `user_preferences` based on `user_id`

## Files Modified

### Database
- ✅ `supabase/migrations/20251226_user_theme_preferences.sql` - New migration

### Frontend Components
- ✅ `src/pages/ThemeCustomization.tsx` - Updated to use user preferences
- ✅ `src/hooks/useThemeInit.ts` - Updated to load user theme
- ✅ `src/config/rbac.ts` - Added `view_theme` permission to all roles
- ✅ `src/lib/routePermissions.ts` - Updated route permissions

## How It Works

### 1. Theme Loading (App Start)

When a user logs in:
1. `useThemeInit` hook runs
2. Fetches user's theme preferences from `user_preferences` table
3. Applies theme to CSS variables
4. Theme persists across page refreshes

### 2. Theme Customization

When a user customizes their theme:
1. User selects a preset or customizes colors
2. Changes are applied immediately (preview)
3. User clicks "Save Theme"
4. Theme is saved to `user_preferences` table
5. Theme persists for future sessions

### 3. Theme Persistence

- Theme is stored per user in database
- Automatically loaded on app start
- Persists across:
  - Page refreshes
  - Browser sessions
  - Different devices (if same user account)

## User Experience

### For Users
- ✅ Each user has their own theme preference
- ✅ Theme page accessible from sidebar (no admin restriction)
- ✅ Changes apply immediately
- ✅ Theme persists across sessions
- ✅ Can reset to default anytime

### For Admins
- ✅ Same experience as regular users
- ✅ Can customize their own theme
- ✅ No longer affects other users

## Database Schema

```sql
CREATE TABLE public.user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  preference_key TEXT NOT NULL,
  preference_value JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, preference_key)
);
```

## RLS Policies

- Users can only view their own preferences
- Users can only insert/update/delete their own preferences
- Secure by default - no cross-user access

## Migration Steps

1. **Run Database Migration**:
   ```sql
   \i supabase/migrations/20251226_user_theme_preferences.sql
   ```

2. **Deploy Frontend Changes**:
   - No additional deployment needed
   - Changes are in code

3. **Verify**:
   - Log in as any user
   - Navigate to Theme Customization
   - Customize and save theme
   - Log out and log back in
   - Theme should persist

## Testing Checklist

- [ ] User can access theme customization page
- [ ] User can select preset themes
- [ ] User can customize colors
- [ ] Theme applies immediately on preview
- [ ] Theme saves to database
- [ ] Theme persists after page refresh
- [ ] Theme persists after logout/login
- [ ] Each user has independent theme
- [ ] RLS policies prevent cross-user access

## Benefits

1. **Personalization**: Each user can have their preferred theme
2. **Accessibility**: Users can choose themes that work best for them
3. **Privacy**: Each user's preferences are isolated
4. **Flexibility**: Easy to extend for other user preferences in future

## Future Enhancements

The `user_preferences` table can be extended for:
- Language preferences
- Dashboard layout preferences
- Notification preferences
- UI density preferences
- Other personalization settings

