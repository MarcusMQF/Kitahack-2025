import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CoordinateValidator {
  /// Validates if a map contains valid latitude and longitude values
  static bool hasValidCoordinates(Map<String, dynamic>? locationMap) {
    if (locationMap == null) {
      return false;
    }
    
    if (!locationMap.containsKey('latitude') || !locationMap.containsKey('longitude')) {
      return false;
    }
    
    final lat = locationMap['latitude'];
    final lng = locationMap['longitude'];
    
    if (lat == null || lng == null) {
      return false;
    }
    
    // Check if values are numeric
    if (lat is! double && lat is! int) {
      return false;
    }
    
    if (lng is! double && lng is! int) {
      return false;
    }
    
    // Convert to double for validation
    final latDouble = lat is int ? lat.toDouble() : lat;
    final lngDouble = lng is int ? lng.toDouble() : lng;
    
    // Check if values are finite (not NaN or infinite)
    if (!latDouble.isFinite || !lngDouble.isFinite) {
      return false;
    }
    
    // Check if values are in valid range
    if (latDouble < -90 || latDouble > 90) {
      return false;
    }
    
    if (lngDouble < -180 || lngDouble > 180) {
      return false;
    }
    
    return true;
  }
  
  /// Gets a LatLng object from a map, or null if invalid
  static LatLng? getLatLng(Map<String, dynamic>? locationMap) {
    if (!hasValidCoordinates(locationMap)) {
      return null;
    }
    
    return LatLng(
      locationMap!['latitude'] is int 
          ? (locationMap['latitude'] as int).toDouble() 
          : locationMap['latitude'],
      locationMap['longitude'] is int 
          ? (locationMap['longitude'] as int).toDouble() 
          : locationMap['longitude'],
    );
  }
  
  /// Shows an error message for invalid coordinates
  static void showInvalidCoordinatesError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
} 