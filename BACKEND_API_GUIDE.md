# 🔌 Backend API Integration Guide

## Database Connection Implementation

Aplikasi Flutter sekarang sudah siap untuk connect ke database real Anda melalui backend Laravel API.

---

## ✅ Required Backend Endpoints

### Authentication Endpoints

#### 1. Admin Login
```
POST /api/admin/login
```

**Request Body:**
```json
{
  "email": "admin@kugar.com",
  "password": "admin123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "user": {
      "id": 32,
      "name": "Admin User",
      "email": "admin@kugar.com",
      "role": "admin"
    }
  }
}
```

**Laravel Controller Example:**
```php
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AdminAuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Kredensial tidak valid',
            ], 401);
        }

        // Check if user is admin
        if ($user->role !== 'admin') {
            return response()->json([
                'success' => false,
                'message': 'Akses ditolak. Hanya admin yang diizinkan.',
            ], 403);
        }

        // Create token (if using Sanctum)
        $token = $user->createToken('admin-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => [
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                ],
            ],
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil',
        ]);
    }
}
```

---

### User Management Endpoints

#### 2. List Users
```
GET /api/admin/users?page=1&per_page=10&search=john&role=user
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "user",
      "phone": "08123456789",
      "email_verified_at": "2025-11-12 01:31:33",
      "created_at": "2025-11-12 01:31:33"
    }
  ],
  "current_page": 1,
  "last_page": 3,
  "per_page": 10,
  "total": 27
}
```

**Laravel Controller:**
```php
public function index(Request $request)
{
    $query = User::query();

    // Search
    if ($request->has('search')) {
        $search = $request->search;
        $query->where(function($q) use ($search) {
            $q->where('name', 'like', "%{$search}%")
              ->orWhere('email', 'like', "%{$search}%");
        });
    }

    // Filter by role
    if ($request->has('role')) {
        $query->where('role', $request->role);
    }

    $users = $query->paginate($request->per_page ?? 10);

    return response()->json([
        'success' => true,
        'data' => $users->items(),
        'current_page' => $users->currentPage(),
        'last_page' => $users->lastPage(),
        'per_page' => $users->perPage(),
        'total' => $users->total(),
    ]);
}
```

#### 3. Get User Detail
```
GET /api/admin/users/{id}
```

#### 4. Create User
```
POST /api/admin/users
```

**Request Body:**
```json
{
  "name": "New User",
  "email": "newuser@example.com",
  "password": "password123",
  "role": "user",
  "phone": "08123456789"
}
```

**Laravel Controller:**
```php
public function store(Request $request)
{
    $validated = $request->validate([
        'name' => 'required|string|max:255',
        'email' => 'required|email|unique:users,email',
        'password' => 'required|min:6',
        'role' => 'required|in:user,admin',
        'phone' => 'nullable|string',
    ]);

    $validated['password'] = Hash::make($validated['password']);
    $validated['email_verified_at'] = now();

    $user = User::create($validated);

    return response()->json([
        'success' => true,
        'message' => 'User berhasil dibuat',
        'data' => $user,
    ], 201);
}
```

#### 5. Update User
```
PUT /api/admin/users/{id}
```

**Laravel Controller:**
```php
public function update(Request $request, $id)
{
    $user = User::findOrFail($id);

    $validated = $request->validate([
        'name' => 'sometimes|string|max:255',
        'email' => 'sometimes|email|unique:users,email,' . $id,
        'password' => 'sometimes|min:6',
        'role' => 'sometimes|in:user,admin',
        'phone' => 'nullable|string',
    ]);

    if (isset($validated['password'])) {
        $validated['password'] = Hash::make($validated['password']);
    }

    $user->update($validated);

    return response()->json([
        'success' => true,
        'message' => 'User berhasil diupdate',
        'data' => $user,
    ]);
}
```

#### 6. Delete User
```
DELETE /api/admin/users/{id}
```

**Laravel Controller:**
```php
public function destroy($id)
{
    $user = User::findOrFail($id);
    
    // Prevent deleting own account
    if ($user->id === auth()->id()) {
        return response()->json([
            'success' => false,
            'message' => 'Tidak dapat menghapus akun sendiri',
        ], 400);
    }

    $user->delete();

    return response()->json([
        'success' => true,
        'message' => 'User berhasil dihapus',
    ]);
}
```

---

### Product Management Endpoints

#### 7. List Products
```
GET /api/admin/produk?page=1&limit=10&search=garam&category=garam
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nama": "Garam Konsumsi Premium",
      "deskripsi": "Garam laut berkualitas tinggi",
      "kategori": "garam",
      "harga": 15000,
      "stok": 100,
      "berat": 500,
      "gambar": "http://wisatalembung.test/storage/products/garam1.jpg",
      "created_at": "2025-12-01T10:00:00Z"
    }
  ],
  "current_page": 1,
  "last_page": 5,
  "total": 45,
  "per_page": 10
}
```

