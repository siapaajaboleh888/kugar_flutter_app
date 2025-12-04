class DashboardStats {
  final UserStats users;
  final ProductStats products;
  final OrderStats orders;
  final RevenueStats revenue;
  final VirtualTourStats virtualTours;
  final ChartsData? charts;

  DashboardStats({
    required this.users,
    required this.products,
    required this.orders,
    required this.revenue,
    required this.virtualTours,
    this.charts,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      users: UserStats.fromJson(json['users'] as Map<String, dynamic>),
      products: ProductStats.fromJson(json['products'] as Map<String, dynamic>),
      orders: OrderStats.fromJson(json['orders'] as Map<String, dynamic>),
      revenue: RevenueStats.fromJson(json['revenue'] as Map<String, dynamic>),
      virtualTours: VirtualTourStats.fromJson(
        json['virtual_tours'] as Map<String, dynamic>,
      ),
      charts: json['charts'] != null
          ? ChartsData.fromJson(json['charts'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UserStats {
  final int total;
  final int admins;
  final List<RecentUser> recent;

  UserStats({
    required this.total,
    required this.admins,
    required this.recent,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      total: json['total'] as int? ?? 0,
      admins: json['admins'] as int? ?? 0,
      recent: (json['recent'] as List<dynamic>? ?? [])
          .map((e) => RecentUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RecentUser {
  final int id;
  final String name;
  final String email;
  final DateTime? createdAt;

  RecentUser({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
  });

  factory RecentUser.fromJson(Map<String, dynamic> json) {
    return RecentUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

class ProductStats {
  final int total;
  final double averagePrice;
  final int minPrice;
  final int maxPrice;
  final List<RecentProduct> recent;

  ProductStats({
    required this.total,
    required this.averagePrice,
    required this.minPrice,
    required this.maxPrice,
    required this.recent,
  });

  factory ProductStats.fromJson(Map<String, dynamic> json) {
    return ProductStats(
      total: json['total'] as int? ?? 0,
      averagePrice: (json['average_price'] as num?)?.toDouble() ?? 0.0,
      minPrice: json['min_price'] as int? ?? 0,
      maxPrice: json['max_price'] as int? ?? 0,
      recent: (json['recent'] as List<dynamic>? ?? [])
          .map((e) => RecentProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RecentProduct {
  final int id;
  final String nama;
  final int harga;
  final DateTime? createdAt;

  RecentProduct({
    required this.id,
    required this.nama,
    required this.harga,
    this.createdAt,
  });

  factory RecentProduct.fromJson(Map<String, dynamic> json) {
    return RecentProduct(
      id: json['id'] as int,
      nama: json['nama'] as String? ?? json['title'] as String? ?? '',
      harga: json['harga'] as int? ?? json['price'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

class OrderStats {
  final int total;
  final int pending;
  final int processing;
  final int completed;
  final int cancelled;

  OrderStats({
    required this.total,
    required this.pending,
    required this.processing,
    required this.completed,
    required this.cancelled,
  });

  factory OrderStats.fromJson(Map<String, dynamic> json) {
    return OrderStats(
      total: json['total'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      processing: json['processing'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      cancelled: json['cancelled'] as int? ?? 0,
    );
  }
}

class RevenueStats {
  final int thisMonth;
  final int total;
  final String formattedThisMonth;
  final String formattedTotal;

  RevenueStats({
    required this.thisMonth,
    required this.total,
    required this.formattedThisMonth,
    required this.formattedTotal,
  });

  factory RevenueStats.fromJson(Map<String, dynamic> json) {
    return RevenueStats(
      thisMonth: json['this_month'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      formattedThisMonth: json['formatted_this_month'] as String? ?? 'Rp 0',
      formattedTotal: json['formatted_total'] as String? ?? 'Rp 0',
    );
  }
}

class VirtualTourStats {
  final int total;

  VirtualTourStats({required this.total});

  factory VirtualTourStats.fromJson(Map<String, dynamic> json) {
    return VirtualTourStats(
      total: json['total'] as int? ?? 0,
    );
  }
}

class ChartsData {
  final List<MonthlyRevenue> monthlyRevenue;

  ChartsData({required this.monthlyRevenue});

  factory ChartsData.fromJson(Map<String, dynamic> json) {
    return ChartsData(
      monthlyRevenue: (json['monthly_revenue'] as List<dynamic>? ?? [])
          .map((e) => MonthlyRevenue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MonthlyRevenue {
  final String month;
  final int revenue;
  final int orders;

  MonthlyRevenue({
    required this.month,
    required this.revenue,
    required this.orders,
  });

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenue(
      month: json['month'] as String,
      revenue: json['revenue'] as int? ?? 0,
      orders: json['orders'] as int? ?? 0,
    );
  }
}
