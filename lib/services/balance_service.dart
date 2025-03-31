import 'package:flutter/foundation.dart';

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
}

enum IconType {
  bus,
  wallet,
  transfer,
  payment,
}

class BalanceService extends ChangeNotifier {
  double _balance = 30.0; // Default starting balance
  final List<Transaction> _transactions = [];
  
  // Getter for current balance
  double get balance => _balance;
  
  // Getter for all transactions
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  
  // Getter for recent transactions
  List<Transaction> get recentTransactions => 
      _transactions.length <= 4 ? _transactions : _transactions.sublist(0, 4);
  
  // Constructor to initialize with some demo transactions
  BalanceService() {
    // Add some demo transactions
    _addDemoTransactions();
  }
  
  void _addDemoTransactions() {
    // Add demo transactions
    _addTransaction(
      'Bus Fare Payment',
      2.50,
      DateTime.now().subtract(const Duration(hours: 5)),
      true,
      IconType.bus,
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
      'Top Up',
      50.00,
      DateTime.now().subtract(const Duration(days: 5)),
      false,
      IconType.wallet,
    );
  }
  
  // Method to add money to balance and record transaction
  void addBalance(double amount) {
    _balance += amount;
    _addTransaction('Top Up', amount, DateTime.now(), false, IconType.wallet);
    notifyListeners();
  }
  
  // Method to deduct money from balance and record transaction
  bool deductBalance(double amount, {String title = 'Payment', IconType iconType = IconType.payment}) {
    if (_balance >= amount) {
      _balance -= amount;
      _addTransaction(title, amount, DateTime.now(), true, iconType);
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
  
  // Method to reset balance to initial value
  void resetBalance() {
    _balance = 30.0;
    _transactions.clear();
    _addDemoTransactions();
    notifyListeners();
  }
} 