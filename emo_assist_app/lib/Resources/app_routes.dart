import 'package:emo_assist_app/Models/OTP.dart';
import 'package:emo_assist_app/Resources/RouteNames.dart';
import 'package:emo_assist_app/ViewModels/Auth/ProfileViewModel.dart';
import 'package:emo_assist_app/Views/Chat/ChatHistoryScreen.dart';
import 'package:emo_assist_app/Views/ForgotPassword/ForgotPasswordScreen.dart';
import 'package:emo_assist_app/Views/ForgotPassword/ResetPasswordScreen.dart';
import 'package:emo_assist_app/Views/Home/HomeScreen.dart';
import 'package:emo_assist_app/Views/OTPVerification/OTPVerificationScreen.dart';
import 'package:emo_assist_app/Views/PrivacyPolicy/PrivacyPolicyScreen.dart';
import 'package:emo_assist_app/Views/Profile/ProfileScreen.dart';
import 'package:emo_assist_app/Views/Setting/SettingsScreen.dart';
import 'package:emo_assist_app/Views/Terms/TermsScreen.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Views/Splash/SplashScreen.dart';
import 'package:emo_assist_app/Views/OnBoarding/OnBoardingScreen.dart';
import 'package:emo_assist_app/Views/Signin/Signin.dart';
import 'package:emo_assist_app/Views/SignUp/SignUpScreen.dart';
import 'package:emo_assist_app/Views/Chat/ChatScreen.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: RouteNames.splash,
      page: () => SplashScreen(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: RouteNames.onboarding,
      page: () => OnBoardingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RouteNames.login,
      page: () => SigninScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteNames.signup,
      page: () => SignupScreen(),
      transition: Transition.rightToLeft,
    ),

    // Routes configuration
    GetPage(
      name: RouteNames.resetPassword,
      page: () {
        final parameters = Get.parameters;
        final arguments = Get.arguments;

        String email = '';
        String otp = '';

        // Get from parameters
        if (parameters['email'] != null) {
          email = parameters['email']!;
        }
        if (parameters['otp'] != null) {
          otp = parameters['otp']!;
        }

        // Get from arguments
        if (arguments is Map<String, dynamic>) {
          email = arguments['email'] ?? email;
          otp = arguments['otp'] ?? otp;
        }

        return ResetPasswordScreen(email: email, otp: otp);
      },
    ),
    GetPage(
      name: RouteNames.otpVerification,
      page: () {
        final parameters = Get.parameters;
        final arguments = Get.arguments;

        String email = '';
        OTPType type = OTPType.EmailVerification;

        // Get email from parameters or arguments
        if (parameters['email'] != null) {
          email = parameters['email']!;
        } else if (arguments is Map && arguments['email'] != null) {
          email = arguments['email'];
        }

        // Get type from parameters or arguments
        if (parameters['type'] != null) {
          final typeString = parameters['type']!;
          type = OTPType.values.firstWhere(
            (e) => e.toString().split('.').last == typeString,
            orElse: () => OTPType.EmailVerification,
          );
        } else if (arguments is Map && arguments['type'] != null) {
          type = arguments['type'];
        }

        return OTPVerificationScreen(email: email, type: type);
      },
    ),
    GetPage(
      name: RouteNames.forgotPassword,
      page: () => ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteNames.chat,
      page: () => const ChatScreen(),
      transition: Transition.fade,
    ),

    // Drawer Routes
    GetPage(name: RouteNames.home, page: () => HomeScreen()),
    GetPage(name: RouteNames.chatHistory, page: () => ChatHistoryScreen()),
    GetPage(name: RouteNames.settings, page: () => SettingsScreen()),
    GetPage(name: RouteNames.privacyPolicy, page: () => PrivacyPolicyScreen()),
    GetPage(name: RouteNames.terms, page: () => TermsScreen()),
    GetPage(
      name: RouteNames.profile,
      page: () => ProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileViewModel>(() => ProfileViewModel(), fenix: true);
      }),
    ),
  ];
}
