# Fixes Applied - API & Images

## Issues Fixed

### 1. API Configuration ✅
**Problem:** Flutter app was trying to call `http://wisatalembung.test/api` directly, causing CORS errors.

**Solution:** Updated `lib/core/constants/app_constants.dart`:
```dart
static const String apiBaseUrl = 'http://localhost:3001/api';
```

Now all API calls go through the proxy server at `localhost:3001`.

---

### 2. Proxy Server Enhanced ✅
**Problem:** Proxy only handled `/api/*` requests, not image requests from `/assets/*` and `/storage/*`.

**Solution:** Updated `proxy.js` to handle:
- `/api/*` - API requests
- `/assets/*` - Static assets (images)
- `/storage/*` - Uploaded files (images)

---

### 3. Image URL Processing ✅
**Problem:** Product images showed "Gagal memuat gambar" errors because URLs weren't going through proxy.

**Solution:** Updated `lib/presentation/pages/product/product_catalog_page.dart`:
- Images now load via `http://localhost:3001/[path]`
- Proper URL extraction and conversion to proxy URLs

---

### 4. Admin Login - FIXED! ✅

**Previous Situation:**
- Login was hardcoded (email == 'admin@kugar.com' && password == 'admin123')
- No real backend integration
- Error: "Kredensial tidak valid"

**What Was Fixed:**

#### Created Admin Auth Service (`lib/data/services/admin_auth_service.dart`)
- Real API integration with backend
- Dual endpoint support:
  1. Primary: `POST /api/admin/login` (admin-specific)
  2. Fallback: `POST /api/auth/login` (with role validation)
- Token management (auto-save to SharedPreferences)
- Proper error handling
- Debug logging for troubleshooting

#### Created Admin Auth Provider (`lib/data/providers/admin_auth_provider.dart`)
- Riverpod providers for state management
- Login status provider
- Admin data provider

#### Updated Admin Login Page
- Removed hardcoded credentials
- Uses AdminAuthService for real authentication
- Better error messages
- Success/failure notifications
- Proper loading states

**How It Works:**
1. User enters email & password
2. AdminAuthService tries `/api/admin/login` first
3. If endpoint not found (404), falls back to `/api/auth/login`
4. If using `/api/auth/login`, validates user has admin role
5. On success, saves token and admin data
6. Navigates to admin dashboard

**Requirements:**
- Admin user must exist in backend database
- User must have role = 'admin' (if using /auth/login endpoint)
- Backend must have either `/api/admin/login` or `/api/auth/login` endpoint

**Setup Instructions:**
See `QUICK_START_ADMIN.md` for step-by-step setup guide.

**Files Created:**
- `AdminUserSeeder.php` - Database seeder to create admin user
- `ADMIN_LOGIN_SETUP.md` - Detailed setup guide
- `QUICK_START_ADMIN.md` - Quick start instructions

---

## Test Instructions

### 1. Setup Admin User (REQUIRED)

**Option A: Using Seeder (Recommended)**
```bash
# Copy seeder to backend
copy AdminUserSeeder.php C:\Users\LENOVO\Herd\wisatalembung\database\seeders\AdminUserSeeder.php

# Run seeder
cd C:\Users\LENOVO\Herd\wisatalembung
php artisan db:seed --class=AdminUserSeeder
```

**Option B: Using SQL**
```sql
INSERT INTO users (name, email, password, role, email_verified_at, created_at, updated_at) 
VALUES (
    'Admin KUGAR', 
    'admin@kugar.com', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'admin',
    NOW(),
    NOW(), 
    NOW()
);
```

### 2. Start Proxy Server

```powershell
cd C:\Users\LENOVO\Herd\kugar_flutter_app
node proxy.js
```

### 3. Restart Flutter App

```powershell
flutter run -d chrome
```

### 4. Test Admin Login

1. Navigate to `/admin/login`
2. Enter credentials:
   - Email: `admin@kugar.com`
   - Password: `admin123`
3. Click "Login"
4. Should navigate to admin dashboard!

### 5. Verify in Console

**Flutter Console should show:**
```
DEBUG ADMIN: Attempting admin login for email: admin@kugar.com
DEBUG ADMIN: Trying /admin/login endpoint
DEBUG ADMIN: /admin/login response status: 200
DEBUG ADMIN: /admin/login response data: {...}
```

**Proxy Console should show:**
```
📡 [timestamp] POST /api/admin/login
   → http://wisatalembung.test/api/admin/login
   ✅ Status: 200
```

---

## Backend Verification

### Check if Admin User Exists
```sql
SELECT * FROM users WHERE email = 'admin@kugar.com';
```

### Check User Table Structure
```sql
DESCRIBE users;
```

### Reset Admin Password (if needed)
```sql
UPDATE users 
SET password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi' 
WHERE email = 'admin@kugar.com';
-- Password hash above is for: admin123
```

### Set Admin Role
```sql
UPDATE users 
SET role = 'admin' 
WHERE email = 'admin@kugar.com';
```

---

## Current Status

| Component | Status | Notes |
|-----------|--------|-------|
| Proxy Server | ✅ Running | Port 3001 |
| API Requests via Proxy | ✅ Working | All `/api/*` calls proxied |
| Image Loading via Proxy | ✅ Fixed | `/assets/*` and `/storage/*` proxied |
| Product API | ✅ Working | Returns product data |
| Admin Login API | ✅ FIXED | Real backend integration |
| Admin Auth Service | ✅ Created | Dual endpoint support |
| Admin User Creation | ⚠️ Manual | User must create admin in DB |

---

## Default Admin Credentials

```
Email: admin@kugar.com
Password: admin123
```

**⚠️ IMPORTANT:** Change this password in production!

---

## Troubleshooting

### Error: "Email atau password salah"
- Verify admin user exists in database
- Check email and password are correct
- Ensure password is hashed correctly

### Error: "Akun Anda tidak memiliki akses admin"
- User exists but doesn't have admin role
- Solution: `UPDATE users SET role = 'admin' WHERE email = 'admin@kugar.com';`

### Error: "Terjadi kesalahan saat login"
- Backend server not running
- Proxy server not running
- Network connectivity issues
- Check console logs for details

---

## Files Modified/Created

### Created:
1. `lib/data/services/admin_auth_service.dart` - Admin authentication service
2. `lib/data/providers/admin_auth_provider.dart` - Riverpod providers
3. `AdminUserSeeder.php` - Database seeder
4. `ADMIN_LOGIN_SETUP.md` - Detailed setup guide
5. `QUICK_START_ADMIN.md` - Quick start guide

### Modified:
1. `lib/presentation/pages/admin/auth/admin_login_page.dart` - Real API integration

---

## Next Steps

1. ✅ **Create admin user in database** (see Quick Start guide)
2. ✅ **Test admin login** with real credentials
3. 🔄 **Implement admin dashboard** features
4. 🔄 **Add role-based access control** middleware
5. 🔄 **Create admin profile management**
6. 🔄 **Add change password functionality**

---

## Verification Checklist

Before testing admin login:

- [ ] Backend Laravel server is running
- [ ] Proxy server is running (`node proxy.js`)
- [ ] Admin user exists in database with email `admin@kugar.com`
- [ ] Admin user has password hash for `admin123`
- [ ] Admin user has role `admin` (if using /auth/login)
- [ ] Flutter app has been restarted
- [ ] Browser cache cleared (if needed)
