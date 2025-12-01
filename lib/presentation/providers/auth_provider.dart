import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../data/services/api_service.dart';
import '../../domain/entities/user.dart';
import 'api_provider.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
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
      String? errorMessage;
      
      if (response['success'] == true) {
        isSuccess = true;
        final data = response['data'] as Map<String, dynamic>?;
        if (data != null) {
          userData = data['user'] as Map<String, dynamic>?;
          print('DEBUG: Extracted user from data[\'user\']: $userData');
        }
      } else if (response['status'] == 'success') {
        isSuccess = true;
        userData = (response['data'] ?? response['user']) as Map<String, dynamic>?;
      } else if (response['access_token'] != null || response['token'] != null) {
        isSuccess = true;
        userData = (response['user'] ?? response) as Map<String, dynamic>?;
      } else if (response['user'] != null) {
        // Handle case where user data is directly in response
        isSuccess = true;
        userData = response['user'] as Map<String, dynamic>?;
        print('DEBUG: Found user data in response[\'user\']: $userData');
      }
      
      if (!isSuccess) {
        errorMessage = response['message']?.toString() ?? 
                      response['error']?.toString() ?? 
                      'Login failed';
      }

      if (isSuccess && userData != null) {
        print('DEBUG: Login successful, user data: $userData');
        print('DEBUG: User data type: ${userData.runtimeType}');
        print('DEBUG: User name from data: ${userData['name']}');
        try {
          final user = User.fromJson(userData);
          print('DEBUG: User object created: ${user.toString()}');
          print('DEBUG: User.name property: "${user.name}"');
          print('DEBUG: User.email property: "${user.email}"');
          print('DEBUG: About to update state...');
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
          print('DEBUG: State updated - isAuthenticated: ${state.isAuthenticated}, user.name: "${state.user?.name}"');
        } catch (e) {
          print('DEBUG: Error creating user from JSON: $e');
          // Create minimal user if JSON parsing fails
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
          print('DEBUG: Fallback user created: ${fallbackUser.email}, name: ${fallbackUser.name}');
        }
      } else if (isSuccess) {
        // Success but no user data - create minimal user
        print('DEBUG: Login successful but no user data, creating minimal user.');
        final user = User(
          id: (response['id'] as int?) ?? 0,
          name: response['name'] ?? email.split('@')[0],
          email: email,
          createdAt: DateTime.now(),
        );
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        print('DEBUG: Minimal user created: ${user.email}');
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
        error: 'Login error: ${e.toString()}',
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
