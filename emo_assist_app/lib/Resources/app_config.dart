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
        return 'http://192.168.0.104:5104';
      case Environment.production:
        return 'https://your-production-domain/api/v1';
    }
  }

  // Model URLs for different services
  static String get imageVideoModelUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://182.180.159.89:8002'; // Image/Video port
      case Environment.production:
        return 'https://your-image-video-production-domain';
    }
  }

  static String get textModelUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://182.180.159.89:8001'; // Text port
      case Environment.production:
        return 'https://your-text-production-domain';
    }
  }

  static String get voiceModelUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://182.180.159.89:8000'; // Voice port
      case Environment.production:
        return 'https://your-voice-production-domain';
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
      'imageVideoModelUrl': imageVideoModelUrl,
      'textModelUrl': textModelUrl,
      'voiceModelUrl': voiceModelUrl,
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
