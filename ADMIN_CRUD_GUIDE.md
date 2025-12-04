# 🎨 Admin Panel CRUD - User & Product Management

## ✅ LENGKAP DENGAN SISTEM CRUD!

Admin panel telah dilengkapi dengan sistem CRUD (Create, Read, Update, Delete) untuk mengelola **User** dan **Produk**.

---

## 🚀 Fitur yang Tersedia

### 1. **Dashboard Admin** 📊
- Overview dengan statistics cards
- Quick access ke semua management pages
- Responsive sidebar navigation

### 2. **Product Management** 🛍️ (BARU!)
**Fitur:**
- ✅ **List Products** dengan pagination
- ✅ **Search** produk by nama
- ✅ **Filter** by kategori (Garam, Seafood, Kerajinan, Lainnya)
- ✅ **Create** produk baru
- ✅ **Edit** produk existing
- ✅ **Delete** produk dengan konfirmasi
- ✅ Display gambar produk
- ✅ Stok status indicator

**Data yang bisa dikelola:**
- Nama Produk *
- Deskripsi
- Kategori * (dropdown)
- Harga *
- Stok *
- Berat (gram)
- URL Gambar

### 3. **User Management** 👥
**Fitur:**
- ✅ **List Users**
- ✅ **View** user details
- ✅ **Create** user baru
- ✅ **Edit** user existing
- ✅ **Delete** user
- ✅ **Toggle status** (active/inactive)
- ✅ Role management (user/admin)

---

## 📱 Cara Menggunakan

### Akses Admin Panel

1. **Login sebagai admin:**
   - Navigate ke `/admin/login`
   - Email: `admin@kugar.com`
   - Password: `admin123`

2. **Dashboard muncul** dengan menu:
   - Users
   - Products ⭐ BARU
   - Orders
   - Chats

---

### Kelola Produk

#### 🔍 Melihat Daftar Produk
1. Klik **"Products"** di dashboard atau sidebar
2. Lihat list produk dengan:
   - Gambar produk
   - Nama, kategori, harga
   - Stok dan status ketersediaan
   - Menu actions (Edit/Delete)

#### ➕ Tambah Produk Baru
1. Klik tombol **"+"** di kanan atas
2. Isi form:
   - **Nama Produk** (required)
   - **Deskripsi**
   - **Kategori** (Garam/Seafood/Kerajinan/Lainnya)
   - **Harga** (required, hanya angka)
   - **Stok** (required, hanya angka)
   - **Berat** (optional, dalam gram)
   - **URL Gambar** (optional)
3. Klik **"Tambah"**
4. Produk akan muncul di list

#### ✏️ Edit Produk
1. Klik **menu titik tiga (⋮)** pada produk
2. Pilih **"Edit"**
3. Form muncul dengan data sudah terisi
4. Update data yang diperlukan
5. Klik **"Update"**

#### 🗑️ Hapus Produk
1. Klik **menu titik tiga (⋮)** pada produk
2. Pilih **"Hapus"**
3. Konfirmasi pop-up muncul
4. Klik **"Hapus"** untuk confirm

#### 🔎 Search & Filter
- **Search:** Ketik nama produk di search bar
- **Filter Kategori:** Klik chip kategori (Garam, Seafood, dll)
- **Pagination:** Gunakan arrows untuk navigate pages

---

### Kelola User

#### ➕ Tambah User Baru
1. Navigate ke **"Users"** page
2. Klik tombol **"+**" 
3. Isi form:
   - Name
   - Email
   - Password
   - Role (user/admin)
4. Klik **"Add User"**

#### ✏️ Edit User
1. Klik menu pada user card
2. Pilih **"Edit User"**
3. Update informasi
4. Save changes

#### 🗑️ Delete User
1. Klik menu pada user card
2. Pilih **"Delete"**
3. Konfirmasi delete

#### 🔄 Toggle Status
1. Klik menu pada user card
2. Pilih **"Activate"** atau **"Deactivate"**

---

## 🛠️ File yang Dibuat/Dimodifikasi

### Baru Created:
1. **`lib/data/services/admin_service.dart`**
   - Service untuk API calls CRUD
   - User management methods
   - Product management methods
   - Dashboard stats

2. **`lib/data/providers/admin_provider.dart`**
   - Riverpod providers
   - Filter classes (UsersFilter, ProductsFilter)

3. **`lib/presentation/pages/admin/products/admin_products_page.dart`**
   - Product list page
   - Search & filter UI
   - Pagination

4. **`lib/presentation/pages/admin/products/product_form_dialog.dart`**
   - Create/Edit product form
   - Validation
   - Field formatting

5. **`lib/presentation/widgets/loading_widget.dart`**
   - Reusable loading indicator

### Modified:
1. **`lib/core/router/admin_router.dart`**
   - Added `/admin/products` route

2. **`lib/presentation/pages/admin/dashboard/admin_dashboard_page.dart`**
   - Added Products menu in sidebar
   - Added Products card in dashboard

---

## 🔌 Backend API Endpoints Required

Admin Service menggunakan endpoint berikut:

### Product Endpoints:
```
GET    /api/admin/produk              - List products with pagination
GET    /api/admin/produk/{id}         - Get product detail
POST   /api/admin/produk              - Create new product
PUT    /api/admin/produk/{id}         - Update product
DELETE /api/admin/produk/{id}         - Delete product
POST   /api/admin/produk/{id}/image   - Upload product image
```

