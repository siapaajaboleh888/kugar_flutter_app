# 🧪 ADMIN PANEL TESTING GUIDE

## 📋 PRE-TESTING CHECKLIST

### Backend Ready?
- [ ] Laravel server running (`php artisan serve`)
- [ ] Database configured & migrated
- [ ] Admin user seeded (`php artisan db:seed --class=AdminUserSeeder`)
- [ ] Storage link created (`php artisan storage:link`)
- [ ] CORS configured for localhost/proxy

### Frontend Ready?
- [ ] Dependencies installed (`flutter pub get`)
- [ ] No compilation errors
- [ ] Proxy running (if testing on web: `node proxy.js`)
- [ ] Device/emulator connected

---

## 🎯 TESTING SCENARIOS

### 1. AUTHENTICATION TESTING

#### Test 1.1: Login with Valid Credentials
**Steps:**
1. Navigate to `/admin/login`
2. Enter email: `admin@kugar.com`
3. Enter password: `admin123`
4. Tap "Login"

**Expected:**
✅ Redirect to dashboard
✅ Token saved to SharedPreferences
✅ Admin data saved

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 1.2: Login with Invalid Credentials
**Steps:**
1. Navigate to `/admin/login`
2. Enter email: `wrong@email.com`
3. Enter password: `wrongpass`
4. Tap "Login"

**Expected:**
✅ Error message shown
✅ "Kredensial tidak valid" or similar
✅ Stay on login page

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 1.3: Login with Empty Fields
**Steps:**
1. Navigate to `/admin/login`
2. Leave fields empty
3. Tap "Login"

**Expected:**
✅ Validation errors shown
✅ "Email harus diisi"
✅ "Password harus diisi"

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 1.4: Logout
**Steps:**
1. Login successfully
2. Tap logout button (in AppBar or Drawer)
3. Confirm logout

**Expected:**
✅ Redirect to login page
✅ Token removed from storage
✅ Cannot access dashboard without login

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

### 2. DASHBOARD TESTING

#### Test 2.1: Dashboard Load
**Steps:**
1. Login as admin
2. Wait for dashboard to load

**Expected:**
✅ Loading indicator shown while fetching
✅ Statistics cards displayed
✅ Total Users shown
✅ Total Products shown
✅ Total Orders shown
✅ Revenue shown
✅ All numbers are correct

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 2.2: Order Status Breakdown
**Steps:**
1. View dashboard
2. Check order status section

**Expected:**
✅ Shows Pending count
✅ Shows Processing count
✅ Shows Completed count
✅ Shows Cancelled count
✅ All counts match database

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 2.3: Recent Users List
**Steps:**
1. View dashboard
2. Check recent users section

**Expected:**
✅ Shows 5 most recent users
✅ Shows user name
✅ Shows user email
✅ Shows creation time (e.g., "2h ago")
✅ Sorted by newest first

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 2.4: Recent Products List
**Steps:**
1. View dashboard
2. Check recent products section

**Expected:**
✅ Shows 5 most recent products
✅ Shows product name
✅ Shows formatted price
✅ Shows creation time
✅ Sorted by newest first

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 2.5: Dashboard Refresh
**Steps:**
1. View dashboard
2. Tap refresh button in AppBar
3. OR pull down to refresh

**Expected:**
✅ Data reloads
✅ Statistics updated
✅ Recent lists updated
✅ No errors

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 2.6: Dashboard Navigation
**Steps:**
1. View dashboard
2. Tap drawer menu icon
3. Verify all menu items

**Expected:**
✅ Dashboard (active)
✅ Manage Users
✅ Manage Products
✅ Manage Orders
✅ Customer Chats
✅ Logout

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

### 3. USER MANAGEMENT TESTING

#### Test 3.1: Load Users List
**Steps:**
1. Navigate to Users page
2. Wait for list to load

**Expected:**
✅ Loading indicator while fetching
✅ Users list displayed in cards
✅ Each card shows: name, email, role
✅ Role chips color-coded
✅ Pagination controls if > 15 users
✅ Total count shown in AppBar

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 3.2: Search Users
**Steps:**
1. Go to Users page
2. Type in search box: "john"
3. Press Enter or tap search

**Expected:**
✅ List filtered to matching users
✅ Shows users with "john" in name/email
✅ Page reset to 1
✅ Total count updated

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 3.3: Clear Search
**Steps:**
1. Search for something
2. Tap clear button (X) in search field

**Expected:**
✅ Search cleared
✅ All users shown again
✅ Page reset to 1

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 3.4: Filter by Role - User
**Steps:**
1. Go to Users page
2. Tap "User" filter chip

**Expected:**
✅ List filtered to users only
✅ Chip highlighted/selected
✅ Page reset to 1

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 3.5: Filter by Role - Admin
**Steps:**
1. Go to Users page
2. Tap "Admin" filter chip

