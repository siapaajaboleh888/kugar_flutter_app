# 🚀 PROMPT UNTUK BACKEND SETUP - COPY THIS!

Buka AI assistant Anda di folder backend Laravel, lalu copy-paste prompt ini:

---

## PROMPT START ↓↓↓

```
Saya perlu setup backend API untuk admin panel Flutter app yang sudah jadi. 

CONTEXT:
- Project: E-commerce Laravel Backend (wisatalembung)
- Database: MySQL (sudah ada via TablePlus)
- Table users: sudah ada dengan admin user (email: admin@kugar.com, password: admin123, role: admin)
- Table produk: sudah ada
- Framework: Laravel dengan Sanctum untuk API authentication
- Frontend: Flutter app yang sudah ready di folder berbeda

REQUIREMENT:
Saya butuh create dan configure backend API endpoints untuk:

1. **Admin Authentication**
   - POST /api/admin/login (login admin dengan email & password)
   - POST /api/admin/logout (logout admin)
   - Return JWT token dengan Sanctum

2. **User Management API** (CRUD)
   - GET /api/admin/users (list users dengan pagination, search, filter by role)
   - GET /api/admin/users/{id} (detail user)
   - POST /api/admin/users (create user baru)
   - PUT /api/admin/users/{id} (update user)
   - DELETE /api/admin/users/{id} (delete user)

3. **Product Management API** (CRUD)
   - GET /api/admin/produk (list produk dengan pagination, search, filter by kategori)
   - GET /api/admin/produk/{id} (detail produk)
   - POST /api/admin/produk (create produk baru)
   - PUT /api/admin/produk/{id} (update produk)
   - DELETE /api/admin/produk/{id} (delete produk)

4. **Dashboard Statistics**
   - GET /api/admin/dashboard/stats (return total users, products, orders, revenue)

5. **Admin Middleware**
   - Protect admin routes dengan middleware yang cek:
     - User authenticated (via Sanctum)
     - User role = 'admin'

RESPONSE FORMAT yang diharapkan Flutter:
```json
{
  "success": true,
  "message": "Success message",
  "data": {...}
}
```

Untuk pagination:
```json
{
  "success": true,
  "data": [...],
  "current_page": 1,
  "last_page": 5,
  "total": 45,
  "per_page": 10
}
```

DATABASE STRUCTURE:
- Table: users
  - Columns: id, name, email, password (hashed), role (user/admin), phone, email_verified_at, created_at, updated_at
  
- Table: produk
  - Columns: id, nama, deskripsi, kategori, harga, stok, berat, gambar, created_at, updated_at

TASKS:
1. Generate complete controller code untuk:
   - AdminAuthController (login, logout)
   - UserController (CRUD users)
   - ProductController (CRUD produk)
   - DashboardController (stats)

2. Generate routes di routes/api.php dengan:
   - Prefix /admin
   - Protected dengan sanctum + admin middleware
   - Public route hanya /admin/login

3. Generate AdminMiddleware yang check user role = 'admin'

4. Configure Sanctum jika belum (composer, config, migrate)

5. Configure CORS untuk allow:
   - http://localhost:3001 (proxy server)
   - http://localhost:3000
   - http://localhost:*

6. Testing commands untuk verify semua endpoint

Tolong generate semua file yang diperlukan dengan complete working code!
```

## PROMPT END ↑↑↑

---

## 📝 Cara Menggunakan:

1. **Buka terminal/folder backend:**
   ```bash
   cd C:\Users\LENOVO\Herd\wisatalembung
   ```

2. **Buka AI assistant** (bisa Cline, Cursor, atau AI assistant lain)

3. **Copy-paste** prompt di atas

4. **AI akan generate:**
   - Controllers lengkap
   - Routes configuration
   - Middleware
   - Config files
   - Testing commands

5. **Follow instructions** yang diberikan AI

6. **Test endpoints** dengan curl atau Postman

7. **Refresh Flutter app** - data real akan muncul!

---

## 🎯 Expected Result:

Setelah setup selesai, Anda akan punya:

✅ `app/Http/Controllers/Admin/AdminAuthController.php`
✅ `app/Http/Controllers/Admin/UserController.php`
✅ `app/Http/Controllers/Admin/ProductController.php`
✅ `app/Http/Controllers/Admin/DashboardController.php`
✅ `app/Http/Middleware/AdminMiddleware.php`
✅ `routes/api.php` (updated)
✅ `config/sanctum.php` (configured)
✅ `config/cors.php` (configured)

---

## ⚡ Quick Alternative (Manual):

Jika tidak pakai AI, buka:
- **`BACKEND_API_GUIDE.md`** di folder Flutter
- Copy semua code ke Laravel files manual
- Estimated time: 30 menit

---

## 📞 Support:

Jika ada error setelah setup:
1. Check Laravel logs: `storage/logs/laravel.log`
2. Test dengan curl
3. Check proxy server logs
4. Verify database connection

---

**Status:** Prompt ready to use! 🚀
**Folder target:** `C:\Users\LENOVO\Herd\wisatalembung`
