# Dashboard Statistics API Setup Guide

## ✅ **Perbaikan Sementara**
Dashboard sekarang menggunakan **mock data fallback** jika API gagal. Ini memastikan dashboard tetap bisa tampil meskipun backend belum siap.

## 🔧 **Cara Mengisi Data Real dari Backend**

### 1. **Buat Endpoint Statistics di Backend**

Tambahkan route di `routes/api.php`:
```php
// Admin Statistics Endpoint
Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::get('/admin/statistics', [AdminController::class, 'getStatistics']);
});
```

### 2. **Buat Method di AdminController**

Di `app/Http/Controllers/AdminController.php`:
```php
public function getStatistics()
{
    try {
        $stats = [
            'total_users' => \App\Models\User::count(),
            'total_products' => \App\Models\Kuliner::count(),
            'total_orders' => 0, // Sesuaikan dengan model Order kalau ada
            'total_revenue' => 0, // Sesuaikan dengan field revenue
            'pending_orders' => 0,
            'processing_orders' => 0,
            'shipped_orders' => 0,
            'delivered_orders' => 0,
        ];

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Failed to fetch statistics: ' . $e->getMessage()
        ], 500);
    }
}
```

### 3. **Format Response yang Diharapkan**

```json
{
  "success": true,
  "data": {
    "total_users": 24,
    "total_products": 6,
    "total_orders": 5,
    "total_revenue": 662440,
    "pending_orders": 1,
    "processing_orders": 1,
    "shipped_orders": 1,
    "delivered_orders": 1
  }
}
```

### 4. **Test Endpoint**

```bash
# Test di terminal atau Postman
curl -X GET "http://localhost:3001/api/admin/statistics" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Accept: application/json"
```

## 📊 **Mock Data yang Digunakan Saat Ini**

Jika API gagal, dashboard akan menampilkan:
- **Total Users:** 24
- **Total Products:** 6
- **Total Orders:** 5
- **Total Revenue:** Rp 662.440
- **Pending Orders:** 1
- **Processing:** 1
- **Shipped:** 1
- **Delivered:** 1

## 🔄 **Cara Refresh Data**

1. Klik tombol **refresh** (ikon refresh) di AppBar
2. Atau hot reload aplikasi (tekan `r`)

## ⚠️ **Troubleshooting**

### Dashboard masih kosong?
1. **Check console log** - lihat apakah ada error API
2. **Check admin token** - pastikan login dengan admin account
3. **Check backend running** - pastikan Laravel server berjalan di port 3001
4. **Check middleware** - pastikan route dilindungi dengan middleware yang benar

### Backend API belum siap?
**Tidak masalah!** Dashboard akan tetap menampilkan mock data sehingga Anda bisa lanjut develop UI tanpaharus menunggu backend selesai.

## 🚀 **Next Steps**

1. ✅ Dashboard sudah tampil dengan mock data
2. 🔧 Setup backend API endpoint `/admin/statistics`
3. 🔄 Test dengan data real
4. ✨ Customize statistik sesuai kebutuhan bisnis

---

**Catatan:** Mock data hanya untuk development. Untuk production, pastikan backend API sudah siap!
