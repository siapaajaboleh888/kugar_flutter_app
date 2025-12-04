import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';

/// Provider for AdminService singleton
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

/// Provider for dashboard stats
final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  return await adminService.getDashboardStats();
});

/// Provider for users list
final usersListProvider = FutureProvider.family<Map<String, dynamic>, UsersFilter>(
  (ref, filter) async {
    final adminService = ref.watch(adminServiceProvider);
    return await adminService.getUsers(
      page: filter.page,
      perPage: filter.perPage,
      search: filter.search,
      role: filter.role,
    );
  },
);

/// Provider for products list
final productsListProvider = FutureProvider.family<Map<String, dynamic>, ProductsFilter>(
  (ref, filter) async {
    final adminService = ref.watch(adminServiceProvider);
    return await adminService.getProducts(
      page: filter.page,
      perPage: filter.perPage,
      search: filter.search,
      category: filter.category,
    );
  },
);

/// Filter class for users
class UsersFilter {
  final int page;
  final int perPage;
  final String? search;
  final String? role;

  const UsersFilter({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.role,
  });

  UsersFilter copyWith({
    int? page,
    int? perPage,
    String? search,
    String? role,
  }) {
    return UsersFilter(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      search: search ?? this.search,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UsersFilter &&
        other.page == page &&
        other.perPage == perPage &&
        other.search == search &&
        other.role == role;
  }

  @override
  int get hashCode =>
      page.hashCode ^ perPage.hashCode ^ search.hashCode ^ role.hashCode;
}

/// Filter class for products
class ProductsFilter {
  final int page;
  final int perPage;
  final String? search;
  final String? category;

  const ProductsFilter({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.category,
  });

  ProductsFilter copyWith({
    int? page,
    int? perPage,
    String? search,
    String? category,
  }) {
    return ProductsFilter(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      search: search ?? this.search,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductsFilter &&
        other.page == page &&
        other.perPage == perPage &&
        other.search == search &&
        other.category == category;
  }

  @override
  int get hashCode =>
      page.hashCode ^
      perPage.hashCode ^
      search.hashCode ^
      category.hashCode;
}
