import 'package:flutter/material.dart';

/// Defines the loyalty ranks with their requirements and benefits
class LoyaltyRank {
  final String id;
  final String name;
  final int creditsRequired;
  final Color color;
  final List<String> benefits;
  final String iconPath;

  const LoyaltyRank({
    required this.id,
    required this.name,
    required this.creditsRequired,
    required this.color,
    required this.benefits,
    required this.iconPath,
  });

  static const List<LoyaltyRank> ranks = [
    LoyaltyRank(
      id: 'bronze',
      name: 'Bronze',
      creditsRequired: 0,
      color: Color(0xFFCD7F32),
      benefits: [
        'Basic reward catalog access',
        '5% bonus points on trips',
        'Special offers notification',
      ],
      iconPath: 'lib/images/bronze.png',
    ),
    LoyaltyRank(
      id: 'silver',
      name: 'Silver',
      creditsRequired: 5000,
      color: Color(0xFFC0C0C0),
      benefits: [
        'All Bronze benefits',
        '10% bonus points on trips',
        'Priority customer support',
        'Monthly bonus rewards',
      ],
      iconPath: 'lib/images/silver.png',
    ),
    LoyaltyRank(
      id: 'gold',
      name: 'Gold',
      creditsRequired: 15000,
      color: Color(0xFFDAA520),
      benefits: [
        'All Silver benefits',
        '15% bonus points on trips',
        'Exclusive gold rewards',
        'Quarterly loyalty gift',
        'Premium trip experiences',
      ],
      iconPath: 'lib/images/gold.png',
    ),
    LoyaltyRank(
      id: 'platinum',
      name: 'Platinum',
      creditsRequired: 30000,
      color: Color(0xFF3F51B5),
      benefits: [
        'All Gold benefits',
        '25% bonus points on trips',
        'Exclusive partnerships benefits',
        'Special event invitations',
        'Priority booking for services',
        'Dedicated support line',
      ],
      iconPath: 'lib/images/platinum.png',
    ),
    LoyaltyRank(
      id: 'diamond',
      name: 'Diamond',
      creditsRequired: 50000,
      color: Color(0xFF9C27B0),
      benefits: [
        'All Platinum benefits',
        '40% bonus points on trips',
        'VIP experiences and services',
        'Complimentary upgrades',
        'Annual luxury gift',
        'Personal travel concierge',
        'Exclusive Diamond-only rewards',
      ],
      iconPath: 'lib/images/diamond.png',
    ),
  ];

  /// Get a rank based on the accumulated credits
  static LoyaltyRank getRankFromPoints(int credits) {
    LoyaltyRank currentRank = ranks.first;
    
    for (var rank in ranks) {
      if (credits >= rank.creditsRequired) {
        currentRank = rank;
      } else {
        break;
      }
    }
    
    return currentRank;
  }

  /// Get the next rank based on the current accumulated credits
  static LoyaltyRank? getNextRank(int credits) {
    LoyaltyRank currentRank = getRankFromPoints(credits);
    int currentIndex = ranks.indexOf(currentRank);
    
    if (currentIndex < ranks.length - 1) {
      return ranks[currentIndex + 1];
    }
    
    return null; // Already at highest rank
  }

  /// Calculate progress to next rank (0.0 to 1.0)
  static double getProgressToNextRank(int credits) {
    LoyaltyRank currentRank = getRankFromPoints(credits);
    LoyaltyRank? nextRank = getNextRank(credits);
    
    if (nextRank == null) {
      return 1.0; // Already at max rank
    }
    
    int creditsForCurrentRank = credits - currentRank.creditsRequired;
    int creditsNeededForNextRank = nextRank.creditsRequired - currentRank.creditsRequired;
    
    return creditsForCurrentRank / creditsNeededForNextRank;
  }
}