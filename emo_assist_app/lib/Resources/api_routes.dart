// lib/Resources/api_routes.dart
import 'app_config.dart';

class API {
  static String get baseUrl => AppConfig.baseUrl;

  // Auth endpoints (matching your backend Swagger)
  static String get authBase => '$baseUrl/auth';
  static String get login => '$authBase/login';
  static String get register => '$authBase/register';
  static String get googleOAuth => '$authBase/oauth/google';
  static String get googleOAuthCallback => '$authBase/oauth/google/callback';
  static String get logout => '$authBase/logout';
  static String get refreshToken => '$authBase/refresh-token';
  static String get changePassword => '$authBase/change-password';
  static String get healthCheck => '$authBase/health-check';




 // OTP endpoints
  static String get sendOTP => '$authBase/send-otp';
  static String get verifyOTP => '$authBase/verify-otp';
  static String get resendOTP => '$authBase/resend-otp';
  static String get sendPasswordResetOTP => '$authBase/send-password-reset-otp';
  static String get resetPasswordWithOTP => '$authBase/reset-password-with-otp';
  static String get checkEmailVerified => '$authBase/check-email-verified';



  
  // User management (admin only)
  static String get users => '$authBase/users';
  static String revokeToken(String userId) => '$authBase/revoke/$userId';
  static String deleteUser(String id) => '$authBase/delete/$id';
}