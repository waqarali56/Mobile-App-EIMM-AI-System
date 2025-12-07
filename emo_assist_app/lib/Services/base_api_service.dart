// lib/Services/base_api_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Resources/api_client.dart';

/// Base API service class with common functionality
abstract class BaseApiService extends GetxService {
  final ApiClient _apiClient = ApiClient();

  // Common reactive variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _setupApiClient();
  }

  void _setupApiClient() {
    // Set up default headers
    _apiClient.setCustomHeaders({
      'X-App-Version': '1.0.0',
      'X-Platform': 'Flutter',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });
  }

  /// Get the API client instance
  ApiClient get apiClient => _apiClient;

  /// Set authentication token
  void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
  }

  /// Clear authentication token
  void clearAuthToken() {
    _apiClient.clearAuthTokens();
  }

  /// Get current auth token
  String? get authToken => _apiClient.authToken;

  /// Check if user is authenticated
  bool get isAuthenticated => authToken != null && authToken!.isNotEmpty;

  /// Handle loading state
  void startLoading() {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';
  }

  /// Stop loading state
  void stopLoading() {
    isLoading.value = false;
  }

  /// Handle success response
  void handleSuccess(String message) {
    successMessage.value = message;
    if (message.isNotEmpty) {
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );
    }
  }

  /// Handle error response
  void handleError(String message) {
    errorMessage.value = message;
    if (message.isNotEmpty) {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Check network connectivity
  Future<bool> checkConnectivity() async {
    return await _apiClient.checkConnectivity();
  }

  /// Clear all messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  @override
  void onClose() {
    _apiClient.dispose();
    super.onClose();
  }
}