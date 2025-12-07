// main.dart
import 'package:emo_assist_app/Binding/AppBinding';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/Resources/app_routes.dart';
import 'package:emo_assist_app/Views/Chat/ChatScreen.dart';
import 'package:emo_assist_app/Views/OnBoarding/OnBoardingScreen.dart';
import 'package:emo_assist_app/Views/SignUp/SignUpScreen.dart';
import 'package:emo_assist_app/Views/Signin/Signin.dart';
import 'package:emo_assist_app/Views/Splash/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EmoAssist',
      theme: Constants.lightTheme,
      darkTheme: Constants.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,  // CHANGED
      initialBinding: AppBinding(),
      getPages: [
        GetPage(name: AppRoutes.splash, page: () => SplashScreen()),      // CHANGED
        GetPage(name: AppRoutes.onboarding, page: () => OnBoardingScreen()),   // CHANGED
        GetPage(name: AppRoutes.login, page: () => SigninScreen()),             // CHANGED
        GetPage(name: AppRoutes.signup, page: () => SignupScreen()),           // CHANGED
        GetPage(name: AppRoutes.chat, page: () => ChatScreen()),               // CHANGED
      ],
    );
  }
}