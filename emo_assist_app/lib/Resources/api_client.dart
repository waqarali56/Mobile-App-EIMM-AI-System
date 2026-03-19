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

  /// When a request returns 401, this runs once (deduped) to refresh tokens; return true to retry.
  Future<bool> Function()? _sessionRefreshHandler;
  Future<bool>? _sharedRefreshFuture;

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

  void setSessionRefreshHandler(Future<bool> Function()? handler) {
    _sessionRefreshHandler = handler;
  }

  Future<bool> _runSharedRefresh() async {
    if (_sessionRefreshHandler == null) return false;
    if (_sharedRefreshFuture != null) return await _sharedRefreshFuture!;
    _sharedRefreshFuture = _sessionRefreshHandler!().whenComplete(() {
      _sharedRefreshFuture = null;
    });
    return await _sharedRefreshFuture!;
  }

  bool _shouldAttemptTokenRefreshForRequest(String url) {
    final u = url.toLowerCase();
    if (u.contains('refresh-token')) return false;
    if (u.contains('/login')) return false;
    if (u.contains('/register')) return false;
    if (u.contains('sendotp')) return false;
    if (u.contains('verifyotp')) return false;
    if (u.contains('health-check')) return false;
    if (u.contains('/oauth/')) return false;
    return true;
  }

  Future<http.Response> _on401MaybeRefreshAndRetry(
    http.Response firstResponse,
    Future<http.Response> Function() resend,
    String requestUrl,
  ) async {
    if (firstResponse.statusCode != 401) return firstResponse;
    if (!_shouldAttemptTokenRefreshForRequest(requestUrl)) return firstResponse;
    final ok = await _runSharedRefresh();
    if (!ok) return firstResponse;
    return resend();
  }

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
    T Function(dynamic)? fromJson,
  ) {
    final statusCode = response.statusCode;

    try {
      final responseBody = response.body.isEmpty ? '{}' : response.body;
      final dynamic decoded = json.decode(responseBody);
      final Map<String, dynamic> jsonResponse = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

      // Handle successful responses
      if (statusCode >= 200 && statusCode < 300) {
        // For model APIs, they return direct data without 'success' property
        if (fromJson != null) {
          try {
            final data = fromJson(decoded);
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
            decoded as T,
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
    T Function(dynamic)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final url = _buildUrl(endpoint, baseUrlOverride: baseUrlOverride);
      Uri uri = Uri.parse(url);

      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      Future<http.Response> send() => _client
          .get(uri, headers: _getHeaders(headers))
          .timeout(timeout ?? AppConfig.defaultTimeout);

      var response = await send();
      response = await _on401MaybeRefreshAndRetry(response, send, uri.toString());

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

      Future<http.Response> send() => _client
          .post(
            uri,
            headers: _getHeaders(headers),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout ?? AppConfig.defaultTimeout);

      var response = await send();

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      response = await _on401MaybeRefreshAndRetry(response, send, uri.toString());

      return _handleResponse<T>(response, fromJson as T Function(dynamic p1)?);
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

  /// Build URL: only multimodal /analyze and .NET backend. No other model URLs.
  String _buildUrl(String endpoint, {String? baseUrlOverride}) {
    if (baseUrlOverride != null && baseUrlOverride.isNotEmpty) {
      return _ensureUrlFormat(baseUrlOverride, endpoint);
    }

    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      return endpoint;
    }

    // Multimodal orchestrator API (/analyze, /sessions)
    if (endpoint.contains('/analyze') || endpoint.contains('sessions')) {
      return _ensureUrlFormat(AppConfig.multimodal_analyze_ApiUrl, endpoint);
    }

    // .NET backend (auth, users, etc.)
    return _ensureUrlFormat(AppConfig.baseUrl, endpoint);
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
    required T Function(dynamic) fromJson,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      print('🚀 [API] Starting multipart POST to: $endpoint');
      final url = _buildUrl(endpoint, baseUrlOverride: baseUrlOverride);
      print('🔗 [API] Full URL: $url');
      final uri = Uri.parse(url);

      print(
          '⏳ [API] Sending request with timeout: ${timeout ?? AppConfig.uploadTimeout}');

      Future<http.Response> sendMultipart() async {
        final req = http.MultipartRequest('POST', uri);
        final requestHeaders = _getHeaders(headers);
        requestHeaders
            .remove('Content-Type'); // Let multipart set its own content-type
        req.headers.addAll({
          'accept': 'application/json',
          ...requestHeaders,
        });
        if (files != null) {
          print('📎 [API] Attaching ${files.length} file(s)');
          req.files.addAll(files);
        }
        if (fields != null) {
          print('📋 [API] Adding fields: ${fields.keys}');
          req.fields.addAll(fields);
        }
        final streamedResponse =
            await req.send().timeout(timeout ?? AppConfig.uploadTimeout);
        return http.Response.fromStream(streamedResponse);
      }

      // Send request with timeout
      var response = await sendMultipart();
      print('✅ [API] Request sent successfully');

      print('📥 [API] Response received: ${response.statusCode}');

      response =
          await _on401MaybeRefreshAndRetry(response, sendMultipart, url);

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
      Future<http.Response> send() => _client
          .put(
            uri,
            headers: _getHeaders(headers),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout ?? AppConfig.defaultTimeout);

      var response = await send();
      response = await _on401MaybeRefreshAndRetry(response, send, uri.toString());

      return _handleResponse<T>(response, fromJson as T Function(dynamic p1)?);
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
      Future<http.Response> send() => _client
          .patch(
            uri,
            headers: _getHeaders(headers),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout ?? AppConfig.defaultTimeout);

      var response = await send();
      response = await _on401MaybeRefreshAndRetry(response, send, uri.toString());

      return _handleResponse<T>(response, fromJson as T Function(dynamic p1)?);
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
      Future<http.Response> send() => _client
          .delete(uri, headers: _getHeaders(headers))
          .timeout(timeout ?? AppConfig.defaultTimeout);

      var response = await send();
      response = await _on401MaybeRefreshAndRetry(response, send, uri.toString());

      return _handleResponse<T>(response, fromJson as T Function(dynamic p1)?);
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
