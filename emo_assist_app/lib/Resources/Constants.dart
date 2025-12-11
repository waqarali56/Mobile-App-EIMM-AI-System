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

  // In Constants.dart
static Color get premiumColor => Color(0xFFFFD700); // Gold color for premium
  
  // NEW: Chat and UI Specific Colors
  static const Color textColor = Color(0xFF333333);
  static const Color textSecondaryColor = Color(0xFF666666);
  static const Color textHintColor = Color(0xFF999999);
  
  static const Color chatUserBubble = Color(0xFF1E88E5);
  static const Color chatAIBubble = Color(0xFFF5F5F5);
  static const Color chatAIBubbleText = Color(0xFF333333);
  static const Color chatUserBubbleText = Color(0xFFFFFFFF);
  
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color shadowColor = Color(0x1A000000);
  
  static const Color onlineStatus = Color(0xFF4CAF50);
  static const Color offlineStatus = Color(0xFF757575);
  static const Color awayStatus = Color(0xFFFF9800);
  
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFE0E0E0);
  
  static const Color typingIndicator = Color(0xFF1E88E5);
  static const Color typingBackground = Color(0xFFF0F0F0);
  
  static const Color quickChipBackground = Color(0xFFE3F2FD);
  static const Color quickChipBorder = Color(0xFFBBDEFB);
  static const Color quickChipText = Color(0xFF0D47A1);
  
  static const Color guestModeBackground = Color(0xFFFFF3E0);
  static const Color guestModeText = Color(0xFFE65100);
  static const Color guestModeBorder = Color(0xFFFFCC80);
  
  // Material design opacity variants
  static Color get primaryColorLight => primaryColor.withOpacity(0.1);
  static Color get primaryColorMedium => primaryColor.withOpacity(0.3);
  static Color get primaryColorDark => primaryColor.withOpacity(0.7);
  
  static Color get secondaryColorLight => secondaryColor.withOpacity(0.1);
  static Color get secondaryColorMedium => secondaryColor.withOpacity(0.3);
  static Color get secondaryColorDark => secondaryColor.withOpacity(0.7);
  
  // Neutral shades
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  
  // Grey scale
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // Semantic colors
  static const Color infoColor = Color(0xFF2196F3);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color warningLight = Color(0xFFFFECB3);
  static const Color errorLight = Color(0xFFFFCDD2);
  
  // Chat specific
  static const Color chatBackground = Color(0xFFF8F9FA);
  static const Color chatInputBackground = Color(0xFFFFFFFF);
  static const Color chatMessageTime = Color(0xFF888888);
  static const Color chatAvatarUser = Color(0xFFE3F2FD);
  static const Color chatAvatarAI = Color(0xFFF5F5F5);
  
  // Gradients
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryColor, const Color(0xFF64B5F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get secondaryGradient => LinearGradient(
    colors: [secondaryColor, const Color(0xFFF48FB1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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