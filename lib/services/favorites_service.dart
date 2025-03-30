import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// A service to manage favorite locations across the app
class FavoritesService extends ChangeNotifier {
  List<Map<String, dynamic>> _favorites = [];
  bool _initialized = false;

  FavoritesService() {
    _loadFavorites();
  }

  // Getter for favorites list
  List<Map<String, dynamic>> get favorites => _favorites;
  
  // Check if initialization is complete
  bool get isInitialized => _initialized;

  // Check if a location is already a favorite
  bool isFavorite(String locationId) {
    return _favorites.any((location) => location['id'] == locationId);
  }

  // Load favorites from shared preferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorites') ?? [];
      
      _favorites = favoritesJson
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
      
      // If no favorites are saved yet, initialize with sample data for demonstration
      if (_favorites.isEmpty) {
        _favorites = [
          {
            'id': 'fav1', 
            'name': 'Petronas Twin Towers', 
            'address': 'Kuala Lumpur City Centre',
            'icon': 'place',
            'isStarred': true
          },
          {
            'id': 'fav2', 
            'name': 'KL Sentral', 
            'address': 'Brickfields, Kuala Lumpur',
            'icon': 'place',
            'isStarred': true
          },
        ];
        
        await _saveFavorites();
      }
      
      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      _initialized = true;
      notifyListeners();
    }
  }

  // Save favorites to shared preferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favorites
          .map((item) => jsonEncode(item))
          .toList();
      
      await prefs.setStringList('favorites', favoritesJson);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  // Add a location to favorites
  Future<void> addFavorite(Map<String, dynamic> location) async {
    if (!isFavorite(location['id'])) {
      // Create a copy of the location data with isStarred set to true
      final favoriteLocation = Map<String, dynamic>.from(location);
      favoriteLocation['isStarred'] = true;
      
      _favorites.add(favoriteLocation);
      await _saveFavorites();
      notifyListeners();
    }
  }

  // Remove a location from favorites
  Future<void> removeFavorite(String locationId) async {
    _favorites.removeWhere((location) => location['id'] == locationId);
    await _saveFavorites();
    notifyListeners();
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Map<String, dynamic> location) async {
    if (isFavorite(location['id'])) {
      await removeFavorite(location['id']);
    } else {
      await addFavorite(location);
    }
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    _favorites.clear();
    await _saveFavorites();
    notifyListeners();
  }
} 