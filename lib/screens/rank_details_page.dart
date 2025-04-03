import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/loyalty_rank.dart';
import '../services/rewards_service.dart';
import '../services/theme_service.dart';

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
    // Get theme service to access theme colors
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Loyalty Ranks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        leading: Container(
          margin: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(0),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
      body: Consumer<RewardsService>(
        builder: (context, rewardsService, child) {
          final currentUserRank = rewardsService.currentRank;
          final userPoints = rewardsService.points;
          final userCredits = rewardsService.credits;
          
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
                      final isLocked = userCredits < rank.creditsRequired;
                      
                      return _buildRankCard(
                        rank,
                        isCurrentRank,
                        isLocked,
                        userPoints,
                        userCredits,
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
                          ? primaryColor
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
    int userCredits,
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
                        'Credits Required',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${rank.creditsRequired}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      
                      if (isLocked && rank.creditsRequired > userCredits) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Need ${rank.creditsRequired - userCredits} more credits',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
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
                          boxShadow: [
                            BoxShadow(
                              color: rank.color.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                              spreadRadius: -2,
                            ),
                          ],
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
        ],
      ),
    );
  }
}