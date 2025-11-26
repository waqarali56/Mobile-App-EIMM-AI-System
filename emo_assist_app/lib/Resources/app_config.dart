/// Environment configuration for API endpoints
enum Environment { development, production }

class AppConfig {
  static const Environment _currentEnvironment =
      Environment.development; // Change this to switch environments

  static Environment get currentEnvironment => _currentEnvironment;

  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'https://localhost:65201/api'; // Removed extra slash
      case Environment.production:
        return 'https://domain/api'; // Production server
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
