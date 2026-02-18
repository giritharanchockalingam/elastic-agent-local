# 🚀 Complete HMS Database Migration - Quick Start Guide

## Overview

This guide will migrate your HMS database from the old Supabase project to the new one with proper security and data integrity.

**Time Required**: 15-20 minutes  
**Difficulty**: Easy (just run SQL scripts)  
**Backup Required**: Yes (automatic via Supabase)

---

## ✅ Pre-Migration Checklist

- [ ] New Supabase project created: `qnwsnrfcnonaxvnithfv`
- [ ] Admin access to both projects
- [ ] App connected to new project (`.env` updated)
- [ ] Current property_id: `00000000-0000-0000-0000-000000000111` (Aurora Grand Hotel with 40 rooms)

---

## 🎯 Migration Steps

### Step 1: Create Missing Tables (5 min)

**Open**: https://supabase.com/dashboard/project/qnwsnrfcnonaxvnithfv/sql/new

**Run**: `scripts/migration-step1-create-tables.sql`

This creates:
- ✅ `languages` - i18n support
- ✅ `system_settings` - app configuration
- ✅ `scheduled_jobs` - background tasks
- ✅ `user_activity_logs` - audit trail
- ✅ `guests` - guest management (fixed)
- ✅ `reservations` - booking system (fixed)

**Expected Output**:
```
Tables Created Successfully
table_count: 6
```

---

### Step 2: Apply RLS Security Policies (5 min)

**Run**: `scripts/migration-step2-rls-policies.sql`

This secures:
- 🔒 Property-based data isolation
- 🔒 User can only see their assigned properties
- 🔒 Prevents unauthorized access
- 🔒 Implements least-privilege access

**Expected Output**:
```
RLS Policies Created
policy_count: 40+
```

All tables should show: `✅ Enabled`

---

### Step 3: Data Integrity & Validation (5 min)

**Run**: `scripts/migration-step3-data-integrity.sql`

This ensures:
- 📇 Performance indexes created
- ⏰ Auto-update timestamps
- 🔗 Foreign key constraints
- ✅ All records have valid property_id
- ✅ No orphaned records

**Expected Output**:
```
📊 RECORD COUNTS
properties: 2
rooms: 40
staff: 4
...

⚠️ ORPHANED RECORDS
All should be: 0

🔒 RLS STATUS
All should be: ✅ Enabled
```

---

### Step 4: Verify in Application (2 min)

1. **Clear browser cache**:
   ```javascript
   localStorage.clear();
   sessionStorage.clear();
   ```

2. **Hard refresh**: `Ctrl+Shift+R` or `Cmd+Shift+R`

3. **Check Console** - Should show:
   ```
   ✅ Found 1 properties from staff assignments
   🏨 PropertyContext: Final Property ID: 00000000-0000-0000-0000-000000000111
   🔍 Found 40 rooms with property_id filter
   ```

4. **Check UI**:
   - ✅ Header shows: **🏢 Aurora Grand Hotel**
   - ✅ Rooms Inventory shows: **40 rooms**
   - ✅ No console errors (404s, 400s should be gone)

---

## 🎉 Migration Complete!

Your database is now:
- ✅ Fully migrated with all tables
- ✅ Secured with RLS policies
- ✅ Data integrity enforced
- ✅ Performance optimized
- ✅ Ready for production

---

## 📊 What Was Migrated

### Tables Created/Fixed:
1. **languages** - Multi-language support (9 languages)
2. **system_settings** - App configuration (7 settings)
3. **scheduled_jobs** - Background task management
4. **user_activity_logs** - Audit trail and compliance
5. **guests** - Fixed schema and RLS policies
6. **reservations** - Fixed schema and RLS policies

### Security Applied:
- 🔒 **RLS enabled** on all tables
- 🔒 **Property-based isolation** - Users only see their property data
- 🔒 **User-based access** - Authenticated users only
- 🔒 **Foreign key constraints** - Data integrity enforced
- 🔒 **Cascading deletes** - Prevent orphaned records

### Performance Optimizations:
- 📇 **30+ indexes** created for fast queries
- ⏰ **Auto-update triggers** for timestamps
- 🔍 **Query optimization** for property filtering

---

## 🔧 Troubleshooting

### Still seeing 404 errors (languages, etc.)?
**Run**: Step 1 again to ensure tables were created

### Still seeing 400 errors (guests, reservations)?
**Run**: Step 2 again to fix RLS policies

### Rooms not showing?
**Check**:
```sql
SELECT 
  u.email,
  p.name,
  COUNT(r.id) as room_count
FROM public.staff s
JOIN auth.users u ON s.user_id = u.id
JOIN public.properties p ON s.property_id = p.id
LEFT JOIN public.rooms r ON r.property_id = p.id
WHERE u.id = auth.uid()
GROUP BY u.email, p.name;
```

### Property selector not showing?
**Verify staff assignment**:
```sql
SELECT * FROM public.staff WHERE user_id = auth.uid();
```
If empty, run the user linking script from earlier.

---

## 📝 Additional Setup (Optional)

### Add More Languages

```sql
INSERT INTO public.languages (language_code, language_name, native_name, flag_emoji) VALUES
  ('pt', 'Portuguese', 'Português', '🇵🇹'),
  ('ru', 'Russian', 'Русский', '🇷🇺'),
  ('ko', 'Korean', '한국어', '🇰🇷');
```

### Add Custom System Settings

```sql
INSERT INTO public.system_settings (setting_key, setting_value, setting_type, description, is_public) VALUES
  ('email_notifications', 'true', 'boolean', 'Enable email notifications', false),
  ('max_file_size', '10485760', 'number', 'Max file upload size in bytes', false),
  ('session_timeout', '3600', 'number', 'Session timeout in seconds', false);
```

### Create Additional Staff Assignments

```sql
-- Assign user to multiple properties
INSERT INTO public.staff (id, user_id, property_id, full_name, email, status)
VALUES (
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'user@example.com'),
  '00000000-0000-0000-0000-000000000111',
  'User Name',
  'user@example.com',
  'active'
);
```

---

## 🎯 Success Criteria

✅ All 3 SQL scripts ran without errors  
✅ Console shows no 404/400 errors  
✅ Property selector visible in header  
✅ 40 rooms displaying correctly  
✅ All HMS features working  

---

## 📞 Need Help?

If you encounter issues:
1. Check the **Troubleshooting** section above
2. Review console logs for specific errors
3. Run the validation queries in Step 3
4. Verify your staff assignment exists

---

**Your HMS is now fully migrated and production-ready!** 🎉
