// lib/Views/Splash/SplashScreen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/ViewModels/SplashViewModel.dart';  // ADD THIS

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // THIS IS CRITICAL: Get the ViewModel instance
    // This triggers onInit() in the ViewModel
    final SplashViewModel viewModel = Get.find<SplashViewModel>();
    
    return Scaffold(
      backgroundColor: Constants.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Icon(
              Icons.psychology,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            
            // App Name
            Text(
              "EmoAssist",
              style: Constants.headlineLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            // Tagline
            Text(
              "Your Emotional AI Companion",
              style: Constants.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Loading indicator
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}