import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/loyalty_rank.dart';
import '../models/reward_item.dart';

/// Service responsible for managing the user rewards and loyalty program
class RewardsService extends ChangeNotifier {
  int _points = 0;
  List<String> _redeemedRewards = [];
  List<RewardHistoryItem> _pointsHistory = [];
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  RewardsService() {
    _initPrefs();
  }

  // Initialize shared preferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadData();
    _isInitialized = true;
    notifyListeners();
  }

  // Load saved data from storage
  Future<void> _loadData() async {
    _points = _prefs.getInt('user_points') ?? 16399; // Default points from the example
    _redeemedRewards = _prefs.getStringList('redeemed_rewards') ?? [];
    
    // Load points history
    List<String>? historyJson = _prefs.getStringList('points_history');
    if (historyJson != null) {
      _pointsHistory = historyJson
          .map((json) => RewardHistoryItem.fromJson(json))
          .toList();
    } else {
      // Sample history if none exists
      _pointsHistory = [
        RewardHistoryItem(
          id: 'h001',
          title: 'Bus trip from Central to Downtown',
          points: 125,
          date: DateTime.now().subtract(const Duration(days: 1)),
          type: HistoryItemType.earned,
        ),
        RewardHistoryItem(
          id: 'h002',
          title: 'Weekly streak bonus',
          points: 200,
          date: DateTime.now().subtract(const Duration(days: 3)),
          type: HistoryItemType.earned,
        ),
        RewardHistoryItem(
          id: 'h003',
          title: 'Coffee Discount Voucher',
          points: -300,
          date: DateTime.now().subtract(const Duration(days: 7)),
          type: HistoryItemType.redeemed,
          rewardId: 'r002',
        ),
      ];
    }
    notifyListeners();
  }

  // Save data to storage
  Future<void> _saveData() async {
    await _prefs.setInt('user_points', _points);
    await _prefs.setStringList('redeemed_rewards', _redeemedRewards);
    
    List<String> historyJson = _pointsHistory
        .map((item) => item.toJson())
        .toList();
    await _prefs.setStringList('points_history', historyJson);
  }

  // Properties
  int get points => _points;
  List<String> get redeemedRewards => _redeemedRewards;
  List<RewardHistoryItem> get pointsHistory => _pointsHistory;
  bool get isInitialized => _isInitialized;

  // Get the current loyalty rank based on points
  LoyaltyRank get currentRank => LoyaltyRank.getRankFromPoints(_points);

  // Get the next loyalty rank (or null if already at max)
  LoyaltyRank? get nextRank => LoyaltyRank.getNextRank(_points);

  // Get progress to next rank (0.0 to 1.0)
  double get progressToNextRank => LoyaltyRank.getProgressToNextRank(_points);

  // Get points needed for next rank
  int get pointsToNextRank {
    LoyaltyRank? next = nextRank;
    if (next == null) return 0; // Already at max rank
    return next.pointsRequired - _points;
  }

  // Check if user has redeemed a specific reward
  bool hasRedeemed(String rewardId) {
    return _redeemedRewards.contains(rewardId);
  }

  // Check if user can afford a reward
  bool canAfford(RewardItem reward) {
    return _points >= reward.pointsCost;
  }

  // Add points to user's account
  Future<void> addPoints(int amount, {required String title}) async {
    if (amount <= 0) return;
    
    _points += amount;
    
    // Create history item
    final historyItem = RewardHistoryItem(
      id: 'h${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      points: amount,
      date: DateTime.now(),
      type: HistoryItemType.earned,
    );
    
    _pointsHistory.insert(0, historyItem);
    
    await _saveData();
    notifyListeners();
  }

  // Redeem a reward (spend points)
  Future<bool> redeemReward(RewardItem reward) async {
    // Check if user can afford the reward
    if (_points < reward.pointsCost) {
      return false;
    }
    
    // Check if user meets rank requirements
    if (reward.requiredRank != null) {
      final userRank = currentRank.id;
      final requiredRankIndex = LoyaltyRank.ranks.indexWhere((r) => r.id == reward.requiredRank);
      final userRankIndex = LoyaltyRank.ranks.indexWhere((r) => r.id == userRank);
      
      if (userRankIndex < requiredRankIndex) {
        return false; // User's rank is lower than required
      }
    }
    
    // Deduct points
    _points -= reward.pointsCost;
    
    // Add to redeemed rewards
    _redeemedRewards.add(reward.id);
    
    // Create history item
    final historyItem = RewardHistoryItem(
      id: 'h${DateTime.now().millisecondsSinceEpoch}',
      title: reward.title,
      points: -reward.pointsCost,
      date: DateTime.now(),
      type: HistoryItemType.redeemed,
      rewardId: reward.id,
    );
    
    _pointsHistory.insert(0, historyItem);
    
    await _saveData();
    notifyListeners();
    return true;
  }

  // Get available rewards for the user's rank
  List<RewardItem> getAvailableRewards() {
    return RewardItem.getRewardsForRank(currentRank.id);
  }

  // Reset all data (for testing)
  Future<void> resetData() async {
    _points = 3250;
    _redeemedRewards = [];
    _pointsHistory = [];
    await _saveData();
    notifyListeners();
  }
  
  // Set points directly (for testing purposes)
  Future<void> setPoints(int newPoints) async {
    _points = newPoints;
    await _saveData();
    notifyListeners();
  }
}

/// Type of history item
enum HistoryItemType {
  earned,
  redeemed,
  expired,
  system
}

/// Represents an item in the user's points history
class RewardHistoryItem {
  final String id;
  final String title;
  final int points;
  final DateTime date;
  final HistoryItemType type;
  final String? rewardId;

  RewardHistoryItem({
    required this.id,
    required this.title,
    required this.points,
    required this.date,
    required this.type,
    this.rewardId,
  });

  factory RewardHistoryItem.fromJson(String jsonString) {
    final parts = jsonString.split('|');
    return RewardHistoryItem(
      id: parts[0],
      title: parts[1],
      points: int.parse(parts[2]),
      date: DateTime.parse(parts[3]),
      type: HistoryItemType.values[int.parse(parts[4])],
      rewardId: parts.length > 5 ? parts[5] : null,
    );
  }

  String toJson() {
    return '$id|$title|$points|${date.toIso8601String()}|${type.index}${rewardId != null ? '|$rewardId' : ''}';
  }
}