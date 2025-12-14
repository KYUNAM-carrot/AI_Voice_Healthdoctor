import 'package:flutter/material.dart';

class AppTheme {
  // Primary Gradient Colors (Modern Purple-Blue)
  static const Color primaryStart = Color(0xFF667EEA);
  static const Color primaryEnd = Color(0xFF764BA2);
  static const Color primary = Color(0xFF6C5CE7);

  // Secondary Colors
  static const Color secondary = Color(0xFF00B894);
  static const Color accent = Color(0xFFFF7675);
  static const Color accentSoft = Color(0xFFFFB8B8);

  // Semantic Colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFE17055);
  static const Color info = Color(0xFF74B9FF);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textTertiary = Color(0xFFB2BEC3);
  static const Color textOnPrimary = Colors.white;

  // Background Colors
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F3F8);

  // Card Colors (for glassmorphism)
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE8ECF4);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FE)],
  );

  static LinearGradient softGradient(Color color) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
  );

  // Typography (Modern, Clean)
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
    color: textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
    color: textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
    color: textTertiary,
  );

  // Spacing
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 24.0;
  static const double space2xl = 32.0;
  static const double space3xl = 48.0;

  // Border Radius
  static const double radiusXs = 6.0;
  static const double radiusSm = 10.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 28.0;
  static const double radiusFull = 100.0;

  // Shadows
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: const Color(0xFF6C5CE7).withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: const Color(0xFF6C5CE7).withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: const Color(0xFF6C5CE7).withOpacity(0.16),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> shadowXl = [
    BoxShadow(
      color: const Color(0xFF6C5CE7).withOpacity(0.20),
      blurRadius: 32,
      offset: const Offset(0, 12),
      spreadRadius: 0,
    ),
  ];

  // Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radiusMd),
    border: Border.all(color: cardBorder, width: 1),
    boxShadow: shadowSm,
  );

  static BoxDecoration get cardDecorationElevated => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radiusLg),
    boxShadow: shadowMd,
  );

  static BoxDecoration glassDecoration({Color? color}) => BoxDecoration(
    color: (color ?? Colors.white).withOpacity(0.9),
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(
      color: Colors.white.withOpacity(0.5),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        error: error,
        surface: surface,
        background: background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        margin: const EdgeInsets.symmetric(vertical: spaceSm),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceXl,
            vertical: spaceLg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: spaceXl,
            vertical: spaceLg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
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
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceLg,
          vertical: spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error),
        ),
        hintStyle: bodyMedium.copyWith(color: textTertiary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: cardBorder,
        thickness: 1,
        space: spaceLg,
      ),
    );
  }
}
