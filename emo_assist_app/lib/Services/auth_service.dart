// lib/Services/auth_service.dart
import 'package:emo_assist_app/Services/base_api_service.dart';
import '../Resources/api_client.dart';
import '../Resources/api_routes.dart';

class AuthService extends BaseApiService {
  
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    return apiClient.login(email, password);
  }

  // FIXED: Changed from signup to register
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
    return apiClient.refreshAccessToken(); // Note: This was renamed in ApiClient
  }
}