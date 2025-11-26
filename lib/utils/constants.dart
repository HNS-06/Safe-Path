class AppConstants {
  // App Information
  static const String appName = 'SafePath';
  static const String appVersion = '1.0.0';
  
  // API Constants
  static const String baseUrl = 'https://api.safepath.com';
  static const int apiTimeout = 30;
  
  // Map Constants
  static const double defaultMapZoom = 14.0;
  static const double maxMapZoom = 18.0;
  static const double minMapZoom = 10.0;
  static const double safetyRadiusKm = 5.0;
  
  // Location Constants
  static const int locationUpdateInterval = 5000; // milliseconds
  static const double locationAccuracy = 50.0; // meters
  
  // Safety Thresholds
  static const double highSafetyThreshold = 4.0;
  static const double mediumSafetyThreshold = 2.5;
  static const double lowSafetyThreshold = 1.5;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Storage Keys
  static const String userPrefsKey = 'user_preferences';
  static const String authTokenKey = 'auth_token';
  static const String lastLocationKey = 'last_location';
  static const String reportsCacheKey = 'reports_cache';
}

class RouteNames {
  static const String home = '/';
  static const String map = '/map';
  static const String report = '/report';
  static const String routes = '/routes';
  static const String profile = '/profile';
  static const String settings = '/settings';
}