**Laravel Controller:**
```php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Produk;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Produk::query();

        // Search
        if ($request->has('search')) {
            $query->where('nama', 'like', "%{$request->search}%");
        }

        // Filter by category
        if ($request->has('category')) {
            $query->where('kategori', $request->category);
        }

        $products = $query->paginate($request->limit ?? 10);

        return response()->json([
            'success' => true,
            'data' => $products->items(),
            'current_page' => $products->currentPage(),
            'last_page' => $products->lastPage(),
            'total' => $products->total(),
            'per_page' => $products->perPage(),
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
            'kategori' => 'required|string',
            'harga' => 'required|numeric|min:0',
            'stok' => 'required|integer|min:0',
            'berat' => 'nullable|numeric',
            'gambar' => 'nullable|url',
        ]);

        $product = Produk::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Produk berhasil ditambahkan',
            'data' => $product,
        ], 201);
    }

    public function show($id)
    {
        $product = Produk::findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $product,
        ]);
    }

    public function update(Request $request, $id)
    {
        $product = Produk::findOrFail($id);

        $validated = $request->validate([
            'nama' => 'sometimes|string|max:255',
            'deskripsi' => 'nullable|string',
            'kategori' => 'sometimes|string',
            'harga' => 'sometimes|numeric|min:0',
            'stok' => 'sometimes|integer|min:0',
            'berat' => 'nullable|numeric',
            'gambar' => 'nullable|url',
        ]);

        $product->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Produk berhasil diupdate',
            'data' => $product,
        ]);
    }

    public function destroy($id)
    {
        $product = Produk::findOrFail($id);
        $product->delete();

        return response()->json([
            'success' => true,
            'message' => 'Produk berhasil dihapus',
        ]);
    }
}
```

---

### Dashboard Statistics

#### 8. Dashboard Stats
```
GET /api/admin/dashboard/stats
```

**Response:**
```json
{
  "success": true,
  "data": {
    "total_users": 1234,
    "total_products": 156,
    "total_orders": 256,
    "total_chats": 42,
    "revenue": 12345000
  }
}
```

**Laravel Controller:**
```php
public function stats()
{
    return response()->json([
        'success' => true,
        'data' => [
            'total_users' => \App\Models\User::count(),
            'total_products' => \App\Models\Produk::count(),
            'total_orders' => \App\Models\Order::count(),
            'total_chats' => \App\Models\Chat::count(),
            'revenue' => \App\Models\Order::sum('total'),
        ],
    ]);
}
```

---

## 🛠️ Laravel Routes Setup

Create file: `routes/api.php`

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\ProductController;
use App\Http\Controllers\Admin\DashboardController;

// Admin routes
Route::prefix('admin')->group(function () {
    // Authentication (public)
    Route::post('/login', [AdminAuthController::class, 'login']);
    
    // Protected admin routes
    Route::middleware(['auth:sanctum', 'admin'])->group(function () {
        Route::post('/logout', [AdminAuthController::class, 'logout']);
        
        // Dashboard
        Route::get('/dashboard/stats', [DashboardController::class, 'stats']);
        
        // Users Management
        Route::apiResource('users', UserController::class);
        
        // Products Management
        Route::apiResource('produk', ProductController::class);
    });
});
```

---

## 🔐 Admin Middleware

Create file: `app/Http/Middleware/AdminMiddleware.php`

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        if (!$request->user() || $request->user()->role !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Hanya admin yang diizinkan.',
            ], 403);
        }

        return $next($request);
    }
}
```

Register middleware in `app/Http/Kernel.php`:

```php
protected $middlewareAliases = [
    'admin' => \App\Http\Middleware\AdminMiddleware::class,
];
```

---

## 📦 Installation Steps

### 1. Install Laravel Sanctum (if not installed)

```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

### 2. Configure Sanctum

Add to `config/sanctum.php`:

```php
'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
    '%s%s',
    'localhost,localhost:3001,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
    Sanctum::currentApplicationUrlWithPort()
))),
```

### 3. Update CORS

`config/cors.php`:

```php
'paths' => ['api/*', 'sanctum/csrf-cookie'],
'allowed_origins' => ['http://localhost:3001', 'http://localhost:3000'],
'supports_credentials' => true,
```

---

## ✅ Testing

### Test Admin Login:

```bash
curl -X POST http://wisatalembung.test/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@kugar.com",
    "password": "admin123"
  }'
```

### Test Get Users (with token):

```bash
curl -X GET "http://wisatalembung.test/api/admin/users?page=1" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

### Test Get Products:

```bash
curl -X GET "http://wisatalembung.test/api/admin/produk?page=1&limit=10" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

---

## 🎯 Next Steps

1. ✅ **Create controllers** as shown above
2. ✅ **Add routes** to api.php
3. ✅ **Create middleware** for admin protection
4. ✅ **Test endpoints** with curl or Postman
5. ✅ **Restart proxy** server
6. ✅ **Test from Flutter** app

---

## 📝 Quick Reference

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/admin/login` | POST | Admin login |
| `/api/admin/users` | GET | List users |
| `/api/admin/users` | POST | Create user |
| `/api/admin/users/{id}` | PUT | Update user |
| `/api/admin/users/{id}` | DELETE | Delete user |
| `/api/admin/produk` | GET | List products |
| `/api/admin/produk` | POST | Create product |
| `/api/admin/produk/{id}` | PUT | Update product |
| `/api/admin/produk/{id}` | DELETE | Delete product |
| `/api/admin/dashboard/stats` | GET | Dashboard stats |

---

**Status:** Backend implementation guide complete!  
**Ready for:** Laravel backend development
