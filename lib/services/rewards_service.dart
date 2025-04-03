import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/loyalty_rank.dart';
import '../models/reward_item.dart';

/// Service responsible for managing the user rewards and loyalty program
///
/// This service implements a dual-currency rewards system:
/// 1. Points - Used for redeeming rewards from the rewards catalog
///    When points are spent on rewards, they are deducted from the user's
///    available points balance but do NOT affect their rank progression.
///
/// 2. TransitGo Credits - Used for determining loyalty rank progression
///    Credits are accumulated alongside points but are never spent.
///    They represent the user's lifetime contribution/usage and determine
///    their loyalty rank (Bronze, Silver, Gold, etc.).
///
/// This approach allows users to freely spend their points on rewards
/// without worrying about losing their loyalty rank status.
class RewardsService extends ChangeNotifier {
  int _points = 0;
  int _credits = 0; // TransitGo Credits for rank promotion
  List<String> _redeemedRewards = [];
  List<RewardHistoryItem> _pointsHistory = [];
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  RewardsService() {
    _initPrefs();
  }

  // Initialize shared preferences
  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadData();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing rewards service: $e');
      // If there's an error loading data, reset to defaults
      try {
        _prefs = await SharedPreferences.getInstance();
        await _resetToDefaults();
      } catch (e2) {
        print('Error during recovery: $e2');
        // Last resort fallback
        _points = 100;
        _credits = 100;
        _redeemedRewards = [];
        _pointsHistory = [];
      }
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Load saved data from storage
  Future<void> _loadData() async {
    // Load basic data
    _points = _prefs.getInt('user_points') ?? 16399; // Default points from the example
    _credits = _prefs.getInt('user_credits') ?? 16399; // Start with same value as points
    _redeemedRewards = _prefs.getStringList('redeemed_rewards') ?? [];
    
    // Load points history with better error handling
    List<String>? historyJson = _prefs.getStringList('points_history');
    print('Loading history: Found ${historyJson?.length ?? 0} items in SharedPreferences');
    
    if (historyJson != null && historyJson.isNotEmpty) {
      try {
        List<RewardHistoryItem> loadedItems = [];
        
        // Process each item individually to avoid failing the entire load
        for (String json in historyJson) {
          try {
            RewardHistoryItem item = RewardHistoryItem.fromJson(json);
            loadedItems.add(item);
          } catch (itemError) {
            print('Error parsing history item: $itemError');
            // Continue to next item
          }
        }
        
        // Only assign if we loaded some valid items
        if (loadedItems.isNotEmpty) {
          _pointsHistory = loadedItems;
          print('Successfully loaded ${loadedItems.length} history items');
        } else {
          // Handle case where we couldn't parse any items
          print('Warning: Could not parse any history items');
          _createDefaultHistory();
        }
      } catch (e) {
        print('Error loading reward history: $e');
        _createDefaultHistory();
      }
    } else {
      print('No history found, creating sample history');
      _createDefaultHistory();
    }
    notifyListeners();
  }
  
