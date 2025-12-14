
import 'package:emo_assist_app/Binding/AppBinding.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/Resources/RouteNames.dart';
import 'package:emo_assist_app/Resources/app_routes.dart';
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
      initialRoute: RouteNames.splash, // Use RouteNames
      initialBinding: AppBinding(),
      getPages: AppRoutes.routes,
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      popGesture: true,
    );
  }
}
