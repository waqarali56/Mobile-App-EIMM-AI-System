// ViewModels/ForgotPasswordViewModel.dart
import 'dart:developer' as developer;

import 'package:emo_assist_app/Models/OTP.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Services/auth_service.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';

class ForgotPasswordViewModel extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  // Rx values for reactive state
  final RxString email = ''.obs;
  final RxString emailError = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSuccess = false.obs;
  final RxString successMessage = ''.obs;

  // Email validation regex
  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Validation
  bool get isValidEmail => emailError.value.isEmpty && email.value.trim().isNotEmpty;

  void validateEmail() {
    final emailValue = email.value.trim();
    
    if (emailValue.isEmpty) {
      emailError.value = 'Email is required';
      return;
    }
    
    if (!emailRegex.hasMatch(emailValue)) {
      emailError.value = 'Please enter a valid email address';
      return;
    }
    
    emailError.value = '';
  }

  // Reset all fields
  void reset() {
    email.value = '';
    emailError.value = '';
    errorMessage.value = '';
    isLoading.value = false;
    isSuccess.value = false;
    successMessage.value = '';
  }


Future<bool> sendPasswordResetOTP() async {
  // Validate email
  validateEmail();
  if (!isValidEmail) {
    errorMessage.value = emailError.value;
    Get.snackbar(
      'Validation Error',
      emailError.value,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return false;
  }

  // Clear previous messages
  errorMessage.value = '';
  successMessage.value = '';
  isSuccess.value = false;
  isLoading.value = true;

  try {
    final emailValue = email.value.trim();
    
    // Add proper logging to see the email being passed
    developer.log('📱 [ForgotPasswordViewModel] Sending password reset OTP to: $emailValue');
    developer.log('📱 [ForgotPasswordViewModel] Email value before sending: $emailValue');
    developer.log('📱 [ForgotPasswordViewModel] Email raw (from Rx): ${email.value}');
    developer.log('📱 [ForgotPasswordViewModel] Email trimmed: $emailValue');
    
    // Log the type of the email value
    developer.log('📱 [ForgotPasswordViewModel] Email type: ${emailValue.runtimeType}');
    
  

    // Call the auth service to send password reset OTP
    final response = await _authService.sendPasswordResetOTP(emailValue);
    
    // Log the response
    developer.log('📱 [ForgotPasswordViewModel] API Response success: ${response.success}');
    developer.log('📱 [ForgotPasswordViewModel] API Response message: ${response.message}');
    
    if (response.success) {
      // Success - navigate to OTP verification screen
      isSuccess.value = true;
      successMessage.value = 'OTP sent to your email';
      
      Get.snackbar(
        'Success',
        'OTP sent to $emailValue',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Log navigation details
      developer.log('📱 [ForgotPasswordViewModel] Navigating to OTP verification with email: $emailValue');
      
      // Navigate to OTP verification screen
      NavigationService.goToOTPVerification(
        email: emailValue,
        type: OTPType.PasswordReset,
      );
      
      return true;
    } else {
      // Handle API error
      errorMessage.value = response.message ?? 'Failed to send OTP';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  } catch (e) {
    // Handle network or other errors
    errorMessage.value = 'An error occurred: $e';
    Get.snackbar(
      'Error',
      'Failed to send OTP. Please try again.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    
    // Log the error
    developer.log('🔥 [ForgotPasswordViewModel] Error in sendPasswordResetOTP: $e');
    developer.log('🔥 [ForgotPasswordViewModel] Error stack trace: ${e.toString()}');
    
    return false;
  } finally {
    isLoading.value = false;
  }
}


 // Alternative: Use the generic sendOTP method
  Future<bool> sendPasswordResetOTPViaSendOTP() async {
    validateEmail();
    if (!isValidEmail) {
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final emailValue = email.value.trim();
      
      final response = await _authService.sendOTP(
        SendOTPRequest(
          email: emailValue,
          type: OTPType.PasswordReset,
        ),
      );
      
      if (response.success) {
        Get.snackbar(
          'Success',
          'OTP sent to $emailValue',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        NavigationService.goToOTPVerification(
          email: emailValue,
          type: OTPType.PasswordReset,
        );
        
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to send OTP';
        Get.snackbar(
          'Error',
          errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        'Failed to send OTP',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate back
  void navigateBack() {
    NavigationService.goBack();
  }

  // Navigate to login
  void navigateToLogin() {
    NavigationService.goToLogin();
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}