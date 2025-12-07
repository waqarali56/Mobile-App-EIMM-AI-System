// lib/ViewModels/AuthViewModel.dart
import 'dart:developer'; // Add this import for logging
import 'package:emo_assist_app/Enums/AppEnums.dart';
import 'package:emo_assist_app/Models/User.dart';
import 'package:emo_assist_app/Resources/app_routes.dart';
import 'package:emo_assist_app/Services/auth_service.dart';
import 'package:get/get.dart';

class AuthViewModel extends GetxController {
  final AuthService _authService = AuthService();
  
  // Form fields
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxString name = ''.obs;
  
  // Password visibility
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  
  // Validation errors
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;
  final RxString nameError = ''.obs;
  
  // App state
  final Rx<AuthStatus> status = AuthStatus.initial.obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxString errorMessage = ''.obs;
  final RxBool rememberMe = false.obs;
  final RxBool agreeToTerms = false.obs;

  // Validation getters
  bool get isValidEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.value);
  bool get isValidPassword => password.value.length >= 6;
  bool get isValidConfirmPassword => password.value == confirmPassword.value;
  bool get isValidName => name.value.trim().length >= 2;
  
  bool get canLogin => isValidEmail && isValidPassword && emailError.isEmpty && passwordError.isEmpty;
  bool get canSignup => canLogin && isValidConfirmPassword && isValidName && agreeToTerms.value;
  
  bool get isLoading => status.value == AuthStatus.loading;

  // Password visibility methods
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void toggleTermsAgreement() {
    agreeToTerms.value = !agreeToTerms.value;
  }

  // Validation methods
  void validateEmail() {
    if (email.value.isEmpty) {
      emailError.value = 'Email is required';
    } else if (!isValidEmail) {
      emailError.value = 'Please enter a valid email';
    } else {
      emailError.value = '';
    }
  }

  void validatePassword() {
    if (password.value.isEmpty) {
      passwordError.value = 'Password is required';
    } else if (!isValidPassword) {
      passwordError.value = 'Password must be at least 6 characters';
    } else {
      passwordError.value = '';
    }
  }

  void validateConfirmPassword() {
    if (confirmPassword.value.isEmpty) {
      confirmPasswordError.value = 'Please confirm your password';
    } else if (!isValidConfirmPassword) {
      confirmPasswordError.value = 'Passwords do not match';
    } else {
      confirmPasswordError.value = '';
    }
  }

  void validateName() {
    if (name.value.isEmpty) {
      nameError.value = 'Name is required';
    } else if (!isValidName) {
      nameError.value = 'Name must be at least 2 characters';
    } else {
      nameError.value = '';
    }
  }

  // Actions
  Future<void> login() async {
    try {
      log('📱 [AuthViewModel] login() started', name: 'Auth');
      log('📱 Email: ${email.value}', name: 'Auth');
      log('📱 Password length: ${password.value.length}', name: 'Auth');
      
      validateEmail();
      validatePassword();
      
      if (!canLogin) {
        log('❌ [AuthViewModel] Validation failed', name: 'Auth');
        return;
      }
      
      status.value = AuthStatus.loading;
      errorMessage.value = '';
      
      log('📱 [AuthViewModel] Calling _authService.login()', name: 'Auth');
      
      final stopwatch = Stopwatch()..start();
      final response = await _authService.login(email.value.trim(), password.value);
      stopwatch.stop();
      
      log('📱 [AuthViewModel] Response received after ${stopwatch.elapsedMilliseconds}ms', name: 'Auth');
      log('📱 [AuthViewModel] Response success: ${response.success}', name: 'Auth');
      log('📱 [AuthViewModel] Response status code: ${response.statusCode}', name: 'Auth');
      log('📱 [AuthViewModel] Response message: ${response.message}', name: 'Auth');
      log('📱 [AuthViewModel] Response data type: ${response.data.runtimeType}', name: 'Auth');
      
      if (response.data != null) {
        log('📱 [AuthViewModel] Response data keys: ${response.data!.keys}', name: 'Auth');
      }
      
      if (response.success) {
        final userData = response.data;
        if (userData != null && userData is Map<String, dynamic>) {
          log('📱 [AuthViewModel] Parsing user data', name: 'Auth');
          
          // Log the entire response to see structure
          log('📱 [AuthViewModel] Full response: $userData', name: 'Auth');
          
          // IMPORTANT: Your backend returns different field names!
          // According to your API response:
          // - "userName" not "email"
          // - "user" object contains user details
          
          // Check if response has "user" object
          if (userData.containsKey('user')) {
            final userResponse = userData['user'] as Map<String, dynamic>;
            log('📱 [AuthViewModel] User object: $userResponse', name: 'Auth');
            
            // Your API returns "userName" but User model expects "email"
            // You need to update your User model or create mapping
            
            // Create user object with your API response structure
            currentUser.value = User(
              id: userResponse['id']?.toString() ?? '',
              email: userResponse['userName']?.toString() ?? userResponse['email']?.toString() ?? '',
              name: userResponse['firstName']?.toString() ?? userResponse['lastName']?.toString() ?? '',
              type: UserType.user,
            );
          } else {
            currentUser.value = User(
              id: userData['id']?.toString() ?? '',
              email: userData['userName']?.toString() ?? userData['email']?.toString() ?? '',
              name: userData['firstName']?.toString() ?? userData['lastName']?.toString() ?? '',
              type: UserType.user,
            );
            
          }
          
          // Store tokens if available
          final accessToken = userData['accessToken'];
          final refreshToken = userData['refreshToken'];
          
          log('📱 [AuthViewModel] Access token: ${accessToken != null ? "Present" : "Missing"}', name: 'Auth');
          log('📱 [AuthViewModel] Refresh token: ${refreshToken != null ? "Present" : "Missing"}', name: 'Auth');
          
          if (accessToken != null && accessToken is String) {
            // Store token in service
            _authService.setAuthToken(accessToken);
            log('📱 [AuthViewModel] Token stored successfully', name: 'Auth');
          }
          
          status.value = AuthStatus.success;
          
          if (rememberMe.value) {
            // TODO: Store user session securely
            log('📱 [AuthViewModel] Remember me enabled', name: 'Auth');
          }
          
          log('📱 [AuthViewModel] Login successful, navigating to chat', name: 'Auth');
          AppRoutes.goToChat();
          Get.snackbar('Success', 'Login successful!');
        } else {
          log('❌ [AuthViewModel] Invalid response format: $userData', name: 'Auth');
          errorMessage.value = 'Invalid response format from server';
          status.value = AuthStatus.error;
          Get.snackbar('Error', errorMessage.value);
        }
      } else {
        log('❌ [AuthViewModel] Login failed: ${response.message}', name: 'Auth');
        errorMessage.value = response.message ?? 'Login failed. Please check your credentials.';
        status.value = AuthStatus.error;
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e, stackTrace) {
      log('🔥 [AuthViewModel] Exception in login(): $e', name: 'Auth');
      log('🔥 [AuthViewModel] Stack trace: $stackTrace', name: 'Auth');
      
      errorMessage.value = 'Connection error: ${e.toString()}';
      status.value = AuthStatus.error;
      Get.snackbar('Error', errorMessage.value);
    } finally {
      log('📱 [AuthViewModel] login() completed', name: 'Auth');
    }
  }

  Future<void> signup() async {
    try {
      log('📱 [AuthViewModel] signup() started', name: 'Auth');
      
      validateEmail();
      validatePassword();
      validateConfirmPassword();
      validateName();
      
      if (!canSignup) {
        log('❌ [AuthViewModel] Signup validation failed', name: 'Auth');
        return;
      }
      
      status.value = AuthStatus.loading;
      errorMessage.value = '';

      // IMPORTANT: Your API expects "userName" not "email"!
      final userData = {
        'userName': email.value.trim(), // Changed from 'email' to 'userName'
        'password': password.value,
        'name': name.value.trim(),
        'email': email.value.trim(), // You might want to send both
      };
      
      log('📱 [AuthViewModel] Sending signup data: $userData', name: 'Auth');
      
      final response = await _authService.register(userData);
      
      log('📱 [AuthViewModel] Signup response success: ${response.success}', name: 'Auth');
      log('📱 [AuthViewModel] Signup response: ${response.data}', name: 'Auth');
      
      if (response.success) {
        final userData = response.data;
        if (userData != null && userData is Map<String, dynamic>) {
          log('📱 [AuthViewModel] Signup successful, parsing user data', name: 'Auth');
          
          // Parse user data from response
          currentUser.value = User(
            id: userData['id']?.toString() ?? '',
            email: userData['userName']?.toString() ?? userData['email']?.toString() ?? '',
            name: userData['firstName']?.toString() ?? userData['lastName']?.toString() ?? userData['name']?.toString() ?? '',
            type: UserType.user,
          );
          
          // Store tokens if available
          final accessToken = userData['accessToken'];
          final refreshToken = userData['refreshToken'];
          
          if (accessToken != null && accessToken is String) {
            _authService.setAuthToken(accessToken);
            log('📱 [AuthViewModel] Token stored after signup', name: 'Auth');
          }
          
          status.value = AuthStatus.success;
          log('📱 [AuthViewModel] Signup successful, navigating to chat', name: 'Auth');
          AppRoutes.goToChat();
          Get.snackbar('Success', 'Signup successful!');
        } else {
          errorMessage.value = 'Invalid response format';
          status.value = AuthStatus.error;
          Get.snackbar('Error', errorMessage.value);
        }
      } else {
        errorMessage.value = response.message ?? 'Signup failed';
        status.value = AuthStatus.error;
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e, stackTrace) {
      log('🔥 [AuthViewModel] Exception in signup(): $e', name: 'Auth');
      log('🔥 [AuthViewModel] Stack trace: $stackTrace', name: 'Auth');
      
      errorMessage.value = 'Connection error: ${e.toString()}';
      status.value = AuthStatus.error;
      Get.snackbar('Error', errorMessage.value);
    }
  }

  Future<void> logout() async {
    try {
      log('📱 [AuthViewModel] logout() started', name: 'Auth');
      final response = await _authService.logout();
      
      if (response.success) {
        currentUser.value = null;
        status.value = AuthStatus.initial;
        clearForm();
        log('📱 [AuthViewModel] Logout successful', name: 'Auth');
        AppRoutes.goToLogin();
      } else {
        errorMessage.value = response.message ?? 'Logout failed';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e, stackTrace) {
      log('🔥 [AuthViewModel] Exception in logout(): $e', name: 'Auth');
      log('🔥 [AuthViewModel] Stack trace: $stackTrace', name: 'Auth');
    }
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
    log('📱 [AuthViewModel] Remember me toggled: ${rememberMe.value}', name: 'Auth');
  }

  void clearForm() {
    email.value = '';
    password.value = '';
    confirmPassword.value = '';
    name.value = '';
    obscurePassword.value = true;
    obscureConfirmPassword.value = true;
    emailError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';
    nameError.value = '';
    errorMessage.value = '';
    agreeToTerms.value = false;
  }

  @override
  void onClose() {
    clearForm();
    super.onClose();
  }
}