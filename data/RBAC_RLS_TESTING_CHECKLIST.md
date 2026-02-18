# RBAC & RLS Testing Checklist

## ✅ Verification Complete

The following verification checks have passed:
- ✓ All tables have RLS enabled
- ✓ All tables have policies
- ✓ `user_has_property_access` function exists

## 🧪 Manual Testing Checklist

### 1. Test Guest Access (Staff User)

**As a staff user (e.g., `front_desk_agent`, `staff`, `cook`):**

- [ ] Can view the Guests page
- [ ] Can see list of guests
- [ ] Can click "View Profile" button
- [ ] Can click "New Booking" button
- [ ] Can click "Edit" button (should be visible)
- [ ] **Cannot see "Delete" button** (should be hidden, not showing error)
- [ ] Can create new guest
- [ ] Can update existing guest

**Expected Result:** Staff should see guests and be able to manage them, but delete buttons should be hidden.

---

### 2. Test Guest Access (Admin User)

**As an admin user (e.g., `admin`, `super_admin`, `general_manager`):**

- [ ] Can view the Guests page
- [ ] Can see list of guests
- [ ] Can see all action buttons (View, Edit, Delete)
- [ ] Can create new guest
- [ ] Can update existing guest
- [ ] Can delete guest (should work)

**Expected Result:** Admins should see all buttons including delete.

---

### 3. Test Property Isolation

**Test that users only see data for their assigned properties:**

- [ ] As User A (assigned to Property 1):
  - [ ] Can see reservations for Property 1
  - [ ] Cannot see reservations for Property 2
  - [ ] Can see rooms for Property 1
  - [ ] Cannot see rooms for Property 2
  - [ ] Can see payments for Property 1 (via reservations)
  - [ ] Cannot see payments for Property 2

- [ ] As Super Admin:
  - [ ] Can see data from all properties

---

### 4. Test Lost & Found

**As a staff user with property access:**

- [ ] Can view Lost & Found page (should not be empty)
- [ ] Can see items for assigned properties
- [ ] Can add new lost & found items
- [ ] Can update existing items
- [ ] Cannot see items from other properties

**Expected Result:** Lost & Found should show items based on property access.

---

### 5. Test Reservations Access

**As different role types:**

- [ ] Front Desk Staff: Can view/create/update reservations for their property
- [ ] Housekeeping Staff: Can view reservations (needed for room assignments)
- [ ] Finance Staff: Can view reservations (for payment processing)
- [ ] Only Admins: Can delete reservations

---

### 6. Test Rooms Access

**As different role types:**

- [ ] Staff: Can view rooms for their property
- [ ] Housekeeping: Can update room status
- [ ] Maintenance: Can update room status
- [ ] Only Admins/Managers: Can create/delete rooms

---

### 7. Test Payments Access

**As finance staff:**

- [ ] Can view payments for reservations in their property
- [ ] Can create payments
- [ ] Can update payments
- [ ] Only Finance Managers/Admins: Can delete payments

---

### 8. UI/UX Verification

**Check that UI elements are properly hidden (not showing errors):**

- [ ] Delete buttons are hidden (not showing red error alerts) for non-admin users
- [ ] No permission error messages visible on pages
- [ ] Action buttons only appear when user has permission
- [ ] Page-level access is properly blocked with clear messages

---

## 🐛 Common Issues & Solutions

### Issue: "Lost & Found is empty"

**Solution:**
1. Verify user has property assignment: `SELECT * FROM user_property_assignments WHERE user_id = 'YOUR_USER_ID';`
2. Verify items exist: `SELECT * FROM lost_found_items;`
3. Check RLS policies are applied: Run verification script again

### Issue: "Cannot see guests"

**Solution:**
1. Verify user has appropriate role: `SELECT * FROM user_roles WHERE user_id = 'YOUR_USER_ID';`
2. Verify roles include: `front_desk_agent`, `staff`, `admin`, etc.
3. Check RLS policies: Run verification script

### Issue: "Delete button showing error message"

**Solution:**
- This should be fixed with the RBACGuard update
- Verify `hideOnDeny={true}` is set on delete button guards
- Clear browser cache and hard refresh

### Issue: "Can see data from other properties"

**Solution:**
1. Verify `user_has_property_access()` function exists
2. Verify RLS policies use property access checks
3. Verify user property assignments are correct

---

## 📊 SQL Verification Queries

### Check User Roles
```sql
SELECT ur.role, p.full_name, p.email
FROM user_roles ur
JOIN profiles p ON p.id = ur.user_id
WHERE ur.user_id = 'YOUR_USER_ID';
```

### Check Property Assignments
```sql
SELECT upa.*, prop.name as property_name
FROM user_property_assignments upa
JOIN properties prop ON prop.id = upa.property_id
WHERE upa.user_id = 'YOUR_USER_ID';
```

### Test Property Access Function
```sql
-- Test if user has access to a property
SELECT public.user_has_property_access(
  'PROPERTY_ID_HERE'::uuid,
  'USER_ID_HERE'::uuid
) as has_access;
```

### Check What Data User Can See
```sql
-- As the current user, what reservations can they see?
SELECT r.*, prop.name as property_name
FROM reservations r
JOIN properties prop ON prop.id = r.property_id
LIMIT 10;

-- As the current user, what guests can they see?
SELECT COUNT(*) as guest_count FROM guests;

-- As the current user, what lost & found items can they see?
SELECT lf.*, prop.name as property_name
FROM lost_found_items lf
JOIN properties prop ON prop.id = lf.property_id
LIMIT 10;
```

---

## ✅ Success Criteria

All tests should pass:
- ✓ Property-level data isolation works
- ✓ Role-based access control works
- ✓ UI elements are hidden (not showing errors)
- ✓ Staff can view/manage within their scope
- ✓ Admins have full access
- ✓ No unauthorized data access
- ✓ Lost & Found shows items correctly

---

## 📝 Notes

- **Property Isolation**: All tables with `property_id` should check `user_has_property_access()`
- **Guest Access**: Guests don't have `property_id` directly, so we use role-based access
- **Super Admins**: Automatically have access to all properties via `user_has_property_access()`
- **UI Elements**: Use `hideOnDeny={true}` for buttons/icons, default behavior for pages