**Expected:**
✅ List filtered to admins only
✅ Chip highlighted
✅ Should show at least 1 user (you)

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 3.6: Add New User - Valid Data
**Steps:**
1. Tap FloatingActionButton (+)
2. Fill form:
   - Name: "Test User"
   - Email: "test@example.com"
   - Phone: "08123456789"
   - Password: "password123"
   - Role: "User"
3. Tap "Tambah"

**Expected:**
✅ User created successfully
✅ Success SnackBar shown
✅ Dialog closed
✅ List refreshed
✅ New user appears in list

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 3.7: Add New User - Invalid Email
**Steps:**
1. Tap FloatingActionButton (+)
2. Fill form with invalid email: "notanemail"
3. Try to submit

**Expected:**
✅ Validation error shown
✅ "Email tidak valid"
✅ Cannot submit

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 3.8: Add New User - Empty Password
**Steps:**
1. Tap FloatingActionButton (+)
2. Fill all fields except password
3. Try to submit

**Expected:**
✅ Validation error shown
✅ "Password harus diisi"
✅ Cannot submit

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 3.9: Edit User
**Steps:**
1. Tap on a user card
2. Edit dialog opens
3. Change name to "Updated Name"
4. Leave password empty
5. Tap "Update"

**Expected:**
✅ User updated successfully
✅ Success SnackBar shown
✅ Dialog closed
✅ List refreshed
✅ Updated name shown
✅ Password not changed (because empty)

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 3.10: Edit User with New Password
**Steps:**
1. Tap on a user card
2. Enter new password: "newpass123"
3. Tap "Update"

**Expected:**
✅ User updated with new password
✅ Success message shown
✅ Can login with new password

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 3.11: Delete User
**Steps:**
1. Long press on a user card
2. Confirmation dialog appears
3. Tap "Hapus"

**Expected:**
✅ Confirmation dialog shown
✅ User deleted from database
✅ Success SnackBar shown
✅ User removed from list
✅ Total count decreased

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 3.12: Delete User - Cancel
**Steps:**
1. Long press on a user card
2. Confirmation dialog appears
3. Tap "Batal"

**Expected:**
✅ Dialog closed
✅ User NOT deleted
✅ User still in list

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 3.13: User Pagination - Next Page
**Steps:**
1. If > 15 users, pagination shown
2. Tap "Next" button

**Expected:**
✅ Load next page
✅ Page number increased
✅ Different users shown
✅ Previous button enabled

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 3.14: User Pagination - Previous Page
**Steps:**
1. Go to page 2+
2. Tap "Previous" button

**Expected:**
✅ Load previous page
✅ Page number decreased
✅ Correct users shown

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 3.15: Pull to Refresh Users
**Steps:**
1. On Users page
2. Pull down from top
3. Release

**Expected:**
✅ Refresh indicator shown
✅ List reloaded
✅ Updated data shown

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

### 4. PRODUCT MANAGEMENT TESTING

#### Test 4.1: Load Products List
**Steps:**
1. Navigate to Products page
2. Wait for list to load

**Expected:**
✅ Loading indicator shown
✅ Products displayed in cards
✅ Each card shows:
  - Product image (or placeholder)
  - Product title
  - Description (max 2 lines)
  - Formatted price
  - Location (if available)
  - Action menu
✅ Total count in AppBar

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 4.2: Search Products
**Steps:**
1. Go to Products page
2. Type in search: "garam"
3. Press Enter

**Expected:**
✅ List filtered to matching products
✅ Shows products with "garam" in title/text
✅ Page reset to 1

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 4.3: Add New Product - Complete Data
**Steps:**
1. Tap FloatingActionButton (+)
2. Tap image area, pick image from gallery
3. Fill form:
   - Nama: "Garam Premium"
   - Deskripsi: "Garam berkualitas tinggi"
   - Harga: "15000"
   - Alamat: "Sumenep"
   - No HP: "08123456789"
4. Tap "Tambah"

**Expected:**
✅ Product created successfully
✅ Image uploaded
✅ Success message shown
✅ Dialog closed
✅ List refreshed
✅ New product appears with image

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 4.4: Add Product - No Image
**Steps:**
1. Tap FloatingActionButton (+)
2. Don't select image
3. Fill other required fields
4. Tap "Tambah"

