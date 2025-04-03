class SdgImpact {
  final double co2Saved; // in kg (SDG 13: Climate Action)
  final double distanceTraveled; // in km
  final int stepsWalked; // SDG 3: Good Health
  final int publicTransitTrips; // SDG 11: Sustainable Cities
  final double averageTripDuration; // in minutes
  final Map<String, double> transitTypeBreakdown; // percentage by transit type

  SdgImpact({
    required this.co2Saved,
    required this.distanceTraveled,
    required this.stepsWalked,
    required this.publicTransitTrips,
    required this.averageTripDuration,
    required this.transitTypeBreakdown,
  });

  // Calculate health benefits (calories burned) - SDG 3
  int get caloriesBurned => (stepsWalked * 0.04).round();
  
  // Calculate CO2 equivalent trees planted - SDG 13
  double get treesEquivalent => co2Saved / 21.0; // Average tree absorbs ~21kg CO2 per year
  
  // Calculate urban congestion reduction - SDG 11
  double get congestionReduction => publicTransitTrips * 0.5; // Each transit trip reduces congestion by average of 0.5%

  // Create a copy with updated values
  SdgImpact copyWith({
    double? co2Saved,
    double? distanceTraveled,
    int? stepsWalked,
    int? publicTransitTrips,
    double? averageTripDuration,
    Map<String, double>? transitTypeBreakdown,
  }) {
    return SdgImpact(
      co2Saved: co2Saved ?? this.co2Saved,
      distanceTraveled: distanceTraveled ?? this.distanceTraveled,
      stepsWalked: stepsWalked ?? this.stepsWalked,
      publicTransitTrips: publicTransitTrips ?? this.publicTransitTrips,
      averageTripDuration: averageTripDuration ?? this.averageTripDuration,
      transitTypeBreakdown: transitTypeBreakdown ?? this.transitTypeBreakdown,
    );
  }

  // Convert to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'co2Saved': co2Saved,
      'distanceTraveled': distanceTraveled,
      'stepsWalked': stepsWalked,
      'publicTransitTrips': publicTransitTrips,
      'averageTripDuration': averageTripDuration,
      'transitTypeBreakdown': transitTypeBreakdown,
    };
  }

  // Create from a map (for loading from storage)
  factory SdgImpact.fromMap(Map<String, dynamic> map) {
    Map<String, double> transitBreakdown = {};
    
    if (map.containsKey('transitTypeBreakdown')) {
      final transitData = map['transitTypeBreakdown'] as Map<dynamic, dynamic>;
      transitData.forEach((key, value) {
        transitBreakdown[key.toString()] = (value as num).toDouble();
      });
    }
    
    return SdgImpact(
      co2Saved: (map['co2Saved'] as num).toDouble(),
      distanceTraveled: (map['distanceTraveled'] as num).toDouble(),
      stepsWalked: (map['stepsWalked'] as num).toInt(),
      publicTransitTrips: (map['publicTransitTrips'] as num).toInt(),
      averageTripDuration: (map['averageTripDuration'] as num).toDouble(),
      transitTypeBreakdown: transitBreakdown,
    );
  }
  
  // Create an empty impact record
  factory SdgImpact.empty() {
    return SdgImpact(
      co2Saved: 0.0,
      distanceTraveled: 0.0,
      stepsWalked: 0,
      publicTransitTrips: 0,
      averageTripDuration: 0.0,
      transitTypeBreakdown: {
        'bus': 0.0,
        'subway': 0.0,
        'tram': 0.0,
        'train': 0.0,
        'ferry': 0.0,
        'walk': 0.0,
      },
    );
  }
} 