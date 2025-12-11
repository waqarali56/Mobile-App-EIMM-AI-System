// Views/ForgotPasswordScreen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/ViewModels/ForgotPasswordViewModel.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final ForgotPasswordViewModel viewModel = Get.find<ForgotPasswordViewModel>();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
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
                'Reset Password',
                style: Constants.headlineMedium.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Description
              Text(
                'Enter your email address and we\'ll send you an OTP to reset your password.',
                style: Constants.bodyMedium.copyWith(color: Colors.black54),
              ),

              const SizedBox(height: 40),

              // Error Message
              Obx(() {
                if (viewModel.errorMessage.value.isNotEmpty) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                viewModel.errorMessage.value,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              // Success Message
              Obx(() {
                if (viewModel.successMessage.value.isNotEmpty) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                viewModel.successMessage.value,
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              // Email Field
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                  errorText: viewModel.emailError.value.isEmpty
                      ? null
                      : viewModel.emailError.value,
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  viewModel.email.value = value;
                  viewModel.validateEmail();
                },
                onFieldSubmitted: (_) async {
                  FocusScope.of(context).unfocus();
                  await viewModel.sendPasswordResetOTP();
                },
              ),

              const SizedBox(height: 40),

              // Send OTP Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: viewModel.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            await viewModel.sendPasswordResetOTP();
                          },
                          child: const Text(
                            'Send OTP',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () => viewModel.navigateToLogin(),
                  child: Text(
                    'Back to Login',
                    style: TextStyle(color: Constants.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
