
/// Categories of rewards available in the app
enum RewardCategory {
  voucher,
  discount,
  experience,
  merchandise,
  service,
  donation,
  exclusive
}

/// Model representing a reward item that can be redeemed with points
class RewardItem {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final String imageUrl;
  final RewardCategory category;
  final bool isExclusive;
  final String? requiredRank; // Null means available to all ranks
  final DateTime? expiryDate;
  final bool isLimited;
  final int? remainingQuantity;

  const RewardItem({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.imageUrl,
    required this.category,
    this.isExclusive = false,
    this.requiredRank,
    this.expiryDate,
    this.isLimited = false,
    this.remainingQuantity,
  });

  // Example list of reward items
  static const List<RewardItem> sampleRewards = [
    RewardItem(
      id: 'r001',
      title: 'Free Bus Ride',
      description: 'Get a free bus ride to any destination within the city.',
      pointsCost: 500,
      imageUrl: 'assets/images/rewards/bus_ticket.png',
      category: RewardCategory.voucher,
    ),
    RewardItem(
      id: 'r002',
      title: 'Coffee Discount',
      description: '50% off at participating coffee shops near transit stations.',
      pointsCost: 300,
      imageUrl: 'assets/images/rewards/coffee.png',
      category: RewardCategory.discount,
    ),
    RewardItem(
      id: 'r003',
      title: 'Movie Tickets',
      description: 'Two movie tickets at any cinema in the city.',
      pointsCost: 1200,
      imageUrl: 'assets/images/rewards/movie.png',
      category: RewardCategory.voucher,
    ),
    RewardItem(
      id: 'r004',
      title: 'Transit Merchandise',
      description: 'Exclusive transit-themed t-shirt.',
      pointsCost: 800,
      imageUrl: 'assets/images/rewards/tshirt.png',
      category: RewardCategory.merchandise,
    ),
    RewardItem(
      id: 'r005',
      title: 'Museum Pass',
      description: 'Free entry to the city museum for two persons.',
      pointsCost: 1000,
      imageUrl: 'assets/images/rewards/museum.png',
      category: RewardCategory.experience,
    ),
    RewardItem(
      id: 'r006',
      title: 'Premium Account Upgrade',
      description: 'Upgrade to Premium account for 1 month with extra features.',
      pointsCost: 2000,
      imageUrl: 'assets/images/rewards/premium.png',
      category: RewardCategory.service,
    ),
    RewardItem(
      id: 'r007',
      title: 'Plant a Tree',
      description: 'Donate your points to plant a tree in the city park.',
      pointsCost: 1500,
      imageUrl: 'assets/images/rewards/tree.png',
      category: RewardCategory.donation,
    ),
    RewardItem(
      id: 'r008',
      title: 'VIP City Tour',
      description: 'Exclusive guided tour of city landmarks.',
      pointsCost: 5000,
      imageUrl: 'assets/images/rewards/tour.png',
      category: RewardCategory.exclusive,
      isExclusive: true,
      requiredRank: 'gold',
    ),
    RewardItem(
      id: 'r009',
      title: 'Limited Edition Transit Card',
      description: 'Collector\'s edition transit card with special design.',
      pointsCost: 3000,
      imageUrl: 'assets/images/rewards/card.png',
      category: RewardCategory.merchandise,
      isLimited: true,
      remainingQuantity: 50,
    ),
    RewardItem(
      id: 'r010',
      title: 'Annual Transit Pass',
      description: 'Free transit for a full year on all city routes.',
      pointsCost: 25000,
      imageUrl: 'assets/images/rewards/annual_pass.png',
      category: RewardCategory.exclusive,
      isExclusive: true,
      requiredRank: 'diamond',
    ),
  ];

  // Get rewards filtered by rank
  static List<RewardItem> getRewardsForRank(String rankId) {
    return sampleRewards.where((reward) {
      if (reward.requiredRank == null) return true;
      
      // Check rank hierarchy
      if (rankId == 'diamond') return true;
      if (rankId == 'platinum' && reward.requiredRank != 'diamond') return true;
      if (rankId == 'gold' && (reward.requiredRank == 'gold' || reward.requiredRank == 'silver' || reward.requiredRank == 'bronze')) return true;
      if (rankId == 'silver' && (reward.requiredRank == 'silver' || reward.requiredRank == 'bronze')) return true;
      if (rankId == 'bronze' && reward.requiredRank == 'bronze') return true;
      
      return false;
    }).toList();
  }
}