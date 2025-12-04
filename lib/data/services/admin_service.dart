import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  late Dio _dio;
  String? _token;

  AdminService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: AppConstants.apiTimeout),
        receiveTimeout: const Duration(seconds: AppConstants.apiTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _loadToken();
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          print('DEBUG ADMIN SERVICE: ${options.method} ${options.path}');
          handler.next(options);
        },
        onError: (error, handler) {
          print('DEBUG ADMIN SERVICE ERROR: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('admin_token');
  }

  // ============ USER MANAGEMENT ============
  
  /// Get all users with pagination
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int perPage = 10,
    String? search,
    String? role,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/users',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (search != null) 'search': search,
          if (role != null) 'role': role,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception(response.data['message'] ?? 'Failed to fetch users');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get user by ID
  Future<Map<String, dynamic>> getUser(int id) async {
    try {
      final response = await _dio.get('/admin/users/$id');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception(response.data['message'] ?? 'Failed to fetch user');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new user
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/admin/users', data: userData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception(response.data['message'] ?? 'Failed to create user');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user
  Future<Map<String, dynamic>> updateUser(
    int id,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _dio.put('/admin/users/$id', data: userData);
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception(response.data['message'] ?? 'Failed to update user');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete user
  Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final response = await _dio.delete('/admin/users/$id');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception(response.data['message'] ?? 'Failed to delete user');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Activate user
  Future<Map<String, dynamic>> activateUser(int id) async {
    try {
      final response = await _dio.post('/admin/users/$id/activate');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception(response.data['message'] ?? 'Failed to activate user');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Deactivate user
  Future<Map<String, dynamic>> deactivateUser(int id) async {
    try {
      final response = await _dio.post('/admin/users/$id/deactivate');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception(response.data['message'] ?? 'Failed to deactivate user');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ PRODUCT MANAGEMENT ============
  
  /// Get all products with pagination
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int perPage = 10,
    String? search,
    String? category,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/products',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (search != null) 'search': search,
          if (category != null) 'category': category,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception(response.data['message'] ?? 'Failed to fetch products');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get product by ID
  Future<Map<String, dynamic>> getProduct(int id) async {
    try {
      final response = await _dio.get('/admin/products/$id');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception(response.data['message'] ?? 'Failed to fetch product');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new product
  Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> productData,
  ) async {
    try {
      final response = await _dio.post('/admin/products', data: productData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception(response.data['message'] ?? 'Failed to create product');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update product
  Future<Map<String, dynamic>> updateProduct(
    int id,
    Map<String, dynamic> productData,
  ) async {
    try {
      final response = await _dio.put('/admin/products/$id', data: productData);
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception(response.data['message'] ?? 'Failed to update product');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete product
  Future<Map<String, dynamic>> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('/admin/products/$id');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception(response.data['message'] ?? 'Failed to delete product');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload product image
  Future<Map<String, dynamic>> uploadProductImage(
    int productId,
    String filePath,
  ) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post(
        '/admin/products/$productId/upload-image',
        data: formData,
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception(response.data['message'] ?? 'Failed to upload image');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ DASHBOARD STATS ============
  
  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/admin/statistics');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception(
        response.data['message'] ?? 'Failed to fetch dashboard stats',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ ERROR HANDLING ============
  
  String _handleError(DioException error) {
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    }
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'An error occurred: ${error.message}';
    }
  }
}
