// ViewModels/AuthViewModel.dart
import 'dart:developer';
import 'package:emo_assist_app/Enums/AppEnums.dart';
import 'package:emo_assist_app/Models/OTP.dart';
import 'package:emo_assist_app/Models/User.dart';
import 'package:emo_assist_app/Services/auth_service.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Form fields
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;

  // Password visibility
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  // Validation errors
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;
  final RxString firstNameError = ''.obs;
  final RxString lastNameError = ''.obs;

  // App state
  final Rx<AuthStatus> status = AuthStatus.initial.obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxString errorMessage = ''.obs;
  final RxBool rememberMe = false.obs;
  final RxBool agreeToTerms = false.obs;

  // Validation getters
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.value);
  bool get isValidPassword => password.value.length >= 6;
  bool get isValidConfirmPassword => password.value == confirmPassword.value;
  bool get isValidFirstName => firstName.value.trim().length >= 2;
  bool get isValidLastName => lastName.value.trim().length >= 2;

  bool get canLogin =>
      isValidEmail &&
      isValidPassword &&
      emailError.isEmpty &&
      passwordError.isEmpty;
  bool get canSignup =>
      canLogin &&
      isValidConfirmPassword &&
      isValidFirstName &&
      isValidLastName &&
      agreeToTerms.value;
  bool get isLoading => status.value == AuthStatus.loading;

  @override
  void onInit() {
    super.onInit();
    // Check for saved session
    checkSavedSession();
  }

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

  void validateFirstName() {
    if (firstName.value.isEmpty) {
      firstNameError.value = 'First name is required';
    } else if (!isValidFirstName) {
      firstNameError.value = 'First name must be at least 2 characters';
    } else {
      firstNameError.value = '';
    }
  }

  void validateLastName() {
    if (lastName.value.isEmpty) {
      lastNameError.value = 'Last name is required';
    } else if (!isValidLastName) {
      lastNameError.value = 'Last name must be at least 2 characters';
    } else {
      lastNameError.value = '';
    }
  }

  // Login with OTP verification check
  Future<void> login() async {
    try {
      log('📱 [AuthViewModel] login() started', name: 'Auth');

      validateEmail();
      validatePassword();

      if (!canLogin) {
        log('❌ [AuthViewModel] Validation failed', name: 'Auth');
        return;
      }

      status.value = AuthStatus.loading;
      errorMessage.value = '';

      // Proceed with login if email is verified
      final response = await _authService.login(
        email.value.trim(),
        password.value,
      );

      log(
        '📱 [AuthViewModel] Response success: ${response.success}',
        name: 'Auth',
      );

      if (response.success) {
        final userData = response.data;
        if (userData != null && userData is Map<String, dynamic>) {
          log('📱 [AuthViewModel] Parsing user data', name: 'Auth');

          User? user = _parseUserFromResponse(userData);

          if (user != null) {
            currentUser.value = user;

            final accessToken = userData['accessToken'];
            if (accessToken != null && accessToken is String) {
              _authService.setAuthToken(accessToken);

              if (rememberMe.value) {
                await _saveUserSession(user, accessToken);
              }
            }

            status.value = AuthStatus.success;

            log(
              '📱 [AuthViewModel] Login successful, navigating to chat',
              name: 'Auth',
            );
            NavigationService.goToHome();
            Get.snackbar('Success', 'Login successful!');
          } else {
            _handleInvalidResponse();
          }
        } else {
          _handleInvalidResponse();
        }
      } else {
        _handleLoginError(response.message);
      }
    } catch (e, stackTrace) {
      _handleException('login', e, stackTrace);
    } finally {
      log('📱 [AuthViewModel] login() completed', name: 'Auth');
    }
  }

  // Signup with automatic OTP sending
  Future<void> signup() async {
    try {
      log('📱 [AuthViewModel] signup() started', name: 'Auth');

      validateEmail();
      validatePassword();
      validateConfirmPassword();
      validateFirstName();
      validateLastName();

      if (!canSignup) {
        log('❌ [AuthViewModel] Signup validation failed', name: 'Auth');
        return;
      }

      status.value = AuthStatus.loading;
      errorMessage.value = '';

      final userData = {
        'firstName': firstName.value.trim(),
        'lastName': lastName.value.trim(),
        'email': email.value.trim(),
        'password': password.value,
        'role': "User",
      };

      log('📱 [AuthViewModel] Sending signup data: $userData', name: 'Auth');

      final response = await _authService.register(userData);

      log(
        '📱 [AuthViewModel] Signup response success: ${response.success}',
        name: 'Auth',
      );

     // In AuthViewModel.dart - signup method
if (response.success) {
  final responseData = response.data;
  if (responseData != null && responseData is Map<String, dynamic>) {
    log('📱 [AuthViewModel] Signup successful', name: 'Auth');
    
    // Always send OTP for email verification after signup
    status.value = AuthStatus.success;
    log('📱 [AuthViewModel] Sending verification OTP after signup', name: 'Auth');
    
    // Store email temporarily before clearing form
    final userEmail = email.value.trim();
    
    // Clear form
    clearForm();
    
    // Navigate to OTP verification with email
    NavigationService.goToOTPVerification(
      email: userEmail,
      type: OTPType.EmailVerification,
    );
    
    Get.snackbar('Success', 'Signup successful! Please verify your email.');
  }
} else {
        _handleSignupError(response.message);
      }
    } catch (e, stackTrace) {
      _handleException('signup', e, stackTrace);
    } finally {
      status.value = AuthStatus.initial;
    }
  }

  // Send verification OTP
  Future<void> sendVerificationOTP({
    required String email,
    required OTPType type,
  }) async {
    try {
      log(
        '📨 [AuthViewModel] Sending verification OTP to: $email',
        name: 'Auth',
      );
      status.value = AuthStatus.loading;
      errorMessage.value = '';

      final request = SendOTPRequest(email: email, type: type);
      final response = await _authService.sendOTP(request);

      if (response.success) {
        status.value = AuthStatus.success;

        // Navigate to OTP verification screen
        NavigationService.goToOTPVerification(email: email, type: type);

        Get.snackbar('Success', 'OTP sent to your email');
      } else {
        status.value = AuthStatus.error;
        errorMessage.value = response.message ?? 'Failed to send OTP';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e, stackTrace) {
      _handleException('sendVerificationOTP', e, stackTrace);
    }
  }

  // Forgot password with OTP
  Future<void> forgotPassword(String email) async {
    try {
      status.value = AuthStatus.loading;
      errorMessage.value = '';

      final response = await _authService.sendPasswordResetOTP(email);

      if (response.success) {
        status.value = AuthStatus.success;

        // Navigate to OTP verification
        NavigationService.goToOTPVerification(
          email: email,
          type: OTPType.PasswordReset,
        );

        Get.snackbar('Success', 'OTP sent to your email');
      } else {
        status.value = AuthStatus.error;
        errorMessage.value = response.message ?? 'Failed to send OTP';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e, stackTrace) {
      _handleException('forgotPassword', e, stackTrace);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      log('📱 [AuthViewModel] logout() started', name: 'Auth');
      final response = await _authService.logout();

      if (response.success) {
        currentUser.value = null;
        status.value = AuthStatus.initial;
        clearForm();

        await _clearUserSession();

        log('📱 [AuthViewModel] Logout successful', name: 'Auth');
        NavigationService.goToLogin();
      } else {
        errorMessage.value = response.message ?? 'Logout failed';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e, stackTrace) {
      log('🔥 [AuthViewModel] Exception in logout(): $e', name: 'Auth');
      NavigationService.goToLogin();
    }
  }

  // Helper methods
  User? _parseUserFromResponse(Map<String, dynamic> responseData) {
    try {
      Map<String, dynamic> userData;

      if (responseData.containsKey('user')) {
        userData = responseData['user'] as Map<String, dynamic>;
      } else {
        userData = responseData;
      }

      return User(
        id: userData['id']?.toString() ?? '',
        email:
            userData['userName']?.toString() ??
            userData['email']?.toString() ??
            '',
        name: '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
            .trim(),
        type: UserType.user,
      );
    } catch (e) {
      log('❌ [AuthViewModel] Error parsing user: $e', name: 'Auth');
      return null;
    }
  }

  void _handleInvalidResponse() {
    errorMessage.value = 'Invalid response format from server';
    status.value = AuthStatus.error;
    Get.snackbar('Error', errorMessage.value);
  }

  void _handleLoginError(String? message) {
    errorMessage.value =
        message ?? 'Login failed. Please check your credentials.';
    status.value = AuthStatus.error;
    Get.snackbar('Error', errorMessage.value);
  }

  void _handleSignupError(String? message) {
    errorMessage.value = message ?? 'Signup failed';
    status.value = AuthStatus.error;
    Get.snackbar('Error', errorMessage.value);
  }

  void _handleException(String method, dynamic e, StackTrace stackTrace) {
    log('🔥 [AuthViewModel] Exception in $method(): $e', name: 'Auth');

    errorMessage.value = 'Connection error: ${e.toString()}';
    status.value = AuthStatus.error;
    Get.snackbar('Error', errorMessage.value);
  }

  Future<void> _saveUserSession(User user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_name', user.name);
      await prefs.setString('auth_token', token);
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('remember_me', rememberMe.value);

      log('📱 [AuthViewModel] User session saved', name: 'Auth');
    } catch (e) {
      log('❌ [AuthViewModel] Error saving user session: $e', name: 'Auth');
    }
  }

  Future<void> _clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('auth_token');
      await prefs.setBool('is_logged_in', false);

      log('📱 [AuthViewModel] User session cleared', name: 'Auth');
    } catch (e) {
      log('❌ [AuthViewModel] Error clearing user session: $e', name: 'Auth');
    }
  }

  Future<void> checkSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final rememberMeValue = prefs.getBool('remember_me') ?? false;

      if (isLoggedIn && rememberMeValue) {
        final email = prefs.getString('user_email');
        final name = prefs.getString('user_name');
        final token = prefs.getString('auth_token');

        if (email != null && name != null && token != null) {
          currentUser.value = User(
            id: prefs.getString('user_id') ?? '',
            email: email,
            name: name,
            type: UserType.user,
          );

          _authService.setAuthToken(token);
          rememberMe.value = true;

          log('📱 [AuthViewModel] User session restored', name: 'Auth');
          NavigationService.goToChat();
        }
      }
    } catch (e) {
      log('❌ [AuthViewModel] Error checking saved session: $e', name: 'Auth');
    }
  }

  Future<bool> isEmailVerified(String email) async {
    try {
      final response = await _authService.checkEmailVerified(email);
      return response.success && (response.data ?? false);
    } catch (e) {
      log(
        '❌ [AuthViewModel] Error checking email verification: $e',
        name: 'Auth',
      );
      return false;
    }
  }

  void clearForm() {
    email.value = '';
    password.value = '';
    confirmPassword.value = '';
    firstName.value = '';
    lastName.value = '';
    obscurePassword.value = true;
    obscureConfirmPassword.value = true;
    emailError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';
    firstNameError.value = '';
    lastNameError.value = '';
    errorMessage.value = '';
    agreeToTerms.value = false;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
    log(
      '📱 [AuthViewModel] Remember me toggled: ${rememberMe.value}',
      name: 'Auth',
    );
  }

  @override
  void onClose() {
    clearForm();
    super.onClose();
  }
}
