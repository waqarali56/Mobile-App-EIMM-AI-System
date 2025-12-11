class SendOTPRequest {
  final String email;
  final OTPType type;

  SendOTPRequest({
    required this.email,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'type': type.toString().split('.').last,
  };
}

class OTPRequest {
  final String email;
  final String otp;
  final OTPType type;

  OTPRequest({
    required this.email,
    required this.otp,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
    'type': type.toString().split('.').last,
  };
}

// Models/OTP.dart - Update the ResetPasswordWithOTPRequest model
class ResetPasswordWithOTPRequest {
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordWithOTPRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
}

class SendOTPResponse {
  final String email;
  final String message;
  final DateTime expiresAt;
  final OTPType type;

  SendOTPResponse({
    required this.email,
    required this.message,
    required this.expiresAt,
    required this.type,
  });

  factory SendOTPResponse.fromJson(Map<String, dynamic> json) {
    return SendOTPResponse(
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      expiresAt: DateTime.parse(json['expiresAt']),
      type: OTPType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => OTPType.EmailVerification,
      ),
    );
  }
}

class OTPResponse {
  final String email;
  final bool isVerified;
  final String message;
  final DateTime expiresAt;
  final OTPType type;

  OTPResponse({
    required this.email,
    required this.isVerified,
    required this.message,
    required this.expiresAt,
    required this.type,
  });

  factory OTPResponse.fromJson(Map<String, dynamic> json) {
    return OTPResponse(
      email: json['email'] ?? '',
      isVerified: json['isVerified'] ?? false,
      message: json['message'] ?? '',
      expiresAt: DateTime.parse(json['expiresAt']),
      type: OTPType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => OTPType.EmailVerification,
      ),
    );
  }
}


class OTPVerificationState {
  final String email;
  final OTPType type;
  final List<String> otpDigits;
  final bool isLoading;
  final String errorMessage;
  final String countdown;
  final bool canResend;
  final bool isVerified;

  OTPVerificationState({
    required this.email,
    required this.type,
    this.otpDigits = const ['', '', '', '', '', ''],
    this.isLoading = false,
    this.errorMessage = '',
    this.countdown = '02:00',
    this.canResend = false,
    this.isVerified = false,
  });

  OTPVerificationState copyWith({
    String? email,
    OTPType? type,
    List<String>? otpDigits,
    bool? isLoading,
    String? errorMessage,
    String? countdown,
    bool? canResend,
    bool? isVerified,
  }) {
    return OTPVerificationState(
      email: email ?? this.email,
      type: type ?? this.type,
      otpDigits: otpDigits ?? this.otpDigits,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      countdown: countdown ?? this.countdown,
      canResend: canResend ?? this.canResend,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}



enum OTPType {
  EmailVerification,
  PasswordReset,
  TwoFactorAuth,
  AccountRecovery
}