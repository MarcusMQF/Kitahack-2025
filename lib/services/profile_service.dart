import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class ProfileService extends ChangeNotifier {
  File? _profileImage;
  String _username = 'Marcus';
  String _email = 'marcus.t@example.com';
  bool _notificationsEnabled = true;
  String _paymentAccountName = 'MARCUS';
  
  // Keys for SharedPreferences
  static const String _usernameKey = 'profile_username';
  static const String _emailKey = 'profile_email';
  static const String _notificationsEnabledKey = 'profile_notifications';
  static const String _paymentAccountNameKey = 'profile_payment_name';
  static const String _profileImagePathKey = 'profile_image_path';
  
  // Getters
  File? get profileImage => _profileImage;
  String get username => _username;
  String get email => _email;
  bool get notificationsEnabled => _notificationsEnabled;
  String get paymentAccountName => _paymentAccountName;
  
  // Constructor - load saved profile if available
  ProfileService() {
    _loadProfileData();
  }
  
  // Load profile data from SharedPreferences
  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load simple profile data
      _username = prefs.getString(_usernameKey) ?? _username;
      _email = prefs.getString(_emailKey) ?? _email;
      _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? _notificationsEnabled;
      _paymentAccountName = prefs.getString(_paymentAccountNameKey) ?? _paymentAccountName;
      
      // Load profile image
      final imagePath = prefs.getString(_profileImagePathKey);
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          _profileImage = file;
        }
      }
      
      // Notify listeners about the loaded data
      notifyListeners();
    } catch (e) {
      print('Error loading profile data: $e');
    }
  }
  
  // Save the profile image
  Future<void> updateProfileImage(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return;
      }
      
      // Get the app's documents directory for storing the image
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      
      // Save the image path to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileImagePathKey, savedImage.path);
      
      // Update the in-memory image
      _profileImage = savedImage;
      
      // Notify listeners of the change
      notifyListeners();
    } catch (e) {
      print('Error saving profile image: $e');
    }
  }
  
  // Update username
  Future<void> updateUsername(String username) async {
    if (username.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username);
      
      _username = username;
      notifyListeners();
    } catch (e) {
      print('Error saving username: $e');
    }
  }
  
  // Update email
  Future<void> updateEmail(String email) async {
    if (email.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emailKey, email);
      
      _email = email;
      notifyListeners();
    } catch (e) {
      print('Error saving email: $e');
    }
  }
  
  // Update notifications setting
  Future<void> updateNotificationsSetting(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);
      
      _notificationsEnabled = enabled;
      notifyListeners();
    } catch (e) {
      print('Error saving notifications setting: $e');
    }
  }
  
  // Update payment account name
  Future<void> updatePaymentAccountName(String name) async {
    if (name.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_paymentAccountNameKey, name);
      
      _paymentAccountName = name;
      notifyListeners();
    } catch (e) {
      print('Error saving payment account name: $e');
    }
  }
} 