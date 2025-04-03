import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' show sin, pi;
import '../models/reward_item.dart';
import '../services/rewards_service.dart';
import '../services/theme_service.dart';

class RewardCatalogPage extends StatefulWidget {
  const RewardCatalogPage({super.key});

  @override
  State<RewardCatalogPage> createState() => _RewardCatalogPageState();
}

class _RewardCatalogPageState extends State<RewardCatalogPage> {
  RewardCategory? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RewardsService>(
      builder: (context, rewardsService, child) {
        final availableRewards = rewardsService.getAvailableRewards();
        final themeService = Provider.of<ThemeService>(context);
        // ignore: unused_local_variable
        final primaryColor = themeService.primaryColor;
        
        // Filter rewards based on selected category and search query
        final filteredRewards = _filterRewards(availableRewards);
        
        return Column(
          children: [
            // Search and filter bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search rewards',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      _showFilterBottomSheet(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedCategory != null ? primaryColor : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedCategory != null ? primaryColor.withOpacity(0.8) : Colors.grey.shade300,
                        ),
                      ),
                      child: Icon(
                        Icons.filter_list,
                        color: _selectedCategory != null ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Category filter chips
            SizedBox(
              height: 56,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip(null, 'All'),
                  _buildFilterChip(RewardCategory.voucher, 'Vouchers'),
                  _buildFilterChip(RewardCategory.discount, 'Discounts'),
                  _buildFilterChip(RewardCategory.experience, 'Experiences'),
                  _buildFilterChip(RewardCategory.merchandise, 'Merchandise'),
                  _buildFilterChip(RewardCategory.service, 'Services'),
                  _buildFilterChip(RewardCategory.donation, 'Donations'),
                  _buildFilterChip(RewardCategory.exclusive, 'Exclusive'),
                ],
              ),
            ),
            
            // Display filtered rewards
            Expanded(
              child: filteredRewards.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: filteredRewards.length,
                      itemBuilder: (context, index) {
                        return _buildRewardCard(filteredRewards[index], rewardsService);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  List<RewardItem> _filterRewards(List<RewardItem> rewards) {
    // Apply category filter
    var filtered = _selectedCategory == null
        ? rewards
        : rewards.where((reward) => reward.category == _selectedCategory).toList();
    
    // Apply search filter if needed
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((reward) =>
          reward.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          reward.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    return filtered;
  }

  Widget _buildFilterChip(RewardCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final primaryColor = themeService.primaryColor;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey.shade100,
        selectedColor: primaryColor,
        checkmarkColor: Colors.white,
        onSelected: (selected) {
          setState(() {
            if (category == RewardCategory.exclusive) {
              final rewardsService = Provider.of<RewardsService>(context, listen: false);
              if (rewardsService.currentRank.id != 'diamond') {
                _showDiamondLockOverlay();
                return;
              }
            }
            _selectedCategory = selected ? category : null;
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? primaryColor.withOpacity(0.8) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  void _showDiamondLockOverlay() {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final primaryColor = themeService.primaryColor;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lock animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.9 + (0.1 * value),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeInOut,
                      builder: (context, pulseValue, child) {
                        return Transform.scale(
                          scale: 1 + 0.05 * sin(pulseValue * 6 * pi),
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.lock,
                                    size: 60,
                                    color: primaryColor,
                                  ),
                                  Positioned(
                                    top: 15,
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0.0, end: 1.0),
                                      duration: const Duration(milliseconds: 1000),
                                      curve: Curves.elasticOut,
                                      builder: (context, rotateValue, child) {
                                        return Transform.rotate(
                                          angle: rotateValue * 2 * pi,
                                          child: Icon(
                                            Icons.workspace_premium,
                                            size: 24,
                                            color: Colors.amber,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Premium Content Locked',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Reach Diamond rank to unlock these premium rewards!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('OK, I understand'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final primaryColor = themeService.primaryColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.search_off,
                size: 40,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No rewards found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try changing your search or filter settings',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _searchQuery = '';
                _searchController.clear();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: primaryColor.withOpacity(0.7)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(RewardItem reward, RewardsService rewardsService) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    return GestureDetector(
      onTap: () {
        _showRewardDetails(reward, rewardsService);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First, show the image or category icon
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: reward.isExclusive 
                    ? Colors.amber.withOpacity(0.1) 
                    : Colors.blue.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(reward.category),
                  size: 48,
                  color: reward.isExclusive 
                      ? Colors.amber 
                      : Colors.blue,
                ),
              ),
            ),
            
            // Then show the details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Special tag for exclusive rewards
                  if (reward.isExclusive)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'EXCLUSIVE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ),
                  
                  // Reward title and category
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reward.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${reward.pointsCost} Points',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Redeem button or Locked indicator
                      if (rewardsService.canAfford(reward))
                        ElevatedButton(
                          onPressed: () {
                            _showRewardDetails(reward, rewardsService);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Redeem'),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.lock_outline, size: 12),
                          label: Text('${reward.pointsCost - rewardsService.points} more'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            disabledBackgroundColor: Colors.grey.shade200,
                            disabledForegroundColor: Colors.grey.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    reward.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final themeService = Provider.of<ThemeService>(context, listen: false);
        // ignore: unused_local_variable
        final primaryColor = themeService.primaryColor;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Filter title
                  const Text(
                    'Filter Rewards',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category selection
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildBottomSheetFilterChip(null, 'All', setState),
                      _buildBottomSheetFilterChip(RewardCategory.voucher, 'Vouchers', setState),
                      _buildBottomSheetFilterChip(RewardCategory.discount, 'Discounts', setState),
                      _buildBottomSheetFilterChip(RewardCategory.experience, 'Experiences', setState),
                      _buildBottomSheetFilterChip(RewardCategory.merchandise, 'Merchandise', setState),
                      _buildBottomSheetFilterChip(RewardCategory.service, 'Services', setState),
                      _buildBottomSheetFilterChip(RewardCategory.donation, 'Donations', setState),
                      _buildBottomSheetFilterChip(RewardCategory.exclusive, 'Exclusive', setState),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                            this.setState(() {}); // Update the main state
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomSheetFilterChip(RewardCategory? category, String label, StateSetter setState) {
    final isSelected = _selectedCategory == category;
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final primaryColor = themeService.primaryColor;
    
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.grey.shade100,
      selectedColor: primaryColor,
      checkmarkColor: Colors.white,
      onSelected: (selected) {
        setState(() {
          if (category == RewardCategory.exclusive) {
            final rewardsService = Provider.of<RewardsService>(context, listen: false);
            if (rewardsService.currentRank.id != 'diamond') {
              Navigator.pop(context); // Close the bottom sheet first
              _showDiamondLockOverlay();
              return;
            }
          }
          _selectedCategory = selected ? category : null;
        });
        this.setState(() {}); // Update the main state as well
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? primaryColor.withOpacity(0.7) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  void _showRewardDetails(RewardItem reward, RewardsService rewardsService) {
    final Color cardColor = reward.isExclusive ? Colors.amber : Colors.blue;
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final primaryColor = themeService.primaryColor;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Reward Icon/Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(reward.category),
                        color: cardColor,
                        size: 40,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Title
                  Center(
                    child: Text(
                      reward.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Point cost
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 20,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${reward.pointsCost} Points',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reward.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Additional info
                  if (reward.isLimited && reward.remainingQuantity != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Limited Availability',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                Text(
                                  'Only ${reward.remainingQuantity} left',
                                  style: TextStyle(
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  if (reward.requiredRank != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Exclusive Reward',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade700,
                                  ),
                                ),
                                Text(
                                  'Requires ${reward.requiredRank!.substring(0, 1).toUpperCase()}${reward.requiredRank!.substring(1)} rank or higher',
                                  style: TextStyle(
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Redeem button
                  ElevatedButton(
                    onPressed: rewardsService.canAfford(reward) 
                        ? () async {
                            bool success = await rewardsService.redeemReward(reward);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Successfully redeemed ${reward.title}!'
                                        : 'Failed to redeem the reward',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: success ? Colors.green : Colors.red,
                                ),
                              );
                            }
                          } 
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      rewardsService.canAfford(reward) 
                          ? 'Redeem Now' 
                          : 'Not Enough Points (Need ${reward.pointsCost - rewardsService.points} more)',
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(RewardCategory category) {
    switch (category) {
      case RewardCategory.voucher:
        return Icons.confirmation_number;
      case RewardCategory.discount:
        return Icons.local_offer;
      case RewardCategory.experience:
        return Icons.theater_comedy;
      case RewardCategory.merchandise:
        return Icons.shopping_bag;
      case RewardCategory.service:
        return Icons.room_service;
      case RewardCategory.donation:
        return Icons.volunteer_activism;
      case RewardCategory.exclusive:
        return Icons.workspace_premium;
    }
  }
} 