  // Create default history items
  void _createDefaultHistory() {
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

  // Save data to storage
  Future<void> _saveData() async {
    try {
      print('Saving data to SharedPreferences...');
      print('Points: $_points, Credits: $_credits');
      print('History items count: ${_pointsHistory.length}');
      
      // Save basic data
      await _prefs.setInt('user_points', _points);
      await _prefs.setInt('user_credits', _credits);
      await _prefs.setStringList('redeemed_rewards', _redeemedRewards);
      
      // Convert history items to JSON
      List<String> historyJson = [];
      for (var item in _pointsHistory) {
        try {
          final json = item.toJson();
          historyJson.add(json);
        } catch (e) {
          print('Error converting history item to JSON: $e');
          // Continue with other items
        }
      }
      
      // Save history items
      final success = await _prefs.setStringList('points_history', historyJson);
      
      if (success) {
        print('Successfully saved ${historyJson.length} history items');
      } else {
        print('Failed to save history items');
      }
      
      // Verify data was saved correctly by reading it back
      final verifyPoints = _prefs.getInt('user_points');
      final verifyCredits = _prefs.getInt('user_credits');
      final verifyHistory = _prefs.getStringList('points_history');
      
      print('Verification - Points: $verifyPoints, Credits: $verifyCredits');
      print('Verification - History items: ${verifyHistory?.length ?? 0}');
      
    } catch (e) {
      print('Error in _saveData: $e');
      // Try to save the most critical data even if there was an error
      try {
        await _prefs.setInt('user_points', _points);
        await _prefs.setInt('user_credits', _credits);
      } catch (e2) {
        print('Critical error saving basic data: $e2');
      }
    }
  }

  // Properties
  int get points => _points;
  int get credits => _credits; // Getter for credits
  List<String> get redeemedRewards => _redeemedRewards;
  List<RewardHistoryItem> get pointsHistory => _pointsHistory;
  bool get isInitialized => _isInitialized;

  // Get the current loyalty rank based on credits, not points
  LoyaltyRank get currentRank => LoyaltyRank.getRankFromPoints(_credits);

  // Get the next loyalty rank (or null if already at max)
  LoyaltyRank? get nextRank => LoyaltyRank.getNextRank(_credits);

  // Get progress to next rank (0.0 to 1.0)
  double get progressToNextRank => LoyaltyRank.getProgressToNextRank(_credits);

  // Get credits needed for next rank
  int get pointsToNextRank {
    LoyaltyRank? next = nextRank;
    if (next == null) return 0; // Already at max rank
    return next.creditsRequired - _credits;
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
    _credits += amount; // Also add to credits
    
    // Create history item
    final historyItem = RewardHistoryItem(
      id: 'h${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      points: amount,
      date: DateTime.now(),
      type: HistoryItemType.earned,
    );
    
    _pointsHistory.insert(0, historyItem);
    
    // Limit history to latest 20 items
    if (_pointsHistory.length > 20) {
      _pointsHistory = _pointsHistory.sublist(0, 20);
    }
    
    await _saveData();
    notifyListeners();
  }

  // Add both points and credits separately (for trip rewards)
  Future<void> claimTripRewards(int pointsAmount, int creditsAmount, {required String title}) async {
    if (pointsAmount <= 0 && creditsAmount <= 0) return;
    
    // Update points and credits
    _points += pointsAmount;
    _credits += creditsAmount;
    
    // Create a single history item that represents both values
    final historyItem = RewardHistoryItem(
      id: 'h${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      points: pointsAmount,
      date: DateTime.now(),
      type: HistoryItemType.earned,
      creditsAmount: creditsAmount,
      hasMultipleRewards: true,
    );
    
    // Add to history and limit to 20 items
    _pointsHistory.insert(0, historyItem);
    if (_pointsHistory.length > 20) {
      _pointsHistory = _pointsHistory.sublist(0, 20);
    }
    
    // Make sure we save data synchronously before proceeding
    try {
      // Immediately save to SharedPreferences
      await _prefs.setInt('user_points', _points);
      await _prefs.setInt('user_credits', _credits);
      
      // Save history items
      List<String> historyJson = _pointsHistory.map((item) => item.toJson()).toList();
      await _prefs.setStringList('points_history', historyJson);
      
      print('Saved ${historyJson.length} history items to SharedPreferences');
    } catch (e) {
      print('Error saving claim data: $e');
    }
    
    // Notify listeners after data is saved
    notifyListeners();
  }

  // Redeem a reward (spend points but don't affect credits)
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
    
    // Deduct points but don't affect credits
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
    _credits = 3250;
    _redeemedRewards = [];
    _pointsHistory = [];
    await _saveData();
    notifyListeners();
  }
  
  // Set points directly (for testing purposes)
  Future<void> setPoints(int newPoints) async {
    _points = newPoints;
    _credits = newPoints; // Also set credits to same value
    await _saveData();
    notifyListeners();
  }
  
  // Set credits directly (for testing)
  Future<void> setCredits(int newCredits) async {
    _credits = newCredits;
    await _saveData();
    notifyListeners();
  }

