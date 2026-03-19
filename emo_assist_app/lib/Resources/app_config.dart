// lib/Resources/app_config.dart
/// Environment configuration for API endpoints
enum Environment { development, production }

class AppConfig {
  static const Environment _currentEnvironment = Environment.development;

  static Environment get currentEnvironment => _currentEnvironment;

  // Main .NET backend URL
  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
         return 'http://182.180.159.89:5104';
       // return 'http://192.168.100.4:5104';
      case Environment.production:
        return 'https://your-production-domain/api/v1';
    }
  }

  /// Single multimodal analyze API (text, audio, image, video)
  static String get multimodal_analyze_ApiUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://182.180.159.89:8003';
      case Environment.production:
        return 'https://your-analyze-production-domain';
    }
  }

  static bool get isProduction => _currentEnvironment == Environment.production;
  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;

  // API Configuration
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);
  static const Duration downloadTimeout = Duration(minutes: 5);

  // App Configuration
  static const String appName = 'Emo Assist';
  static const String appVersion = '1.0.0';

  // Debug settings
  static bool get enableLogging => !isProduction;
  static bool get enableDebugMode => isDevelopment;

  /// Get environment-specific configuration
  static Map<String, dynamic> get config {
    return {
      'environment': _currentEnvironment.name,
      'baseUrl': baseUrl,
      'analyzeApiUrl': multimodal_analyze_ApiUrl,
      'isProduction': isProduction,
      'isDevelopment': isDevelopment,
      'enableLogging': enableLogging,
      'enableDebugMode': enableDebugMode,
      'appName': appName,
      'appVersion': appVersion,
    };
  }

  /// Print current configuration (for debugging)
  static void printConfig() {
    if (enableLogging) {
      print('=== App Configuration ===');
      config.forEach((key, value) {
        print('$key: $value');
      });
      print('========================');
    }
  }
}
