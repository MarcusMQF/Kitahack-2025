import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/rewards_service.dart';
import '../services/theme_service.dart';
import '../models/loyalty_rank.dart';
import '../models/reward_item.dart';
import 'rank_details_page.dart';
import 'reward_history_page.dart';
import 'reward_catalog_page.dart';

class RewardPage extends StatefulWidget {
  final int initialTabIndex;

  const RewardPage({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if the page was navigated to directly (not via bottom nav)
    final bool showBackButton = Navigator.canPop(context);
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    final secondaryColor = themeService.secondaryColor;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                secondaryColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top section with back button and title
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      // Back button or rewards icon
                      if (showBackButton)
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      const SizedBox(width: 16),
                      // Title
                      const Text(
                        'Rewards',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tab bar
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withOpacity(0.7),
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Redeem'),
                        Tab(text: 'History'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          const RewardCatalogPage(),
          const RewardHistoryPage(isStandalone: false),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    return Consumer<RewardsService>(
      builder: (context, rewardsService, child) {
        // Get current rank and next rank
        final currentRank = rewardsService.currentRank;
        final nextRank = rewardsService.nextRank;
        final progress = rewardsService.progressToNextRank;
        final pointsToNext = rewardsService.pointsToNextRank;
        final totalCredits = rewardsService.credits;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current rank card with upgrade progress
              _buildRankCard(currentRank, nextRank, progress, pointsToNext, totalCredits),
              
              const SizedBox(height: 24),
              
              // Quick stats cards
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 24,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Stats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Available Points',
                      value: '${rewardsService.points}',
                      icon: Icons.star_rounded,
                      color: const Color.fromARGB(255, 255, 189, 45),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'TransitGo Credits',
                      value: '${rewardsService.credits}',
                      icon: Icons.diamond_rounded,
                      color: Colors.purple
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Recommended rewards section
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 24,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Recommended For You',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        _tabController.animateTo(1); // Switch to Rewards tab
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'See All',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Show recommended rewards (first 3 that the user can afford)
              _buildRecommendedRewards(rewardsService),
              
              const SizedBox(height: 24),
              
              // Rank benefits section
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 24,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Your Rank Benefits',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => RankDetailsPage(initialRank: currentRank),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'View All Ranks',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              _buildRankBenefits(currentRank),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankCard(
    LoyaltyRank currentRank, 
    LoyaltyRank? nextRank, 
    double progress, 
    int creditsToNext,
    int totalCredits
  ) {
    return Card(
      elevation: 8,
      shadowColor: currentRank.color.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
          ),
          border: Border.all(
            color: currentRank.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top section with current rank and icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rank info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Rank',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            currentRank.name,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: currentRank.color,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.star,
                            color: currentRank.color,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Rank icon with shadow
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: currentRank.color.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: currentRank.color.withOpacity(0.1),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Image.asset(
                            currentRank.iconPath,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.emoji_events,
                                color: currentRank.color,
                                size: 28,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Points display with animation - only shown if not at highest rank
              if (nextRank != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: TweenAnimationBuilder(
                    tween: IntTween(begin: 0, end: totalCredits),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Text(
                        '$value TransitGo Credits',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
              
              // Progress section
              if (nextRank != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progress to ${nextRank.name}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${totalCredits - currentRank.creditsRequired} of ${nextRank.creditsRequired - currentRank.creditsRequired} credits',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              'Need $creditsToNext more',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Clean progress bar
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final barWidth = constraints.maxWidth;
                          
                          return Stack(
                            children: [
                              // Background track
                              Container(
                                height: 8,
                                width: barWidth,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              
                              // Progress fill with animation
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.0, end: progress),
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Container(
                                    height: 8,
                                    width: barWidth * value,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          nextRank.color.withOpacity(0.7),
                                          nextRank.color,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        }
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Rank indicators at bottom
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Current rank
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: currentRank.color.withOpacity(0.1),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Image.asset(
                                      currentRank.iconPath,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.emoji_events,
                                          color: currentRank.color,
                                          size: 12,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentRank.name,
                                    style: TextStyle(
                                      color: currentRank.color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '${currentRank.creditsRequired} credits',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          // Next rank
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    nextRank.name,
                                    style: TextStyle(
                                      color: nextRank.color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '${nextRank.creditsRequired} credits',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 6),
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: nextRank.color.withOpacity(0.1),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Image.asset(
                                      nextRank.iconPath,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.emoji_events,
                                          color: nextRank.color,
                                          size: 12,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Highest rank achieved
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: currentRank.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: currentRank.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: currentRank.color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'You\'ve reached the highest rank!',
                        style: TextStyle(
                          color: currentRank.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedRewards(RewardsService rewardsService) {
    final availableRewards = rewardsService.getAvailableRewards();
    final affordableRewards = availableRewards
        .where((reward) => rewardsService.canAfford(reward))
        .take(3)
        .toList();
    
    if (affordableRewards.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.amber.shade200,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.amber.shade700,
                size: 40,
              ),
              const SizedBox(height: 16),
              const Text(
                'Earn more points to unlock rewards!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Take more trips to earn points that you can redeem for exciting rewards.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      children: affordableRewards.map((reward) => _buildRewardCard(reward, rewardsService)).toList(),
    );
  }

  Widget _buildRewardCard(RewardItem reward, RewardsService rewardsService) {
    final isExclusive = reward.isExclusive;
    final Color cardColor = isExclusive ? Colors.amber : Colors.blue;
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black26,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isExclusive ? Colors.amber.shade200 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            _showRewardDetails(reward, rewardsService);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Reward image/icon
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: cardColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(reward.category),
                      color: cardColor,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Reward details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reward.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (isExclusive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.amber.shade300),
                              ),
                              child: Text(
                                'Exclusive',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reward.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primaryColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: primaryColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${reward.pointsCost}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (reward.isLimited && reward.remainingQuantity != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_filled,
                                    size: 12,
                                    color: Colors.red.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${reward.remainingQuantity} left',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankBenefits(LoyaltyRank rank) {
    return Column(
      children: rank.benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
              color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
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
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                        spreadRadius: -1,
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
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    benefit,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showRewardDetails(RewardItem reward, RewardsService rewardsService) {
    final Color cardColor = reward.isExclusive ? Colors.amber : Colors.blue;
    final themeService = Provider.of<ThemeService>(context);
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
                      boxShadow: [
                        BoxShadow(
                          color: cardColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                          spreadRadius: -2,
                        ),
                      ],
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
                            color: primaryColor,
                            size: 16,
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
