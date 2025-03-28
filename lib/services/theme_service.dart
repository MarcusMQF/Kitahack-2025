import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// A service class that manages the application's theme
/// Provides a way to change the theme and notify listeners
class ThemeService extends ChangeNotifier {
  // Initial theme key
  String _currentThemeKey = 'blue';

  // Get the current theme key
  String get currentThemeKey => _currentThemeKey;

  // Change the theme
  void setTheme(String themeKey) {
    if (AppTheme.themes.containsKey(themeKey)) {
      _currentThemeKey = themeKey;
      AppTheme.currentThemeKey = themeKey; // Update the AppTheme setting
      notifyListeners(); // Notify listeners about the change
    }
  }

  // Helper method to get primary color of current theme
  Color get primaryColor => AppThemeColors.fromTheme(_currentThemeKey).primaryColor;
  
  // Helper method to get secondary color of current theme
  Color get secondaryColor => AppThemeColors.fromTheme(_currentThemeKey).secondaryColor;
  
  // Helper method to get accent color of current theme
  Color get accentColor => AppThemeColors.fromTheme(_currentThemeKey).accentColor;
} 