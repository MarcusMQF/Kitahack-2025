import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/loyalty_rank.dart';
import '../services/rewards_service.dart';

class RankDetailsPage extends StatefulWidget {
  final LoyaltyRank initialRank;
  
  const RankDetailsPage({super.key, required this.initialRank});

  @override
  State<RankDetailsPage> createState() => _RankDetailsPageState();
}

class _RankDetailsPageState extends State<RankDetailsPage> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Find the index of the initial rank
    _currentPage = LoyaltyRank.ranks.indexWhere((rank) => rank.id == widget.initialRank.id);
    if (_currentPage < 0) _currentPage = 0; // Default to first rank if not found
    
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.85,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Loyalty Ranks'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<RewardsService>(
        builder: (context, rewardsService, child) {
          final currentUserRank = rewardsService.currentRank;
          
          return Column(
            children: [
              // Rank cards carousel
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: SizedBox(
                  height: 240,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: LoyaltyRank.ranks.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final rank = LoyaltyRank.ranks[index];
                      final isCurrentRank = currentUserRank.id == rank.id;
                      final isLocked = rewardsService.points < rank.pointsRequired;
                      
                      return _buildRankCard(
                        rank,
                        isCurrentRank,
                        isLocked,
                        rewardsService.points,
                      );
                    },
                  ),
                ),
              ),
              
              // Page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(LoyaltyRank.ranks.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.blue
                          : Colors.grey.shade300,
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 24),
              
              // Rank benefits
              Expanded(
                child: _buildRankDetails(LoyaltyRank.ranks[_currentPage]),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildRankCard(
    LoyaltyRank rank,
    bool isCurrentRank,
    bool isLocked,
    int userPoints,
  ) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isLocked ? 0.7 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              rank.color.withOpacity(0.7),
              rank.color,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: rank.color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with rank name and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rank.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isCurrentRank
                                  ? 'Current Rank'
                                  : isLocked
                                      ? 'Locked'
                                      : 'Achieved',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Rank icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              rank.iconPath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                print("Error loading image: ${rank.iconPath} - ${error.toString()}");
                                return const Icon(
                                  Icons.emoji_events,
                                  color: Colors.white,
                                  size: 28,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Points required
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Points Required',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${rank.pointsRequired}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      
                      if (isLocked && rank.pointsRequired > userPoints) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Need ${rank.pointsRequired - userPoints} more points',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRankDetails(LoyaltyRank rank) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(
                Icons.stars,
                color: rank.color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${rank.name} Benefits',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: rank.color,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Benefits list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: rank.benefits.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: rank.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check,
                            color: rank.color,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          rank.benefits[index],
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Compare with other ranks button
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  _showRankComparisonSheet(context);
                },
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Compare All Ranks'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showRankComparisonSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
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
              child: Column(
                children: [
                  // Handle and title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Rank Comparison',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Ranks and benefits comparison
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        _buildComparisonTable(),
                      ],
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
  
  Widget _buildComparisonTable() {
    const TextStyle headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    
    return Consumer<RewardsService>(
      builder: (context, rewardsService, child) {
        final currentRankId = rewardsService.currentRank.id;
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            headingRowHeight: 56,
            dataRowMinHeight: 60,
            dataRowMaxHeight: 100,
            columns: [
              const DataColumn(
                label: Text(
                  'Benefit',
                  style: headerStyle,
                ),
              ),
              ...LoyaltyRank.ranks.map((rank) {
                final isCurrent = rank.id == currentRankId;
                return DataColumn(
                  label: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: isCurrent ? BoxDecoration(
                      color: rank.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: rank.color),
                    ) : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          rank.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: rank.color,
                            fontSize: 14,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: rank.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CURRENT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
            rows: _buildComparisonRows(),
          ),
        );
      },
    );
  }
  
  List<DataRow> _buildComparisonRows() {
    // Collect all unique benefits across all ranks
    final Set<String> allBenefits = {};
    for (var rank in LoyaltyRank.ranks) {
      allBenefits.addAll(rank.benefits);
    }
    
    // Create rows for each benefit
    return allBenefits.map((benefit) {
      return DataRow(
        cells: [
          DataCell(
            SizedBox(
              width: 150,
              child: Text(
                benefit,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ...LoyaltyRank.ranks.map((rank) {
            final hasBenefit = rank.benefits.contains(benefit);
            return DataCell(
              hasBenefit
                ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: rank.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: rank.color,
                      size: 16,
                    ),
                  )
                : const Icon(
                    Icons.close,
                    color: Colors.grey,
                    size: 16,
                  ),
            );
          }).toList(),
        ],
      );
    }).toList();
  }
}