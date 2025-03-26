import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2196F3);  // Sky Blue
  static const Color primaryWhite = Color(0xFFFFFFFF); // Pure White
  static const Color primaryGrey = Color(0xFF424242);  // Grey Black

  // Secondary Colors
  static const Color secondaryBlue = Color(0xFF64B5F6); // Light Sky Blue
  static const Color secondaryGrey = Color(0xFF757575); // Medium Grey
  static const Color lightGrey = Color(0xFFE0E0E0);    // Light Grey

  // Background Colors
  static const Color backgroundColor = primaryWhite;
  static const Color surfaceColor = primaryWhite;

  // Text Colors
  static const Color primaryText = primaryGrey;
  static const Color secondaryText = secondaryGrey;

  // Custom Theme Data
  static ThemeData themeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Colors
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: backgroundColor,
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: primaryGrey,
      elevation: 0,
    ),

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: secondaryBlue,
      surface: surfaceColor,
      onPrimary: primaryWhite,
      onSecondary: primaryWhite,
      onSurface: primaryGrey,
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: primaryGrey),
      displayMedium: TextStyle(color: primaryGrey),
      displaySmall: TextStyle(color: primaryGrey),
      headlineMedium: TextStyle(color: primaryGrey),
      headlineSmall: TextStyle(color: primaryGrey),
      titleLarge: TextStyle(color: primaryGrey),
      titleMedium: TextStyle(color: primaryGrey),
      titleSmall: TextStyle(color: primaryGrey),
      bodyLarge: TextStyle(color: primaryGrey),
      bodyMedium: TextStyle(color: primaryGrey),
      bodySmall: TextStyle(color: secondaryGrey),
      labelLarge: TextStyle(color: primaryGrey),
      labelMedium: TextStyle(color: primaryGrey),
      labelSmall: TextStyle(color: secondaryGrey),
    ),

    // Card Theme
    cardTheme: const CardTheme(
      color: surfaceColor,
      elevation: 0,
    ),

    // Navigation Bar Theme
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: backgroundColor,
      indicatorColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: primaryBlue, fontWeight: FontWeight.w600);
        }
        return const TextStyle(color: secondaryGrey);
      }),
    ),
  );
} 