# Admin Login Setup Guide

## Masalah Login Admin Telah Diperbaiki! ✅

Halaman admin login sekarang sudah terintegrasi dengan backend API dan tidak lagi menggunakan hardcoded credentials.

## 🔑 Setup Admin User di Backend

Karena aplikasi Flutter sekarang menggunakan autentikasi API yang real, Anda perlu memastikan ada user admin di database backend.

### Opsi 1: Menggunakan Tinker (Recommended)

```bash
# Masuk ke direktori backend Laravel
cd C:\Users\LENOVO\Herd\wisatalembung

# Jalankan tinker
php artisan tinker

# Buat admin user
User::create([
    'name' => 'Admin KUGAR',
    'email' => 'admin@kugar.com',
    'password' => Hash::make('admin123'),
    'role' => 'admin',
]);

# Atau jika tidak ada kolom role
User::create([
    'name' => 'Admin KUGAR',
    'email' => 'admin@kugar.com',
    'password' => Hash::make('admin123'),
]);
```

### Opsi 2: Menggunakan SQL Direct

```sql
-- Jalankan query ini di database Anda
INSERT INTO users (name, email, password, role, created_at, updated_at) 
VALUES (
    'Admin KUGAR', 
    'admin@kugar.com', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: admin123
    'admin',
    NOW(), 
    NOW()
);
```

**Note:** Password hash di atas adalah untuk "admin123". Jika Anda ingin password berbeda, gunakan opsi 1 dengan Tinker.

### Opsi 3: Menggunakan Database Seeder

Buat file seeder baru:

```bash
php artisan make:seeder AdminUserSeeder
```

Edit file `database/seeders/AdminUserSeeder.php`:

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AdminUserSeeder extends Seeder
{
    public function run()
    {
        User::create([
            'name' => 'Admin KUGAR',
            'email' => 'admin@kugar.com',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
        ]);
    }
}
```

Jalankan seeder:

```bash
php artisan db:seed --class=AdminUserSeeder
```

## 🔐 Kredensial Default Admin

Setelah membuat user admin di database:

- **Email:** `admin@kugar.com`
- **Password:** `admin123`

**⚠️ PENTING:** Ganti password ini setelah login pertama kali di production!

## 🚀 Cara Login

1. **Pastikan proxy server berjalan:**
   ```bash
   node proxy.js
   ```

2. **Jalankan aplikasi Flutter:**
   ```bash
   flutter run -d chrome
   ```

3. **Akses halaman admin login:**
   - Klik tombol admin di halaman utama, atau
   - Navigasi langsung ke `/admin/login`

4. **Masukkan kredensial:**
   - Email: `admin@kugar.com`
   - Password: `admin123`

## 🔍 Troubleshooting

### Error: "Email atau password salah"

**Kemungkinan penyebab:**
1. User admin belum dibuat di database
2. Password salah
3. Email salah

**Solusi:**
- Verifikasi user ada di database:
  ```sql
  SELECT * FROM users WHERE email = 'admin@kugar.com';
  ```
- Pastikan password di-hash dengan benar
- Cek typo di email/password

### Error: "Terjadi kesalahan saat login"

**Kemungkinan penyebab:**
1. Backend server tidak berjalan
2. Proxy server tidak berjalan
3. Endpoint `/api/admin/login` atau `/api/auth/login` tidak tersedia

**Solusi:**
1. Pastikan Laravel server berjalan:
   ```bash
   # Jika menggunakan Herd, server otomatis berjalan
   # Jika manual:
   php artisan serve
   ```

2. Pastikan proxy berjalan:
   ```bash
   node proxy.js
   ```

3. Cek endpoint tersedia:
   ```bash
   # Test endpoint admin/login
   Invoke-WebRequest -Method POST -Uri "http://localhost:3001/api/admin/login" -ContentType "application/json" -Body '{"email":"admin@kugar.com","password":"admin123"}'
   
   # Test endpoint auth/login
   Invoke-WebRequest -Method POST -Uri "http://localhost:3001/api/auth/login" -ContentType "application/json" -Body '{"email":"admin@kugar.com","password":"admin123"}'
   ```

### Error: "Akun Anda tidak memiliki akses admin"

**Kemungkinan penyebab:**
- User tidak memiliki role admin

**Solusi:**
- Update role user di database:
  ```sql
  UPDATE users SET role = 'admin' WHERE email = 'admin@kugar.com';
  ```

## 📋 Checklist Sebelum Login

- [ ] Backend Laravel server berjalan
- [ ] Proxy server berjalan (`node proxy.js`)
- [ ] User admin sudah dibuat di database
- [ ] Password sudah di-hash dengan benar
- [ ] Flutter app sudah di-restart setelah perubahan code

## 🎯 Technical Details

### Endpoint yang Digunakan

Sistem admin login mencoba 2 endpoint secara berurutan:

1. **Primary:** `POST /api/admin/login`
   - Endpoint khusus untuk admin
   - Lebih aman dan terpisah dari user biasa

2. **Fallback:** `POST /api/auth/login`
   - Endpoint umum untuk semua user
   - Akan memvalidasi role admin sebelum login

### Request Format

```json
{
  "email": "admin@kugar.com",
  "password": "admin123"
}
```

### Expected Response Format

```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "token": "jwt_token_here",
    "user": {
      "id": 1,
      "name": "Admin KUGAR",
      "email": "admin@kugar.com",
      "role": "admin"
    }
  }
}
```

Atau format alternatif:

```json
{
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "name": "Admin KUGAR",
    "email": "admin@kugar.com",
    "role": "admin"
  }
}
```

## 🔧 File yang Diubah

1. **`lib/data/services/admin_auth_service.dart`** (NEW)
   - Service untuk autentikasi admin
   - Dual endpoint support
   - Token management

2. **`lib/data/providers/admin_auth_provider.dart`** (NEW)
   - Riverpod providers untuk state management

3. **`lib/presentation/pages/admin/auth/admin_login_page.dart`** (UPDATED)
   - Menggunakan real API authentication
   - Removed hardcoded credentials
   - Better error handling

## 📚 Next Steps

Setelah berhasil login:

1. **Ganti Password Default**
   - Buat fitur change password di admin panel

2. **Setup Role-Based Access Control**
   - Implementasi middleware untuk checking admin role
   - Protect admin endpoints

3. **Add More Admin Features**
   - Dashboard statistics
   - Product management
   - Order management
   - User management

## 📞 Bantuan Lebih Lanjut

Jika masih ada masalah, cek:
- Console output di Flutter app
- Proxy server logs
- Laravel logs (`storage/logs/laravel.log`)
