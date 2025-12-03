# 🚀 FLUTTER DEVELOPMENT ACTION PLAN

**Target:** Integrate Flutter app dengan Backend API yang sudah ready  
**Timeline:** 10 Hari Development  
**Start Date:** 3 Desember 2025

---

## 📊 QUICK STATUS

| Component | Status | Progress |
|-----------|--------|----------|
| Backend API | ✅ Ready | 100% |
| Flutter Structure | ✅ Ready | 100% |
| API Service (User) | ✅ Ready | 100% |
| API Service (Admin) | ❌ Missing | 0% |
| Auth Integration | 🔄 Partial | 60% |
| Product Features | 🔄 Partial | 50% |
| Cart & Checkout | 🔄 Partial | 40% |
| Admin Features | ❌ Not Started | 0% |

---

## 🎯 PHASE 1: CRITICAL FIXES (Day 1) - HARI INI!

### ✅ Task 1.1: Update Base URL ke Production
**File:** `lib/core/config/app_config.dart`

**Current:**
```dart
static const String localBaseUrl = 'http://wisatalembung.test';
static const String emulatorBaseUrl = 'http://10.0.2.2';
```

**Update to:**
```dart
static const String productionBaseUrl = 'https://kugar.e-pinggirpapas-sumenep.com';
static const String localBaseUrl = 'http://wisatalembung.test';

static String get baseUrl {
  // Use production URL by default, override with environment variable for dev
  final base = const String.fromEnvironment('USE_LOCAL', defaultValue: 'false') == 'true'
    ? localBaseUrl
    : productionBaseUrl;
  return '$base/api';
}
```

**Also update:** `lib/core/constants/app_constants.dart`

---

### ✅ Task 1.2: Fix Admin Authentication

**Problem:** Admin login berbeda dengan user login
- Admin endpoint: `POST /api/admin/login`
- Admin memerlukan: `email`, `password`, `device_name`

**Solution: Create AdminApiService**

**New File:** `lib/data/services/admin_api_service.dart`

```dart
class AdminApiService {
  final Dio _dio;
  
  // Admin Authentication
  Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    final response = await _dio.post('/admin/login', data: {
      'email': email,
      'password': password,
      'device_name': 'flutter_app',
    });
    return response.data;
  }
  
  // Admin Dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    return await _dio.get('/admin/dashboard/stats');
  }
  
  // Admin Products
  Future<Map<String, dynamic>> getAdminProducts({
    int page = 1,
    String? search,
    String? category,
  }) async { ... }
  
  Future<Map<String, dynamic>> createProduct(FormData productData) async { ... }
  
  Future<Map<String, dynamic>> updateProduct(int id, FormData productData) async { ... }
  
  Future<Map<String, dynamic>> deleteProduct(int id) async { ... }
  
  // ... more admin methods
}
```

**New File:** `lib/presentation/providers/admin_provider.dart`

```dart
class AdminAuthState {
  final User? admin;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
}

class AdminAuthNotifier extends StateNotifier<AdminAuthState> {
  final AdminApiService _adminApiService;
  
  Future<void> adminLogin(String email, String password) async { ... }
}

final adminAuthProvider = StateNotifierProvider<AdminAuthNotifier, AdminAuthState>(...);
```

---

### ✅ Task 1.3: Test Basic User Flow

**Checklist:**
- [ ] Test user registration
- [ ] Test user login
- [ ] Verify token saved to SharedPreferences
- [ ] Test get products list
- [ ] Test get product detail
- [ ] Test navigation flow

**How to test:**
1. Run app: `flutter run`
2. Go to Register page
3. Register new user
4. Should auto-login
5. Browse products
6. Click product detail

---

### ✅ Task 1.4: Verify API Responses

**Important:** Pastikan response format sesuai dengan yang di-expect Flutter!

**Check Points:**
1. Auth response includes `token` in `data.token`
2. Products response has `data` array with pagination
3. Product detail has complete fields
4. Error responses consistent

**If not matching:** Update `ApiService` response parsing!

---

## 🔌 PHASE 2: EXTEND API SERVICE (Day 2)

### ✅ Task 2.1: Create Admin API Service

**Create:** `lib/data/services/admin_api_service.dart`

**Include all admin endpoints:**

#### **Admin Authentication:**
```dart
- adminLogin(email, password, deviceName)
- adminLogout()
- getAdminProfile()
```

#### **Admin Dashboard:**
```dart
- getDashboardStats()
- getRecentOrders(limit)
- getRecentUsers(limit)
- getSalesChart(period)
```

