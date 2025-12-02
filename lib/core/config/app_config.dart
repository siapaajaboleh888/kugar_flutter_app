import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'KUGAR';
  
  // Base URLs
  static const String localBaseUrl = 'http://wisatalembung.test';
  static const String emulatorBaseUrl = 'http://10.0.2.2';
  static const String deviceBaseUrl = 'http://192.168.1.x'; // Ganti dengan IP lokal Anda
  
  // Port untuk Laravel (default: 80 untuk HTTP, 443 untuk HTTPS)
  static const int serverPort = 80;
  
  // API Endpoints
  static const String apiPath = '/api';
  
  // Get base URL based on environment
  static String get baseUrl {
    final base = kDebugMode ? emulatorBaseUrl : localBaseUrl;
    final port = serverPort != 80 ? ':$serverPort' : '';
    return '$base$port$apiPath';
  }
  
  // Image base URL
  static String get imageBaseUrl {
    final base = kDebugMode ? emulatorBaseUrl : localBaseUrl;
    final port = serverPort != 80 ? ':$serverPort' : '';
    return '$base$port';
  }
  
  // Timeout
  static const int connectTimeout = 30000; // 30 detik
  static const int receiveTimeout = 30000; // 30 detik
}
