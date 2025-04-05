import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service class that manages the application's theme
/// Provides a way to change the theme and notify listeners
class ThemeService extends ChangeNotifier {
  // Initial theme key
  String _currentThemeKey = 'blue';
  static const String _themePreferenceKey = 'user_theme_preference';

  // Constructor - load saved theme if available
  ThemeService() {
    _loadSavedTheme();
  }

  // Load the saved theme from SharedPreferences
  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePreferenceKey);
      
      if (savedTheme != null && AppTheme.themes.containsKey(savedTheme)) {
        _currentThemeKey = savedTheme;
        AppTheme.currentThemeKey = savedTheme;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading theme preference: $e');
    }
  }

  // Save the current theme to SharedPreferences
  Future<void> _saveTheme(String themeKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePreferenceKey, themeKey);
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  // Get the current theme key
  String get currentThemeKey => _currentThemeKey;

  // Change the theme
  void setTheme(String themeKey) {
    if (AppTheme.themes.containsKey(themeKey)) {
      _currentThemeKey = themeKey;
      AppTheme.currentThemeKey = themeKey; // Update the AppTheme setting
      _saveTheme(themeKey); // Save the theme preference
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