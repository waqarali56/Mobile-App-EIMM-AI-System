// lib/ViewModels/SplashViewModel.dart
import 'package:emo_assist_app/Resources/app_routes.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashViewModel extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for splash screen duration
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool('first_launch') ?? true;
    
    if (isFirstLaunch) {
      // First time - show onboarding
      await prefs.setBool('first_launch', false);
      AppRoutes.goToOnboarding();  // CHANGED
    } else {
      // Check if user is logged in
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final isGuest = prefs.getBool('is_guest') ?? false;
      
      if (isLoggedIn || isGuest) {
        AppRoutes.goToChat();  // CHANGED
      } else {
        AppRoutes.goToLogin();  // CHANGED
      }
    }
  }
}