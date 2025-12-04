class PaginatedResponse<T> {
  final bool success;
  final String? message;
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginatedResponse({
    required this.success,
    this.message,
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;
}

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  factory ApiResponse.success({String? message, T? data}) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
    );
  }

  factory ApiResponse.error({String? message, Map<String, dynamic>? errors}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
    );
  }
}
