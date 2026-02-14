import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF0056D2);
  static const Color primaryDark = Color(0xFF00419E);

  static const Color backgroundLight = Color(0xFFF6F7F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF0F4F9);
  static const Color onSurfaceLight = Color(0xFF1F1F1F);
  static const Color onSurfaceVariantLight = Color(0xFF5F6368);
  static const Color outlineLight = Color(0xFFE5E7EB);

  static const Color backgroundDark = Color(0xFF0B0F14);
  static const Color surfaceDark = Color(0xFF111822);
  static const Color surfaceVariantDark = Color(0xFF17212D);
  static const Color onSurfaceDark = Color(0xFFE9EEF5);
  static const Color onSurfaceVariantDark = Color(0xFFA9B4C0);
  static const Color outlineDark = Color(0xFF263241);
  static const List<String> _fontFallback = <String>['NotoSansArabic'];

  static TextStyle? _withFallback(TextStyle? style) {
    if (style == null) {
      return null;
    }
    return style.copyWith(fontFamilyFallback: _fontFallback);
  }

  static TextTheme _withArabicFallback(TextTheme textTheme) {
    return TextTheme(
      displayLarge: _withFallback(textTheme.displayLarge),
      displayMedium: _withFallback(textTheme.displayMedium),
      displaySmall: _withFallback(textTheme.displaySmall),
      headlineLarge: _withFallback(textTheme.headlineLarge),
      headlineMedium: _withFallback(textTheme.headlineMedium),
      headlineSmall: _withFallback(textTheme.headlineSmall),
      titleLarge: _withFallback(textTheme.titleLarge),
      titleMedium: _withFallback(textTheme.titleMedium),
      titleSmall: _withFallback(textTheme.titleSmall),
      bodyLarge: _withFallback(textTheme.bodyLarge),
      bodyMedium: _withFallback(textTheme.bodyMedium),
      bodySmall: _withFallback(textTheme.bodySmall),
      labelLarge: _withFallback(textTheme.labelLarge),
      labelMedium: _withFallback(textTheme.labelMedium),
      labelSmall: _withFallback(textTheme.labelSmall),
    );
  }

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: primary,
        surface: surfaceLight,
        onSurface: onSurfaceLight,
        outline: outlineLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardColor: surfaceLight,
    );

    return base.copyWith(
      textTheme: _withArabicFallback(
        GoogleFonts.plusJakartaSansTextTheme(
          base.textTheme,
        ).apply(bodyColor: onSurfaceLight, displayColor: onSurfaceLight),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurfaceLight,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.white,
        secondary: primary,
        surface: surfaceDark,
        onSurface: onSurfaceDark,
        outline: outlineDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: surfaceDark,
    );

    return base.copyWith(
      textTheme: _withArabicFallback(
        GoogleFonts.plusJakartaSansTextTheme(
          base.textTheme,
        ).apply(bodyColor: onSurfaceDark, displayColor: onSurfaceDark),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurfaceDark,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        color: surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }
}
