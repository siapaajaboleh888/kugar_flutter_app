import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Redirect to admin login if not authenticated
/// Auto-redirect admins to dashboard
Future<String?> adminAuthRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  final prefs = await SharedPreferences.getInstance();
  final adminToken = prefs.getString('admin_token');
  final adminDataStr = prefs.getString('admin_data');
  
  final isAdminRoute = state.matchedLocation.startsWith('/admin');
  final isLoginRoute = state.matchedLocation == '/admin/login';
  final isRootOrHome = state.matchedLocation == '/' || 
                       state.matchedLocation == '/home' ||
                       state.matchedLocation == '/splash';
  
  print('=== ADMIN AUTH REDIRECT DEBUG ===');
  print('Current location: ${state.matchedLocation}');
  print('Admin token exists: ${adminToken != null}');
  print('Admin data exists: ${adminDataStr != null}');
  print('Is admin route: $isAdminRoute');
  print('Is login route: $isLoginRoute');
  print('Is root/home/splash: $isRootOrHome');
  
  // Check if user is admin
  bool isAdmin = false;
  if (adminToken != null) {
    // Primary check: if admin_token exists, user is admin
    isAdmin = true;
    
    // Secondary check: verify role in admin_data if available
    if (adminDataStr != null) {
      try {
        final adminData = jsonDecode(adminDataStr) as Map<String, dynamic>;
        print('Admin data: $adminData');
        final role = adminData['role'] as String?;
        print('Admin role: $role');
        // Token exists but role check failed - still consider as admin since token exists
        if (role == null || (role != 'admin' && role != 'administrator')) {
          print('WARNING: Admin token exists but role is not admin: $role');
        }
      } catch (e) {
        print('Error parsing admin data: $e');
      }
    }
  }
  
  print('Is admin: $isAdmin');
  
  // If admin is logged in and tries to access root/home/splash, redirect to admin dashboard
  if (isAdmin && isRootOrHome) {
    print('-> Redirecting admin from root/home/splash to dashboard');
    return '/admin/dashboard';
  }
  
  // If admin route but not logged in, redirect to admin login
  if (isAdminRoute && !isLoginRoute && !isAdmin) {
    print('-> Redirecting to admin login (admin route without auth)');
    return '/admin/login';
  }
  
  // If already logged in as admin and trying to access login, redirect to dashboard
  if (isLoginRoute && isAdmin) {
    print('-> Redirecting to dashboard (already logged in)');
    return '/admin/dashboard';
  }
  
  print('-> No redirect needed');
  return null; // No redirect needed
}
