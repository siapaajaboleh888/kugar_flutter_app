import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class AdminAuthService {
  late Dio _dio;
  String? _adminToken;

  AdminAuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: AppConstants.apiTimeout),
        receiveTimeout: const Duration(seconds: AppConstants.apiTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('DEBUG ADMIN: Making request to ${options.baseUrl}${options.path}');
          print('DEBUG ADMIN: Request data: ${options.data}');
          if (_adminToken != null) {
            options.headers['Authorization'] = 'Bearer $_adminToken';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('DEBUG ADMIN: Response status: ${response.statusCode}');
          print('DEBUG ADMIN: Response data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) async {
          print('DEBUG ADMIN: Error - ${error.message}');
          print('DEBUG ADMIN: Error response: ${error.response?.data}');
          if (error.response?.statusCode == 401) {
            await _clearAdminToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _loadAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    _adminToken = prefs.getString('admin_token');
  }

  Future<void> _clearAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
    await prefs.remove('admin_data');
    _adminToken = null;
  }

  Future<void> _setAdminToken(String token) async {
    _adminToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_token', token);
  }

  /// Admin login with fallback mechanism
  /// Will try:
  /// 1. /api/admin/login (preferred for admin)
  /// 2. /api/auth/login (fallback)
  Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    print('DEBUG ADMIN: Attempting admin login for email: $email');

    final requestData = {'email': email, 'password': password};

    // Try admin-specific endpoint first
    try {
      print('DEBUG ADMIN: Trying /admin/login endpoint');
      final response = await _dio.post(
        '/admin/login',
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('DEBUG ADMIN: /admin/login response status: ${response.statusCode}');
      print('DEBUG ADMIN: /admin/login response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        // Handle different response structures
        String? token;
        Map<String, dynamic>? adminData;
        
        if (data['data'] != null) {
          final responseData = data['data'] as Map<String, dynamic>;
          token = responseData['token'] as String?;
          adminData = responseData['user'] as Map<String, dynamic>?;
        } else if (data['token'] != null) {
          token = data['token'] as String?;
          adminData = data['user'] as Map<String, dynamic>?;
        }

        if (token != null) {
          await _setAdminToken(token);
          
          // Save admin data with role field
          if (adminData != null) {
            // Ensure role is set to 'admin'
            if (!adminData.containsKey('role') || adminData['role'] == null) {
              adminData['role'] = 'admin';
            }
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('admin_data', jsonEncode(adminData));
            print('DEBUG ADMIN: Saved admin_data: ${jsonEncode(adminData)}');
          }
          
          return {
            'success': true,
            'message': 'Login berhasil',
            'data': {
              'token': token,
              'admin': adminData,
            }
          };
        }
      }

      // If we get here, login failed
      final data = response.data as Map<String, dynamic>;
      return {
        'success': false,
        'message': data['message'] ?? 'Login gagal',
      };
    } on DioException catch (e) {
      print('DEBUG ADMIN: /admin/login failed - ${e.message}');
      print('DEBUG ADMIN: Status code: ${e.response?.statusCode}');
      
      // If 404, try fallback to /auth/login
      if (e.response?.statusCode == 404) {
        print('DEBUG ADMIN: Admin endpoint not found, trying /auth/login as fallback');
        return await _tryAuthLogin(email, password);
      }
      
      // For other errors, return error message
      final errorData = e.response?.data as Map<String, dynamic>?;
      return {
        'success': false,
        'message': errorData?['message'] ?? 'Terjadi kesalahan saat login',
      };
    }
  }

  /// Fallback to regular auth/login endpoint
  Future<Map<String, dynamic>> _tryAuthLogin(String email, String password) async {
    try {
      print('DEBUG ADMIN: Trying /auth/login endpoint');
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('DEBUG ADMIN: /auth/login response status: ${response.statusCode}');
      print('DEBUG ADMIN: /auth/login response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        // Handle different response structures
        String? token;
        Map<String, dynamic>? userData;
        
        if (data['data'] != null) {
          final responseData = data['data'] as Map<String, dynamic>;
          token = responseData['token'] as String?;
          userData = responseData['user'] as Map<String, dynamic>?;
        } else if (data['token'] != null) {
          token = data['token'] as String?;
          userData = data['user'] as Map<String, dynamic>?;
        }

        // Check if user has admin role
        if (userData != null) {
          final role = userData['role'] as String?;
          final isAdmin = role == 'admin' || role == 'administrator';
          
          if (!isAdmin) {
            return {
              'success': false,
              'message': 'Akun Anda tidak memiliki akses admin',
            };
          }
        }

        if (token != null) {
          await _setAdminToken(token);
          
          // Save admin data with role field
          if (userData != null) {
            // Ensure role is set to 'admin' (it should already be checked above)
            if (!userData.containsKey('role') || userData['role'] == null) {
              userData['role'] = 'admin';
            }
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('admin_data', jsonEncode(userData));
            print('DEBUG ADMIN: Saved admin_data from auth/login: ${jsonEncode(userData)}');
          }
          
          return {
            'success': true,
            'message': 'Login berhasil',
            'data': {
              'token': token,
              'admin': userData,
            }
          };
        }
      }

      final data = response.data as Map<String, dynamic>;
      return {
        'success': false,
        'message': data['message'] ?? 'Login gagal',
      };
    } on DioException catch (e) {
      print('DEBUG ADMIN: /auth/login also failed - ${e.message}');
      final errorData = e.response?.data as Map<String, dynamic>?;
      return {
        'success': false,
        'message': errorData?['message'] ?? 'Email atau password salah',
      };
    }
  }

  /// Logout admin
  Future<void> adminLogout() async {
    try {
      await _dio.post('/admin/logout');
    } catch (e) {
      print('DEBUG ADMIN: Error during logout: $e');
    } finally {
      await _clearAdminToken();
    }
  }

  /// Check if admin is logged in
  Future<bool> isAdminLoggedIn() async {
    await _loadAdminToken();
    return _adminToken != null;
  }

  /// Get current admin data
  Future<Map<String, dynamic>?> getAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    final adminDataStr = prefs.getString('admin_data');
    if (adminDataStr != null) {
      return jsonDecode(adminDataStr) as Map<String, dynamic>;
    }
    return null;
  }
}
