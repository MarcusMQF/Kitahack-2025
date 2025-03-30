import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  String _locationStatus = 'Unknown';
  bool _isLoading = false;

  Position? get currentPosition => _currentPosition;
  String get locationStatus => _locationStatus;
  bool get isLoading => _isLoading;

  // Initialize the location service
  Future<void> initLocationService() async {
    _setLoading(true);
    
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Request permission if denied
        permission = await Geolocator.requestPermission();
        
        if (permission == LocationPermission.denied) {
          _locationStatus = 'Location permission denied';
          _setLoading(false);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _locationStatus = 'Location permission permanently denied';
        _setLoading(false);
        return;
      }
      
      // Get current location
      await getCurrentLocation();
      
    } catch (e) {
      _locationStatus = 'Error initializing location: $e';
      _setLoading(false);
    }
  }

  // Get the current location
  Future<void> getCurrentLocation() async {
    _setLoading(true);
    
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _locationStatus = 'Location retrieved successfully';
    } catch (e) {
      _locationStatus = 'Error getting location: $e';
      _currentPosition = null;
    }
    
    _setLoading(false);
  }
  
  // Helper method to update loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Calculate distance between two points
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
} 