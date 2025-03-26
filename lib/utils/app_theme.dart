import 'package:flutter/material.dart';

// Class to manage the app's theme colors
class AppTheme {
  // Predefined theme color options
  static final Map<String, ThemeData> themes = {
    'blue': _createTheme(
      name: 'Blue',
      primaryColor: const Color(0xFF2196F3),
      secondaryColor: const Color(0xFF64B5F6),
      accentColor: Colors.blue.shade700,
    ),
    'purple': _createTheme(
      name: 'Purple',
      primaryColor: const Color(0xFF9C27B0),
      secondaryColor: const Color(0xFFCE93D8),
      accentColor: Colors.purple.shade700,
    ),
    'orange': _createTheme(
      name: 'Orange',
      primaryColor: const Color(0xFFFF9800),
      secondaryColor: const Color(0xFFFFCC80),
      accentColor: Colors.orange.shade800,
    ),
    'mint': _createTheme(
      name: 'Mint Green',
      primaryColor: const Color(0xFF26A69A),
      secondaryColor: const Color(0xFF80CBC4),
      accentColor: Colors.teal.shade700,
    ),
  };

  // Default theme key
  static String _currentThemeKey = 'blue';
  
  // Current theme getter
  static String get currentThemeKey => _currentThemeKey;
  
  // Current theme setter
  static set currentThemeKey(String themeKey) {
    if (themes.containsKey(themeKey)) {
      _currentThemeKey = themeKey;
    }
  }
  
  // Get the current theme
  static ThemeData get currentTheme => themes[_currentThemeKey]!;
  
  // Get primary color of current theme
  static Color get primaryColor => AppThemeColors.fromTheme(currentThemeKey).primaryColor;
  
  // Get secondary color of current theme
  static Color get secondaryColor => AppThemeColors.fromTheme(currentThemeKey).secondaryColor;
  
  // Get accent color of current theme
  static Color get accentColor => AppThemeColors.fromTheme(currentThemeKey).accentColor;

  // Helper method to create a ThemeData object from colors
  static ThemeData _createTheme({
    required String name,
    required Color primaryColor,
    required Color secondaryColor,
    required Color accentColor,
  }) {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
  
  // Get gradient colors for the current theme
  static List<Color> get currentGradientColors => [
    primaryColor,
    secondaryColor,
  ];
}

// Class to store color combinations for each theme
class AppThemeColors {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  
  AppThemeColors({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });
  
  // Helper function to convert theme name to theme key
  static String nameToKey(String themeName) {
    if (themeName == 'Mint Green') {
      return 'mint';
    }
    return themeName.toLowerCase().replaceAll(' ', '');
  }
  
  // Factory method to create AppThemeColors from a theme key
  factory AppThemeColors.fromTheme(String themeKey) {
    switch (themeKey) {
      case 'purple':
        return AppThemeColors(
          name: 'Purple',
          primaryColor: const Color(0xFF9C27B0),
          secondaryColor: const Color(0xFFCE93D8),
          accentColor: Colors.purple.shade700,
        );
      case 'orange':
        return AppThemeColors(
          name: 'Orange',
          primaryColor: const Color(0xFFFF9800),
          secondaryColor: const Color(0xFFFFCC80),
          accentColor: Colors.orange.shade800,
        );
      case 'mint':
        return AppThemeColors(
          name: 'Mint Green',
          primaryColor: const Color(0xFF26A69A),
          secondaryColor: const Color(0xFF80CBC4),
          accentColor: Colors.teal.shade700,
        );
      case 'blue':
      default:
        return AppThemeColors(
          name: 'Blue',
          primaryColor: const Color(0xFF2196F3),
          secondaryColor: const Color(0xFF64B5F6),
          accentColor: Colors.blue.shade700,
        );
    }
  }
  
  // Get all available theme colors
  static List<AppThemeColors> get allThemes => [
    AppThemeColors.fromTheme('blue'),
    AppThemeColors.fromTheme('purple'),
    AppThemeColors.fromTheme('orange'),
    AppThemeColors.fromTheme('mint'),
  ];
} 