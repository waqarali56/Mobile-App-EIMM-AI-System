import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Enums/AppEnums.dart';
import '../../ViewModels/AuthViewModel.dart';
import '../../Resources/Constants.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final AuthViewModel _authViewModel = Get.find<AuthViewModel>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [
            // Left side - Illustration (only for larger screens)
            if (size.width > 700)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Constants.backgroundColor, // ✅ Fixed
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 120,
                        color: Constants.primaryColor, // ✅ Fixed
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Welcome to EmoAssist",
                        style: Constants.headlineLarge.copyWith( // ✅ Fixed
                          color: Constants.primaryColor, // ✅ Fixed
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Your Emotional AI Companion",
                        style: Constants.bodyLarge.copyWith( // ✅ Fixed
                          color: Colors.grey[600], // ✅ Fixed: Using Material colors
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Constants.primaryColor.withOpacity(0.1), // ✅ Fixed
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.emoji_emotions_outlined,
                          size: 80,
                          color: Constants.primaryColor, // ✅ Fixed
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Right side - Login Form
            Expanded(
              child: Container(
                margin: size.width > 700 
                    ? const EdgeInsets.fromLTRB(20, 20, 150, 20)
                    : const EdgeInsets.all(20),
                width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo for mobile
                    if (size.width <= 700) ...[
                      Icon(
                        Icons.psychology,
                        size: 80,
                        color: Constants.primaryColor, // ✅ Fixed
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "EmoAssist",
                        style: Constants.headlineLarge.copyWith( // ✅ Fixed
                          color: Constants.primaryColor, // ✅ Fixed
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Your Emotional AI Companion",
                        style: Constants.bodyMedium, // ✅ Fixed
                      ),
                      const SizedBox(height: 30),
                    ],
                    
                    Text(
                      "Log in to your account",
                      style: Constants.headlineMedium, // ✅ Fixed
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Welcome back! Please enter your details',
                      style: Constants.bodyMedium, // ✅ Fixed
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    
                    // Login Form
                    _buildLoginForm(),
                    
                    const SizedBox(height: 20),
                    
                    // Sign up option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: Constants.bodyMedium, // ✅ Fixed
                        ),
                        TextButton(
                          onPressed: () {
                            Get.toNamed('/signup');
                          },
                          child: Text(
                            'Sign up',
                            style: Constants.bodyLarge.copyWith( // ✅ Fixed
                              color: Constants.primaryColor, // ✅ Fixed
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Guest login option
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Constants.primaryColor), // ✅ Fixed
                        ),
                        onPressed: () {
                          Get.offAllNamed('/chat');
                        },
                        child: Text(
                          'Continue as Guest',
                          style: Constants.bodyLarge.copyWith( // ✅ Fixed
                            color: Constants.primaryColor, // ✅ Fixed
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Email Field
        Obx(() => TextFormField(
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.email_outlined),
            errorText: _authViewModel.emailError.value.isEmpty 
                ? null 
                : _authViewModel.emailError.value,
          ),
          onChanged: (value) {
            _authViewModel.email.value = value;
            _authViewModel.validateEmail();
          },
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        )),
        
        const SizedBox(height: 16),
        
        // Password Field
        Obx(() => TextFormField(
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_outline),
            errorText: _authViewModel.passwordError.value.isEmpty 
                ? null 
                : _authViewModel.passwordError.value,
          ),
          onChanged: (value) {
            _authViewModel.password.value = value;
            _authViewModel.validatePassword();
          },
          obscureText: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _login(),
        )),
        
        const SizedBox(height: 16),
        
        // Remember Me & Forgot Password
        Row(
          children: [
            Obx(() => Checkbox(
              value: _authViewModel.rememberMe.value,
              onChanged: (v) {
                _authViewModel.toggleRememberMe();
              },
              activeColor: Constants.primaryColor, // ✅ Fixed
            )),
            Text(
              "Remember for 30 days",
              style: Constants.bodyMedium, // ✅ Fixed
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Get.snackbar(
                  'Forgot Password',
                  'Feature coming soon!',
                  backgroundColor: Constants.primaryColor, // ✅ Fixed
                  colorText: Colors.white,
                );
              },
              child: Text(
                'Forgot password?',
                style: Constants.bodyMedium.copyWith( // ✅ Fixed
                  color: Constants.primaryColor, // ✅ Fixed
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Login Button
        Obx(() {
          return SizedBox(
            width: double.infinity,
            height: 50,
            child: _authViewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Constants.primaryColor), // ✅ Fixed
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor, // ✅ Fixed
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _authViewModel.canLogin ? _login : null,
                    child: Text(
                      'Sign in',
                      style: Constants.bodyLarge.copyWith( // ✅ Fixed
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          );
        }),
      ],
    );
  }

  void _login() {
    if (_authViewModel.canLogin) {
      _authViewModel.login();
      
      // Listen for login success/error
      ever(_authViewModel.status, (status) {
        if (status == AuthStatus.success) {
          Get.offAllNamed('/chat');
          Get.snackbar(
            'Success',
            'Login successful!',
            backgroundColor: Constants.successColor, // ✅ Fixed
            colorText: Colors.white,
          );
        } else if (status == AuthStatus.error) {
          Get.snackbar(
            'Error',
            _authViewModel.errorMessage.value,
            backgroundColor: Constants.errorColor, // ✅ Fixed
            colorText: Colors.white,
          );
        }
      });
    }
  }
}