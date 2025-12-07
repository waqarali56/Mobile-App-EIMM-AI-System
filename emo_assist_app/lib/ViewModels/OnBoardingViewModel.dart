// lib/ViewModels/OnBoardingViewModel.dart
import 'package:emo_assist_app/Resources/app_routes.dart';
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    AppRoutes.goToLogin();  // CHANGED
  }

  Future<void> skipOnBoarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    AppRoutes.goToLogin();  // CHANGED
  }
}