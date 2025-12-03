import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/pages/admin/auth/admin_login_page.dart';
import '../../presentation/pages/admin/dashboard/admin_dashboard_page.dart';
import '../../presentation/pages/admin/users/admin_users_page.dart';
import '../../presentation/pages/admin/orders/admin_orders_page.dart';
import '../../presentation/pages/admin/chats/admin_chats_page.dart';

class AdminRouter {
  static const String login = '/admin/login';
  static const String dashboard = '/admin/dashboard';
  static const String users = '/admin/users';
  static const String orders = '/admin/orders';
  static const String chats = '/admin/chats';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: login,
        name: 'adminLogin',
        builder: (context, state) => const AdminLoginPage(),
      ),
      GoRoute(
        path: dashboard,
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: users,
        name: 'adminUsers',
        builder: (context, state) => const AdminUsersPage(),
      ),
      GoRoute(
        path: orders,
        name: 'adminOrders',
        builder: (context, state) => const AdminOrdersPage(),
      ),
      GoRoute(
        path: chats,
        name: 'adminChats',
        builder: (context, state) => const AdminChatsPage(),
      ),
    ],
  );
}
