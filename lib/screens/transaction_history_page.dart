import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/theme_service.dart';
import '../services/balance_service.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Top Up', 'Bus Fare', 'Payments'];
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final balanceService = Provider.of<BalanceService>(context);
    final primaryColor = themeService.primaryColor;
    final secondaryColor = themeService.secondaryColor;
    
    // Get all transactions
    final transactions = balanceService.transactions;
    
    // Filter transactions if needed
    var filteredTransactions = _selectedFilter == 'All'
        ? transactions
        : transactions.where((tx) {
            if (_selectedFilter == 'Top Up') {
              return !tx.isDebit && tx.title == 'Top Up';
            } else if (_selectedFilter == 'Bus Fare') {
              return tx.isDebit && tx.title.contains('Bus');
            } else if (_selectedFilter == 'Payments') {
              return tx.isDebit && !tx.title.contains('Bus');
            }
            return false;
          }).toList();
    
    // Split by month
    final transactionsByMonth = _groupTransactionsByMonth(filteredTransactions);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: primaryColor.withOpacity(0.2),
                      checkmarkColor: primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? primaryColor : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? primaryColor : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Divider
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          
          // Transactions list
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_selectedFilter != 'All')
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedFilter = 'All';
                              });
                            },
                            child: Text(
                              'Clear filters',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: transactionsByMonth.length,
                    itemBuilder: (context, index) {
                      final monthEntry = transactionsByMonth.entries.elementAt(index);
                      return _buildMonthSection(monthEntry.key, monthEntry.value, primaryColor);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMonthSection(String month, List<Transaction> transactions, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            month,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        ...transactions.map((tx) => _buildTransactionItem(tx, primaryColor)).toList(),
        const SizedBox(height: 12),
      ],
    );
  }
  
  Widget _buildTransactionItem(Transaction transaction, Color primaryColor) {
    // Format date
    final formattedDate = _formatDate(transaction.date);
    
    // Determine icon based on transaction type
    IconData icon;
    
    switch (transaction.iconType) {
      case IconType.bus:
        icon = Icons.directions_bus;
        break;
      case IconType.wallet:
        icon = Icons.account_balance_wallet;
        break;
      case IconType.transfer:
        icon = Icons.swap_horiz;
        break;
      case IconType.payment:
        icon = Icons.payment;
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTransactionDetails(transaction),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Transaction icon
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: transaction.isDebit ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (transaction.isDebit ? Colors.red : Colors.green).withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: transaction.isDebit ? Colors.red : Colors.green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Transaction details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Amount
                Text(
                  '${transaction.isDebit ? '-' : '+'}RM ${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: transaction.isDebit ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Map<String, List<Transaction>> _groupTransactionsByMonth(List<Transaction> transactions) {
    final Map<String, List<Transaction>> result = {};
    
    for (final tx in transactions) {
      final month = DateFormat('MMMM yyyy').format(tx.date);
      if (!result.containsKey(month)) {
        result[month] = [];
      }
      result[month]!.add(tx);
    }
    
    return result;
  }
  
  void _showTransactionDetails(Transaction transaction) {
    final formattedDate = DateFormat('dd MMMM yyyy, h:mm a').format(transaction.date);
    IconData icon;
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final primaryColor = themeService.primaryColor;
    
    switch (transaction.iconType) {
      case IconType.bus:
        icon = Icons.directions_bus;
        break;
      case IconType.wallet:
        icon = Icons.account_balance_wallet;
        break;
      case IconType.transfer:
        icon = Icons.swap_horiz;
        break;
      case IconType.payment:
        icon = Icons.payment;
        break;
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              
              // Transaction icon
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: transaction.isDebit ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: transaction.isDebit ? Colors.red : Colors.green,
                  size: 35,
                ),
              ),
              const SizedBox(height: 16),
              
              // Amount
              Text(
                '${transaction.isDebit ? '-' : '+'}RM ${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: transaction.isDebit ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              
              // Title and date
              Text(
                transaction.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              
              // Transaction details
              _buildDetailRow('Transaction ID', '#TRX${transaction.date.millisecondsSinceEpoch.toString().substring(5)}'),
              const SizedBox(height: 8),
              _buildDetailRow('Status', 'Completed'),
              const SizedBox(height: 8),
              _buildDetailRow('Payment Method', 'Transit Go Card'),
              const SizedBox(height: 24),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Receipt downloaded'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Download Receipt'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction reported'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Report Issue'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      foregroundColor: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('d MMM, h:mm a').format(date);
    }
  }
} 