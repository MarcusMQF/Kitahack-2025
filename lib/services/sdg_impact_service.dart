import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sdg_impact.dart';
import '../models/transit_record.dart';

class SdgImpactService extends ChangeNotifier {
  SdgImpact _impact = SdgImpact.empty();
  bool _isInitialized = false;
  late SharedPreferences _prefs;

  // SDG 13: Climate Action - CO2 emissions per km for different transport modes
  static const Map<String, double> co2PerKm = {
    'car': 0.192, // Average car emits 192g CO2 per km
    'bus': 0.104, // Bus emits 104g CO2 per km per passenger
    'subway': 0.041, // Subway/Metro emits 41g CO2 per km per passenger
    'tram': 0.035, // Tram emits 35g CO2 per km per passenger
    'train': 0.028, // Train emits 28g CO2 per km per passenger
    'ferry': 0.120, // Ferry emits 120g CO2 per km per passenger
    'walk': 0.0, // Walking emits 0g CO2
  };

  // SDG 3: Good Health - steps per km
  static const int stepsPerKm = 1312; // Average person walks 1312 steps per km

  // Constructors and getters
  SdgImpactService() {
    _initPrefs();
  }

  bool get isInitialized => _isInitialized;
  SdgImpact get impact => _impact;

  // Initialize shared preferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadImpact();
    _isInitialized = true;
    notifyListeners();
  }

  // Load impact data from storage
  Future<void> _loadImpact() async {
    final impactJson = _prefs.getString('sdg_impact');
    if (impactJson != null) {
      try {
        final impactMap = jsonDecode(impactJson);
        _impact = SdgImpact.fromMap(impactMap);
      } catch (e) {
        debugPrint('Error loading SDG impact data: $e');
        _impact = SdgImpact.empty();
      }
    } else {
      // Initialize with sample data for demo purposes
      _impact = SdgImpact(
        co2Saved: 28.4,
        distanceTraveled: 147.5,
        stepsWalked: 18750,
        publicTransitTrips: 23,
        averageTripDuration: 24.7,
        transitTypeBreakdown: {
          'bus': 45.0,
          'subway': 35.0,
          'tram': 5.0,
          'train': 10.0,
          'ferry': 0.0,
          'walk': 5.0,
        },
      );
    }
  }

  // Save impact data to storage
  Future<void> _saveImpact() async {
    await _prefs.setString('sdg_impact', jsonEncode(_impact.toMap()));
  }

  // Calculate and add impact from a completed transit trip
  Future<void> addTripImpact(TransitRecord trip, List<Map<String, dynamic>> segments) async {
    if (!_isInitialized) await _initPrefs();
    
    // Calculate trip metrics
    double tripDistance = 0.0;
    int walkingSteps = 0;
    Map<String, double> transitKm = {};
    
    // Process each segment of the trip to calculate metrics
    for (final segment in segments) {
      final String type = segment['type'] as String;
      final double segmentDistance = segment['distance'] as double; // in km
      
      tripDistance += segmentDistance;
      
      if (type == 'walk') {
        walkingSteps += (segmentDistance * stepsPerKm).round();
      }
      
      // Track distance by transit type
      transitKm[type] = (transitKm[type] ?? 0) + segmentDistance;
    }
    
    // Calculate CO2 saved (compared to driving the same distance)
    double co2EmittedByTransit = 0.0;
    transitKm.forEach((type, distance) {
      co2EmittedByTransit += (co2PerKm[type] ?? 0) * distance;
    });
    
    double co2EmittedByCar = co2PerKm['car']! * tripDistance;
    double co2Saved = co2EmittedByCar - co2EmittedByTransit;
    
    // Calculate trip duration in minutes
    double tripDuration = 0.0;
    if (trip.exitTime != null) {
      tripDuration = trip.exitTime!.difference(trip.entryTime).inMinutes.toDouble();
    }
    
    // Calculate transit type breakdown percentages
    Map<String, double> updatedBreakdown = {
      'bus': 0.0,
      'subway': 0.0,
      'tram': 0.0,
      'train': 0.0,
      'ferry': 0.0,
      'walk': 0.0,
    };
    
    if (tripDistance > 0) {
      transitKm.forEach((type, distance) {
        updatedBreakdown[type] = (distance / tripDistance) * 100;
      });
    }
    
    // Update overall impact with the new trip data
    final totalDistance = _impact.distanceTraveled + tripDistance;
    final totalTrips = _impact.publicTransitTrips + 1;
    
    // Calculate new average trip duration
    final newAverageDuration = 
        ((_impact.averageTripDuration * _impact.publicTransitTrips) + tripDuration) / totalTrips;
    
    // Update breakdown percentages based on total distance
    final newBreakdown = Map<String, double>.from(_impact.transitTypeBreakdown);
    updatedBreakdown.forEach((type, percentage) {
      final existingPercentage = _impact.transitTypeBreakdown[type] ?? 0.0;
      final existingDistance = _impact.distanceTraveled * (existingPercentage / 100);
      final newTypeDistance = existingDistance + (tripDistance * (percentage / 100));
      newBreakdown[type] = (newTypeDistance / totalDistance) * 100;
    });
    
    // Create updated impact
    _impact = _impact.copyWith(
      co2Saved: _impact.co2Saved + co2Saved,
      distanceTraveled: totalDistance,
      stepsWalked: _impact.stepsWalked + walkingSteps,
      publicTransitTrips: totalTrips,
      averageTripDuration: newAverageDuration,
      transitTypeBreakdown: newBreakdown,
    );
    
    await _saveImpact();
    notifyListeners();
  }
  
  // Generate SDG impact summary text
  String generateSdgSummary() {
    return '''
By using public transit, you've:
• Saved ${_impact.co2Saved.toStringAsFixed(1)} kg of CO2 emissions (SDG 13: Climate Action)
• Equivalent to planting ${_impact.treesEquivalent.toStringAsFixed(1)} trees
• Walked ${_impact.stepsWalked} steps (SDG 3: Good Health)
• Burned approximately ${_impact.caloriesBurned} calories
• Completed ${_impact.publicTransitTrips} public transit trips (SDG 11: Sustainable Cities)
• Reduced urban congestion by ${_impact.congestionReduction.toStringAsFixed(1)}%
''';
  }
  
  // Reset impact data (for testing)
  Future<void> resetImpact() async {
    _impact = SdgImpact.empty();
    await _saveImpact();
    notifyListeners();
  }
} 