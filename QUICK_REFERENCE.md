# 📱 KUGAR FLUTTER - QUICK REFERENCE

**Project:** E-Pinggirpapas Sumenep Mobile App  
**Date:** 3 Desember 2025  
**Status:** Ready for Integration Phase

---

## 🎯 PROJECT STATUS

| Component | Status | Notes |
|-----------|--------|-------|
| Backend API | ✅ 100% | 63+ endpoints ready |
| Flutter Structure | ✅ 100% | Clean Architecture |
| User API Integration | 🔄 60% | Basic methods ready |
| Admin API Integration | ❌ 0% | Need to create |
| UI Pages | 🔄 70% | 19 pages exist |
| State Management | ✅ 100% | Riverpod configured |

---

## 📚 DOCUMENTATION FILES

1. **`FLUTTER_PROJECT_ANALYSIS.md`** ⭐
   - Complete project structure analysis
   - What's done, what's missing
   - Technical details

2. **`FLUTTER_ACTION_PLAN.md`** ⭐⭐⭐
   - 10-day development roadmap
   - Daily tasks breakdown
   - Step-by-step instructions

3. **`API_DOCUMENTATION_FLUTTER.md`** (Backend folder)
   - All API endpoints
   - Request/response examples
   - Authentication flow

---

## 🔑 CREDENTIALS

### **Admin:**
```
Email: admin@epinggirpapas.com
Password: admin123
Device: flutter_app
```

### **Production URL:**
```
Base: https://kugar.e-pinggirpapas-sumenep.com
API: https://kugar.e-pinggirpapas-sumenep.com/api
```

### **Local URL:**
```
Base: http://wisatalembung.test
API: http://wisatalembung.test/api
```

---

## 📁 KEY FILES TO KNOW

### **Configuration:**
- `lib/core/config/app_config.dart` - Base URL config
- `lib/core/constants/app_constants.dart` - App constants
- `pubspec.yaml` - Dependencies

### **API Services:**
- `lib/data/services/api_service.dart` - User API (37+ methods) ✅
- `lib/data/services/admin_api_service.dart` - Admin API (need to create) ❌

### **State Management:**
- `lib/presentation/providers/auth_provider.dart` - User auth
- `lib/presentation/providers/product_provider.dart` - Products
- `lib/presentation/providers/cart_provider.dart` - Shopping cart
- `lib/presentation/providers/order_provider.dart` - Orders

### **Models:**
- `lib/domain/entities/user.dart` - User model ✅
- `lib/domain/entities/product.dart` - Product model ✅
- `lib/domain/entities/order.dart` - Order model ✅
- `lib/domain/entities/cart_item.dart` - Cart item model ✅

### **Pages:**
- User: auth, home, products, cart, checkout, tracking, profile
- Admin: login, dashboard, products, orders, users

---

## 🚀 QUICK START COMMANDS

### **Install Dependencies:**
```bash
flutter pub get
```

### **Run App:**
```bash
flutter run
```

### **Build APK:**
```bash
flutter build apk --release
```

### **Build App Bundle:**
```bash
flutter build appbundle --release
```

### **Code Generation:**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### **Format Code:**
```bash
flutter format .
```

### **Analyze Code:**
```bash
flutter analyze
```

---

## 🎯 TODAY'S PRIORITY TASKS

### **1. Update Base URL** ⚠️ CRITICAL
**File:** `lib/core/config/app_config.dart`
- Change default to production URL
- Keep local for development flag

### **2. Create Admin API Service** 🔥
**File:** `lib/data/services/admin_api_service.dart`
- Admin login with device_name
- Dashboard stats
- Products CRUD
- Orders management
- Users management

### **3. Test Basic Flow** ✅
- User register → login → browse → cart → checkout

---

## 📊 BACKEND API SUMMARY

### **User Endpoints (Ready):**
- Auth: login, register, logout, profile
- Products: list, detail, categories, featured
- Cart: get, add, update, remove, clear
- Orders: create, list, detail, track
- Reviews: list, create, update, delete
- Virtual Tours: list, detail
- Content: posts, about, contact

### **Admin Endpoints (Ready):**
- Auth: admin login
- Dashboard: stats, charts
- Products: list, create, update, delete, toggle status
- Orders: list, detail, update status
- Users: list, detail, update, delete
- Virtual Tours: list, create, update, delete
- Content: list, create, update, delete
- Utilities: export, backup, logs

**Total:** 63+ endpoints

---

## 🎨 UI PAGES

### **User App (13 pages):**
1. Splash
2. Login
3. Register
4. Home
5. Products List
6. Product Detail
7. Cart
8. Checkout
9. Order Tracking
10. QR Scanner
11. Virtual Tour
12. Reviews
13. Profile (need to create)

