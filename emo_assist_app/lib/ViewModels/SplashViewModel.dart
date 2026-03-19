import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';
import 'package:emo_assist_app/Enums/AppEnums.dart';
import 'package:emo_assist_app/ViewModels/Auth/AuthViewModel.dart';

class SplashViewModel extends GetxController {
  final Rx<AppStatus> status = AppStatus.loading.obs;
  final RxString loadingMessage = 'Initializing...'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Basic initialization
      loadingMessage.value = 'Loading app...';
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Check shared preferences
      loadingMessage.value = 'Checking preferences...';
      final prefs = await SharedPreferences.getInstance();
      
      // Step 3: Check if first launch
      await Future.delayed(const Duration(milliseconds: 500));
      final bool isFirstLaunch = prefs.getBool('first_launch') ?? true;
      
      if (!isFirstLaunch) {
        // First time - show onboarding
        loadingMessage.value = 'Welcome to EmoAssist!';
        await prefs.setBool('first_launch', false);
        await Future.delayed(const Duration(milliseconds: 500));
        NavigationService.goToOnboarding();
        return;
      }

      // Step 4: Check user authentication status
      loadingMessage.value = 'Checking authentication...';
      await Future.delayed(const Duration(milliseconds: 500));

      // Load tokens into ApiClient + refresh if JWT expired (Splash used to skip this).
      loadingMessage.value = 'Restoring session...';
      await Get.find<AuthViewModel>().restoreSessionFromStorage();

      final prefsAuth = await SharedPreferences.getInstance();
      final isLoggedIn = prefsAuth.getBool('is_logged_in') ?? false;
      final isGuest = prefsAuth.getBool('is_guest') ?? false;
      final authToken = prefsAuth.getString('auth_token');
      
      // Step 5: Navigate based on authentication status
      if (isLoggedIn || isGuest || authToken != null) {
        loadingMessage.value = 'Welcome back!';
        await Future.delayed(const Duration(milliseconds: 500));
        NavigationService.goToHome();
      } else {
        loadingMessage.value = 'Ready to get started!';
        await Future.delayed(const Duration(milliseconds: 500));
        NavigationService.goToLogin();
      }
      
      status.value = AppStatus.success;
      
    } catch (e) {
      // Handle errors gracefully
      status.value = AppStatus.error;
      loadingMessage.value = 'Error: $e';
      
      Get.snackbar(
        'Initialization Error',
        'Failed to initialize app. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Fallback: Navigate to login after error
      await Future.delayed(const Duration(seconds: 1));
      NavigationService.goToLogin();
    }
  }

  // Optional: Retry initialization if failed
  Future<void> retryInitialization() async {
    status.value = AppStatus.loading;
    loadingMessage.value = 'Retrying...';
    await _initializeApp();
  }

  // Optional: Check if app needs update
  Future<bool> checkForUpdates() async {
    // Implement update check logic here
    await Future.delayed(const Duration(milliseconds: 300));
    return false; // Return true if update available
  }

  // Optional: Get app version
  Future<String> getAppVersion() async {
    // Implement version check logic here
    return '1.0.0';
  }

  // Optional: Check network connectivity
  Future<bool> checkConnectivity() async {
    // Implement connectivity check here
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}