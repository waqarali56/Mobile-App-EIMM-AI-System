// ViewModels/AuthViewModel.dart
import 'dart:convert';
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
    _authService.apiClient.setSessionRefreshHandler(_onSessionRefreshRequested);
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

          final payload = _unwrapAuthPayload(userData);
          User? user = _parseUserFromResponse(payload);

          if (user != null) {
            currentUser.value = user;

            final accessToken = _readStringToken(
              payload,
              keys: const ['accessToken', 'access_token'],
            );
            final refreshToken = _readStringToken(
              payload,
              keys: const ['refreshToken', 'refresh_token'],
            );
            if (accessToken != null) {
              _authService.setAuthToken(accessToken);
              if (refreshToken != null) {
                _authService.setRefreshToken(refreshToken);
              }
              await _saveUserToPreferences(
                user,
                accessToken: accessToken,
                refreshToken: refreshToken,
              );
            } else {
              await _saveUserToPreferences(user);
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
          log('📱 [AuthViewModel] Sending verification OTP after signup',
              name: 'Auth');

          // Store email temporarily before clearing form
          final userEmail = email.value.trim();

          // Clear form
          clearForm();

          // Navigate to OTP verification with email
          NavigationService.goToOTPVerification(
            email: userEmail,
            type: OTPType.EmailVerification,
          );

          Get.snackbar(
              'Success', 'Signup successful! Please verify your email.');
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
        email: userData['userName']?.toString() ??
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

  /// Saves user data to SharedPreferences on every login.
  /// When [accessToken] and remember_me are set, also saves tokens for session restore.
  Future<void> _saveUserToPreferences(
    User user, {
    String? accessToken,
    String? refreshToken,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_name', user.name);
      await prefs.setBool('is_logged_in', true);

      if (accessToken != null) {
        await prefs.setString('auth_token', accessToken);
        if (refreshToken != null) {
          await prefs.setString('refresh_token', refreshToken);
        }
        await prefs.setBool('remember_me', true);
        log('📱 [AuthViewModel] User and session saved (remember me)',
            name: 'Auth');
      } else {
        log('📱 [AuthViewModel] User data saved to preferences', name: 'Auth');
      }
    } catch (e) {
      log('❌ [AuthViewModel] Error saving user to preferences: $e',
          name: 'Auth');
    }
  }

  Future<void> _clearUserSession() async {
    try {
      _authService.clearAuthToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      await prefs.remove('remember_me');
      await prefs.setBool('is_logged_in', false);

      log('📱 [AuthViewModel] User session cleared', name: 'Auth');
    } catch (e) {
      log('❌ [AuthViewModel] Error clearing user session: $e', name: 'Auth');
    }
  }

  /// Loads stored tokens into [ApiClient], restores [currentUser], and refreshes if the
  /// access JWT is expired. Call from [SplashViewModel] before routing so API calls work.
  Future<void> restoreSessionFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        return;
      }

      final email = prefs.getString('user_email');
      final name = prefs.getString('user_name');
      if (email != null && name != null) {
        currentUser.value = User(
          id: prefs.getString('user_id') ?? '',
          email: email,
          name: name,
          type: UserType.user,
        );
      }
      rememberMe.value = prefs.getBool('remember_me') ?? false;

      _authService.setAuthToken(token);
      final storedRefresh = prefs.getString('refresh_token');
      if (storedRefresh != null && storedRefresh.isNotEmpty) {
        _authService.setRefreshToken(storedRefresh);
      }

      log('📱 [AuthViewModel] Session tokens applied from storage',
          name: 'Auth');

      final expired = _isJwtExpiredOrExpiringSoon(token);
      if (!expired) return;

      if (storedRefresh == null || storedRefresh.isEmpty) {
        log('⚠️ [AuthViewModel] Access token expired, no refresh token in storage',
            name: 'Auth');
        await _clearUserSession();
        return;
      }

      final ok = await _performTokenRefresh();
      if (!ok) {
        log('⚠️ [AuthViewModel] Startup token refresh failed', name: 'Auth');
        await _clearUserSession();
      }
    } catch (e, st) {
      log('❌ [AuthViewModel] restoreSessionFromStorage: $e',
          name: 'Auth', error: e, stackTrace: st);
    }
  }

  /// If the HTTP client has no bearer token but prefs still hold one (e.g. race with splash),
  /// apply them. Does not navigate.
  Future<void> applyStoredTokensToApiClientIfMissing() async {
    try {
      final existing = _authService.authToken;
      if (existing != null && existing.isNotEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) return;

      _authService.setAuthToken(token);
      final r = prefs.getString('refresh_token');
      if (r != null && r.isNotEmpty) {
        _authService.setRefreshToken(r);
      }
      log('📱 [AuthViewModel] Applied missing API tokens from prefs',
          name: 'Auth');
    } catch (e) {
      log('❌ [AuthViewModel] applyStoredTokensToApiClientIfMissing: $e',
          name: 'Auth');
    }
  }

  Future<void> _ensureRefreshTokenFromPrefsIfMissing() async {
    try {
      final cur = _authService.apiClient.refreshToken;
      if (cur != null && cur.isNotEmpty) return;
      final prefs = await SharedPreferences.getInstance();
      final r = prefs.getString('refresh_token');
      if (r != null && r.isNotEmpty) {
        _authService.setRefreshToken(r);
      }
    } catch (e) {
      log('❌ [AuthViewModel] _ensureRefreshTokenFromPrefsIfMissing: $e',
          name: 'Auth');
    }
  }

  /// Call before orchestrator calls (`/analyze`, `/sessions`) so expired JWTs are refreshed
  /// before large uploads; also loads tokens/refresh from prefs when missing in memory.
  Future<void> ensureFreshAccessTokenForProtectedApis() async {
    try {
      await applyStoredTokensToApiClientIfMissing();
      await _ensureRefreshTokenFromPrefsIfMissing();
      final token = _authService.authToken;
      if (token == null || token.isEmpty) return;
      if (!_isJwtExpiredOrExpiringSoon(token)) return;
      final refresh = _authService.apiClient.refreshToken;
      if (refresh == null || refresh.isEmpty) {
        log(
          '⚠️ [AuthViewModel] Access JWT expired but no refresh token for proactive refresh',
          name: 'Auth',
        );
        return;
      }
      final ok = await _performTokenRefresh();
      if (ok) {
        log('📱 [AuthViewModel] Proactive token refresh before orchestrator call',
            name: 'Auth');
      }
    } catch (e, st) {
      log('⚠️ [AuthViewModel] ensureFreshAccessTokenForProtectedApis: $e',
          name: 'Auth', error: e, stackTrace: st);
    }
  }

  /// Loads user from SharedPreferences into currentUser (e.g. when opening profile).
  Future<void> loadUserFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      final name = prefs.getString('user_name');
      if (email == null || name == null) return;
      currentUser.value = User(
        id: prefs.getString('user_id') ?? '',
        email: email,
        name: name,
        type: UserType.user,
      );
    } catch (e) {
      log('❌ [AuthViewModel] Error loading user from preferences: $e',
          name: 'Auth');
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

  /// Returns true if new access token was applied (and persisted when appropriate).
  Future<bool> _performTokenRefresh() async {
    final response = await _authService.refreshToken();
    if (response.success && response.data != null) {
      final data = _unwrapAuthPayload(response.data!);
      final access = _readStringToken(
        data,
        keys: const ['accessToken', 'access_token'],
      );
      final newRefresh = _readStringToken(
        data,
        keys: const ['refreshToken', 'refresh_token'],
      );
      if (access != null && access.isNotEmpty) {
        _authService.setAuthToken(access);
        if (newRefresh != null && newRefresh.isNotEmpty) {
          _authService.setRefreshToken(newRefresh);
        }
        await _persistRefreshedTokens(
          accessToken: access,
          refreshToken: newRefresh,
        );
        log('📱 [AuthViewModel] Session refreshed', name: 'Auth');
        return true;
      }
    }
    log(
      '⚠️ [AuthViewModel] Token refresh failed: ${response.message}',
      name: 'Auth',
    );
    return false;
  }

  /// Called by [ApiClient] on 401 (deduped). Refreshes tokens or clears session and opens login.
  Future<bool> _onSessionRefreshRequested() async {
    try {
      final refresh = _authService.apiClient.refreshToken;
      if (refresh == null || refresh.isEmpty) {
        log('⚠️ [AuthViewModel] No refresh token; cannot refresh session',
            name: 'Auth');
        await _clearSessionAndNavigateToLogin();
        return false;
      }

      final ok = await _performTokenRefresh();
      if (ok) return true;
    } catch (e, stackTrace) {
      log('🔥 [AuthViewModel] Token refresh exception: $e',
          name: 'Auth', error: e, stackTrace: stackTrace);
    }
    await _clearSessionAndNavigateToLogin();
    return false;
  }

  Future<void> _clearSessionAndNavigateToLogin() async {
    currentUser.value = null;
    status.value = AuthStatus.initial;
    clearForm();
    await _clearUserSession();
    NavigationService.goToLogin();
    Get.snackbar(
      'Session expired',
      'Please sign in again.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// After refresh, persist so the next cold start does not reuse an expired access token.
  Future<void> _persistRefreshedTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remember = prefs.getBool('remember_me') == true;
      final hadStoredAccess = prefs.containsKey('auth_token');
      if (!remember && !hadStoredAccess) return;
      await prefs.setString('auth_token', accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await prefs.setString('refresh_token', refreshToken);
      }
    } catch (e) {
      log('❌ [AuthViewModel] Error persisting refreshed tokens: $e',
          name: 'Auth');
    }
  }

  /// JWT `exp` is UTC; if payload cannot be read, returns false (rely on 401 refresh path).
  bool _isJwtExpiredOrExpiringSoon(
    String jwt, {
    Duration skew = const Duration(seconds: 90),
  }) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return false;
      var segment = parts[1];
      switch (segment.length % 4) {
        case 1:
          segment += '===';
          break;
        case 2:
          segment += '==';
          break;
        case 3:
          segment += '=';
          break;
      }
      final decoded = json.decode(
        utf8.decode(base64Url.decode(segment)),
      );
      if (decoded is! Map<String, dynamic>) return false;
      final exp = decoded['exp'];
      if (exp is! num) return false;
      final expiry =
          DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
      final now = DateTime.now().toUtc();
      return !now.isBefore(expiry.subtract(skew));
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _unwrapAuthPayload(Map<String, dynamic> root) {
    final inner = root['data'];
    if (inner is Map<String, dynamic>) return inner;
    return root;
  }

  String? _readStringToken(
    Map<String, dynamic> map, {
    required List<String> keys,
  }) {
    for (final k in keys) {
      final v = map[k];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }

  @override
  void onClose() {
    _authService.apiClient.setSessionRefreshHandler(null);
    clearForm();
    super.onClose();
  }
}
