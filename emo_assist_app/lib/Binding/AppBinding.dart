// lib/Binding/AppBinding.dart
import 'package:emo_assist_app/ViewModels/Auth/ProfileViewModel.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Controllers/ThemeController.dart';
import 'package:emo_assist_app/Services/auth_service.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';
import 'package:emo_assist_app/ViewModels/Auth/AuthViewModel.dart';
import 'package:emo_assist_app/ViewModels/SplashViewModel.dart';
import 'package:emo_assist_app/ViewModels/Auth/ForgotPasswordViewModel.dart';
import 'package:emo_assist_app/ViewModels/Auth/ForgotPasswordViewModel.dart';

import 'package:emo_assist_app/ViewModels/OnBoardingViewModel.dart';
import 'package:emo_assist_app/ViewModels/Auth/ResetPasswordViewModel.dart';
import 'package:emo_assist_app/ViewModels/Chat/ChatViewModel.dart';
import 'package:emo_assist_app/ViewModels/Chat/ChatHistoryViewModel.dart';
import 'package:emo_assist_app/ViewModels/Auth/OTPViewModel.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    print('[BINDING] Registering dependencies...');

    // Services (singleton)
    Get.lazyPut(() => AuthService(), fenix: true);
    Get.lazyPut(() => NavigationService(), fenix: true);

    Get.lazyPut(() => ThemeController(), fenix: true);

    // ViewModels
    Get.lazyPut(() => AuthViewModel(), fenix: true);
    Get.lazyPut(() => ForgotPasswordViewModel(), fenix: true);
    Get.lazyPut(() => ResetPasswordViewModel(), fenix: true);
    Get.lazyPut(() => OTPViewModel(), fenix: true);
    Get.lazyPut(() => SplashViewModel(), fenix: true);
    Get.lazyPut(() => OnBoardingViewModel(), fenix: true);
    Get.lazyPut(() => ChatViewModel(), fenix: true);
    Get.lazyPut(() => ChatHistoryViewModel(), fenix: true);
    Get.lazyPut(() => ProfileViewModel(), fenix: true);
  }
}
