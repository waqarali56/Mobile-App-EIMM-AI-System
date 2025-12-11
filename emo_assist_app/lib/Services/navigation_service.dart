// Services/NavigationService.dart
import 'dart:developer' as consol;

import 'package:get/get.dart';
import 'package:emo_assist_app/Models/OTP.dart';
import 'package:emo_assist_app/Resources/RouteNames.dart';

class NavigationService {
  // Basic Navigation
  static Future<void>? goToSplash() => Get.offAllNamed(RouteNames.splash);
  static Future<void>? goToOnboarding() => Get.offAllNamed(RouteNames.onboarding);
  static Future<void>? goToLogin() => Get.offAllNamed(RouteNames.login);
  static Future<void>? goToSignup() => Get.toNamed(RouteNames.signup);
  static Future<void>? goToChat() => Get.offAllNamed(RouteNames.chat);
    static Future<void>? goToHome() => Get.offAllNamed(RouteNames.home);
  static Future<void>? goToForgotPassword() => Get.toNamed(RouteNames.forgotPassword);
  
  // New Drawer Navigation
  static Future<void>? goToChatHistory() => Get.toNamed(RouteNames.chatHistory);
  static Future<void>? goToSettings() => Get.toNamed(RouteNames.settings);
  static Future<void>? goToPrivacyPolicy() => Get.toNamed(RouteNames.privacyPolicy);
  static Future<void>? goToTerms() => Get.toNamed(RouteNames.terms);
  static Future<void>? goToProfile() => Get.toNamed(RouteNames.profile);
  
  // OTP Navigation with proper email encoding
  static Future<void>? goToOTPVerification({
    required String email,
    required OTPType type,
  }) {
    consol.log('🔄 [NavigationService] Navigating to OTP with email: $email');
    
    return Get.toNamed(
      RouteNames.otpVerification,
      arguments: {
        'email': email,
        'type': type,
      },
      parameters: {
        'email': email, 
        'type': type.toString().split('.').last,
      },
    );
  }
  
  // Reset Password Navigation
  static Future<void>? goToResetPassword({
    required String email,
    required String otp,
  }) {
    consol.log('🔄 [NavigationService] Navigating to Reset Password with email: $email');
    
    return Get.toNamed(
      RouteNames.resetPassword,
      arguments: {
        'email': email,
        'otp': otp,
      },
      parameters: {
        'email': email,
        'otp': otp,
      },
    );
  }
  
  // Navigation with replacement
  static Future<void>? replaceWithLogin() => Get.offNamed(RouteNames.login);
  static Future<void>? replaceWithChat() => Get.offNamed(RouteNames.chat);
  static Future<void>? replaceWithOnboarding() => Get.offNamed(RouteNames.onboarding);
  
  // Back navigation
  static void goBack([dynamic result]) => Get.back(result: result);
  static void goBackTo(String routeName) => Get.until((route) => route.settings.name == routeName);
  
  // Utility methods
  static String get currentRoute => Get.currentRoute;
  static bool isOnRoute(String routeName) => Get.currentRoute == routeName;
  
  static Future<T?>? goToWithCallback<T>(String routeName, {
    Map<String, String>? parameters,
    dynamic arguments,
  }) {
    return Get.toNamed<T?>(
      routeName,
      parameters: parameters,
      arguments: arguments,
    );
  }
  
  // Clear all routes and go to
  static Future<void>? clearAllAndGoTo(String routeName) {
    return Get.offAllNamed(routeName);
  }
}