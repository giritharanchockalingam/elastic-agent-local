# Complete Setup and Test Guide

This guide walks you through all 3 next actions:
1. Create test users in Supabase
2. Re-run automation tests to verify RBAC fixes
3. Verify access control manually

---

## Step 1: Create Test Users in Supabase

### Option A: Automated (Recommended)

**Prerequisites:**
- Supabase Service Role Key (from Supabase Dashboard → Settings → API)

**Steps:**

1. Get your Supabase credentials:
   ```bash
   # Find these in Supabase Dashboard → Settings → API
   # - Project URL (SUPABASE_URL)
   # - Service Role Key (SUPABASE_SERVICE_ROLE_KEY) - Keep this secret!
   ```

2. Run the creation script:
   ```bash
   cd /Users/giritharanchockalingam/Desktop/GitHub/hms-gcp-refactor
   
   # Set environment variables
   export SUPABASE_URL="your_supabase_project_url"
   export SUPABASE_SERVICE_ROLE_KEY="your_service_role_key"
   
   # Run the script
   node scripts/create-test-users.cjs
   ```

3. Verify users were created:
   - Go to Supabase Dashboard → Authentication → Users
   - You should see 9 users with @hmstest.com emails

### Option B: Manual Setup

1. Go to https://app.supabase.com
2. Select project: `crumfjyjvofleoqfpwzm`
3. Navigate to: **Authentication → Users**
4. Click **"Add user"** for each test user:

| Email | Password | Role |
|-------|----------|------|
| superadmin@hmstest.com | Test@1234567890 | super_admin |
| propertyadmin@hmstest.com | Test@1234567890 | admin |
| manager@hmstest.com | Test@1234567890 | general_manager |
| frontdesk@hmstest.com | Test@1234567890 | front_desk_agent |
| housekeeping@hmstest.com | Test@1234567890 | housekeeping_staff |
| kitchen@hmstest.com | Test@1234567890 | kitchen_staff |
| accountant@hmstest.com | Test@1234567890 | accountant |
| hrmanager@hmstest.com | Test@1234567890 | hr_manager |
| guest@hmstest.com | Test@1234567890 | guest |

5. Assign roles via SQL Editor:
   - Go to **SQL Editor** in Supabase
   - Copy and paste contents of `scripts/setup-test-users.sql`
   - Run the script

6. Verify roles:
   - Run the verification query at the end of the SQL script
   - Should show 9 users with their roles

---

## Step 2: Re-run Automation Tests

After test users are created:

```bash
cd /Users/giritharanchockalingam/Desktop/GitHub/hms-gcp-refactor

# Make sure dev server is running
npm run dev

# In another terminal, run automation tests
cd /Users/giritharanchockalingam/Desktop/GitHub/Testing
node manual-testing-automation.cjs 2>&1 | tee automation-test-results.log
```

**Expected Results:**
- All users should log in successfully
- RBAC violations should be detected (housekeeping denied access to restricted modules)
- Page detection should be more accurate with improved logic

---

## Step 3: Verify Access Control Manually

### Automated Verification

```bash
cd /Users/giritharanchockalingam/Desktop/GitHub/hms-gcp-refactor

# Make sure dev server is running
npm run dev

# Run verification script
node scripts/verify-rbac-access.cjs
```

### Manual Verification Checklist

Test each user and verify access:

#### 1. Housekeeping Staff (housekeeping@hmstest.com)

**Should be DENIED access to:**
- ✅ `/accounting` - Should show "You don't have permission" message
- ✅ `/revenue` - Should show "You don't have permission" message
- ✅ `/staff-hr` - Should show "You don't have permission" message
- ✅ `/check-in-out` - Should show "You don't have permission" message

**Should have ACCESS to:**
- ✅ `/housekeeping` - Should load successfully

#### 2. Front Desk Agent (frontdesk@hmstest.com)

**Should be DENIED access to:**
- ✅ `/accounting` - Should show "You don't have permission" message
- ✅ `/staff-hr` - Should show "You don't have permission" message

**Should have ACCESS to:**
- ✅ `/revenue` - Should load (read-only)
- ✅ `/check-in-out` - Should load successfully
- ✅ `/reservations` - Should load successfully

#### 3. Accountant (accountant@hmstest.com)

**Should have ACCESS to:**
- ✅ `/accounting` - Should load successfully
- ✅ `/revenue` - Should load (read-only)

**Should be DENIED access to:**
- ✅ `/staff-hr` - Should show "You don't have permission" message
- ✅ `/check-in-out` - Should show "You don't have permission" message

#### 4. Kitchen Staff (kitchen@hmstest.com)

**Should be DENIED access to:**
- ✅ `/accounting` - Should show "You don't have permission" message
- ✅ `/revenue` - Should show "You don't have permission" message
- ✅ `/staff-hr` - Should show "You don't have permission" message
- ✅ `/check-in-out` - Should show "You don't have permission" message

---

## Quick Test Commands

```bash
# 1. Create test users (if you have service role key)
export SUPABASE_URL="your_url"
export SUPABASE_SERVICE_ROLE_KEY="your_key"
node scripts/create-test-users.cjs

# 2. Run RBAC verification
node scripts/verify-rbac-access.cjs

# 3. Run full automation tests
cd /Users/giritharanchockalingam/Desktop/GitHub/Testing
node manual-testing-automation.cjs
```

---

## Troubleshooting

### Users can't log in
- Verify users exist in Supabase Auth
- Check email addresses match exactly
- Verify password is correct: `Test@1234567890`
- Check if email confirmation is required (disable in Supabase Auth settings)

### Roles not assigned
- Run `scripts/setup-test-users.sql` in Supabase SQL Editor
- Verify `user_roles` table exists
- Check that `app_role` enum includes all roles

### RBAC not working
- Verify RBAC fixes were applied (check `RBAC_FIXES_SUMMARY.md`)
- Check browser console for errors
- Verify user roles are correctly assigned in database

---

## Expected Test Results After Fixes

### Before Fixes:
- ❌ Housekeeping could access Accounting, Revenue, Staff & HR, Check-In/Out
- ❌ Front Desk could access Accounting, Staff & HR
- ❌ Kitchen Staff could access Revenue, Staff & HR

### After Fixes:
- ✅ Housekeeping DENIED: Accounting, Revenue, Staff & HR, Check-In/Out
- ✅ Front Desk DENIED: Accounting, Staff & HR
- ✅ Front Desk ALLOWED: Revenue (read-only), Check-In/Out
- ✅ Kitchen Staff DENIED: Accounting, Revenue, Staff & HR, Check-In/Out
- ✅ Accountant ALLOWED: Accounting, Revenue (read-only)

---

**Status:** Ready for execution once test users are created

