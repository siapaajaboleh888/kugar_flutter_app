# 🚀 QUICK START - ADMIN PANEL

## 📱 CARA MENJALANKAN ADMIN PANEL

### Step 1: Persiapan Backend

```bash
# 1. Pastikan backend Laravel sudah running
cd /path/to/laravel/project
php artisan serve

# Backend akan jalan di: http://127.0.0.1:8000
```

### Step 2: (Optional) Run Proxy untuk Web Development

Jika develop di web browser, jalankan proxy untuk avoid CORS:

```bash
# Di folder Flutter project
cd c:\Users\LENOVO\Herd\kugar_flutter_app
node proxy.js

# Proxy akan jalan di: http://localhost:3001
```

### Step 3: Run Flutter App

```bash
# Di folder Flutter project
flutter run

# Atau untuk web:
flutter run -d chrome

# Atau untuk Android:
flutter run -d <device-id>
```

---

## 🔐 LOGIN ADMIN

### Kredensial Default

```
Email    : admin@kugar.com
Password : admin123
```

### Langkah Login

1. Buka app
2. Navigate ke halaman admin login: `/admin/login`
3. Input email dan password
4. Klik "Login"
5. Akan redirect ke Dashboard

---

## 🎯 FITUR YANG TERSEDIA

### 1. **Dashboard** 📊
URL: `/admin/dashboard`

**Menampilkan:**
- Total Users (dengan jumlah admin)
- Total Products (dengan rata-rata harga)
- Total Orders (dengan completed orders)
- Revenue bulan ini
- Order status breakdown
- 5 Recent Users
- 5 Recent Products

**Actions:**
- Refresh data (button di AppBar)
- Navigate ke halaman lain via drawer
- Pull-to-refresh

---

### 2. **User Management** 👥
URL: `/admin/users`

**Fitur:**
- List semua users dengan pagination
- Search by nama, email, atau no HP
- Filter by role (All, User, Admin, Staff)
- Total users counter

**Actions:**
- ➕ **Tambah User** (FloatingActionButton)
  - Isi form: Nama, Email, Phone, Password, Role
  - Klik "Tambah"
  
- ✏️ **Edit User** (Tap pada card user)
  - Update data user
  - Password optional (kosongkan jika tidak diubah)
  - Klik "Update"
  
- 🗑️ **Hapus User** (Long press pada card)
  - Konfirmasi hapus
  - User akan dihapus dari database

**Pagination:**
- 15 users per page
- Previous/Next buttons
- Page indicator

---

### 3. **Product Management** 🛍️
URL: `/admin/products`

**Fitur:**
- List semua products dengan pagination
- Search products
- Total products counter
- Product images (cached)

**Actions:**
- ➕ **Tambah Product** (FloatingActionButton)
  1. Tap area gambar untuk pilih foto (dari gallery)
  2. Isi form:
     - Nama Produk (required)
     - Deskripsi (required)
     - Harga (required, number only)
     - Alamat (optional)
     - No. HP (optional)
  3. Klik "Tambah"
  4. Gambar akan di-upload otomatis
  
- ✏️ **Edit Product** (Tap card atau pilih dari menu)
  - Update data product
  - Ganti gambar (optional)
  - Klik "Update"
  
- 🗑️ **Hapus Product** (Menu → Hapus)
  - Konfirmasi hapus
  - Product + gambar akan dihapus

**Product Card Shows:**
- Gambar produk (80x80)
- Nama produk
- Deskripsi (max 2 lines)
- Harga (formatted: Rp x.xxx)
- Lokasi (jika ada)
- Action menu

**Pagination:**
- 15 products per page
- Previous/Next buttons

---

## 🎨 UI/UX FEATURES

### Loading States
Semua halaman menampilkan loading indicator saat fetch data:
- CircularProgressIndicator di center
- Skeleton loaders (optional enhancement)

### Error Handling
Jika terjadi error:
- Error icon + message ditampilkan
- "Coba Lagi" button untuk retry
- SnackBar notifications untuk success/error

### Pull to Refresh
Semua list pages support pull-to-refresh:
- Drag down dari top
- List akan refresh otomatis

### Confirmation Dialogs
Untuk destructive actions (delete):
- Confirmation dialog muncul
- "Batal" atau "Hapus"
- Prevents accidental deletion

### Form Validation
Semua forms punya validation:
- Required fields ditandai
- Email validation
- Number validation untuk harga
- Password min 6 characters
- Error messages in red

---

## 📱 NAVIGATION

### App Drawer (Sidebar)
Buka dengan tap icon ☰ di AppBar

**Menu:**
- 📊 Dashboard
- 👥 Manage Users
- 🛍️ Manage Products
- 🛒 Manage Orders (coming soon)
- 💬 Customer Chats (coming soon)
- 🚪 Logout

### Go Router Paths

```dart
/admin/login       - Admin Login
/admin/dashboard   - Dashboard
/admin/users       - User Management
/admin/products    - Product Management
/admin/orders      - Orders (skeleton)
/admin/chats       - Chats (skeleton)
```

---

## 🔧 TROUBLESHOOTING

### Problem: White screen/blank page
**Solution:**
1. Check console untuk errors
2. Check backend is running
3. Check API base URL di `app_constants.dart`
4. Check token tersimpan di SharedPreferences

