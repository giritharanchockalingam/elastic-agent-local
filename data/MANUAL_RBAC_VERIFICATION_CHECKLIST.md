# Manual RBAC Verification Checklist

Use this checklist to manually verify that RBAC fixes are working correctly.

**Prerequisites:**
- Dev server running: `npm run dev`
- Test users created in Supabase
- Browser ready for testing

---

## Test User Credentials

All users use password: `Test@1234567890`

| Email | Role |
|-------|------|
| superadmin@hmstest.com | super_admin |
| propertyadmin@hmstest.com | admin |
| manager@hmstest.com | general_manager |
| frontdesk@hmstest.com | front_desk_agent |
| housekeeping@hmstest.com | housekeeping_staff |
| kitchen@hmstest.com | kitchen_staff |
| accountant@hmstest.com | accountant |
| hrmanager@hmstest.com | hr_manager |
| guest@hmstest.com | guest |

---

## Verification Tests

### Test 1: Housekeeping Staff Access Control

**Login:** housekeeping@hmstest.com / Test@1234567890

| Module | URL | Expected | Actual | Status | Notes |
|--------|-----|----------|--------|--------|-------|
| Accounting | /accounting | ❌ DENIED | | ⬜ | Should show "You don't have permission" |
| Revenue | /revenue | ❌ DENIED | | ⬜ | Should show "You don't have permission" |
| Staff & HR | /staff-hr | ❌ DENIED | | ⬜ | Should show "You don't have permission" |
| Check-In/Out | /check-in-out | ❌ DENIED | | ⬜ | Should show "You don't have permission" |
| Housekeeping | /housekeeping | ✅ ACCESS | | ⬜ | Should load successfully |

**Expected Result:** ⬜ PASS / ⬜ FAIL

---

### Test 2: Front Desk Agent Access Control

**Login:** frontdesk@hmstest.com / Test@1234567890

| Module | URL | Expected | Actual | Status | Notes |
|--------|-----|----------|--------|--------|-------|
| Accounting | /accounting | ❌ DENIED | | ⬜ | Should show "You don't have permission" |
| Staff & HR | /staff-hr | ❌ DENIED | | ⬜ | Should show "You don't have permission" |
| Revenue | /revenue | ✅ ACCESS (read-only) | | ⬜ | Should load, but read-only |
| Check-In/Out | /check-in-out | ✅ ACCESS | | ⬜ | Should load successfully |
| Reservations | /reservations | ✅ ACCESS | | ⬜ | Should load successfully |

**Expected Result:** ⬜ PASS / ⬜ FAIL

---

### Test 3: Accountant Access Control

**Login:** accountant@hmstest.com / Test@1234567890

| Module | URL | Expected | Actual | Status | Notes |
|--------|-----|----------|--------|--------|-------|
| Accounting | /accounting | ✅ ACCESS | | ⬜ | Should load successfully |
| Revenue | /revenue | ✅ ACCESS (read-only) | | ⬜ | Should load, but read-only |
| Staff & HR | /staff-hr | ❌ DENIED | | ⬜ | Should show "You don't have permission" |
| Check-In/Out | /check-in-out | ❌ DENIED | | ⬜ | Should show "You don't have permission" |

**Expected Result:** ⬜ PASS / ⬜ FAIL

---

### Test 4: Kitchen Staff Access Control

**Login:** kitchen@hmstest.com / Test@1234567890

| Module | URL | Expected | Actual | Status | Notes |
|--------|-----|----------|--------|--------|-------|
| Accounting | /accounting | ❌ DENIED | | ⬜ | Should show "You don't have permission" |
| Revenue | /revenue | ❌ DENIED | | ⬜ | Should show "You don't have permission" |
| Staff & HR | /staff-hr | ❌ DENIED | | ⬜ | Should show "You don't have permission" |
| Check-In/Out | /check-in-out | ❌ DENIED | | ⬜ | Should show "You don't have permission" |

**Expected Result:** ⬜ PASS / ⬜ FAIL

---

### Test 5: Super Admin Access Control

**Login:** superadmin@hmstest.com / Test@1234567890

| Module | URL | Expected | Actual | Status | Notes |
|--------|-----|----------|--------|--------|-------|
| Accounting | /accounting | ✅ ACCESS | | ⬜ | Should load successfully |
| Revenue | /revenue | ✅ ACCESS | | ⬜ | Should load successfully |
| Staff & HR | /staff-hr | ✅ ACCESS | | ⬜ | Should load successfully |
| Check-In/Out | /check-in-out | ✅ ACCESS | | ⬜ | Should load successfully |
| All Modules | All | ✅ ACCESS | | ⬜ | Should have full access |

**Expected Result:** ⬜ PASS / ⬜ FAIL

---

## RBAC Denial Message Verification

When access is denied, you should see:

1. **Visual Indicator:**
   - Red/destructive alert box
   - Lock icon (🔒)
   - Error message text

2. **Message Text:**
   - "You don't have permission to access this resource"
   - "Required roles: [role names]"

3. **Page Behavior:**
   - Page does NOT show module content
   - Only shows denial message
   - User cannot interact with module features

---

## Screenshot Documentation

Take screenshots of:
- ✅ Successful access (page loads with content)
- ❌ Denied access (RBAC denial message visible)
- ⚠️ Unexpected behavior (access when should be denied, or vice versa)

Save screenshots in: `manual-verification-screenshots/`

---

## Results Summary

**Total Tests:** _____  
**Passed:** _____  
**Failed:** _____  
**Pass Rate:** _____%

**Critical Issues Found:**
- [ ] List any RBAC violations found

**Overall Assessment:** ⬜ PASS / ⬜ FAIL

---

**Tester:** _______________  
**Date:** _______________  
**Time Taken:** _______________

