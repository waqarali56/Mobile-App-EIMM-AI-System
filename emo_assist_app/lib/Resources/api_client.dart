// lib/Resources/api_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:emo_assist_app/Models/OTP.dart';
import 'package:http/http.dart' as http;
import 'api_routes.dart';
import 'app_config.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic response;

  ApiException(this.message, {this.statusCode, this.response});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Response wrapper for API calls
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? rawResponse;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.rawResponse,
  });

  factory ApiResponse.success(
    T data, {
    int? statusCode,
    Map<String, dynamic>? rawResponse,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      statusCode: statusCode,
      rawResponse: rawResponse,
    );
  }

  factory ApiResponse.error(
    String message, {
    int? statusCode,
    Map<String, dynamic>? rawResponse,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      rawResponse: rawResponse,
    );
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] ?? false;
    final data = json['data'];
    final message = json['message'];
    final statusCode = json['statusCode'];

    return ApiResponse(
      success: success,
      data: data,
      message: message,
      statusCode: statusCode,
      rawResponse: json,
    );
  }
}

/// Centralized HTTP client for all API operations
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();
  String? _authToken;
  String? _refreshToken;
  
  Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
    _defaultHeaders['Authorization'] = 'Bearer $token';
  }

  /// Set refresh token
  void setRefreshToken(String token) {
    _refreshToken = token;
  }

  /// Clear authentication tokens
  void clearAuthTokens() {  // Fixed: clearAuthTokenS (plural)
    _authToken = null;
    _refreshToken = null;
    _defaultHeaders.remove('Authorization');
  }

  /// Get current auth token
  String? get authToken => _authToken;
  
  /// Get current refresh token
  String? get refreshToken => _refreshToken;  // Fixed: Only one getter

  /// Set custom headers
  void setCustomHeaders(Map<String, String> headers) {
    _defaultHeaders.addAll(headers);
  }

  /// Get headers with authentication
  Map<String, String> _getHeaders([Map<String, String>? additionalHeaders]) {
    final headers = Map<String, String>.from(_defaultHeaders);
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  /// Handle HTTP response with backend format
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final statusCode = response.statusCode;

    try {
      final responseBody = response.body.isEmpty ? '{}' : response.body;
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      // Handle your backend response format
      if (statusCode >= 200 && statusCode < 300) {
        // Check if response has success property (your backend format)
        final success = jsonResponse['success'] ?? true;
        
        if (!success) {
          final errorMessage = jsonResponse['message'] ?? 
                              jsonResponse['error'] ?? 
                              'Operation failed';
          return ApiResponse.error(
            errorMessage,
            statusCode: statusCode,
            rawResponse: jsonResponse,
          );
        }

        // Success response
        final responseData = jsonResponse['data'] ?? jsonResponse;
        
        if (fromJson != null && responseData != null) {
          try {
            final data = fromJson(responseData);
            return ApiResponse.success(
              data,
              statusCode: statusCode,
              rawResponse: jsonResponse,
            );
          } catch (e) {
            return ApiResponse.error(
              'Failed to parse response data: $e',
              statusCode: statusCode,
              rawResponse: jsonResponse,
            );
          }
        } else {
          return ApiResponse.success(
            responseData as T,
            statusCode: statusCode,
            rawResponse: jsonResponse,
          );
        }
      } else {
        // Error response
        final errorMessage = jsonResponse['message'] ??
                            jsonResponse['error'] ??
                            jsonResponse['title'] ??
                            'HTTP Error $statusCode';
        
        // Extract validation errors if present
        String detailedMessage = errorMessage;
        if (jsonResponse['errors'] != null) {
          final errors = jsonResponse['errors'];
          if (errors is Map) {
            detailedMessage += '\n${errors.entries.map((e) => '${e.key}: ${e.value}').join('\n')}';
          } else if (errors is List) {
            detailedMessage += '\n${errors.join('\n')}';
          }
        }
        
        return ApiResponse.error(
          detailedMessage,
          statusCode: statusCode,
          rawResponse: jsonResponse,
        );
      }
    } catch (e) {
      // JSON parsing error or other exceptions
      return ApiResponse.error(
        'Failed to parse response: $e',
        statusCode: statusCode,
        rawResponse: {'raw_body': response.body},
      );
    }
  }

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      Uri uri = Uri.parse(endpoint);
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final response = await _client
          .get(uri, headers: _getHeaders(headers))
          .timeout(timeout ?? AppConfig.defaultTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException catch (e) {
      return ApiResponse.error('HTTP error: ${e.message}');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

 /// Generic POST request with query parameters support
Future<ApiResponse<T>> post<T>(
  String endpoint, {
  Map<String, dynamic>? body,
  Map<String, String>? queryParameters, // Add this parameter
  Map<String, String>? headers,
  T Function(Map<String, dynamic>)? fromJson,
  Duration? timeout,
}) async {
  try {
    // Build URI with query parameters if provided
    Uri uri = Uri.parse(endpoint);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    print('POST Request to: $uri');
    if (body != null) {
      print('Request Body: ${json.encode(body)}');
    }
    
    final response = await _client
        .post(
          uri,
          headers: _getHeaders(headers),
          body: body != null ? json.encode(body) : null,
        )
        .timeout(timeout ?? AppConfig.defaultTimeout);

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    return _handleResponse<T>(response, fromJson);
  } on SocketException {
    return ApiResponse.error('No internet connection');
  } on HttpException catch (e) {
    return ApiResponse.error('HTTP error: ${e.message}');
  } on FormatException {
    return ApiResponse.error('Invalid response format');
  } catch (e) {
    return ApiResponse.error('Unexpected error: $e');
  }
}

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final response = await _client
          .put(
            uri,
            headers: _getHeaders(headers),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout ?? AppConfig.defaultTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException catch (e) {
      return ApiResponse.error('HTTP error: ${e.message}');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Generic PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final response = await _client
          .patch(
            uri,
            headers: _getHeaders(headers),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout ?? AppConfig.defaultTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException catch (e) {
      return ApiResponse.error('HTTP error: ${e.message}');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final response = await _client
          .delete(uri, headers: _getHeaders(headers))
          .timeout(timeout ?? AppConfig.defaultTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException catch (e) {
      return ApiResponse.error('HTTP error: ${e.message}');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Refresh access token
  Future<ApiResponse<Map<String, dynamic>>> refreshAccessToken() async {  // Renamed to avoid conflict
    if (_refreshToken == null || _authToken == null) {
      return ApiResponse.error('No refresh token available');
    }

    try {
      final response = await post<Map<String, dynamic>>(
        API.refreshToken,
        body: {
          'accessToken': _authToken,
          'refreshToken': _refreshToken,
        },
      );

      if (response.success && response.data != null) {
        final newAccessToken = response.data!['accessToken'];
        final newRefreshToken = response.data!['refreshToken'];
        
        if (newAccessToken != null) {
          setAuthToken(newAccessToken);
        }
        if (newRefreshToken != null) {
          setRefreshToken(newRefreshToken);
        }
      }

      return response;
    } catch (e) {
      return ApiResponse.error('Token refresh failed: $e');
    }
  }

  /// Check network connectivity
  Future<bool> checkConnectivity() async {
    try {
      final response = await _client
          .get(Uri.parse(API.healthCheck))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Close the HTTP client
  void dispose() {
    _client.close();
  }
}

/// Extension methods for common API operations
extension ApiClientExtensions on ApiClient {
  // Auth operations matching your backend
  Future<ApiResponse<Map<String, dynamic>>> login(
    String email,
    String password,
  ) {
    return post<Map<String, dynamic>>(
      API.login,
      body: {'email': email, 'password': password},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> register(
    Map<String, dynamic> userData,
  ) {
    return post<Map<String, dynamic>>(API.register, body: userData);
  }

  Future<ApiResponse<Map<String, dynamic>>> googleOAuthInitiate() {
    return get<Map<String, dynamic>>(API.googleOAuth);
  }

  Future<ApiResponse<Map<String, dynamic>>> googleOAuthCallback(
    String code,
    String state,
  ) {
    return get<Map<String, dynamic>>(
      API.googleOAuthCallback,
      queryParameters: {'code': code, 'state': state},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> logout() {
    return post<Map<String, dynamic>>(API.logout);
  }

  Future<ApiResponse<Map<String, dynamic>>> changePassword(
    Map<String, dynamic> passwordData,
  ) {
    return post<Map<String, dynamic>>(API.changePassword, body: passwordData);
  }

  Future<ApiResponse<Map<String, dynamic>>> healthCheck() {
    return get<Map<String, dynamic>>(API.healthCheck);
  }

   Future<ApiResponse<Map<String, dynamic>>> sendOTP(
    SendOTPRequest request,
  ) {
    return post<Map<String, dynamic>>(
      API.sendOTP,
      body: request.toJson(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyOTP(
    OTPRequest request,
  ) {
    return post<Map<String, dynamic>>(
      API.verifyOTP,
      body: request.toJson(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> resendOTP(
    String email,
    OTPType type,
  ) {
    return post<Map<String, dynamic>>(
      API.resendOTP,
      queryParameters: {
        'email': email,
        'type': type.toString().split('.').last,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> sendPasswordResetOTP(
    SendOTPRequest request,
  ) {
    return post<Map<String, dynamic>>(
      API.sendPasswordResetOTP,
      body: request.toJson(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> resetPasswordWithOTP(
    ResetPasswordWithOTPRequest request,
  ) {
    return post<Map<String, dynamic>>(
      API.resetPasswordWithOTP,
      body: request.toJson(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> checkEmailVerified(
    String email,
  ) {
    return get<Map<String, dynamic>>(
      '${API.checkEmailVerified}/$email',
    );
  }
}