### User Endpoints:
```
GET    /api/admin/users               - List users with pagination
GET    /api/admin/users/{id}          - Get user detail
POST   /api/admin/users               - Create new user
PUT    /api/admin/users/{id}          - Update user
DELETE /api/admin/users/{id}          - Delete user
```

### Dashboard:
```
GET    /api/admin/dashboard/stats     - Get dashboard statistics
```

---

## 📊 Request/Response Format

### Create Product Request:
```json
{
  "nama": "Garam Laut Premium",
  "deskripsi": "Garam laut berkualitas tinggi",
  "kategori": "garam",
  "harga": 25000,
  "stok": 100,
  "berat": 500,
  "gambar": "http://example.com/image.jpg"
}
```

### List Products Response:
```json
{
  "data": [
    {
      "id": 1,
      "nama": "Garam Laut Premium",
      "deskripsi": "Garam laut berkualitas tinggi",
      "kategori": "garam",
      "harga": 25000,
      "stok": 100,
      "berat": 500,
      "gambar": "http://example.com/image.jpg",
      "created_at": "2025-12-04T10:00:00Z"
    }
  ],
  "current_page": 1,
  "last_page": 5,
  "total": 45,
  "per_page": 10
}
```

---

## ⚠️ Backend Setup Required

Untuk menggunakan Admin CRUD, backend harus:

1. **Punya endpoint** seperti yang disebutkan di atas
2. **Middleware admin** untuk proteksi route
3. **Return format** sesuai dengan yang diharapkan
4. **CORS** sudah dikonfigurasi dengan benar

### Contoh Laravel Controller:

```php
// app/Http/Controllers/Admin/ProductController.php
public function index(Request $request)
{
    $products = Product::query()
        ->when($request->search, function($q, $search) {
            $q->where('nama', 'like', "%{$search}%");
        })
        ->when($request->category, function($q, $cat) {
            $q->where('kategori', $cat);
        })
        ->paginate($request->limit ?? 10);

    return response()->json($products);
}

public function store(Request $request)
{
    $validated = $request->validate([
        'nama' => 'required|string',
        'deskripsi' => 'nullable|string',
        'kategori' => 'required|string',
        'harga' => 'required|numeric',
        'stok' => 'required|integer',
        'berat' => 'nullable|numeric',
        'gambar' => 'nullable|url',
    ]);

    $product = Product::create($validated);

    return response()->json([
        'success' => true,
        'data' => $product
    ]);
}

public function update(Request $request, $id)
{
    $product = Product::findOrFail($id);
    $product->update($request->all());

    return response()->json([
        'success' => true,
        'data' => $product
    ]);
}

public function destroy($id)
{
    Product::findOrFail($id)->delete();

    return response()->json([
        'success' => true,
        'message' => 'Product deleted'
    ]);
}
```

---

## 🎯 Testing

### Test Product CRUD:

1. **Login** sebagai admin
2. **Navigate** ke Products page
3. **Add product:**
   - Nama: "Test Product"
   - Kategori: "garam"
   - Harga: 10000
   - Stok: 50
4. **Verify** product muncul di list
5. **Edit** product - ubah stok jadi 100
6. **Verify** changes tersimpan
7. **Delete** product
8. **Verify** product hilang dari list

---

## 🐛 Troubleshooting

### Error: "Failed to fetch products"
**Penyebab:** Backend endpoint tidak tersedia atau return format salah

**Solusi:**
1. Cek proxy running: `node proxy.js`
2. Cek backend Laravel running
3. Test endpoint manual:
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:3001/api/admin/produk" `
     -Headers @{"Authorization"="Bearer YOUR_TOKEN"}
   ```

### Error: "Failed to create product"
**Penyebab:** Validation error atau database constraint

**Solusi:**
1. Cek console error untuk detail message
2. Cek backend logs
3. Pastikan semua required fields diisi

### Products tidak muncul
**Penyebab:** Response format tidak sesuai

**Solusi:**
1. Cek response di Network tab browser DevTools
2. Pastikan response format: `{ data: [...], current_page: 1, ... }`

---

## 📈 Next Steps

Setelah Product & User CRUD berjalan:

1. ✅ **Test semua fitur CRUD**
2. 🔄 **Implement image upload** (saat ini URL only)
3. 🔄 **Add category management** page
4. 🔄 **Add order management** dengan status updates
5. 🔄 **Add dashboard real statistics** dari API
6. 🔄 **Add export/import** products (CSV/Excel)
7. 🔄 **Add product variants** (size, color, etc)
8. 🔄 **Add bulk actions** (delete multiple, update stock)

---

## ✨ Summary

| Feature | Status | Description |
|---------|--------|-------------|
| Product List | ✅ Done | View all products with pagination |
| Product Search | ✅ Done | Search by product name |
| Product Filter | ✅ Done | Filter by category |
| Create Product | ✅ Done | Add new product with validation |
| Edit Product | ✅ Done | Update product details |
| Delete Product | ✅ Done | Remove product with confirmation |
| User List | ✅ Done | View all users |
| User CRUD | ✅ Done | Create, Edit, Delete users |
| **Backend Integration** | ⚠️ Required | Need backend endpoints |

---

**Status:** ✅ READY TO USE (setelah backend endpoints tersedia)

**Hot Reload:** Ya, Flutter akan auto-reload setelah perubahan code!

**Dokumentasi:** File ini + code comments
