// lib/Views/Signin/SigninScreen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/ViewModels/AuthViewModel.dart';
import 'package:emo_assist_app/Services/storage_service.dart'; // Verify this path

class SigninScreen extends StatelessWidget {
  SigninScreen({super.key});

  final AuthViewModel viewModel = Get.find<AuthViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and App Name
                Column(
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 80,
                      color: Constants.primaryColor,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "EmoAssist",
                      style: Constants.headlineLarge.copyWith(
                        color: Constants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Your Emotional AI Companion",
                      style: Constants.bodyMedium.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 50),
                
                // Login Form
                Column(
                  children: [
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
                            const SizedBox(height: 16), // Moved inside Obx
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    
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
                      textInputAction: TextInputAction.next, // Better UX
                    )),
                    const SizedBox(height: 16),
                    
                    // Password Field with Toggle Visibility
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
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => viewModel.login(),
                    )),
                    const SizedBox(height: 16),
                    
                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Obx(() => Checkbox(
                              value: viewModel.rememberMe.value,
                              onChanged: (v) => viewModel.toggleRememberMe(),
                              activeColor: Constants.primaryColor,
                            )),
                            Text("Remember me", style: Constants.bodyMedium),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to forgot password screen
                            Get.toNamed('/forgot-password');
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: Constants.primaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // Sign In Button
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
                                elevation: 0,
                              ),
                              onPressed: viewModel.canLogin
                                  ? () async {
                                      // Hide keyboard when button is pressed
                                      FocusScope.of(context).unfocus();
                                      await viewModel.login();
                                    }
                                  : null,
                              child: const Text(
                                'Sign In',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                    )),
                    
                    const SizedBox(height: 20),
                    
                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'OR',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Guest Login
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Constants.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => guestLogin(),
                        child: Text(
                          'Continue as Guest',
                          style: TextStyle(
                            color: Constants.primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Constants.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Get.toNamed('/signup');
                          },
                          child: Text(
                            'Sign Up',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> guestLogin() async {
    try {
      final storageService = StorageService();
      await storageService.setGuest(true);
      Get.offAllNamed('/chat');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not login as guest: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}