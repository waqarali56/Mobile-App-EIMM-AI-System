// ViewModels/OTPViewModel.dart
import 'dart:async';
import 'dart:developer' as consol;
import 'package:get/get.dart';
import 'package:emo_assist_app/Enums/AppEnums.dart';
import 'package:emo_assist_app/Models/OTP.dart';
import 'package:emo_assist_app/Services/auth_service.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';

class OTPViewModel extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  // State
  final RxString _email = ''.obs;
  final Rx<OTPType> _type = OTPType.EmailVerification.obs;
  final RxList<String> _otpDigits = <String>['', '', '', '', '', ''].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _countdown = '02:00'.obs;
  final RxBool _canResend = false.obs;
  final RxBool _isVerified = false.obs;

  // Getters
  String get email => _email.value;
  OTPType get type => _type.value;
  List<String> get otpDigits => _otpDigits;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get countdown => _countdown.value;
  bool get canResend => _canResend.value;
  bool get isVerified => _isVerified.value;
  String get otp => _otpDigits.join();

  // Timer
  Timer? _timer;
  int _totalSeconds = 120;

  // Initialize
  void initialize(String email, OTPType type) {
    consol.log('📱 [OTPViewModel] Initializing with email: $email, type: $type');
    
    if (email.isEmpty) {
      _errorMessage.value = 'Email is required';
      Get.snackbar('Error', 'Email is required');
      return;
    }
    
    _email.value = email;
    _type.value = type;
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // Timer methods
  void startTimer() {
    _totalSeconds = 120;
    _countdown.value = '02:00';
    _canResend.value = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSeconds <= 0) {
        timer.cancel();
        _canResend.value = true;
      } else {
        _totalSeconds--;
        final minutes = (_totalSeconds ~/ 60).toString().padLeft(2, '0');
        final seconds = (_totalSeconds % 60).toString().padLeft(2, '0');
        _countdown.value = '$minutes:$seconds';
      }
    });
  }

  void restartTimer() {
    _timer?.cancel();
    startTimer();
  }

  // OTP methods
  void updateOTP(int index, String value) {
    if (value.length > 1) {
      value = value.substring(0, 1);
    }
    
    _otpDigits[index] = value;
    _errorMessage.value = '';
    
    // Auto-verify when last digit is entered
    if (index == 5 && value.isNotEmpty && otp.length == 6) {
      verifyOTP();
    }
  }

  void clearOTP() {
    _otpDigits.value = ['', '', '', '', '', ''];
  }

  // API methods
  Future<void> verifyOTP() async {
    if (otp.length != 6) {
      _errorMessage.value = 'Please enter a valid 6-digit OTP';
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP');
      return;
    }

    if (_email.value.isEmpty) {
      _errorMessage.value = 'Email is required';
      Get.snackbar('Error', 'Email is required');
      return;
    }

    _isLoading.value = true;
    _errorMessage.value = '';

    final request = OTPRequest(
      email: _email.value,
      otp: otp,
      type: _type.value,
    );

    try {
      consol.log('🔐 [OTPViewModel] Verifying OTP for: ${_email.value}');
      final response = await _authService.verifyOTP(request);

     if (response.success) {
    _isVerified.value = true;
    Get.snackbar('Success', 'OTP verified successfully!');
    
    if (_type.value == OTPType.EmailVerification) {
      NavigationService.goToLogin();
    } else if (_type.value == OTPType.PasswordReset) {
      // Navigate to reset password screen
      NavigationService.goToResetPassword(
        email: _email.value,
        otp: otp,
      );
    }
  } else {
        _errorMessage.value = response.message ?? 'Failed to verify OTP';
        Get.snackbar('Error', _errorMessage.value);
        clearOTP();
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', 'Failed to verify OTP');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> resendOTP() async {
    if (!_canResend.value) {
      Get.snackbar('Info', 'Please wait before resending OTP');
      return;
    }

    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      consol.log('📨 [OTPViewModel] Resending OTP to: ${_email.value}');
      final response = await _authService.resendOTP(_email.value, _type.value);

      if (response.success) {
        Get.snackbar('Success', 'OTP sent to ${_email.value}');
        restartTimer();
      } else {
        _errorMessage.value = response.message ?? 'Failed to resend OTP';
        Get.snackbar('Error', _errorMessage.value);
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', 'Failed to resend OTP');
    } finally {
      _isLoading.value = false;
    }
  }

  // Navigation
  void navigateBack() {
    if (_type.value == OTPType.EmailVerification) {
      NavigationService.goToLogin();
    } else {
      NavigationService.goToForgotPassword();
    }
  }

  // Validation
  bool get canVerify => otp.length == 6 && !_isLoading.value;
}