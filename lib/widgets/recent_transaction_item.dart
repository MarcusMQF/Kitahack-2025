import 'package:flutter/material.dart';

class RecentTransactionItem extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final IconData icon;
  final bool isDebit;
  final Color color;

  const RecentTransactionItem({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.icon,
    required this.isDebit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDebit ? Colors.red.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDebit ? Colors.red.shade700 : Colors.green.shade700,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          date,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDebit ? Colors.red.shade700 : Colors.green.shade700,
          ),
        ),
      ),
    );
  }
} 