#### **Admin Products:**
```dart
- getAdminProducts(page, search, category, status)
- createProduct(productData)
- updateProduct(id, productData)
- deleteProduct(id)
- toggleProductStatus(id)
- uploadProductImage(id, imageFile)
```

#### **Admin Orders:**
```dart
- getAdminOrders(page, status, search)
- getAdminOrderDetail(orderId)
- updateOrderStatus(orderId, status)
- assignOrderToStaff(orderId, staffId)
- exportOrders(dateFrom, dateTo)
```

#### **Admin Virtual Tours:**
```dart
- getAdminVirtualTours(page, search, status)
- createVirtualTour(tourData)
- updateVirtualTour(id, tourData)
- deleteVirtualTour(id)
- toggleVirtualTourStatus(id)
```

#### **Admin Content/Posts:**
```dart
- getAdminPosts(page, search, category, status)
- createPost(postData)
- updatePost(id, postData)
- deletePost(id)
- publishPost(id)
- uploadPostImage(id, imageFile)
```

#### **Admin Users:**
```dart
- getAdminUsers(page, search, role, status)
- getUserDetail(id)
- updateUserStatus(id, status)
- deleteUser(id)
```

#### **Admin Utilities:**
```dart
- exportData(type, dateFrom, dateTo)
- backupDatabase()
- getActivityLog(page, userId, action)
```

---

### ✅ Task 2.2: Create Missing Entities

**Create:** `lib/domain/entities/virtual_tour.dart`
```dart
class VirtualTour {
  final int id;
  final String title;
  final String description;
  final String tourUrl;
  final String? thumbnailUrl;
  final bool isActive;
  final DateTime? createdAt;
  
  factory VirtualTour.fromJson(Map<String, dynamic> json) { ... }
}
```

**Create:** `lib/domain/entities/post.dart`
```dart
class Post {
  final int id;
  final String title;
  final String content;
  final String? category;
  final String? imageUrl;
  final String status;
  final DateTime? publishedAt;
  
  factory Post.fromJson(Map<String, dynamic> json) { ... }
}
```

**Create:** `lib/domain/entities/review.dart`
```dart
class Review {
  final int id;
  final int productId;
  final int userId;
  final String userName;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  
  factory Review.fromJson(Map<String, dynamic> json) { ... }
}
```

**Create:** `lib/domain/entities/dashboard_stats.dart`
```dart
class DashboardStats {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final double totalRevenue;
  final int totalProducts;
  final int totalUsers;
  final List<SalesData> salesChart;
  
  factory DashboardStats.fromJson(Map<String, dynamic> json) { ... }
}
```

---

### ✅ Task 2.3: Update Existing Providers

**Review & Update:**
- `lib/presentation/providers/cart_provider.dart`
- `lib/presentation/providers/order_provider.dart`
- `lib/presentation/providers/product_provider.dart`

**Ensure they:**
1. Handle loading states properly
2. Handle errors properly
3. Use the ApiService methods correctly
4. Parse responses correctly
5. Update UI state correctly

---

## 👨‍💼 PHASE 3: ADMIN FEATURES (Day 3-4)

### ✅ Task 3.1: Admin Login Page

**Update:** `lib/presentation/pages/admin/auth/admin_login_page.dart`

**Features:**
- Email & password fields
- "Login as Admin" button
- Loading state
- Error handling
- Navigate to admin dashboard on success

**Integration:**
```dart
final adminAuth = ref.watch(adminAuthProvider.notifier);
await adminAuth.adminLogin(email, password);
```

---

### ✅ Task 3.2: Admin Dashboard Page

**Update:** `lib/presentation/pages/admin/dashboard/admin_dashboard_page.dart`

**Features:**
- Statistics cards (orders, revenue, users, products)
- Sales chart
- Recent orders table
- Recent users list
- Quick actions (add product, view orders, etc.)

**Use Provider:**
```dart
final dashboardProvider = FutureProvider<DashboardStats>((ref) async {
  final adminApi = ref.watch(adminApiServiceProvider);
  return await adminApi.getDashboardStats();
});
```

---

### ✅ Task 3.3: Admin Products Page

**Create:** `lib/presentation/pages/admin/products/admin_products_page.dart`

**Features:**
- Product list with search & filters
- Add new product (floating action button)
- Edit product (tap item)
- Delete product (swipe to delete)
- Toggle active/inactive status
- Image upload

**Create:** `lib/presentation/pages/admin/products/product_form_page.dart`

**Features:**
- Form for add/edit product
- Fields: name, price, description, category, stock, image
- Image picker
- Save button
- Validation

---

### ✅ Task 3.4: Admin Orders Page

