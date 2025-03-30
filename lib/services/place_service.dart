import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlaceService {
  final String apiKey;
  final http.Client _client = http.Client();

  PlaceService({required this.apiKey});

  // Search for places based on text input
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey'
      );
      
      final response = await _client.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          return (data['results'] as List).map((place) {
            final location = place['geometry']['location'];
            return {
              'id': place['place_id'],
              'name': place['name'],
              'address': place['formatted_address'],
              'latitude': location['lat'],
              'longitude': location['lng'],
              'type': _getPlaceType(place),
              'icon': _getIconForPlaceType(place),
            };
          }).toList();
        } else {
          debugPrint('Place API error: ${data['status']}');
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error searching places: $e');
    }
    
    return [];
  }
  
  // Get place details by place ID
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=name,formatted_address,geometry,types&key=$apiKey'
      );
      
      final response = await _client.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          final place = data['result'];
          final location = place['geometry']['location'];
          
          return {
            'id': placeId,
            'name': place['name'],
            'address': place['formatted_address'],
            'latitude': location['lat'],
            'longitude': location['lng'],
            'type': _getPlaceType(place),
            'icon': _getIconForPlaceType(place),
          };
        }
      }
    } catch (e) {
      debugPrint('Error getting place details: $e');
    }
    
    return null;
  }
  
  // Determine the type of place from Google place types
  String _getPlaceType(Map<String, dynamic> place) {
    final types = place['types'] as List?;
    
    if (types == null || types.isEmpty) return 'location';
    
    if (types.contains('transit_station') || 
        types.contains('subway_station') || 
        types.contains('train_station')) {
      return 'station';
    } else if (types.contains('bus_station')) {
      return 'bus_station';
    } else if (types.contains('airport')) {
      return 'airport';
    } else if (types.contains('shopping_mall')) {
      return 'mall';
    } else if (types.contains('school') || types.contains('university')) {
      return 'school';
    } else if (types.contains('hospital')) {
      return 'hospital';
    } else if (types.contains('restaurant') || types.contains('food')) {
      return 'restaurant';
    } else if (types.contains('park')) {
      return 'park';
    } else if (types.contains('lodging') || types.contains('hotel')) {
      return 'hotel';
    }
    
    return 'location';
  }
  
  // Get an appropriate icon based on place type
  IconData _getIconForPlaceType(Map<String, dynamic> place) {
    final placeType = _getPlaceType(place);
    
    switch (placeType) {
      case 'station':
        return Icons.train;
      case 'bus_station':
        return Icons.directions_bus;
      case 'airport':
        return Icons.flight;
      case 'mall':
        return Icons.shopping_bag;
      case 'school':
        return Icons.school;
      case 'hospital':
        return Icons.local_hospital;
      case 'restaurant':
        return Icons.restaurant;
      case 'park':
        return Icons.park;
      case 'hotel':
        return Icons.hotel;
      default:
        return Icons.location_on;
    }
  }
} 