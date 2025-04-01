import 'package:flutter/foundation.dart';
import '../models/transit_record.dart';

class WalletService extends ChangeNotifier {
  double _walletBalance = 100.0; // Default starting balance
  final List<TransitRecord> _tripHistory = [];

  // Getters
  double get walletBalance => _walletBalance;
  List<TransitRecord> get tripHistory => List.unmodifiable(_tripHistory);

  // Add money to wallet
  void addMoney(double amount) {
    if (amount <= 0) return;
    
    _walletBalance += amount;
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
    notifyListeners();
    return true;
  }

  // Add a completed trip to history
  void addTripToHistory(TransitRecord trip) {
    if (trip.exitStation == null || trip.exitTime == null) {
      // Trip is not complete, don't add to history
      return;
    }
    
    _tripHistory.add(trip);
    notifyListeners();
  }

  // Clear trip history (for testing)
  void clearTripHistory() {
    _tripHistory.clear();
    notifyListeners();
  }
} 