  // Reset to defaults if data is corrupted
  Future<void> _resetToDefaults() async {
    print('Resetting rewards data to defaults due to corruption');
    _points = 100;
    _credits = 100;
    _redeemedRewards = [];
    _pointsHistory = [
      RewardHistoryItem(
        id: 'welcome',
        title: 'Welcome Bonus',
        points: 100,
        date: DateTime.now(),
        type: HistoryItemType.earned,
        creditsAmount: 100,
        hasMultipleRewards: true,
      ),
    ];
    
    try {
      await _prefs.setInt('user_points', _points);
      await _prefs.setInt('user_credits', _credits);
      await _prefs.setStringList('redeemed_rewards', _redeemedRewards);
      
      List<String> historyJson = _pointsHistory
          .map((item) => item.toJson())
          .toList();
      await _prefs.setStringList('points_history', historyJson);
    } catch (e) {
      print('Error resetting rewards data: $e');
    }
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
  final bool isCredits;
  final int? creditsAmount;
  final bool hasMultipleRewards;

  RewardHistoryItem({
    required this.id,
    required this.title,
    required this.points,
    required this.date,
    required this.type,
    this.rewardId,
    this.isCredits = false,
    this.creditsAmount,
    this.hasMultipleRewards = false,
  });

  factory RewardHistoryItem.fromJson(String jsonString) {
    try {
      print('Parsing history item: $jsonString');
      final parts = jsonString.split('|');
      
      // Ensure we have the minimum required parts
      if (parts.length < 5) {
        throw FormatException('Invalid history item format: expected at least 5 parts, got ${parts.length}');
      }
      
      // More verbose parsing with individual error handling for each field
      String id;
      String title;
      int points;
      DateTime date;
      HistoryItemType type;
      String? rewardId;
      bool isCredits;
      int? creditsAmount;
      bool hasMultipleRewards;
      
      try {
        id = parts[0];
        if (id.isEmpty) throw FormatException('Empty ID');
      } catch (e) {
        print('Error parsing ID: $e');
        id = 'error_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      try {
        title = parts[1];
        if (title.isEmpty) throw FormatException('Empty title');
      } catch (e) {
        print('Error parsing title: $e');
        title = 'Unknown Reward';
      }
      
      try {
        points = int.parse(parts[2]);
      } catch (e) {
        print('Error parsing points: $e');
        points = 0;
      }
      
      try {
        date = DateTime.parse(parts[3]);
      } catch (e) {
        print('Error parsing date: $e');
        date = DateTime.now();
      }
      
      try {
        final typeIndex = int.parse(parts[4]);
        if (typeIndex < 0 || typeIndex >= HistoryItemType.values.length) {
          throw FormatException('Invalid type index: $typeIndex');
        }
        type = HistoryItemType.values[typeIndex];
      } catch (e) {
        print('Error parsing type: $e');
        type = HistoryItemType.system;
      }
      
      // Optional fields
      try {
        rewardId = parts.length > 5 && parts[5].isNotEmpty ? parts[5] : null;
      } catch (e) {
        print('Error parsing rewardId: $e');
        rewardId = null;
      }
      
      try {
        isCredits = parts.length > 6 ? parts[6] == 'true' : false;
      } catch (e) {
        print('Error parsing isCredits: $e');
        isCredits = false;
      }
      
      try {
        creditsAmount = parts.length > 7 && parts[7].isNotEmpty ? int.parse(parts[7]) : null;
      } catch (e) {
        print('Error parsing creditsAmount: $e');
        creditsAmount = null;
      }
      
      try {
        hasMultipleRewards = parts.length > 8 ? parts[8] == 'true' : false;
      } catch (e) {
        print('Error parsing hasMultipleRewards: $e');
        hasMultipleRewards = false;
      }
      
      return RewardHistoryItem(
        id: id,
        title: title,
        points: points,
        date: date,
        type: type,
        rewardId: rewardId,
        isCredits: isCredits,
        creditsAmount: creditsAmount,
        hasMultipleRewards: hasMultipleRewards,
      );
    } catch (e) {
      print('Fatal error parsing history item: $e');
      // Return a fallback item in case of errors
      return RewardHistoryItem(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Data Error',
        points: 0,
        date: DateTime.now(),
        type: HistoryItemType.system,
      );
    }
  }

  String toJson() {
    try {
      // Build the string with predictable field order using proper delimiters
      // Ensure no field contains the pipe character to avoid parsing issues
      String safeTitle = title.replaceAll('|', '-');
      
      String result = '$id|$safeTitle|$points|${date.toIso8601String()}|${type.index}';
      
      // Add rewardId (always include the pipe even if null)
      result += '|${rewardId ?? ""}';
      
      // Add isCredits
      result += '|${isCredits ? "true" : "false"}';
      
      // Add creditsAmount (always include the pipe)
      result += '|${creditsAmount ?? ""}';
      
      // Add hasMultipleRewards
      result += '|${hasMultipleRewards ? "true" : "false"}';
      
      print('Serialized history item: $result');
      return result;
    } catch (e) {
      print('Error serializing history item: $e');
      // Return a minimal valid format in case of errors
      return 'error_${DateTime.now().millisecondsSinceEpoch}|Error Item|0|${DateTime.now().toIso8601String()}|3';
    }
  }
}