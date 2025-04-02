import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transit_record.dart';

class WalletService extends ChangeNotifier {
  double _walletBalance = 100.0; // Default starting balance
  final List<TransitRecord> _tripHistory = [];
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Getters
  double get walletBalance => _walletBalance;
  List<TransitRecord> get tripHistory => List.unmodifiable(_tripHistory);
  bool get isInitialized => _isInitialized;
  
  // Constructor to initialize with SharedPreferences
  WalletService() {
    _initPrefs();
  }
  
  // Initialize shared preferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
    _isInitialized = true;
    notifyListeners();
  }
  
  // Load saved data from storage
  Future<void> _loadData() async {
    // Load wallet balance
    _walletBalance = _prefs.getDouble('wallet_balance') ?? 100.0;
    
    // Load trip history
    List<String>? tripHistoryJson = _prefs.getStringList('trip_history');
    if (tripHistoryJson != null && tripHistoryJson.isNotEmpty) {
      _tripHistory.clear();
      for (String json in tripHistoryJson) {
        try {
          Map<String, dynamic> map = jsonDecode(json);
          _tripHistory.add(TransitRecord.fromMap(map));
        } catch (e) {
          // Skip invalid entries
          print('Error parsing trip history: $e');
        }
      }
    }
  }
  
  // Save data to storage
  Future<void> _saveData() async {
    await _prefs.setDouble('wallet_balance', _walletBalance);
    
    List<String> tripHistoryJson = _tripHistory
        .map((trip) => jsonEncode(trip.toMap()))
        .toList();
    await _prefs.setStringList('trip_history', tripHistoryJson);
  }

  // Add money to wallet
  void addMoney(double amount) {
    if (amount <= 0) return;
    
    _walletBalance += amount;
    _saveData();
    notifyListeners();
  }

  // Deduct money from wallet
  bool deductMoney(double amount) {
    if (amount <= 0) return false;
    
    // Check if enough balance
    if (_walletBalance < amount) {
      return false;
    }
    
    _walletBalance -= amount;
    _saveData();
    notifyListeners();
    return true;
  }

  // Add a completed trip to history
  void addTripToHistory(TransitRecord trip) {
    if (trip.exitStation == null || trip.exitTime == null) {
      // Trip is not complete, don't add to history
      return;
    }
    
    // Add to the beginning of the list so newest is first
    _tripHistory.insert(0, trip);
    _saveData();
    notifyListeners();
  }

  // Clear trip history (for testing)
  void clearTripHistory() {
    _tripHistory.clear();
    _saveData();
    notifyListeners();
  }
  
  // Reset wallet balance (for testing)
  void resetWalletBalance() {
    _walletBalance = 100.0;
    _saveData();
    notifyListeners();
  }
} 