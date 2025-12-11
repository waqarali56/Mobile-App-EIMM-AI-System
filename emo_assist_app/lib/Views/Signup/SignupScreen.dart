// lib/Views/Signup/SignupScreen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/ViewModels/AuthViewModel.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final AuthViewModel viewModel = Get.find<AuthViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Create Account',
                style: Constants.headlineMedium.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Join EmoAssist today',
                style: Constants.bodyMedium.copyWith(
                  color: Colors.black54,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Error Message with conditional spacing
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
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
              
              // First Name Field
              Obx(() => TextFormField(
                decoration: InputDecoration(
                  labelText: 'First Name',
                  hintText: 'Enter your first name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                  errorText: viewModel.firstNameError.value.isEmpty
                      ? null
                      : viewModel.firstNameError.value,
                ),
                onChanged: (value) {
                  viewModel.firstName.value = value;
                  viewModel.validateFirstName();
                },
                textInputAction: TextInputAction.next,
              )),
              const SizedBox(height: 16),
              
              // Last Name Field
              Obx(() => TextFormField(
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  hintText: 'Enter your last name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                  errorText: viewModel.lastNameError.value.isEmpty
                      ? null
                      : viewModel.lastNameError.value,
                ),
                onChanged: (value) {
                  viewModel.lastName.value = value;
                  viewModel.validateLastName();
                },
                textInputAction: TextInputAction.next,
              )),
              const SizedBox(height: 16),
              
              // Email Field
              Obx(() => TextFormField(
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
                onChanged: (value) {
                  viewModel.email.value = value;
                  viewModel.validateEmail();
                },
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              )),
              const SizedBox(height: 16),
              
              // Password Field with Toggle
              Obx(() => TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      viewModel.obscurePassword.value 
                          ? Icons.visibility_off 
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => viewModel.togglePasswordVisibility(),
                  ),
                  errorText: viewModel.passwordError.value.isEmpty
                      ? null
                      : viewModel.passwordError.value,
                ),
                onChanged: (value) {
                  viewModel.password.value = value;
                  viewModel.validatePassword();
                },
                obscureText: viewModel.obscurePassword.value,
                textInputAction: TextInputAction.next,
              )),
              const SizedBox(height: 16),
              
              // Confirm Password Field with Toggle
              Obx(() => TextFormField(
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      viewModel.obscureConfirmPassword.value 
                          ? Icons.visibility_off 
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => viewModel.toggleConfirmPasswordVisibility(),
                  ),
                  errorText: viewModel.confirmPasswordError.value.isEmpty
                      ? null
                      : viewModel.confirmPasswordError.value,
                ),
                onChanged: (value) {
                  viewModel.confirmPassword.value = value;
                  viewModel.validateConfirmPassword();
                },
                obscureText: viewModel.obscureConfirmPassword.value,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) async {
                  // Hide keyboard and trigger signup
                  FocusScope.of(context).unfocus();
                  if (viewModel.canSignup) {
                    await viewModel.signup();
                  }
                },
              )),
              
              const SizedBox(height: 30),
              
              // Terms and Conditions Checkbox
              Obx(() => Row(
                children: [
                  Checkbox(
                    value: viewModel.agreeToTerms.value,
                    onChanged: (value) => viewModel.toggleTermsAgreement(),
                    activeColor: Constants.primaryColor,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => viewModel.toggleTermsAgreement(),
                      child: Text.rich(
                        TextSpan(
                          text: 'I agree to the ',
                          style: Constants.bodyMedium,
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: Constants.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: Constants.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
              
              const SizedBox(height: 20),
              
              // Sign Up Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: viewModel.canSignup && viewModel.agreeToTerms.value
                            ? () async {
                                // Hide keyboard when button is pressed
                                FocusScope.of(context).unfocus();
                                await viewModel.signup();
                              }
                            : null,
                        child: const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
              )),
              
              const SizedBox(height: 20),
              
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: Constants.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Constants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}