import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    final authState = ref.read(authProvider);
    
    if (authState.isAuthenticated && mounted) {
      // Get token directly from authState instead of SharedPreferences
      final token = authState.token;
      
      // Also get from SharedPreferences for user data
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('user_data');
      
      print('=== LOGIN PAGE DEBUG ===');
      print('User authenticated: ${authState.isAuthenticated}');
      print('Token from authState: $token');
      print('Token exists: ${token != null}');
      print('User data from prefs: $userDataStr');
      
      bool isAdmin = false;
      if (userDataStr != null) {
        try {
          final userData = jsonDecode(userDataStr) as Map<String, dynamic>;
          final role = userData['role'] as String?;
          print('User role: $role');
          isAdmin = role == 'admin' || role == 'administrator';
          print('Is admin: $isAdmin');
        } catch (e) {
          print('Error parsing user data: $e');
        }
      }
      
      print('Final check - isAdmin: $isAdmin, token != null: ${token != null}');
      
      if (isAdmin && token != null) {
        print('Admin detected! Redirecting to admin dashboard');
        
        // Copy token to admin storage
        await prefs.setString('admin_token', token);
        if (userDataStr != null) {
          await prefs.setString('admin_data', userDataStr);
        }
        
        print('Admin token and data saved to admin storage');
        
        // Clear regular user storage
        await prefs.remove('token');
        await prefs.remove('user_data');
        
        print('Regular user storage cleared');
        
        // Navigate to admin dashboard
        if (mounted) {
          print('Navigating to admin dashboard...');
          context.go(AppRouter.adminDashboard);
        }
      } else {
        print('Regular user, redirecting to home');
        if (mounted) {
          context.go(AppRouter.home);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 50,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Selamat Datang',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Masuk ke akun KUGAR Anda',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(
                  onPressed: authState.isLoading ? null : _login,
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Masuk'),
                ),
                const SizedBox(height: 32),
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.go(AppRouter.register);
                    },
                    child: Text(
                      'Belum punya akun? Daftar',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
