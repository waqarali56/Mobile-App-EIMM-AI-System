// Views/ResetPasswordScreen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/ViewModels/ResetPasswordViewModel.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late ResetPasswordViewModel viewModel;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    viewModel = Get.find<ResetPasswordViewModel>();
    
    // Initialize ViewModel with email and OTP
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String email = widget.email;
      String otp = widget.otp;
      
      // Try to get from route parameters if widget parameters are empty
      if (email.isEmpty) {
        email = Get.parameters['email'] ?? '';
      }
      if (otp.isEmpty) {
        otp = Get.parameters['otp'] ?? '';
      }
      
      // Try to get from arguments
      if (email.isEmpty || otp.isEmpty) {
        final arguments = Get.arguments;
        if (arguments is Map<String, dynamic>) {
          email = arguments['email'] ?? email;
          otp = arguments['otp'] ?? otp;
        }
      }
      
      if (email.isNotEmpty && otp.isNotEmpty) {
        viewModel.initialize(email, otp);
      } else {
        Get.snackbar(
          'Error',
          'Required information missing. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back();
      }
    });
  }
  
  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => viewModel.navigateBack(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Title
              Text(
                'Create New Password',
                style: Constants.headlineMedium.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              
              // Description
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please enter your new password for:',
                    style: Constants.bodyMedium.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      viewModel.email.value.isNotEmpty 
                          ? viewModel.email.value 
                          : 'Loading...',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              )),
              
              const SizedBox(height: 30),
              
              // Error message
              Obx(() {
                if (viewModel.errorMessage.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            viewModel.errorMessage.value,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              
              // Success message
              Obx(() {
                if (viewModel.successMessage.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            viewModel.successMessage.value,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              
              // New Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Password',
                    style: TextStyle(
                      color: Constants.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => TextFormField(
                    controller: _newPasswordController,
                    obscureText: viewModel.obscureNewPassword.value,
                    decoration: InputDecoration(
                      hintText: 'Enter new password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          viewModel.obscureNewPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: viewModel.toggleNewPasswordVisibility,
                      ),
                      errorText: viewModel.newPasswordError.value.isNotEmpty
                          ? viewModel.newPasswordError.value
                          : null,
                    ),
                    onChanged: (value) {
                      viewModel.newPassword.value = value;
                      viewModel.validateNewPassword();
                    },
                  )),
                  const SizedBox(height: 5),
                  Text(
                    'Password must be at least 6 characters',
                    style: TextStyle(
                      fontSize: 12,
                      color: Constants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Confirm Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm Password',
                    style: TextStyle(
                      color: Constants.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: viewModel.obscureConfirmPassword.value,
                    decoration: InputDecoration(
                      hintText: 'Confirm your new password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          viewModel.obscureConfirmPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: viewModel.toggleConfirmPasswordVisibility,
                      ),
                      errorText: viewModel.confirmPasswordError.value.isNotEmpty
                          ? viewModel.confirmPasswordError.value
                          : null,
                    ),
                    onChanged: (value) {
                      viewModel.confirmPassword.value = value;
                      viewModel.validateConfirmPassword();
                    },
                  )),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Reset Password Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  onPressed: viewModel.canReset && !viewModel.isLoading.value
                      ? () {
                          FocusScope.of(context).unfocus();
                          viewModel.resetPassword();
                        }
                      : null,
                  child: viewModel.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              )),
              
              const SizedBox(height: 20),
              
              // Back to Login Button
              Center(
                child: TextButton(
                  onPressed: viewModel.navigateBack,
                  child: Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Constants.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              // Password Strength Indicator
              const SizedBox(height: 30),
              _buildPasswordStrengthIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Obx(() {
      final password = viewModel.newPassword.value;
      String strength = 'None';
      Color color = Colors.grey;
      
      if (password.isNotEmpty) {
        if (password.length < 6) {
          strength = 'Weak';
          color = Colors.red;
        } else if (password.length < 8) {
          strength = 'Fair';
          color = Colors.orange;
        } else if (RegExp(r'[A-Z]').hasMatch(password) && 
                   RegExp(r'[0-9]').hasMatch(password) && 
                   RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
          strength = 'Strong';
          color = Colors.green;
        } else if (password.length >= 8) {
          strength = 'Good';
          color = Colors.blue;
        }
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Strength:',
            style: TextStyle(
              color: Constants.textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: password.isEmpty ? 0 : 
                        password.length < 6 ? 0.25 : 
                        password.length < 8 ? 0.5 : 
                        strength == 'Good' ? 0.75 : 1.0,
                  backgroundColor: Colors.grey.shade200,
                  color: color,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                strength,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          if (password.isNotEmpty)
            Text(
              _getPasswordTips(password),
              style: TextStyle(
                fontSize: 12,
                color: Constants.textSecondaryColor,
              ),
            ),
        ],
      );
    });
  }

  String _getPasswordTips(String password) {
    final tips = <String>[];
    
    if (password.length < 6) {
      tips.add('At least 6 characters');
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      tips.add('Add uppercase letter');
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      tips.add('Add number');
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      tips.add('Add special character');
    }
    
    return tips.isEmpty ? 'Strong password!' : 'Tips: ${tips.join(', ')}';
  }
}