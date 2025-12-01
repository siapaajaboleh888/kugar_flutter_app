import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class ApiService {
  late Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: AppConstants.apiTimeout),
        receiveTimeout: const Duration(seconds: AppConstants.apiTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          // Add CORS headers for Flutter Web
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        },
        validateStatus: (status) {
          // Accept all status codes to handle errors manually
          return status != null && status < 500;
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('DEBUG: Making request to ${options.baseUrl}${options.path}');
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          print('DEBUG: Interceptor error - ${error.message}');
          if (error.response?.statusCode == 401) {
            await _clearToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    _token = null;
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  // Authentication Endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('DEBUG LOGIN: Attempting login with email: $email');
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      print('DEBUG LOGIN: Response status: ${response.statusCode}');
      print('DEBUG LOGIN: Response data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      if (response.statusCode == 200 && data['data']?['token'] != null) {
        await setToken(data['data']['token'] as String);
      }
      return data;
    } on DioException catch (e) {
      print(
        'DEBUG LOGIN: DioException - Status: ${e.response?.statusCode}, Message: ${e.message}',
      );
      print('DEBUG LOGIN: Response data: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post('/auth/logout');
      await _clearToken();
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      await _clearToken();
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _dio.put('/users/profile', data: userData);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Product Endpoints
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
        if (search != null) 'search': search,
        if (sortBy != null) 'sort_by': sortBy,
        if (sortOrder != null) 'sort_order': sortOrder,
      };

      print('DEBUG API: Requesting /produk with params: $queryParams');
      print('DEBUG API: Full URL: ${_dio.options.baseUrl}/produk');
      final response = await _dio.get('/produk', queryParameters: queryParams);
      print('DEBUG API: Response status: ${response.statusCode}');
      print('DEBUG API: Response data: ${response.data}');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print(
        'DEBUG API: DioException - Status: ${e.response?.statusCode}, Message: ${e.message}',
      );
      print('DEBUG API: Response data: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getProductDetail(int id) async {
    try {
      final response = await _dio.get('/produk/$id');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getCategories() async {
    try {
      // Try the API endpoint, return empty if not found
      final response = await _dio.get('/produk/categories');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // If endpoint doesn't exist, return empty categories list
      print('DEBUG: Categories endpoint not available, returning empty list');
      return {'data': []};
    }
  }

  Future<Map<String, dynamic>> getFeaturedProducts() async {
    try {
      final response = await _dio.get('/products/featured');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Order Endpoints
  Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    try {
      final response = await _dio.post('/orders', data: orderData);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getOrders({int page = 1, String? status}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        if (status != null) 'status': status,
      };

      final response = await _dio.get('/orders', queryParameters: queryParams);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getOrderDetail(String orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    try {
      final response = await _dio.put(
        '/orders/$orderId/status',
        data: {'status': status},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId/track');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Cart Endpoints
  Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await _dio.get('/orders/cart');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> addToCart(Map<String, dynamic> cartItem) async {
    try {
      final response = await _dio.post('/orders/cart', data: cartItem);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateCartItem(
    int itemId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/orders/cart/$itemId', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> removeFromCart(int itemId) async {
    try {
      final response = await _dio.delete('/orders/cart/$itemId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> clearCart() async {
    try {
      final response = await _dio.delete('/orders/cart');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Blog/Content Endpoints
  Future<Map<String, dynamic>> getPosts({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
      };

      final response = await _dio.get('/posts', queryParameters: queryParams);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getPostDetail(int id) async {
    try {
      final response = await _dio.get('/posts/$id');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getPostCategories() async {
    try {
      final response = await _dio.get('/posts/categories');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Virtual Tour Endpoints
  Future<Map<String, dynamic>> getVirtualTours() async {
    try {
      final response = await _dio.get('/virtual-tours');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getVirtualTourDetail(int id) async {
    try {
      final response = await _dio.get('/virtual-tours/$id');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Review Endpoints
  Future<Map<String, dynamic>> getProductReviews(
    int productId, {
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/products/$productId/reviews',
        queryParameters: {'page': page},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> createReview(
    Map<String, dynamic> reviewData,
  ) async {
    try {
      final response = await _dio.post('/reviews', data: reviewData);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateReview(
    int reviewId,
    Map<String, dynamic> reviewData,
  ) async {
    try {
      final response = await _dio.put('/reviews/$reviewId', data: reviewData);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> deleteReview(int reviewId) async {
    try {
      final response = await _dio.delete('/reviews/$reviewId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Utility Endpoints
  Future<Map<String, dynamic>> getAbout() async {
    try {
      final response = await _dio.get('/content/about');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await _dio.get('/settings');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> contactSupport(
    Map<String, dynamic> messageData,
  ) async {
    try {
      final response = await _dio.post('/support/contact', data: messageData);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data as Map<String, dynamic>?;

        if (data != null && data['message'] != null) {
          return data['message'].toString();
        }

        switch (statusCode) {
          case 400:
            return 'Bad request. Please check your input.';
          case 401:
            return 'Unauthorized. Please login again.';
          case 403:
            return 'Forbidden. You don\'t have permission to access this resource.';
          case 404:
            return 'Resource not found.';
          case 422:
            if (data != null && data['errors'] != null) {
              final errors = data['errors'] as Map<String, dynamic>;
              return errors.values.first.first.toString();
            }
            return 'Validation error.';
          case 429:
            return 'Too many requests. Please try again later.';
          case 500:
            return 'Server error. Please try again later.';
          default:
            return 'HTTP Error: $statusCode';
        }
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return 'No internet connection. Please check your network.';
        }
        return 'An unexpected error occurred: ${error.message}';
      default:
        return 'An unknown error occurred.';
    }
  }
}
