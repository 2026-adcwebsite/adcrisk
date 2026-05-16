// THEME LOCK: dark — source: domain signal (field ops, monitoring)
// Scaffold.backgroundColor = AppTheme.backgroundDark — ALL screens

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary — ADC safety red
  static const Color primary = Color(0xFFE53935);
  static const Color primaryContainer = Color(0xFF4A0E0E);
  static const Color primaryMuted = Color(0x40E53935);

  // Secondary — warning amber
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryContainer = Color(0xFF3D2A00);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color successContainer = Color(0xFF052E16);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFF3D2A00);
  static const Color errorColor = Color(0xFFEF4444);

  // Dark surfaces — remapped to light/white for the app's light theme
  static const Color backgroundDark = Color(0xFFFFFFFF); // white
  static const Color surfaceDark = Color(0xFFF5F6FA); // light grey card
  static const Color surfaceVariantDark = Color(
    0xFFEEF0F5,
  ); // slightly darker card
  static const Color outlineDark = Color(0xFFDDE1EA); // light border
  static const Color outlineVariantDark = Color(
    0xFFEEF0F5,
  ); // very light border
  static const Color mutedText = Color(0xFF6B7280);
  static const Color onSurfaceText = Color(0xFF1A1A2E); // dark text on white

  // Light surfaces (required even if not primary theme)
  static const Color backgroundLight = Color(0xFFF5F6FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFFFDAD6),
      onPrimaryContainer: const Color(0xFF410002),
      secondary: secondary,
      onSecondary: Colors.white,
      surface: surfaceLight,
      onSurface: const Color(0xFF1A1A1A),
      error: errorColor,
      onError: Colors.white,
      outline: const Color(0xFFCCCCCC),
      outlineVariant: const Color(0xFFEEEEEE),
    ),
    textTheme: GoogleFonts.ibmPlexSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    ),
    scaffoldBackgroundColor: backgroundLight,
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: const Color(0xFFFFDAD6),
      secondary: secondary,
      onSecondary: Colors.black,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: const Color(0xFFFFDFA0),
      surface: surfaceDark,
      onSurface: onSurfaceText,
      surfaceContainerHighest: surfaceVariantDark,
      error: errorColor,
      onError: Colors.white,
      outline: outlineDark,
      outlineVariant: outlineVariantDark,
      inverseSurface: const Color(0xFFE6E6E6),
      onInverseSurface: const Color(0xFF1A1A1A),
    ),
    textTheme: GoogleFonts.ibmPlexSansTextTheme(
      TextTheme(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE6E6E6),
        ),
        titleLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE6E6E6),
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6E6E6),
        ),
        titleSmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6E6E6),
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFFE6E6E6),
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFD1D5DB),
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF9CA3AF),
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6E6E6),
        ),
        labelMedium: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6E6E6),
        ),
        labelSmall: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF9CA3AF),
        ),
      ),
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: AppBarThemeData(
      backgroundColor: backgroundDark,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: surfaceDark,
      titleTextStyle: GoogleFonts.ibmPlexSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: onSurfaceText,
      ),
      iconTheme: const IconThemeData(color: onSurfaceText),
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: outlineDark, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: surfaceVariantDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: outlineDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: outlineDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceDark,
      indicatorColor: primaryMuted,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.ibmPlexSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primary,
          );
        }
        return GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: mutedText,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primary, size: 24);
        }
        return const IconThemeData(color: Color(0xFF6B7280), size: 24);
      }),
    ),
    dividerTheme: const DividerThemeData(color: outlineDark, thickness: 1),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceVariantDark,
      selectedColor: primaryMuted,
      labelStyle: GoogleFonts.ibmPlexSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: onSurfaceText,
      ),
      side: BorderSide(color: outlineDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
  );
}
