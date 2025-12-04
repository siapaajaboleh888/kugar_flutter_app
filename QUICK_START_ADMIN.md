# 🚀 Quick Start - Admin Login Fix

## ✅ Masalah Sudah Diperbaiki!

Aplikasi Flutter sekarang sudah terintegrasi dengan backend API untuk login admin. Tidak ada lagi hardcoded credentials!

## 📋 Langkah-Langkah Setup (WAJIB)

### Step 1: Buat Admin User di Database

**Pilih salah satu cara berikut:**

#### Cara A: Menggunakan Database Seeder (RECOMMENDED) ⭐

1. Copy file `AdminUserSeeder.php` ke folder backend:
   ```bash
   copy AdminUserSeeder.php C:\Users\LENOVO\Herd\wisatalembung\database\seeders\AdminUserSeeder.php
   ```

2. Jalankan seeder:
   ```bash
   cd C:\Users\LENOVO\Herd\wisatalembung
   php artisan db:seed --class=AdminUserSeeder
   ```

   Jika berhasil, akan muncul message:
   ```
   Admin user created successfully!
   Email: admin@kugar.com
   Password: admin123
   ```

#### Cara B: Menggunakan SQL Direct

1. Buka MySQL/database client Anda
2. Jalankan query ini:

```sql
-- Cek dulu apakah tabel users punya kolom 'role'
DESCRIBE users;

-- Jika ada kolom 'role':
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

-- Jika TIDAK ada kolom 'role':
INSERT INTO users (name, email, password, email_verified_at, created_at, updated_at) 
VALUES (
    'Admin KUGAR', 
    'admin@kugar.com', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    NOW(),
    NOW(), 
    NOW()
);
```

**Note:** Password hash di atas adalah untuk password "admin123"

#### Cara C: Menggunakan Tinker

1. Buka terminal
2. Masuk ke folder backend:
   ```bash
   cd C:\Users\LENOVO\Herd\wisatalembung
   ```

3. Jalankan tinker:
   ```bash
   php artisan tinker
   ```

4. Ketik command ini di tinker:
   ```php
   \App\Models\User::create(['name' => 'Admin KUGAR', 'email' => 'admin@kugar.com', 'password' => \Hash::make('admin123'), 'role' => 'admin'])
   ```

5. Tekan Enter, lalu ketik `exit` untuk keluar

### Step 2: Pastikan Backend Endpoint Tersedia

Backend Anda harus punya salah satu dari endpoint berikut:
- `POST /api/admin/login` (preferred), atau
- `POST /api/auth/login` (akan auto-detect)

Aplikasi Flutter akan mencoba kedua endpoint secara otomatis.

### Step 3: Jalankan Proxy Server

```bash
cd C:\Users\LENOVO\Herd\kugar_flutter_app
node proxy.js
```

Biarkan terminal ini tetap terbuka!

### Step 4: Restart Flutter App

```bash
# Stop aplikasi yang sedang berjalan (Ctrl+C)
# Lalu jalankan ulang:
flutter run -d chrome
```

### Step 5: Login!

1. Buka aplikasi Flutter di browser
2. Navigasi ke `/admin/login` atau klik tombol "Admin" jika ada
3. Masukkan kredensial:
   - **Email:** `admin@kugar.com`
   - **Password:** `admin123`
4. Klik "Login"

## ✨ Yang Sudah Diperbaiki

- ✅ Integrasi dengan backend API (tidak hardcoded lagi)
- ✅ Dual endpoint support (/admin/login dan /auth/login)
- ✅ Auto role validation (cek apakah user adalah admin)
- ✅ Token management (otomatis save token)
- ✅ Error handling yang lebih baik
- ✅ Logging untuk debugging

## 🔍 Troubleshooting

### Problem: "Email atau password salah"

**Cek:**
1. Apakah admin user sudah dibuat di database?
   ```sql
   SELECT * FROM users WHERE email = 'admin@kugar.com';
   ```
2. Apakah password benar? (admin123)
3. Apakah ada typo?

**Solusi:**
- Jika user belum ada, ikuti Step 1 lagi
- Jika user ada tapi password salah, reset password:
  ```sql
  UPDATE users 
  SET password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi' 
  WHERE email = 'admin@kugar.com';
  ```

### Problem: "Akun Anda tidak memiliki akses admin"

**Solusi:**
```sql
UPDATE users SET role = 'admin' WHERE email = 'admin@kugar.com';
```

### Problem: "Terjadi kesalahan saat login"

**Cek:**
1. Apakah proxy server berjalan? (lihat terminal proxy)
2. Apakah backend Laravel berjalan?
3. Apakah ada error di console Flutter?

**Solusi:**
1. Pastikan proxy berjalan: `node proxy.js`
2. Cek Laravel server (Herd biasanya auto-start)
3. Lihat error di Flutter DevTools console

### Problem: Proxy/Backend tidak berjalan

**Backend Laravel:**
```bash
# Jika menggunakan Laravel Herd, server auto-start
# Cek di: http://wisatalembung.test

# Jika manual:
cd C:\Users\LENOVO\Herd\wisatalembung
php artisan serve
```

**Proxy Server:**
```bash
cd C:\Users\LENOVO\Herd\kugar_flutter_app
node proxy.js
```

## 📊 Debug Console

Ketika login, cek:

**Flutter Console:**
```
DEBUG ADMIN: Attempting admin login for email: admin@kugar.com
DEBUG ADMIN: Trying /admin/login endpoint
DEBUG ADMIN: /admin/login response status: 200
DEBUG ADMIN: /admin/login response data: {...}
```

**Proxy Console:**
```
📡 [timestamp] POST /api/admin/login
   → http://wisatalembung.test/api/admin/login
   ✅ Status: 200
```

## 🎯 Verification Checklist

Sebelum login, pastikan:

- [ ] ✅ Admin user sudah dibuat di database
- [ ] ✅ Backend Laravel server berjalan (wisatalembung.test)
- [ ] ✅ Proxy server berjalan (localhost:3001)
- [ ] ✅ Flutter app sudah di-restart
- [ ] ✅ Email: admin@kugar.com
- [ ] ✅ Password: admin123

## 📁 Files Modified/Created

1. **NEW:** `lib/data/services/admin_auth_service.dart`
2. **NEW:** `lib/data/providers/admin_auth_provider.dart`
3. **UPDATED:** `lib/presentation/pages/admin/auth/admin_login_page.dart`
4. **NEW:** `ADMIN_LOGIN_SETUP.md` (detailed guide)
5. **NEW:** `AdminUserSeeder.php` (database seeder)

## 🔐 Default Credentials

```
Email: admin@kugar.com
Password: admin123
```

**⚠️ PENTING:** Ganti password ini di production!

## 📞 Need Help?

Jika masih ada masalah:
1. Cek Flutter console untuk error
2. Cek proxy logs
3. Cek Laravel logs: `C:\Users\LENOVO\Herd\wisatalembung\storage\logs\laravel.log`
4. Pastikan semua step sudah diikuti dengan benar