**Expected:**
✅ Product created successfully
✅ No image uploaded (that's OK)
✅ Placeholder image shown in list

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 4.5: Add Product - Missing Required Fields
**Steps:**
1. Tap FloatingActionButton (+)
2. Leave Nama empty
3. Try to submit

**Expected:**
✅ Validation error shown
✅ "Nama produk harus diisi"
✅ Cannot submit

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 4.6: Add Product - Invalid Price
**Steps:**
1. Tap FloatingActionButton (+)
2. Enter price: "abc123"
3. Try to submit

**Expected:**
✅ Validation error shown
✅ "Harga harus berupa angka"
✅ Cannot submit

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 4.7: Image Picker - Gallery
**Steps:**
1. Tap FloatingActionButton (+)
2. Tap image area
3. Gallery picker opens
4. Select an image

**Expected:**
✅ Image picker opens
✅ Can select image
✅ Image preview shown in dialog
✅ Image compressed (max 1024x1024)

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 4.8: Edit Product
**Steps:**
1. Tap on a product card
2. Update Nama to "Updated Product"
3. Don't change image
4. Tap "Update"

**Expected:**
✅ Product updated
✅ Success message
✅ List refreshed
✅ Updated name shown
✅ Image unchanged

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 4.9: Edit Product with New Image
**Steps:**
1. Tap on a product card
2. Tap image area
3. Select new image
4. Tap "Update"

**Expected:**
✅ Product updated
✅ New image uploaded
✅ Old image replaced
✅ New image shown in list

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 4.10: Delete Product
**Steps:**
1. Tap menu (⋮) on product card
2. Select "Hapus"
3. Confirm deletion

**Expected:**
✅ Confirmation dialog shown
✅ Product deleted from database
✅ Image deleted from storage
✅ Success message shown
✅ Product removed from list

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 4.11: Product Price Formatting
**Steps:**
1. View products list
2. Check prices displayed

**Expected:**
✅ Prices formatted as "Rp x.xxx"
✅ Example: "Rp 15.000" (not "15000")
✅ Thousands separator is dot

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 4.12: Product Image Loading
**Steps:**
1. View products with images
2. Observe image loading

**Expected:**
✅ Loading indicator while loading
✅ Cached images load faster
✅ Placeholder for missing images
✅ Error icon for failed images

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 4.13: Product Pagination
**Steps:**
1. If > 15 products, test pagination
2. Tap "Next"
3. Tap "Previous"

**Expected:**
✅ Navigation works correctly
✅ Page indicator updates
✅ Correct products shown

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

### 5. ERROR HANDLING TESTING

#### Test 5.1: Network Error
**Steps:**
1. Stop backend server
2. Try to load dashboard/users/products
3. Observe error handling

**Expected:**
✅ Error message shown
✅ "Coba Lagi" button appears
✅ User-friendly error message
✅ No crash

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 5.2: Token Expiry (401)
**Steps:**
1. Manually delete token from SharedPreferences
2. Try to access protected page

**Expected:**
✅ Auto logout
✅ Redirect to login
✅ Error message shown

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 5.3: Server Error (500)
**Steps:**
1. Cause server error (e.g., break backend code)
2. Try to perform action

**Expected:**
✅ Error message shown
✅ "Server error: 500" or similar
✅ No crash
✅ Can retry

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

### 6. UI/UX TESTING

#### Test 6.1: Loading States
**Steps:**
1. Perform various actions
2. Observe loading indicators

**Expected:**
✅ CircularProgressIndicator shown while loading
✅ Buttons disabled while processing
✅ Clear visual feedback

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 6.2: Empty States
**Steps:**
1. Create empty database
2. View users/products pages

**Expected:**
✅ "Tidak ada users/products" message shown
✅ Not blank screen
✅ Can still add new items

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 6.3: Responsive Layout
**Steps:**
1. Test on different screen sizes
2. Rotate device

**Expected:**
✅ Layout adapts to screen size
✅ No overflow errors
✅ Readable on all sizes

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

#### Test 6.4: Navigation
**Steps:**
1. Test all navigation paths
2. Use back button
3. Use drawer menu

**Expected:**
✅ All routes work
✅ Back button works correctly
✅ Drawer navigation works
✅ No navigation stack issues

**Actual:**
- [ ] Pass
- [ ] Fail (note issue: _________________)

---

## 📊 TEST SUMMARY

### Total Tests: 60+
- Authentication: 4 tests
- Dashboard: 6 tests
- Users: 15 tests
- Products: 13 tests
- Error Handling: 3 tests
- UI/UX: 4 tests

### Pass Rate
- Total Passed: _____ / 60
- Total Failed: _____ / 60
- Pass Rate: _____%

### Critical Issues Found
1. _________________________________
2. _________________________________
3. _________________________________

### Minor Issues Found
1. _________________________________
2. _________________________________
3. _________________________________

---

## ✅ SIGN-OFF

**Tested By:** _________________  
**Date:** _________________  
**Device/Emulator:** _________________  
**Flutter Version:** _________________  

**Overall Status:**
- [ ] Ready for Production
- [ ] Needs Bug Fixes
- [ ] Needs Major Improvements

**Notes:**
_________________________________
_________________________________
_________________________________

---

**Created:** 4 Desember 2025  
**Version:** 1.0
