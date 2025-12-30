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
  void clearAuthTokens() {
    _authToken = null;
    _refreshToken = null;
    _defaultHeaders.remove('Authorization');
  }

  /// Get current auth token
  String? get authToken => _authToken;

  /// Get current refresh token
  String? get refreshToken => _refreshToken;

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

  /// Handle HTTP response (generic for all APIs)
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final statusCode = response.statusCode;

    try {
      final responseBody = response.body.isEmpty ? '{}' : response.body;
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      // Handle successful responses
      if (statusCode >= 200 && statusCode < 300) {
        // For model APIs, they return direct data without 'success' property
        if (fromJson != null) {
          try {
            final data = fromJson(jsonResponse);
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
            jsonResponse as T,
            statusCode: statusCode,
            rawResponse: jsonResponse,
          );
        }
      } else {
        // Error response - handle validation errors (422)
        if (statusCode == 422) {
          final errorMessage = _extractValidationError(jsonResponse);
          return ApiResponse.error(
            errorMessage,
            statusCode: statusCode,
            rawResponse: jsonResponse,
          );
        }

        // Other errors
        final errorMessage = jsonResponse['message'] ??
            jsonResponse['error'] ??
            jsonResponse['detail'] ??
            'HTTP Error $statusCode';

        return ApiResponse.error(
          errorMessage.toString(),
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

  String _extractValidationError(Map<String, dynamic> jsonResponse) {
    if (jsonResponse['detail'] is List) {
      final details = jsonResponse['detail'] as List;
      return details.map((detail) {
        if (detail is Map) {
          return detail['msg'] ?? detail['message'] ?? 'Validation error';
        }
        return detail.toString();
      }).join('\n');
    }
    return jsonResponse['detail']?.toString() ?? 'Validation error';
  }

  /// Generic GET request with custom base URL
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    String? baseUrlOverride,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final url = _buildUrl(endpoint, baseUrlOverride: baseUrlOverride);
      Uri uri = Uri.parse(url);

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

  /// Generic POST request with custom base URL
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    String? baseUrlOverride,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final url = _buildUrl(endpoint, baseUrlOverride: baseUrlOverride);
      Uri uri = Uri.parse(url);

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

  /// Build URL with appropriate base URL based on endpoint type
  String _buildUrl(String endpoint, {String? baseUrlOverride}) {
    print('🔄 [API] _buildUrl called with:');
    print('   endpoint: "$endpoint"');
    print('   baseUrlOverride: "$baseUrlOverride"');

    // Use override if provided
    if (baseUrlOverride != null && baseUrlOverride.isNotEmpty) {
      final url = _ensureUrlFormat(baseUrlOverride, endpoint);
      print('   ➡️ Using baseUrlOverride: $url');
      return url;
    }

    String baseUrl;
    String serviceName;

    // Determine which base URL to use based on endpoint
    if (endpoint.contains('/predict/image') ||
        endpoint.contains('/predict/video')) {
      baseUrl = AppConfig.imageVideoModelUrl;
      serviceName = 'Image/Video Model';
    } else if (endpoint.contains('/predict_text')) {
      baseUrl = AppConfig.textModelUrl;
      serviceName = 'Text Model';
    } else if (endpoint.contains('/predict/voice') ||
        endpoint.contains('/predict/audio') ||
        endpoint.contains('/emotion/voice') ||
        endpoint.contains('/emotion/audio') ||
        endpoint.contains('/analyze_voice') ||
        endpoint.contains('/predict_speech')) {
      baseUrl = AppConfig.voiceModelUrl;
      serviceName = 'Voice Model';
    } else {
      // For auth and other endpoints, use main backend URL
      baseUrl = AppConfig.baseUrl;
      serviceName = 'Main Backend';
    }

    // FIX: Check if endpoint already contains the base URL
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      // Endpoint is already a full URL
      print('   ➡️ Using full URL from endpoint: $endpoint');
      return endpoint;
    }

    // FIX: Check if endpoint already contains /api/v1/auth
    if (endpoint.contains('/api/v1/auth')) {
      // Endpoint already has full path, just prepend base URL
      final url = _ensureUrlFormat(baseUrl, endpoint);
      print('   ➡️ Using $serviceName with full endpoint: $url');
      return url;
    }

    final url = _ensureUrlFormat(baseUrl, endpoint);
    print('   ➡️ Using $serviceName: $url');
    return url;
  }

  /// Ensure proper URL format (handles trailing/leading slashes)
  String _ensureUrlFormat(String baseUrl, String endpoint) {
    // Remove trailing slash from baseUrl if present
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    // Remove leading slash from endpoint if present
    if (endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }

    return '$baseUrl/$endpoint';
  }

  /// Multipart POST for file uploads
  Future<ApiResponse<T>> multipartPost<T>(
    String endpoint, {
    String? baseUrlOverride,
    List<http.MultipartFile>? files,
    Map<String, String>? fields,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      print('🚀 [API] Starting multipart POST to: $endpoint');
      final url = _buildUrl(endpoint, baseUrlOverride: baseUrlOverride);
      print('🔗 [API] Full URL: $url');
      final uri = Uri.parse(url);

      final request = http.MultipartRequest('POST', uri);
      final requestHeaders = _getHeaders(headers);
      requestHeaders
          .remove('Content-Type'); // Let multipart set its own content-type
      request.headers.addAll({
        'accept': 'application/json',
        ...requestHeaders,
      });

      if (files != null) {
        print('📎 [API] Attaching ${files.length} file(s)');
        request.files.addAll(files);
      }

      if (fields != null) {
        print('📋 [API] Adding fields: ${fields.keys}');
        request.fields.addAll(fields);
      }

      print(
          '⏳ [API] Sending request with timeout: ${timeout ?? AppConfig.uploadTimeout}');

      // Send request with timeout
      final streamedResponse =
          await request.send().timeout(timeout ?? AppConfig.uploadTimeout);
      print('✅ [API] Request sent successfully');

      // Convert streamed response to regular response
      final response = await http.Response.fromStream(streamedResponse);
      print('📥 [API] Response received: ${response.statusCode}');

      // Print response body (first 200 chars for brevity)
      final responseBody = response.body;
      if (responseBody.length > 200) {
        print('📄 [API] Response body: ${responseBody.substring(0, 200)}...');
      } else {
        print('📄 [API] Response body: $responseBody');
      }

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      print('❌ [API] multipartPost error: $e');
      if (e is Error) {
        print('🧵 [API] Stack trace: ${e.stackTrace}');
      }
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Create multipart file from File object
  Future<http.MultipartFile> createMultipartFile(
    File file, {
    String fieldName = 'file',
    String? mimeType,
  }) async {
    mimeType ??= _getMimeType(file.path);
    return http.MultipartFile.fromPath(
      fieldName,
      file.path,
      contentType: mimeType != null ? http.MediaType.parse(mimeType) : null,
    );
  }

  /// Create multipart file from bytes
  Future<http.MultipartFile> createMultipartFileFromBytes(
    List<int> bytes, {
    required String fileName,
    String? mimeType,
    String fieldName = 'file',
  }) async {
    mimeType ??= _getMimeType(fileName);
    return http.MultipartFile.fromBytes(
      fieldName,
      bytes,
      filename: fileName,
      contentType: mimeType != null ? http.MediaType.parse(mimeType) : null,
    );
  }

  /// Get MIME type from file extension
  String? _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'avi':
        return 'video/x-msvideo';
      case 'mov':
        return 'video/quicktime';
      case 'wav':
        return 'audio/wav';
      case 'mp3':
        return 'audio/mpeg';
      case 'm4a':
        return 'audio/x-m4a';
      case 'aac':
        return 'audio/aac';
      case 'flac':
        return 'audio/flac';
      default:
        return null;
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    String? baseUrlOverride,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final url = _buildUrl(endpoint, baseUrlOverride: baseUrlOverride);
      final uri = Uri.parse(url);
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
    String? baseUrlOverride,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final url = _buildUrl(endpoint, baseUrlOverride: baseUrlOverride);
      final uri = Uri.parse(url);
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
    String? baseUrlOverride,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final url = _buildUrl(endpoint, baseUrlOverride: baseUrlOverride);
      final uri = Uri.parse(url);
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
  Future<ApiResponse<Map<String, dynamic>>> refreshAccessToken() async {
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
          .get(Uri.parse('${AppConfig.baseUrl}/auth/health-check'))
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
      body: {
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
