class TransitRecord {
  final String entryStation;
  final DateTime entryTime;
  final String? exitStation;
  final DateTime? exitTime;
  final double fare;
  final int pointsEarned;
  final int creditsEarned;

  TransitRecord({
    required this.entryStation,
    required this.entryTime,
    this.exitStation,
    this.exitTime,
    required this.fare,
    required this.pointsEarned,
    required this.creditsEarned,
  });

  // Create a copy with updated values
  TransitRecord copyWith({
    String? entryStation,
    DateTime? entryTime, 
    String? exitStation,
    DateTime? exitTime,
    double? fare,
    int? pointsEarned,
    int? creditsEarned,
  }) {
    return TransitRecord(
      entryStation: entryStation ?? this.entryStation,
      entryTime: entryTime ?? this.entryTime,
      exitStation: exitStation ?? this.exitStation,
      exitTime: exitTime ?? this.exitTime,
      fare: fare ?? this.fare,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      creditsEarned: creditsEarned ?? this.creditsEarned,
    );
  }

  // Convert to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'entryStation': entryStation,
      'entryTime': entryTime.millisecondsSinceEpoch,
      'exitStation': exitStation,
      'exitTime': exitTime?.millisecondsSinceEpoch,
      'fare': fare,
      'pointsEarned': pointsEarned,
      'creditsEarned': creditsEarned,
    };
  }

  // Create from a map (for loading from storage)
  factory TransitRecord.fromMap(Map<String, dynamic> map) {
    return TransitRecord(
      entryStation: map['entryStation'],
      entryTime: DateTime.fromMillisecondsSinceEpoch(map['entryTime']),
      exitStation: map['exitStation'],
      exitTime: map['exitTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['exitTime']) : null,
      fare: map['fare'],
      pointsEarned: map['pointsEarned'],
      creditsEarned: map['creditsEarned'] ?? map['pointsEarned'] * 3, // Fallback for backward compatibility
    );
  }
} 