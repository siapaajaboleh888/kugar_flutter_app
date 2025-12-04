# Admin Models

This directory contains all data models for the Admin Panel.

## Models

### 1. `admin_user_model.dart`
User model untuk admin panel.

**Fields:**
- `id` (int) - User ID
- `name` (String) - User name
- `email` (String) - User email
- `phone` (String?) - Phone number (optional)
- `role` (String) - User role (user, admin, staff)
- `createdAt` (DateTime?) - Creation date

**Usage:**
```dart
final user = AdminUser.fromJson(jsonData);
final json = user.toJson();
```

### 2. `admin_product_model.dart`
Product model untuk admin panel.

**Fields:**
- `id` (int) - Product ID
- `title` (String) - Product title/name
- `text` (String) - Product description
- `price` (int) - Product price
- `image` (String?) - Image filename
- `imageUrl` (String?) - Full image URL
- `alamat` (String?) - Address
- `nomorHp` (String?) - Contact phone
- `createdAt` (DateTime?) - Creation date

**Helpers:**
- `formattedPrice` - Returns formatted price (Rp x.xxx)

**Usage:**
```dart
final product = AdminProduct.fromJson(jsonData);
print(product.formattedPrice); // Rp 15.000
```

### 3. `dashboard_stats_model.dart`
Dashboard statistics model.

**Main Model: `DashboardStats`**
- `users` (UserStats)
- `products` (ProductStats)
- `orders` (OrderStats)
- `revenue` (RevenueStats)
- `virtualTours` (VirtualTourStats)
- `charts` (ChartsData?)

**Nested Models:**
- `UserStats` - User statistics
- `ProductStats` - Product statistics
- `OrderStats` - Order statistics
- `RevenueStats` - Revenue statistics
- `VirtualTourStats` - Virtual tour statistics
- `ChartsData` - Chart data
- `RecentUser` - Recent user item
- `RecentProduct` - Recent product item
- `MonthlyRevenue` - Monthly revenue item

**Usage:**
```dart
final stats = DashboardStats.fromJson(jsonData);
print(stats.users.total); // 45
print(stats.revenue.formattedThisMonth); // Rp 5.000.000
```

### 4. `paginated_response_model.dart`
Generic models untuk API responses.

**PaginatedResponse<T>**
Generic model untuk paginated responses.

**Fields:**
- `success` (bool) - Request success status
- `message` (String?) - Response message
- `data` (List<T>) - List of items
- `currentPage` (int) - Current page number
- `lastPage` (int) - Total pages
- `perPage` (int) - Items per page
- `total` (int) - Total items

**Helpers:**
- `hasNextPage` - Check if has next page
- `hasPreviousPage` - Check if has previous page  
- `isEmpty` - Check if data is empty
- `isNotEmpty` - Check if data is not empty

**Usage:**
```dart
final response = PaginatedResponse<AdminUser>.fromJson(
  jsonData,
  (json) => AdminUser.fromJson(json),
);

print(response.currentPage); // 1
print(response.total); // 45
print(response.hasNextPage); // true
```

**ApiResponse<T>**
Generic model untuk single item responses.

**Fields:**
- `success` (bool) - Request success status
- `message` (String?) - Response message
- `data` (T?) - Single item
- `errors` (Map?) - Validation errors

**Usage:**
```dart
final response = ApiResponse<AdminUser>.fromJson(
  jsonData,
  (data) => AdminUser.fromJson(data),
);

if (response.success) {
  print(response.data?.name);
}
```

## Best Practices

### 1. Always handle null values
```dart
final user = AdminUser.fromJson(json);
final phone = user.phone ?? 'No phone'; // Use null-aware operator
```

### 2. Use try-catch when parsing
```dart
try {
  final user = AdminUser.fromJson(json);
} catch (e) {
  print('Error parsing user: $e');
}
```

### 3. Check success field
```dart
final response = ApiResponse.fromJson(json, ...);
if (response.success) {
  // Handle success
} else {
  // Handle error
  print(response.message);
}
```

### 4. Use type-safe models
```dart
// Good
final users = PaginatedResponse<AdminUser>.fromJson(...);

// Bad
final users = PaginatedResponse.fromJson(...); // Type not specified
```

## Examples

### Parsing Users List
```dart
final response = await adminService.getUsers();
final paginatedUsers = PaginatedResponse<AdminUser>.fromJson(
  response,
  (json) => AdminUser.fromJson(json),
);

for (final user in paginatedUsers.data) {
  print(user.name);
}
```

### Parsing Dashboard Stats
```dart
final response = await adminService.getDashboardStats();
if (response['success'] == true) {
  final stats = DashboardStats.fromJson(response['data']);
  print('Total Users: ${stats.users.total}');
  print('Revenue: ${stats.revenue.formattedThisMonth}');
}
```

### Creating/Updating User
```dart
final user = AdminUser(
  id: 1,
  name: 'John Doe',
  email: 'john@example.com',
  role: 'user',
);

final json = user.toJson();
await adminService.updateUser(user.id, json);
```

## Notes

- All models support JSON serialization/deserialization
- All models are immutable (final fields)
- All models have `fromJson` factory constructors
- All models have `toJson` methods
- Some models have `copyWith` methods for easy updates
- Optional fields are nullable (String?, DateTime?, etc.)
