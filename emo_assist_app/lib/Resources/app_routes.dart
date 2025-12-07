// lib/Resources/Routes.dart
import 'package:get/get.dart';

class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String chat = '/chat';

  // Navigation methods
  static Future<void>? goToSplash() => Get.offAllNamed(splash);
  static Future<void>? goToOnboarding() => Get.offAllNamed(onboarding);
  static Future<void>? goToLogin() => Get.offAllNamed(login);
  static Future<void>? goToSignup() => Get.toNamed(signup);
  static Future<void>? goToChat() => Get.offAllNamed(chat);
  
  // Navigation with replacement (no back option)
  static Future<void>? replaceWithLogin() => Get.offNamed(login);
  static Future<void>? replaceWithChat() => Get.offNamed(chat);
  static Future<void>? replaceWithOnboarding() => Get.offNamed(onboarding);
}