**Update:** `lib/presentation/pages/admin/orders/admin_orders_page.dart`

**Features:**
- Order list with filters (status, date)
- Order detail view
- Update order status
- Search orders
- Export orders

---

### ✅ Task 3.5: Admin Users Page

**Update:** `lib/presentation/pages/admin/users/admin_users_page.dart`

**Features:**
- User list with search
- User detail view
- Update user status (active/inactive)
- Filter by role
- Delete user

---

## 👤 PHASE 4: USER FEATURES (Day 5-6)

### ✅ Task 4.1: Complete Cart & Checkout

**Update:** `lib/presentation/pages/cart/cart_page.dart`

**Features:**
- Display cart items from provider
- Update quantity
- Remove item
- Calculate total
- Proceed to checkout

**Update:** `lib/presentation/pages/checkout/checkout_page.dart`

**Features:**
- Shipping address form
- Payment method selection
- Order summary
- Place order button
- Navigate to order tracking on success

---

### ✅ Task 4.2: Order Tracking

**Update:** `lib/presentation/pages/tracking/order_tracking_page.dart`

**Features:**
- Order list (user's orders)
- Order status badges
- Order detail view
- Track order (status timeline)
- Reorder button

---

### ✅ Task 4.3: QR Scanner Integration

**Update:** `lib/presentation/pages/qr/qr_scanner_page.dart`

**Features:**
- Camera permission
- Scan QR code
- Parse product ID from QR
- Navigate to product detail
- Error handling

**Use Package:** `mobile_scanner: ^5.1.1`

---

### ✅ Task 4.4: Virtual Tour

**Update:** `lib/presentation/pages/virtual_tour/virtual_tour_page.dart`

**Features:**
- List of virtual tours
- WebView for 360° tour
- Loading indicator
- Error handling
- Back button

**Use Package:** Need to add `webview_flutter` to pubspec.yaml!

---

### ✅ Task 4.5: Reviews & Ratings

**Update:** `lib/presentation/pages/reviews/reviews_page.dart`

**Features:**
- Display product reviews
- Add new review (authenticated users only)
- Rating stars
- Review text
- Submit button
- Edit/delete own review

---

### ✅ Task 4.6: Profile Management

**Create:** `lib/presentation/pages/profile/profile_page.dart`

**Features:**
- Display user info
- Edit profile button
- Order history
- Settings
- Logout

**Create:** `lib/presentation/pages/profile/edit_profile_page.dart`

**Features:**
- Form: name, phone, address
- Avatar upload
- Save button
- Validation

---

## 🎨 PHASE 5: POLISH & OPTIMIZATION (Day 7-8)

### ✅ Task 5.1: Error Handling

**Global Error Handler:**
- Network errors
- API errors
- Token expiry
- Validation errors
- User-friendly messages

**Create:** `lib/core/utils/error_handler.dart`

---

### ✅ Task 5.2: Loading States

**Shimmer Loading:**
- Product list loading
- Product detail loading
- Order list loading
- Dashboard loading

**Use Package:** `shimmer: ^3.0.0` (already installed!)

---

### ✅ Task 5.3: Image Optimization

**Features:**
- Cached images
- Placeholder images
- Error images
- Progressive loading

**Use Package:** `cached_network_image: ^3.3.1` (already installed!)

**Ensure:**
- Image URLs are correct (full URL vs relative path)
- ImageBaseUrl configured properly

---

### ✅ Task 5.4: Performance Optimization

**Optimize:**
- Lazy loading lists
- Pagination
- Image caching
- Minimize rebuild
- Use const constructors

---

### ✅ Task 5.5: Offline Support (Basic)

**Features:**
- Check connectivity
- Show offline banner
- Cache basic data
- Queue failed requests

**Use Package:** `connectivity_plus: ^6.0.3` (already installed!)

---

## 🧪 PHASE 6: TESTING (Day 9)

### ✅ Task 6.1: Manual Testing

**User Flow:**
1. [ ] Register new account
2. [ ] Login
3. [ ] Browse products
4. [ ] Search products
5. [ ] Filter products by category
6. [ ] View product detail
7. [ ] Add to cart
8. [ ] Update cart quantity
9. [ ] Remove from cart
10. [ ] Checkout
11. [ ] View order tracking
12. [ ] Write product review
13. [ ] Scan QR code
14. [ ] View virtual tour
15. [ ] Update profile
16. [ ] Logout

**Admin Flow:**
1. [ ] Admin login
2. [ ] View dashboard
3. [ ] Add new product
4. [ ] Edit product
5. [ ] Delete product
6. [ ] View orders
7. [ ] Update order status
8. [ ] View users
9. [ ] Export data
10. [ ] Admin logout

---

### ✅ Task 6.2: Bug Fixes

**Log all bugs and fix them:**
- UI bugs
- Navigation bugs
- API integration bugs
- State management bugs
- Image loading bugs

---

### ✅ Task 6.3: Code Quality

**Check:**
- Remove debug prints
- Remove unused imports
- Format code
- Fix lints
- Add comments where needed

**Run:**
```bash
flutter analyze
flutter format .
```

---

## 🚀 PHASE 7: BUILD & DEPLOYMENT (Day 10)

### ✅ Task 7.1: Build APK

```bash
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

---

### ✅ Task 7.2: Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

**Output:** `build/app/outputs/bundle/release/app-release.aab`

---

### ✅ Task 7.3: Test on Real Device

- Install APK on real Android device
- Test all major flows
- Test performance
- Check for crashes

---

### ✅ Task 7.4: Documentation

**Create/Update:**
- User guide
- Admin guide
- Deployment guide
- API integration guide

---

## 📝 DEVELOPMENT CHECKLIST

### **Day 1 (Today): Critical Fixes**
- [ ] Update base URL to production
- [ ] Create AdminApiService
- [ ] Create AdminAuthProvider
- [ ] Test user login/register
- [ ] Test product listing

### **Day 2: API Extensions**
- [ ] Complete AdminApiService (all methods)
- [ ] Create missing entities (VirtualTour, Post, Review, Stats)
- [ ] Review & update existing providers
- [ ] Add image upload functionality

### **Day 3: Admin Core**
- [ ] Admin login functionality
- [ ] Admin dashboard with stats
- [ ] Admin navigation

### **Day 4: Admin Features**
- [ ] Admin products (list, add, edit, delete)
- [ ] Admin orders (list, detail, update status)
- [ ] Admin users (list, detail, manage)

### **Day 5: User Core**
- [ ] Complete cart & checkout flow
- [ ] Order tracking
- [ ] Profile management

### **Day 6: User Advanced**
- [ ] QR Scanner
- [ ] Virtual Tour WebView
- [ ] Reviews & ratings
- [ ] Search & filters

### **Day 7: Polish**
- [ ] Error handling
- [ ] Loading states
- [ ] Image optimization
- [ ] Performance optimization

### **Day 8: Offline & UX**
- [ ] Offline support
- [ ] Pull to refresh
- [ ] Empty states
- [ ] Success/error messages

### **Day 9: Testing**
- [ ] Complete user flow testing
- [ ] Complete admin flow testing
- [ ] Bug fixes
- [ ] Code quality

### **Day 10: Deployment**
- [ ] Build APK
- [ ] Build AAB
- [ ] Test on device
- [ ] Documentation

---

## 🎯 TODAY'S TASKS (Day 1)

### **Priority 1: Update Configuration** ⏰ 30 mins
1. Update `lib/core/config/app_config.dart` - production URL
2. Update `lib/core/constants/app_constants.dart` - production URL
3. Test connectivity to production API

### **Priority 2: Admin Auth** ⏰ 1 hour
1. Create `lib/data/services/admin_api_service.dart` - basic structure
2. Add admin login method
3. Create `lib/presentation/providers/admin_provider.dart`
4. Test admin login in Postman first

### **Priority 3: Basic Testing** ⏰ 1 hour
1. Run app: `flutter run`
2. Test user registration
3. Test user login
4. Test browse products
5. Document any issues

### **Priority 4: Planning Tomorrow** ⏰ 30 mins
1. Review backend API documentation
2. List all admin endpoints needed
3. Plan entity models needed
4. Prepare for Day 2 work

---

## 📞 NEED HELP?

**When stuck:**
1. Check backend API documentation: `API_DOCUMENTATION_FLUTTER.md`
2. Test endpoint in Postman first
3. Check response format
4. Update Flutter code accordingly

**Common Issues:**
- **401 Unauthorized:** Check token, check headers
- **404 Not Found:** Check endpoint URL
- **422 Validation Error:** Check request data format
- **500 Server Error:** Check backend logs

---

## 🎉 SUCCESS CRITERIA

**App is complete when:**
- ✅ All user features working (browse, cart, checkout, tracking)
- ✅ All admin features working (dashboard, products, orders, users)
- ✅ No critical bugs
- ✅ Smooth user experience
- ✅ Proper error handling
- ✅ Works on real device
- ✅ APK/AAB built successfully

---

**Let's build this! 🚀**

**Created:** 3 Desember 2025, 22:00  
**By:** Cascade AI Assistant  
**Ready to start:** YES! 💪
