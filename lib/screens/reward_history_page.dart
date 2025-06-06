import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/rewards_service.dart';
import '../services/theme_service.dart';

class RewardHistoryPage extends StatefulWidget {
  final bool isStandalone;

  const RewardHistoryPage({
    super.key,
    this.isStandalone = true,
  });

  @override
  State<RewardHistoryPage> createState() => _RewardHistoryPageState();
}

class _RewardHistoryPageState extends State<RewardHistoryPage> {
  HistoryItemType? _selectedFilter;
  
  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    // Build the main content
    Widget content = Consumer<RewardsService>(
      builder: (context, rewardsService, child) {
        final history = rewardsService.pointsHistory;
        
        print('RewardHistoryPage: Displaying ${history.length} history items');
        
        // Apply filter if selected
        final filteredHistory = _selectedFilter == null
            ? history
            : history.where((item) => item.type == _selectedFilter).toList();
        
        return Column(
          children: [
            // Filter buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  _buildFilterButton(null, 'All'),
                  const SizedBox(width: 8),
                  _buildFilterButton(HistoryItemType.earned, 'Earned'),
                  const SizedBox(width: 8),
                  _buildFilterButton(HistoryItemType.redeemed, 'Redeemed'),
                ],
              ),
            ),
            
            // Divider
            Divider(color: Colors.grey.shade200, height: 1),
            
            // History list
            Expanded(
              child: filteredHistory.isEmpty
                  ? _buildEmptyState() 
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: filteredHistory.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filteredHistory[index];
                        return _buildHistoryItem(item);
                      },
                    ),
            ),
          ],
        );
      },
    );
    
    // If this is a standalone page, wrap it in a Scaffold
    if (widget.isStandalone) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Reward History',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: content,
      );
    }
    
    // Otherwise, just return the content for use in a TabBarView
    return content;
  }
  
  Widget _buildFilterButton(HistoryItemType? type, String label) {
    final isSelected = _selectedFilter == type;
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = isSelected ? null : type;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor.withOpacity(0.7) : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == null
                ? 'No History Yet'
                : _selectedFilter == HistoryItemType.earned
                    ? 'No Points Earned Yet'
                    : 'No Rewards Redeemed Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == HistoryItemType.earned
                ? 'Take more trips to earn points'
                : _selectedFilter == HistoryItemType.redeemed
                    ? 'Redeem your points for rewards'
                    : 'Your points activity will appear here',
            style: const TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildHistoryItem(RewardHistoryItem item) {
    Color statusColor;
    IconData statusIcon;
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    switch (item.type) {
      case HistoryItemType.earned:
        statusColor = Colors.green;
        statusIcon = Icons.directions_bus_filled;
        break;
      case HistoryItemType.redeemed:
        statusColor = primaryColor;
        statusIcon = Icons.wallet_giftcard;
        break;
      case HistoryItemType.expired:
        statusColor = Colors.red;
        statusIcon = Icons.timer_off;
        break;
      case HistoryItemType.system:
        statusColor = Colors.grey;
        statusIcon = Icons.settings;
        break;
    }
    
    final formattedDate = DateFormat.yMMMd().format(item.date);
    final formattedTime = DateFormat.jm().format(item.date);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$formattedDate at $formattedTime',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // If this item has multiple rewards (points and credits), show both
            if (item.hasMultipleRewards && item.creditsAmount != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Points indicator
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 245, 218),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color.fromARGB(255, 255, 219, 134),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: const Color.fromARGB(255, 255, 189, 45),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${item.points}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: const Color.fromARGB(255, 255, 189, 45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Credits indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.purple.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.diamond_rounded,
                          size: 14,
                          color: Colors.purple.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${item.creditsAmount}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              // Regular points amount for standard items
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: item.points > 0
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: item.points > 0 
                        ? Colors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.points > 0 ? Icons.star : Icons.remove_circle_outline,
                      size: 14,
                      color: item.points > 0 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.points > 0 ? '+${item.points}' : '${item.points}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: item.points > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
} 