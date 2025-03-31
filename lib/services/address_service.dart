import 'package:flutter/material.dart';

class AddressService extends ChangeNotifier {
  // Home, work, and school addresses
  Map<String, dynamic>? _homeAddress;
  Map<String, dynamic>? _workAddress;
  Map<String, dynamic>? _schoolAddress;
  bool _isInitialized = false;
  
  // Getters
  Map<String, dynamic>? get homeAddress => _homeAddress;
  Map<String, dynamic>? get workAddress => _workAddress;
  Map<String, dynamic>? get schoolAddress => _schoolAddress;
  bool get isInitialized => _isInitialized;
  
  // Initialize the service (load from SharedPreferences in a real app)
  Future<void> initialize() async {
    // In a real app, load from storage
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Set initialized flag
    _isInitialized = true;
    notifyListeners();
  }
  
  // Save a home address
  Future<void> saveHomeAddress(Map<String, dynamic> address) async {
    // In a real app, you would save this to SharedPreferences
    _homeAddress = Map<String, dynamic>.from(address);
    notifyListeners();
  }
  
  // Save a work address
  Future<void> saveWorkAddress(Map<String, dynamic> address) async {
    // In a real app, you would save this to SharedPreferences
    _workAddress = Map<String, dynamic>.from(address);
    notifyListeners();
  }
  
  // Save a school address
  Future<void> saveSchoolAddress(Map<String, dynamic> address) async {
    // In a real app, you would save this to SharedPreferences
    _schoolAddress = Map<String, dynamic>.from(address);
    notifyListeners();
  }
  
  // Delete home address
  Future<void> deleteHomeAddress() async {
    // In a real app, you would remove this from SharedPreferences
    _homeAddress = null;
    notifyListeners();
  }
  
  // Delete work address
  Future<void> deleteWorkAddress() async {
    // In a real app, you would remove this from SharedPreferences
    _workAddress = null;
    notifyListeners();
  }
  
  // Delete school address
  Future<void> deleteSchoolAddress() async {
    // In a real app, you would remove this from SharedPreferences
    _schoolAddress = null;
    notifyListeners();
  }
} 