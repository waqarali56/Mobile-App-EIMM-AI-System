import 'package:flutter/material.dart';

class Constants {
  // ✅ Light Theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: successColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      elevation: 2,
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: const WidgetStatePropertyAll(Colors.white),
      elevation: const WidgetStatePropertyAll(0),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return Colors.grey.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return primaryColor.withOpacity(0.12);
        }
        if (states.contains(WidgetState.pressed)) {
          return primaryColor.withOpacity(0.16);
        }
        return Colors.transparent;
      }),
      textStyle: WidgetStatePropertyAll(
        TextStyle(color: Colors.grey[800], fontSize: 16),
      ),
      hintStyle: WidgetStatePropertyAll(
        TextStyle(color: Colors.grey[600], fontSize: 16),
      ),
      side: WidgetStatePropertyAll(
        BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      constraints: const BoxConstraints(
        minHeight: 42, 
        maxHeight: 42, 
        minWidth: 200, 
        maxWidth: 600
      ),
    ),
  );

  // ✅ Dark Theme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: successColor,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      elevation: 2,
      centerTitle: true,
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: const WidgetStatePropertyAll(Color(0xFF2D2D2D)),
      elevation: const WidgetStatePropertyAll(0),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return Colors.white.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return primaryColor.withOpacity(0.15);
        }
        if (states.contains(WidgetState.pressed)) {
          return primaryColor.withOpacity(0.20);
        }
        return Colors.transparent;
      }),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(color: Colors.white, fontSize: 16),
      ),
      hintStyle: WidgetStatePropertyAll(
        TextStyle(color: Colors.grey[400], fontSize: 16),
      ),
      side: WidgetStatePropertyAll(
        BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      constraints: const BoxConstraints(
        minHeight: 42, 
        maxHeight: 42, 
        minWidth: 200, 
        maxWidth: 600
      ),
    ),
  );

  // ✅ Color Constants (static const)
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color secondaryColor = Color(0xFFF06292);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  // ✅ Text Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );

  // ✅ Button Styles
  static ButtonStyle get primaryButtonStyle => ButtonStyle(
    backgroundColor: WidgetStateProperty.all(primaryColor),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static ButtonStyle get secondaryButtonStyle => ButtonStyle(
    backgroundColor: WidgetStateProperty.all(Colors.transparent),
    foregroundColor: WidgetStateProperty.all(primaryColor),
    side: WidgetStateProperty.all(
      BorderSide(color: primaryColor, width: 2),
    ),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  // ✅ Spacing
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultBorderRadius = 12.0;

  // ✅ App Constants
  static const String appName = 'EmoAssist';
  static const String appVersion = '1.0.0';




    // OnBoarding pages data
  static List<OnBoardingPageData> onBoardingPages = [
    OnBoardingPageData(
      title: "Emotional Intelligence",
      description: "Detect emotions through text, voice, and facial expressions",
        icon: Icons.emoji_emotions_outlined,
        color: primaryColor,
    ),
    OnBoardingPageData(
      title: "AI-Powered Support",
      description: "Get empathetic responses from our intelligent AI companion",
      icon: Icons.psychology_outlined,
      color: primaryColor,
    ),
    OnBoardingPageData(
      title: "Multi-Modal Analysis",
      description: "Combine text sentiment, voice tone, and facial cues for accurate emotion detection",
      icon: Icons.insights_outlined,
      color: secondaryColor,
    ),
  ];
}

class OnBoardingPageData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnBoardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}