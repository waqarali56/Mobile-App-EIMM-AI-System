import '../Resources/api_client.dart';
import '../Models/User.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<User>> login(String email, String password) async {
    final response = await _apiClient.login(email, password);

    if (response.success && response.data != null) {
      final user = User.fromJson(response.data!);

      // Store token if available
      if (response.rawResponse?['token'] != null) {
        _apiClient.setAuthToken(response.rawResponse!['token']);
      }

      return ApiResponse.success(user);
    } else {
      return ApiResponse.error(response.message ?? 'Login failed');
    }
  }

  Future<ApiResponse<User>> signup(Map<String, dynamic> userData) async {
    final response = await _apiClient.register(userData);

    if (response.success && response.data != null) {
      final user = User.fromJson(response.data!);
      return ApiResponse.success(user);
    } else {
      return ApiResponse.error(response.message ?? 'Signup failed');
    }
  }

  Future<ApiResponse<bool>> logout() async {
    _apiClient.clearAuthToken();
    // TODO: Clear local storage
    return ApiResponse.success(true);
  }

  Future<ApiResponse<bool>> changePassword(
    Map<String, dynamic> passwordData,
  ) async {
    final response = await _apiClient.changePassword(passwordData);
    return ApiResponse.success(response.success);
  }
}
