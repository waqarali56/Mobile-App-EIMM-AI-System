import 'package:emo_assist_app/Services/navigation_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emo_assist_app/Resources/Constants.dart';

class OnBoardingViewModel extends GetxController {
  final RxInt currentPage = 0.obs;
  final List<OnBoardingPageData> pages = Constants.onBoardingPages;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  Future<void> completeOnBoarding() async {
    try {
      // Save onboarding completion
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_launch', false);
      
      // Navigate to login
      NavigationService.goToLogin();
      
      // Optional: Show success message
      Get.snackbar(
        'Welcome!',
        'Get started with EmoAssist',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to complete onboarding. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  Future<void> skipOnBoarding() async {
    try {
      // Save onboarding skipped status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_launch', false);
      await prefs.setBool('onboarding_skipped', true);
      
      // Navigate to login
      NavigationService.goToLogin();
      
      // Optional: Show message
      Get.snackbar(
        'Skipped',
        'You can always view onboarding from settings',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to skip onboarding. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }
  
  // Optional: Add method to get onboarding status
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('first_launch') ?? true; // Default to true (not completed)
  }
  
  // Optional: Reset onboarding (for testing or in settings)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('first_launch');
    await prefs.remove('onboarding_skipped');
  }
  
  // Optional: Get next page index
  int get nextPageIndex {
    if (currentPage.value < pages.length - 1) {
      return currentPage.value + 1;
    }
    return currentPage.value;
  }
  
  // Optional: Get previous page index
  int get previousPageIndex {
    if (currentPage.value > 0) {
      return currentPage.value - 1;
    }
    return currentPage.value;
  }
  
  // Optional: Go to next page
  void goToNextPage() {
    if (currentPage.value < pages.length - 1) {
      currentPage.value++;
    } else {
      // If on last page, complete onboarding
      completeOnBoarding();
    }
  }
  
  // Optional: Go to previous page
  void goToPreviousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }
  
  // Optional: Check if on last page
  bool get isLastPage => currentPage.value == pages.length - 1;
  
  // Optional: Check if on first page
  bool get isFirstPage => currentPage.value == 0;
}