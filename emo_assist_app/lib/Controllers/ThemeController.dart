// controllers/theme_controller.dart
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class ThemeController extends GetxController {
  var isDarkMode = true.obs; // Default to dark mode based on your main.dart

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    print('Theme changed: ${isDarkMode.value ? "Dark" : "Light"}');
  }

  ThemeData get currentTheme => isDarkMode.value ? Constants.darkTheme : Constants.lightTheme;
}