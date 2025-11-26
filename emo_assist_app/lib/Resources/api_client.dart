import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api-routes.dart';
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
}

/// Centralized HTTP client for all API operations
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();
  String? _authToken;
  Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
    _defaultHeaders['Authorization'] = 'Bearer $token';
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
    _defaultHeaders.remove('Authorization');
  }

  /// Get current auth token
  String? get authToken => _authToken;

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

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final statusCode = response.statusCode;

    try {
      final responseBody = response.body.isEmpty ? '{}' : response.body;
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (statusCode >= 200 && statusCode < 300) {
        // Success response
        if (fromJson != null) {
          final data = fromJson(jsonResponse);
          return ApiResponse.success(
            data,
            statusCode: statusCode,
            rawResponse: jsonResponse,
          );
        } else {
          return ApiResponse.success(
            jsonResponse as T,
            statusCode: statusCode,
            rawResponse: jsonResponse,
          );
        }
      } else {
        // Error response
        final errorMessage =
            jsonResponse['message'] ??
            jsonResponse['error'] ??
            'HTTP Error $statusCode';
        return ApiResponse.error(
          errorMessage,
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

  /// Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final response = await _client
          .post(
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

  /// Upload file with multipart request
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    String filePath,
    String fieldName, {
    Map<String, String>? fields,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll(_getHeaders(headers));

      // Add file
      final file = await http.MultipartFile.fromPath(fieldName, filePath);
      request.files.add(file);

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send().timeout(
        timeout ?? AppConfig.uploadTimeout,
      );
      final response = await http.Response.fromStream(streamedResponse);

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

  /// Download file
  Future<ApiResponse<List<int>>> downloadFile(
    String endpoint, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final response = await _client
          .get(uri, headers: _getHeaders(headers))
          .timeout(timeout ?? AppConfig.downloadTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          response.bodyBytes,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          'Failed to download file',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException catch (e) {
      return ApiResponse.error('HTTP error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Check network connectivity
  Future<bool> checkConnectivity() async {
    try {
      final response = await _client
          .get(Uri.parse(API.baseUrl))
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
  // Auth operations
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

  Future<ApiResponse<Map<String, dynamic>>> changePassword(
    Map<String, dynamic> passwordData,
  ) {
    return post<Map<String, dynamic>>(API.changePassword, body: passwordData);
  }

  
}
