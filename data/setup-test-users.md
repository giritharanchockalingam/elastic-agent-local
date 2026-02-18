# Test User Setup Guide

This guide helps you set up test users for the Manual Testing Workbook.

## Prerequisites

- Access to Supabase project: `crumfjyjvofleoqfpwzm`
- Admin access to Supabase Authentication

## Step 1: Create Test Users in Supabase

1. Go to https://app.supabase.com
2. Select project: `crumfjyjvofleoqfpwzm`
3. Navigate to: **Authentication → Users**
4. Click **"Add user"** or **"Invite user"**
5. Create 9 test users with the following details:

| # | Email | Password | Role |
|---|-------|----------|------|
| 1 | superadmin@hmstest.com | Test@1234567890 | super_admin |
| 2 | propertyadmin@hmstest.com | Test@1234567890 | admin |
| 3 | manager@hmstest.com | Test@1234567890 | general_manager |
| 4 | frontdesk@hmstest.com | Test@1234567890 | front_desk_agent |
| 5 | housekeeping@hmstest.com | Test@1234567890 | housekeeping_staff |
| 6 | kitchen@hmstest.com | Test@1234567890 | kitchen_staff |
| 7 | accountant@hmstest.com | Test@1234567890 | accountant |
| 8 | hrmanager@hmstest.com | Test@1234567890 | hr_manager |
| 9 | guest@hmstest.com | Test@1234567890 | guest |

**Note:** When creating users, you can:
- Use "Add user" and set email/password manually
- Or use "Invite user" and they'll receive an email to set password

## Step 2: Assign Roles via SQL Editor

1. Go to: **SQL Editor** in Supabase
2. Open the file: `scripts/setup-test-users.sql`
3. Copy and paste the SQL script
4. Run the script section by section:
   - First run the SELECT to see user IDs
   - Then run the INSERT statements
   - Finally run the verification SELECT

## Step 3: Verify Setup

After running the SQL script, verify:

1. All 9 users exist in Authentication → Users
2. All 9 roles are assigned (check via the verification query)
3. Each user can log in with their email and password

## Step 4: Test Login

Test that each user can log in:

1. Go to http://localhost:8080/auth
2. Try logging in with each test user
3. Verify they are redirected to the correct dashboard
4. Verify their role-based access is working

## Troubleshooting

### Users not found
- Make sure users are created in Supabase Auth first
- Check email addresses match exactly (case-sensitive)

### Roles not assigned
- Verify the `user_roles` table exists
- Check that the `app_role` enum includes all roles
- Ensure user IDs match between auth.users and user_roles

### Login fails
- Verify password is correct: `Test@1234567890`
- Check if email confirmation is required
- Verify user is not disabled in Supabase Auth

## Next Steps

After setup is complete:
1. Run the manual testing automation script
2. Verify RBAC enforcement is working
3. Execute all test cases from the workbook

