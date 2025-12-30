import 'dart:developer';

import 'package:emo_assist_app/Services/base_api_service.dart';
import '../Models/OTP.dart';
import '../Resources/api_client.dart';
import '../Resources/api_routes.dart';

class AuthService extends BaseApiService {
  
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    return apiClient.login(email, password);
  }

  Future<ApiResponse<Map<String, dynamic>>> register(Map<String, dynamic> userData) async {
    return apiClient.register(userData);
  }

  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    return apiClient.logout();
  }

  Future<ApiResponse<Map<String, dynamic>>> changePassword(Map<String, dynamic> passwordData) async {
    return apiClient.changePassword(passwordData);
  }

  Future<ApiResponse<Map<String, dynamic>>> googleOAuthInitiate() async {
    return apiClient.googleOAuthInitiate();
  }

  Future<ApiResponse<Map<String, dynamic>>> googleOAuthCallback(String code, String state) async {
    return apiClient.googleOAuthCallback(code, state);
  }

  Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    return apiClient.refreshAccessToken();
  }

  // OTP Methods
  Future<ApiResponse<SendOTPResponse>> sendOTP(SendOTPRequest request) async {
    try {
      log('📱 [AuthService] Sending OTP to ${request.email} for type ${request.type}', name: 'Auth');
   
      final response = await apiClient.post<Map<String, dynamic>>(
        API.sendOTP,
        body: request.toJson(),
      );

      if (response.success && response.data != null) {
        final otpResponse = SendOTPResponse.fromJson(response.data!);
        return ApiResponse.success(otpResponse);
      } else {
        return ApiResponse.error(
          response.message ?? 'Failed to send OTP',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('🔥 [AuthService] Error sending OTP: $e', name: 'Auth');
      return ApiResponse.error('Error sending OTP: $e');
    }
  }

  Future<ApiResponse<OTPResponse>> verifyOTP(OTPRequest request) async {
    try {
      log('📱 [AuthService] Verifying OTP for ${request.email}', name: 'Auth');
      
      final response = await apiClient.post<Map<String, dynamic>>(
        API.verifyOTP,
        body: request.toJson(),
      );

      if (response.success && response.data != null) {
        final otpResponse = OTPResponse.fromJson(response.data!);
        return ApiResponse.success(otpResponse);
      } else {
        return ApiResponse.error(
          response.message ?? 'Failed to verify OTP',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('🔥 [AuthService] Error verifying OTP: $e', name: 'Auth');
      return ApiResponse.error('Error verifying OTP: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> resendOTP(String email, OTPType type) async {
    try {
      log('📱 [AuthService] Resending OTP to $email', name: 'Auth');
      
      final response = await apiClient.post<Map<String, dynamic>>(
        API.resendOTP,
        queryParameters: {
          'email': email,
          'type': type.toString().split('.').last,
        },
      );

      return ApiResponse(
        success: response.success,
        data: response.data,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      log('🔥 [AuthService] Error resending OTP: $e', name: 'Auth');
      return ApiResponse.error('Error resending OTP: $e');
    }
  }

  Future<ApiResponse<SendOTPResponse>> sendPasswordResetOTP(String email) async {
    try {
      log('📱 [AuthService] Sending password reset OTP to $email', name: 'Auth');
      
      final request = SendOTPRequest(email: email, type: OTPType.PasswordReset);
      final response = await apiClient.post<Map<String, dynamic>>(
        API.sendPasswordResetOTP,
        body: request.toJson(),
      );

      if (response.success && response.data != null) {
        final otpResponse = SendOTPResponse.fromJson(response.data!);
        return ApiResponse.success(otpResponse);
      } else {
        return ApiResponse.error(
          response.message ?? 'Failed to send password reset OTP',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('🔥 [AuthService] Error sending password reset OTP: $e', name: 'Auth');
      return ApiResponse.error('Error sending password reset OTP: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> resetPasswordWithOTP(
    ResetPasswordWithOTPRequest request,
  ) async {
    try {
      log('📱 [AuthService] Resetting password with OTP for ${request.email}', name: 'Auth');
      
      final response = await apiClient.post<Map<String, dynamic>>(
        API.resetPasswordWithOTP,
        body: request.toJson(),
      );

      return ApiResponse(
        success: response.success,
        data: response.data,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      log('🔥 [AuthService] Error resetting password with OTP: $e', name: 'Auth');
      return ApiResponse.error('Error resetting password with OTP: $e');
    }
  }

  Future<ApiResponse<bool>> checkEmailVerified(String email) async {
    try {
      log('📱 [AuthService] Checking email verification status for $email', name: 'Auth');
      
      final response = await apiClient.get<Map<String, dynamic>>(
        '${API.checkEmailVerified}/$email',
      );

      if (response.success && response.data != null) {
        final isVerified = response.data!['isVerified'] ?? false;
        return ApiResponse.success(isVerified);
      } else {
        return ApiResponse.error(
          response.message ?? 'Failed to check email verification status',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('🔥 [AuthService] Error checking email verification: $e', name: 'Auth');
      return ApiResponse.error('Error checking email verification: $e');
    }
  }

  // Helper method to send verification OTP after registration
  Future<void> sendVerificationOTPAfterRegistration(String email) async {
    try {
      log('📱 [AuthService] Sending verification OTP after registration to $email', name: 'Auth');
      
      final request = SendOTPRequest(
        email: email,
        type: OTPType.EmailVerification,
      );
      
      final response = await sendOTP(request);
      
      if (!response.success) {
        log('⚠️ [AuthService] Failed to send verification OTP: ${response.message}', name: 'Auth');
      } else {
        log('✅ [AuthService] Verification OTP sent successfully', name: 'Auth');
      }
    } catch (e) {
      log('🔥 [AuthService] Error sending verification OTP: $e', name: 'Auth');
    }
  }
}