### Problem: Login error "Kredensial tidak valid"
**Solution:**
1. Verify credentials: `admin@kugar.com` / `admin123`
2. Check backend database punya admin user
3. Run seeder: `php artisan db:seed --class=AdminUserSeeder`
4. Check endpoint: POST `/api/admin/login`

### Problem: Images tidak muncul
**Solution:**
1. Check storage link: `php artisan storage:link`
2. Check image_url dari backend response
3. Check CORS policy
4. Check network tab di DevTools

### Problem: CORS errors (Web)
**Solution:**
```bash
# Run proxy
node proxy.js

# Update base URL to use proxy
# In app_constants.dart:
apiBaseUrl = 'http://localhost:3001/api'
```

### Problem: "Tidak ada data" padahal ada
**Solution:**
1. Check API response di Network tab
2. Check console logs
3. Verify response format matches model
4. Check `success` field in response

### Problem: Pagination tidak works
**Solution:**
1. Check API returns `current_page`, `last_page`, `total`
2. Verify pagination logic in page
3. Check if `_currentPage` state updates

### Problem: Search tidak works
**Solution:**
1. Check search query dikirim ke API
2. Verify API supports search parameter
3. Reset page to 1 saat search
4. Clear search untuk reset

---

## 💻 DEVELOPMENT TIPS

### Hot Reload
Saat develop, gunakan hot reload:
- Press `r` di terminal untuk reload
- Press `R` untuk full restart
- Press `q` untuk quit

### Debug Mode
Enable debug prints di services:
```dart
print('DEBUG: ...');
```

Log akan muncul di console.

### Test API with Postman
Before implement di Flutter, test endpoint dulu di Postman:
1. Import API collection
2. Test semua endpoints
3. Verify response format
4. Check status codes

### Check Flutter Doctor
Jika ada masalah:
```bash
flutter doctor -v
```

### Clear Cache
Jika ada weird issues:
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📚 HELPFUL COMMANDS

### Flutter Commands
```bash
# Run app
flutter run

# Run on specific device
flutter run -d chrome
flutter run -d emulator-5554

# Build APK
flutter build apk --release

# Analyze code
flutter analyze

# Format code
flutter format .

# Get dependencies
flutter pub get

# Clean build
flutter clean
```

### Backend Commands
```bash
# Run server
php artisan serve

# Run seeder
php artisan db:seed --class=AdminUserSeeder

# Create storage link
php artisan storage:link

# Clear cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

---

## 🎯 NEXT ACTIONS

### For Frontend Developer

1. **Test thoroughly**
   - Test setiap fitur
   - Test error cases
   - Test edge cases
   - Test pada berbagai device sizes

2. **Fix bugs**
   - Log semua bugs yang ditemukan
   - Prioritize critical bugs
   - Fix one by one

3. **Enhance UI** (Optional)
   - Add charts di dashboard
   - Add shimmer loading
   - Add animations
   - Improve colors/themes

4. **Implement remaining pages**
   - Orders management
   - Chats page
   - Settings page
   - Profile page

5. **Performance**
   - Optimize images
   - Add caching
   - Lazy loading
   - Debounce search

### For Backend Developer

1. **Ensure all endpoints working**
2. **Seed test data**
3. **Configure CORS properly**
4. **Setup storage link**
5. **Test image upload**

---

## ✅ TESTING CHECKLIST

### Dashboard
- [ ] Stats tampil dengan benar
- [ ] Recent users tampil
- [ ] Recent products tampil
- [ ] Refresh works
- [ ] Navigation works
- [ ] Logout works

### Users
- [ ] List users tampil
- [ ] Search works
- [ ] Filter works
- [ ] Add user works
- [ ] Edit user works
- [ ] Delete user works
- [ ] Pagination works
- [ ] Validation works

### Products
- [ ] List products tampil
- [ ] Search works
- [ ] Add product works
- [ ] Image picker works
- [ ] Image upload works
- [ ] Edit product works
- [ ] Delete product works
- [ ] Pagination works
- [ ] Price formatting benar

---

## 🆘 NEED HELP?

### Documentation
- `BACKEND_SETUP_PROMPT.md` - Backend API docs
- `ADMIN_IMPLEMENTATION_COMPLETE.md` - Implementation details
- `ADMIN_CRUD_GUIDE.md` - CRUD operations guide

### Debug Logs
Check console untuk error messages:
- Dio errors
- JSON parsing errors
- State errors
- Navigation errors

### Common Error Messages

**"Unauthenticated"**
→ Token invalid atau expired, login ulang

**"403 Forbidden"**
→ User bukan admin, check role

**"404 Not Found"**
→ Endpoint salah, check URL

**"422 Validation Error"**
→ Data tidak valid, check form fields

**"500 Server Error"**
→ Backend error, check Laravel logs

---

## 🎉 SUCCESS!

Jika semua works:
- ✅ Dashboard tampil stats
- ✅ Users bisa di-manage
- ✅ Products bisa di-manage
- ✅ Images bisa di-upload
- ✅ No errors di console

**ADMIN PANEL READY TO USE!** 🚀

---

**Created:** 4 Desember 2025  
**Version:** 1.0.0  
**Status:** READY FOR TESTING ✅
