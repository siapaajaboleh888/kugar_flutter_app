import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../data/services/api_service.dart';
import '../../domain/entities/user.dart';
import 'api_provider.dart';

class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token != null) {
        await _apiService.setToken(token);
        final response = await _apiService.getProfile();
        
        if (response['success'] == true && response['data'] != null) {
          try {
            final user = User.fromJson(response['data'] as Map<String, dynamic>);
            state = state.copyWith(
              user: user,
              isAuthenticated: true,
              isLoading: false,
            );
          } catch (e) {
            print('DEBUG: Error parsing user data in checkAuthStatus: $e');
            await _clearAuth();
          }
        } else {
          await _clearAuth();
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      await _clearAuth();
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('DEBUG: Starting login API call for email: $email');
      final response = await _apiService.login(email, password);
      print('DEBUG: Login API response: $response');
      
      // Handle different response formats
      bool isSuccess = false;
      Map<String, dynamic>? userData;
      String? token;
      String? errorMessage;
      
      // Check for success in various response formats
      if (response['success'] == true || response['status'] == 'success') {
        isSuccess = true;
        // Try to extract user data and token from different locations
        if (response['data'] != null) {
          final data = response['data'] as Map<String, dynamic>;
          userData = data['user'] as Map<String, dynamic>?;
          token = data['token'] as String?;
          if (userData == null) {
            userData = data as Map<String, dynamic>?;
          }
        } else if (response['user'] != null) {
          userData = response['user'] as Map<String, dynamic>?;
          token = response['token'] as String? ?? response['access_token'] as String?;
        } else if (response['access_token'] != null || response['token'] != null) {
          isSuccess = true;
          userData = response as Map<String, dynamic>?;
          token = response['token'] as String? ?? response['access_token'] as String?;
        }
      } else if (response['access_token'] != null || response['token'] != null) {
        isSuccess = true;
        userData = response['user'] as Map<String, dynamic>?;
        token = response['token'] as String? ?? response['access_token'] as String?;
      }
      
      if (!isSuccess) {
        errorMessage = response['message']?.toString() ?? 
                      response['error']?.toString() ?? 
                      'Login gagal - periksa kembali email dan password Anda';
      }

      print('DEBUG: Extracted token: $token');

      if (isSuccess && userData != null) {
        print('DEBUG: Login successful, user data: $userData');
        try {
          final user = User.fromJson(userData);
          state = state.copyWith(
            user: user,
            token: token,
            isAuthenticated: true,
            isLoading: false,
          );
          print('DEBUG: User logged in successfully: ${user.name}');
        } catch (e) {
          print('DEBUG: Error parsing user data: $e');
          // Create fallback user
          final fallbackUser = User(
            id: (userData['id'] as int?) ?? 0,
            name: userData['name'] ?? email.split('@')[0],
            email: email,
            createdAt: DateTime.now(),
          );
          state = state.copyWith(
            user: fallbackUser,
            isAuthenticated: true,
            isLoading: false,
          );
        }
      } else if (isSuccess) {
        // Success but no user data - create minimal user
        print('DEBUG: Login successful but no user data, creating minimal user.');
        final user = User(
          id: 0,
          name: email.split('@')[0],
          email: email,
          createdAt: DateTime.now(),
        );
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        print('DEBUG: Login failed: $errorMessage');
        state = state.copyWith(
          isLoading: false,
          error: errorMessage,
        );
      }
    } catch (e) {
      print('DEBUG: Login exception: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan saat login: ${e.toString()}',
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('DEBUG: Starting registration API call...');
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      
      print('DEBUG: Registration API response: $response');

      // Handle different response formats
      bool isSuccess = false;
      String? errorMessage;
      
      if (response['success'] == true) {
        isSuccess = true;
      } else if (response['status'] == 'success') {
        isSuccess = true;
      } else if (response['message']?.toString().toLowerCase().contains('success') == true) {
        isSuccess = true;
      }

      if (!isSuccess) {
        errorMessage = response['message']?.toString() ?? 
                      response['error']?.toString() ?? 
                      'Registration failed';
      }

      if (isSuccess) {
        print('DEBUG: Registration successful, attempting auto login...');
        // Auto login after successful registration
        await login(email, password);
      } else {
        print('DEBUG: Registration failed: $errorMessage');
        state = state.copyWith(
          isLoading: false,
          error: errorMessage,
        );
      }
    } catch (e) {
      print('DEBUG: Registration exception: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Registration error: ${e.toString()}',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
      print('DEBUG: Logout API failed: $e');
    } finally {
      await _clearAuth();
      print('DEBUG: Logout completed, state reset');
    }
  }

  Future<void> _clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(apiService);
});
