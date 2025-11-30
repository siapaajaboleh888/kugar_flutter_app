class AppConstants {
  // App Info
  static const String appName = 'KUGAR';
  static const String appVersion = '1.0.0';
  
  // API
  static const String apiBaseUrl = 'https://kugar.e-pinggirpapas-sumenep.com/api';
  static const int apiTimeout = 30;
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String cartKey = 'cart_items';
  static const String themeKey = 'theme_mode';
  
  // Pagination
  static const int defaultPageSize = 10;
  
  // Image Quality
  static const int imageQuality = 85;
  
  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 1);
}
