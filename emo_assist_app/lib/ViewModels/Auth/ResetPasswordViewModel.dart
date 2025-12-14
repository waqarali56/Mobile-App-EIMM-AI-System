// ViewModels/ResetPasswordViewModel.dart
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Models/OTP.dart';
import 'package:emo_assist_app/Services/auth_service.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';

class ResetPasswordViewModel extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  // Form fields
  final RxString newPassword = ''.obs;
  final RxString confirmPassword = ''.obs;
  
  // Password visibility
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  
  // Validation errors
  final RxString newPasswordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;
  
  // State
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  
  // Email and OTP (passed from previous screens)
  final RxString email = ''.obs;
  final RxString otp = ''.obs;
  
  // TextEditingController references (optional, for manual clearing)
  TextEditingController? _newPasswordController;
  TextEditingController? _confirmPasswordController;

  // Set controllers (called from screen)
  void setControllers({
    required TextEditingController newPasswordController,
    required TextEditingController confirmPasswordController,
  }) {
    _newPasswordController = newPasswordController;
    _confirmPasswordController = confirmPasswordController;
  }

  // Validation getters
  bool get isValidPassword => newPassword.value.length >= 6;
  bool get isValidConfirmPassword => newPassword.value == confirmPassword.value;
  bool get canReset => isValidPassword && 
                       isValidConfirmPassword && 
                       newPasswordError.isEmpty && 
                       confirmPasswordError.isEmpty &&
                       email.value.isNotEmpty &&
                       otp.value.isNotEmpty;

  // Initialize with email and OTP
  void initialize(String email, String otp) {
    log('📱 [ResetPasswordViewModel] Initializing with email: $email, OTP: $otp');
    this.email.value = email;
    this.otp.value = otp;
    
    // Clear any previous errors
    clearErrors();
  }

  // Password visibility methods
  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  // Validation methods
  void validateNewPassword() {
    if (newPassword.value.isEmpty) {
      newPasswordError.value = 'New password is required';
    } else if (!isValidPassword) {
      newPasswordError.value = 'Password must be at least 6 characters';
    } else {
      newPasswordError.value = '';
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

  // Reset password
  Future<void> resetPassword() async {
    try {
      log('📱 [ResetPasswordViewModel] resetPassword() started', name: 'ResetPassword');
      
      // Validate
      validateNewPassword();
      validateConfirmPassword();
      
      if (!canReset) {
        log('❌ [ResetPasswordViewModel] Validation failed', name: 'ResetPassword');
        return;
      }
      
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      
      log('🔐 [ResetPasswordViewModel] Resetting password for: ${email.value}', name: 'ResetPassword');
      
      final request = ResetPasswordWithOTPRequest(
        email: email.value,
        otp: otp.value,
        newPassword: newPassword.value,
        confirmPassword: confirmPassword.value,
      );
      
      // Log the request body
      log('📤 [ResetPasswordViewModel] Request Body: ${request.toJson()}', name: 'ResetPassword');
      
      final response = await _authService.resetPasswordWithOTP(request);
      
      log('📱 [ResetPasswordViewModel] Reset password response: ${response.success}', name: 'ResetPassword');
      log('📱 [ResetPasswordViewModel] Response message: ${response.message}', name: 'ResetPassword');
      
      if (response.success) {
        successMessage.value = 'Password reset successfully!';
        log('✅ [ResetPasswordViewModel] Password reset successful for ${email.value}', name: 'ResetPassword');
        
        // Show success message
        Get.snackbar(
          'Success',
          'Password has been reset successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
        
        // Clear form
        clearForm();
        
        // Navigate to login after a delay
        await Future.delayed(const Duration(seconds: 2));
        NavigationService.goToLogin();
      } else {
        errorMessage.value = response.message ?? 'Failed to reset password';
        log('❌ [ResetPasswordViewModel] Password reset failed: ${errorMessage.value}', name: 'ResetPassword');
        
        // Check for specific error messages
        if (errorMessage.value.toLowerCase().contains('confirm password') ||
            errorMessage.value.toLowerCase().contains('passwords do not match')) {
          // Clear confirm password field
          confirmPassword.value = '';
          if (_confirmPasswordController != null) {
            _confirmPasswordController!.clear();
          }
          validateConfirmPassword();
        }
        
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    } on SocketException catch (e) {
      errorMessage.value = 'Network error: ${e.message}';
      log('🌐 [ResetPasswordViewModel] SocketException: $e', name: 'ResetPassword');
      
      Get.snackbar(
        'Network Error',
        'Please check your internet connection and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      errorMessage.value = 'HTTP error: ${e.message}';
      log('🌐 [ResetPasswordViewModel] HttpException: $e', name: 'ResetPassword');
      
      Get.snackbar(
        'Connection Error',
        'Failed to connect to the server. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } on FormatException catch (e) {
      errorMessage.value = 'Data format error: ${e.message}';
      log('📊 [ResetPasswordViewModel] FormatException: $e', name: 'ResetPassword');
      
      Get.snackbar(
        'Data Error',
        'Invalid response from server. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      log('🔥 [ResetPasswordViewModel] Exception: $e', name: 'ResetPassword');
      log('🔥 [ResetPasswordViewModel] Stack trace: $stackTrace', name: 'ResetPassword');
      
      Get.snackbar(
        'Error',
        'Failed to reset password. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear form
  void clearForm() {
    newPassword.value = '';
    confirmPassword.value = '';
    obscureNewPassword.value = true;
    obscureConfirmPassword.value = true;
    newPasswordError.value = '';
    confirmPasswordError.value = '';
    errorMessage.value = '';
    successMessage.value = '';
    
    // Clear controllers if they exist
    if (_newPasswordController != null) {
      _newPasswordController!.clear();
    }
    if (_confirmPasswordController != null) {
      _confirmPasswordController!.clear();
    }
  }

  // Clear errors
  void clearErrors() {
    newPasswordError.value = '';
    confirmPasswordError.value = '';
    errorMessage.value = '';
    successMessage.value = '';
  }

  // Navigate back
  void navigateBack() {
    // Clear form before navigating back
    clearForm();
    NavigationService.goToLogin();
  }

  // Check if passwords match
  bool get passwordsMatch => newPassword.value == confirmPassword.value;

  // Get password strength level
  PasswordStrength get passwordStrength {
    final password = newPassword.value;
    
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 6) return PasswordStrength.weak;
    if (password.length < 8) return PasswordStrength.fair;
    
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    
    final criteriaCount = [hasUppercase, hasLowercase, hasNumbers, hasSpecial]
        .where((element) => element)
        .length;
    
    if (criteriaCount >= 4) return PasswordStrength.strong;
    if (criteriaCount >= 3) return PasswordStrength.good;
    return PasswordStrength.fair;
  }

  // Get password strength color
  Color get passwordStrengthColor {
    switch (passwordStrength) {
      case PasswordStrength.none:
        return Colors.grey;
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.fair:
        return Colors.orange;
      case PasswordStrength.good:
        return Colors.blue;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  // Get password strength text
  String get passwordStrengthText {
    switch (passwordStrength) {
      case PasswordStrength.none:
        return 'None';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  // Get password strength value (0.0 to 1.0)
  double get passwordStrengthValue {
    switch (passwordStrength) {
      case PasswordStrength.none:
        return 0.0;
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.fair:
        return 0.5;
      case PasswordStrength.good:
        return 0.75;
      case PasswordStrength.strong:
        return 1.0;
    }
  }

  // Get password tips
  String get passwordTips {
    final password = newPassword.value;
    final tips = <String>[];
    
    if (password.isEmpty) return 'Enter a password';
    
    if (password.length < 8) {
      tips.add('Use at least 8 characters');
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      tips.add('Add an uppercase letter');
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      tips.add('Add a lowercase letter');
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      tips.add('Add a number');
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      tips.add('Add a special character');
    }
    
    return tips.isEmpty ? 'Strong password!' : 'For stronger password: ${tips.join(', ')}';
  }

  @override
  void onClose() {
    clearForm();
    super.onClose();
  }
}

// Password strength enum
enum PasswordStrength {
  none,
  weak,
  fair,
  good,
  strong,
}