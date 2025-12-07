import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF6C5CE7);      // 보라색
  static const Color secondary = Color(0xFF00B894);    // 민트색
  static const Color accent = Color(0xFFFFB8B8);       // 핑크색

  static const Color textPrimary = Color(0xFF2D3436);  // 진한 회색
  static const Color textSecondary = Color(0xFF636E72); // 중간 회색
  static const Color textTertiary = Color(0xFFB2BEC3);  // 연한 회색

  static const Color background = Color(0xFFFDFCFF);   // 연보라 배경
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD63031);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);

  // Typography (20-50세 타겟, 정보 밀도 2배)
  static const TextStyle h1 = TextStyle(
    fontSize: 24,  // 큰 제목
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,  // 중간 제목
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 16,  // 작은 제목
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,  // 본문 (감소)
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,  // 본문 (감소)
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,  // 작은 본문 (감소)
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,  // 캡션 (감소)
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: textSecondary,
  );

  // Spacing (밀도 2배)
  static const double spaceXs = 4.0;   // 감소
  static const double spaceSm = 8.0;   // 감소
  static const double spaceMd = 12.0;  // 감소
  static const double spaceLg = 16.0;  // 감소
  static const double spaceXl = 20.0;  // 감소
  static const double space2xl = 24.0; // 감소

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // Shadows
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        error: error,
        surface: surface,
        background: background,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: textPrimary,
        titleTextStyle: h2,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        margin: const EdgeInsets.symmetric(vertical: spaceSm),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLg,
            vertical: spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceMd,
            vertical: spaceSm,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMd,
          vertical: spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error),
        ),
      ),
    );
  }
}
