// lib/Resources/api_routes.dart
import 'package:emo_assist_app/Resources/app_config.dart';

class API {
  static String get baseUrl => AppConfig.baseUrl;

  // Auth endpoints
  static String get login => '$baseUrl/api/v1/auth/login';
  static String get register => '$baseUrl/api/v1/auth/register';
  static String get googleOAuth => '$baseUrl/api/v1/auth/oauth/google';
  static String get googleOAuthCallback => '$baseUrl/api/v1/auth/oauth/google/callback';
  static String get logout => '$baseUrl/api/v1/auth/logout';
  static String get refreshToken => '$baseUrl/api/v1/auth/refresh-token';
  static String get changePassword => '$baseUrl/api/v1/auth/change-password';
  static String get healthCheck => '$baseUrl/api/v1/auth/health-check';

  // OTP endpoints
  static String get sendOTP => '$baseUrl/api/v1/auth/send-otp';
  static String get verifyOTP => '$baseUrl/api/v1/auth/verify-otp';
  static String get resendOTP => '$baseUrl/api/v1/auth/resend-otp';
  static String get sendPasswordResetOTP => '$baseUrl/api/v1/auth/send-password-reset-otp';
  static String get resetPasswordWithOTP => '$baseUrl/api/v1/auth/reset-password-with-otp';
  static String get checkEmailVerified => '$baseUrl/api/v1/auth/check-email-verified';

  // User management
  static String get users => '$baseUrl/api/v1/auth/users';
  static String revokeToken(String userId) => '$baseUrl/api/v1/auth/revoke/$userId';
  static String deleteUser(String id) => '$baseUrl/api/v1/auth/delete/$id';
}