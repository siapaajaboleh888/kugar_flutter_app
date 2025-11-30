import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/services/api_service.dart';
import '../../domain/entities/user.dart';

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
          final user = User.fromJson(response['data'] as Map<String, dynamic>);
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
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
      final response = await _apiService.login(email, password);
      
      if (response['success'] == true && response['data'] != null) {
        final user = User.fromJson(response['data'] as Map<String, dynamic>);
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response['message']?.toString() ?? 'Login failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    print('DEBUG: AuthProvider.register called');
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('DEBUG: Calling API service register...');
      
      // TEMPORARY MOCK REGISTRATION FOR TESTING
      if (email.isNotEmpty && password.length >= 6 && name.isNotEmpty) {
        print('DEBUG: Using mock registration...');
        
        // Simulate API delay
        await Future.delayed(const Duration(seconds: 2));
        
        // Create mock user with correct int ID
        final mockUser = User(
          id: DateTime.now().millisecondsSinceEpoch,
          name: name,
          email: email,
          phone: phone,
          createdAt: DateTime.now(),
        );
        
        state = state.copyWith(
          user: mockUser,
          isAuthenticated: true,
          isLoading: false,
        );
        
        print('DEBUG: Mock registration successful');
        return;
      }
      
      // Original API call (commented for testing)
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      
      print('DEBUG: API response: $response');

      if (response['success'] == true) {
        print('DEBUG: Registration successful, attempting login...');
        await login(email, password);
      } else {
        print('DEBUG: Registration failed: ${response['message']}');
        state = state.copyWith(
          isLoading: false,
          error: response['message']?.toString() ?? 'Registration failed',
        );
      }
    } catch (e) {
      print('DEBUG: Registration exception: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await _clearAuth();
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
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(apiService);
});
