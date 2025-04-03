import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isDebit;
  final IconType iconType;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isDebit,
    required this.iconType,
  });
  
  // Convert to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'isDebit': isDebit,
      'iconType': iconType.index,
    };
  }
  
  // Create from a map (for loading from storage)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      isDebit: map['isDebit'],
      iconType: IconType.values[map['iconType']],
    );
  }
}

enum IconType {
  bus,
  wallet,
  transfer,
  payment,
  train,
}

class BalanceService extends ChangeNotifier {
  double _balance = 30.0; // Default starting balance
  final List<Transaction> _transactions = [];
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  
  // Getter for current balance
  double get balance => _balance;
  
  // Getter for all transactions
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  
  // Getter for recent transactions
  List<Transaction> get recentTransactions => 
      _transactions.length <= 4 ? _transactions : _transactions.sublist(0, 4);
      
  // Getter for initialization status
  bool get isInitialized => _isInitialized;
  
  // Constructor to initialize with shared preferences
  BalanceService() {
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
    // Load balance
    _balance = _prefs.getDouble('user_balance') ?? 30.0;
    
    // Load transactions
    List<String>? transactionsJson = _prefs.getStringList('transactions');
    if (transactionsJson != null && transactionsJson.isNotEmpty) {
      _transactions.clear();
      for (String json in transactionsJson) {
        try {
          Map<String, dynamic> map = jsonDecode(json);
          _transactions.add(Transaction.fromMap(map));
        } catch (e) {
          // Skip invalid entries
          print('Error parsing transaction: $e');
        }
      }
    } else {
      // If no transactions found, add demo transactions
      _addDemoTransactions();
    }
  }
  
  // Save data to storage
  Future<void> _saveData() async {
    await _prefs.setDouble('user_balance', _balance);
    
    List<String> transactionsJson = _transactions
        .map((transaction) => jsonEncode(transaction.toMap()))
        .toList();
    await _prefs.setStringList('transactions', transactionsJson);
  }
  
  void _addDemoTransactions() {
    if (_transactions.isNotEmpty) return;
    
    // Add demo transactions
    _addTransaction(
      'MRT/LRT Fare',
      2.50,
      DateTime.now().subtract(const Duration(hours: 5)),
      true,
      IconType.train,
    );
    
    _addTransaction(
      'Top Up',
      30.00,
      DateTime.now().subtract(const Duration(days: 1)),
      false,
      IconType.wallet,
    );
    
    _addTransaction(
      'Bus Fare Payment',
      2.50,
      DateTime.now().subtract(const Duration(days: 3)),
      true,
      IconType.bus,
    );
    
    _addTransaction(
      'MRT/LRT Fare',
      2.50,
      DateTime.now().subtract(const Duration(days: 4)),
      true,
      IconType.train,
    );
    
    _addTransaction(
      'Top Up',
      50.00,
      DateTime.now().subtract(const Duration(days: 5)),
      false,
      IconType.wallet,
    );
    
    _saveData();
  }
  
  // Method to add money to balance and record transaction
  void addBalance(double amount) {
    _balance += amount;
    _addTransaction('Top Up', amount, DateTime.now(), false, IconType.wallet);
    _saveData();
    notifyListeners();
  }
  
  // Method to deduct money from balance and record transaction
  bool deductBalance(double amount, {String title = 'Payment', IconType iconType = IconType.payment}) {
    if (_balance >= amount) {
      _balance -= amount;
      _addTransaction(title, amount, DateTime.now(), true, iconType);
      _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }
  
  // Private helper to add a transaction to history
  void _addTransaction(
    String title,
    double amount,
    DateTime date,
    bool isDebit,
    IconType iconType,
  ) {
    final id = 'TRX${DateTime.now().millisecondsSinceEpoch}-${_transactions.length}';
    
    _transactions.insert(
      0,
      Transaction(
        id: id,
        title: title,
        amount: amount,
        date: date,
        isDebit: isDebit,
        iconType: iconType,
      ),
    );
  }
  
  // Method to reset balance to initial value (for testing only)
  void resetBalance() {
    _balance = 30.0;
    _transactions.clear();
    _addDemoTransactions();
    _saveData();
    notifyListeners();
  }
} 