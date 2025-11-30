import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/product/product_catalog_page.dart';
import '../../presentation/pages/product/product_detail_page.dart';
import '../../presentation/pages/cart/cart_page.dart';
import '../../presentation/pages/checkout/checkout_page.dart';
import '../../presentation/pages/tracking/order_tracking_page.dart';
import '../../presentation/pages/qr/qr_scanner_page.dart' show QRScannerPage;
import '../../presentation/pages/virtual_tour/virtual_tour_page.dart';
import '../../presentation/pages/chat/chat_support_page.dart';
import '../../presentation/pages/reviews/reviews_page.dart';
import '../../presentation/pages/splash/splash_page.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String productCatalog = '/products';
  static const String productDetail = '/products/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String tracking = '/tracking/:orderId';
  static const String orderTracking = '/order-tracking/:orderId';
  static const String orders = '/orders';
  static const String qrScanner = '/qr-scanner';
  static const String virtualTour = '/virtual-tour';
  static const String chatSupport = '/chat';
  static const String reviews = '/reviews/:productId';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: productCatalog,
        name: 'productCatalog',
        builder: (context, state) => const ProductCatalogPage(),
      ),
      GoRoute(
        path: productDetail,
        name: 'productDetail',
        builder: (context, state) {
          final productId = int.parse(state.pathParameters['id']!);
          return ProductDetailPage(productId: productId);
        },
      ),
      GoRoute(
        path: cart,
        name: 'cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: checkout,
        name: 'checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: tracking,
        name: 'tracking',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderTrackingPage(orderId: orderId);
        },
      ),
      GoRoute(
        path: orderTracking,
        name: 'orderTracking',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderTrackingPage(orderId: orderId);
        },
      ),
      GoRoute(
        path: orders,
        name: 'orders',
        builder: (context, state) {
          // TODO: Create orders list page
          return const Scaffold(
            body: Center(
              child: Text('Orders Page - Coming Soon'),
            ),
          );
        },
      ),
      GoRoute(
        path: qrScanner,
        name: 'qrScanner',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('QR Scanner - Coming Soon'),
          ),
        ),
      ),
      GoRoute(
        path: virtualTour,
        name: 'virtualTour',
        builder: (context, state) => const VirtualTourPage(),
      ),
      GoRoute(
        path: chatSupport,
        name: 'chatSupport',
        builder: (context, state) => const ChatSupportPage(),
      ),
      GoRoute(
        path: reviews,
        name: 'reviews',
        builder: (context, state) {
          final productId = int.parse(state.pathParameters['productId']!);
          return ReviewsPage(productId: productId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.toString()}'),
      ),
    ),
  );
}
