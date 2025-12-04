import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_auth_service.dart';

/// Provider for AdminAuthService singleton
final adminAuthServiceProvider = Provider<AdminAuthService>((ref) {
  return AdminAuthService();
});

/// Provider for admin login status
final adminLoginStatusProvider = FutureProvider<bool>((ref) async {
  final adminAuthService = ref.watch(adminAuthServiceProvider);
  return await adminAuthService.isAdminLoggedIn();
});

/// Provider for admin data
final adminDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final adminAuthService = ref.watch(adminAuthServiceProvider);
  return await adminAuthService.getAdminData();
});