### **Admin App (6 pages):**
1. Admin Login
2. Admin Dashboard
3. Admin Products
4. Admin Orders
5. Admin Users
6. Admin Virtual Tours (need to create)

---

## 🛠️ TECH STACK

### **Core:**
- Flutter SDK >=3.0.0
- Dart SDK
- Material Design 3

### **State Management:**
- Riverpod 2.5.1

### **Navigation:**
- GoRouter 14.2.0

### **Networking:**
- Dio 5.4.3 (primary)
- HTTP 1.2.1

### **Local Storage:**
- SharedPreferences 2.2.3
- SQLite 2.3.2

### **UI:**
- Google Fonts 6.1.0
- Cached Network Image 3.3.1
- Shimmer 3.0.0
- Lottie 3.1.2

### **Features:**
- Mobile Scanner 5.1.1
- Image Picker 1.1.2
- Geolocator 12.0.0
- Notifications 17.1.2

---

## ⚡ COMMON TASKS

### **Add New API Method:**
1. Add method to `ApiService` or `AdminApiService`
2. Create/update entity model if needed
3. Create/update provider if needed
4. Use in UI page

### **Add New Page:**
1. Create page file in `lib/presentation/pages/`
2. Add route in `lib/core/router/app_router.dart`
3. Implement UI
4. Connect to provider

### **Add New Entity:**
1. Create file in `lib/domain/entities/`
2. Add fields, constructor
3. Add `fromJson` factory
4. Add `toJson` method
5. Add `copyWith` method

### **Fix API Error:**
1. Test in Postman first
2. Check request format
3. Check headers (token?)
4. Check response parsing
5. Update Flutter code

---

## 🐛 DEBUGGING TIPS

### **Login Not Working:**
- Check base URL
- Check endpoint path
- Check token in SharedPreferences
- Check response parsing

### **Images Not Loading:**
- Check image URL format
- Check if needs base URL prefix
- Check cached_network_image error callback
- Check network connectivity

### **API 401 Error:**
- Token expired or invalid
- Check bearer token in headers
- Re-authenticate

### **API 404 Error:**
- Wrong endpoint URL
- Check route in backend

### **API 422 Error:**
- Validation failed
- Check request data format
- Check required fields

---

## 📞 DEVELOPMENT WORKFLOW

### **Feature Development:**
1. **Backend First:** Ensure endpoint works in Postman
2. **Model:** Create/update entity model
3. **Service:** Add method to ApiService
4. **Provider:** Create/update provider
5. **UI:** Implement page UI
6. **Test:** Manual testing
7. **Polish:** Loading states, error handling

### **Bug Fixing:**
1. **Reproduce:** Understand the bug
2. **Isolate:** Find root cause
3. **Fix:** Make minimal changes
4. **Test:** Verify fix works
5. **Regression:** Test other features

---

## 📈 PROGRESS TRACKING

### **Week 1: Integration**
- Day 1-2: Config & Admin API
- Day 3-4: Admin features
- Day 5-6: User features

### **Week 2: Polish**
- Day 7-8: Polish & optimize
- Day 9: Testing & fixes
- Day 10: Build & deploy

---

## 🎯 SUCCESS METRICS

### **Completed when:**
- ✅ User can register & login
- ✅ User can browse products
- ✅ User can add to cart
- ✅ User can checkout
- ✅ User can track orders
- ✅ Admin can login
- ✅ Admin can manage products
- ✅ Admin can manage orders
- ✅ Admin can view stats
- ✅ App runs smoothly
- ✅ No critical bugs
- ✅ APK/AAB built

---

## 💡 PRO TIPS

1. **Test in Postman first** before implementing in Flutter
2. **Use debug prints** to understand API responses
3. **Handle errors gracefully** - don't let app crash
4. **Show loading states** - better UX
5. **Cache images** - faster loading
6. **Use const constructors** - better performance
7. **Format code regularly** - clean code
8. **Test on real device** - better than emulator
9. **Read backend docs** - understand API format
10. **Ask when stuck** - don't waste time

---

## 🔗 IMPORTANT LINKS

- Backend API Docs: `API_DOCUMENTATION_FLUTTER.md`
- Project Analysis: `FLUTTER_PROJECT_ANALYSIS.md`
- Action Plan: `FLUTTER_ACTION_PLAN.md`
- Deployment Guide: `DEPLOYMENT_GUIDE.md`

---

## 🎉 LET'S BUILD THIS!

**Current Step:** Day 1 - Critical Fixes  
**Next Step:** Update base URL & create AdminApiService  
**Timeline:** 10 days to completion  
**You got this!** 💪🚀

---

**Created:** 3 Desember 2025  
**By:** Cascade AI Assistant  
**For:** Flutter Development Phase
