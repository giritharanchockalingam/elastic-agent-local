# User Theme Customization - Setup Verification

## Quick Check

If you're seeing the app running but want to verify the theme system is set up correctly, run this in Supabase SQL Editor:

```sql
\i scripts/verify-user-theme-setup.sql
```

## Expected Results

### ✅ If Setup is Correct:
1. **Table exists**: `user_preferences` table should exist
2. **RLS enabled**: Row Level Security should be enabled
3. **Policies exist**: Should have 4 policies (SELECT, INSERT, UPDATE, DELETE)
4. **Test insert works**: Should be able to insert test data

### ❌ If Setup is Missing:
1. **Table missing**: Run the migration:
   ```sql
   \i supabase/migrations/20251226_user_theme_preferences.sql
   ```

## Common Issues

### Issue 1: Table Doesn't Exist
**Symptom**: Console shows warnings like "Error loading user theme" or "relation user_preferences does not exist"

**Solution**: Run the migration:
```sql
\i supabase/migrations/20251226_user_theme_preferences.sql
```

### Issue 2: RLS Blocking Queries
**Symptom**: Queries return empty results even though data exists

**Solution**: Verify RLS policies are correct:
```sql
SELECT * FROM pg_policies 
WHERE tablename = 'user_preferences';
```

### Issue 3: Theme Not Loading on App Start
**Symptom**: Theme doesn't apply when you log in

**Check**:
1. Verify `useThemeInit` hook is being called in `App.tsx`
2. Check browser console for theme-related warnings
3. Verify user is authenticated (theme only loads for logged-in users)

## Testing the Theme System

### Step 1: Navigate to Theme Page
1. Log in to the app
2. Go to `/theme-customization` or `/theme`
3. Page should load without errors

### Step 2: Select a Theme
1. Click on any preset theme
2. Theme should apply immediately (preview)
3. Click "Save Theme"
4. Should see success toast

### Step 3: Verify Persistence
1. Refresh the page
2. Theme should still be applied
3. Log out and log back in
4. Theme should persist

### Step 4: Check Database
```sql
SELECT 
  preference_key,
  preference_value,
  updated_at
FROM user_preferences
WHERE user_id = auth.uid()
  AND preference_key IN ('theme_colors', 'theme_active');
```

## Debugging

### Check Console Logs
Look for:
- `Error loading user theme:` - Table might not exist
- `Error fetching user theme preferences:` - RLS or query issue
- `Error saving preference:` - Insert/update issue

### Check Network Tab
Look for requests to:
- `/rest/v1/user_preferences` - Should return 200 OK
- If 404: Table doesn't exist
- If 401/403: RLS policy issue

## Next Steps

If everything is working:
- ✅ Users can customize their theme
- ✅ Theme persists across sessions
- ✅ Each user has independent theme

If not working:
1. Run verification script
2. Check migration was applied
3. Verify RLS policies
4. Check browser console for errors

