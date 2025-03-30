import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RouteService {
  final String apiKey;
  final http.Client _client = http.Client();

  RouteService({required this.apiKey});

  /// Fetches transit routes between two points using Google Directions API
  Future<List<Map<String, dynamic>>> getTransitRoutes({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    DateTime? departureTime,
  }) async {
    try {
      final departure = departureTime ?? DateTime.now();
      final departureTimestamp = (departure.millisecondsSinceEpoch / 1000).round();
      
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$startLat,$startLng'
        '&destination=$endLat,$endLng'
        '&mode=transit'
        '&transit_routing_preference=less_walking'
        '&alternatives=true'
        '&departure_time=$departureTimestamp'
        '&language=en'
        '&units=metric'
        '&key=$apiKey'
      );
      
      final response = await _client.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          return _parseRoutes(data);
        } else {
          debugPrint('Directions API error: ${data['status']}');
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting transit routes: $e');
    }
    
    return [];
  }

  /// Parse the Google Directions API response into a format our app can use
  List<Map<String, dynamic>> _parseRoutes(Map<String, dynamic> directionsData) {
    final routes = <Map<String, dynamic>>[];
    
    for (final route in directionsData['routes']) {
      try {
        final leg = route['legs'][0]; // We only handle one leg per route currently
        
        // Calculate total duration
        final int durationInSeconds = leg['duration']['value'];
        final duration = Duration(seconds: durationInSeconds);
        
        // Calculate arrival time
        final int departureTimeValue = leg['departure_time']['value'];
        final DateTime departureTime = DateTime.fromMillisecondsSinceEpoch(departureTimeValue * 1000);
        final DateTime arrivalTime = departureTime.add(duration);
        
        // Process steps into segments
        final segments = <Map<String, dynamic>>[];
        
        // Count transit ride segments (buses, trains, etc.)
        int transitCount = 0;
        for (final step in leg['steps']) {
          if (step['travel_mode'] == 'TRANSIT') {
            transitCount++;
          }
        }
        
        // Process each step in the route
        for (final step in leg['steps']) {
          final travelMode = step['travel_mode'];
          
          if (travelMode == 'WALKING') {
            // Walking segment
            final Map<String, dynamic> walkSegment = {
              'type': 'walk',
              'duration': Duration(seconds: step['duration']['value']),
              'distance': step['distance']['value'] / 1000, // Convert to km
              'icon': Icons.directions_walk,
              'color': Colors.pink.shade400,
              'instructions': step['html_instructions'],
              'polyline': step['polyline']['points'], // Store encoded polyline
            };
            
            // Add detailed destination information for walking segments
            if (step.containsKey('html_instructions')) {
              walkSegment['destination_name'] = step['html_instructions']
                .toString()
                .replaceAll(RegExp(r'<[^>]*>'), ' ')
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim();
            }
            
            // Add start and end locations for the walking segment
            if (step.containsKey('start_location')) {
              walkSegment['start_location'] = {
                'lat': step['start_location']['lat'],
                'lng': step['start_location']['lng'],
              };
            }
            
            if (step.containsKey('end_location')) {
              walkSegment['end_location'] = {
                'lat': step['end_location']['lat'],
                'lng': step['end_location']['lng'],
              };
            }
            
            segments.add(walkSegment);
          } else if (travelMode == 'TRANSIT') {
            // Transit segment (bus, train, etc.)
            final transitDetails = step['transit_details'];
            final line = transitDetails['line'];
            final vehicleType = line['vehicle']['type'].toLowerCase();
            
            // Determine the transit type and color
            IconData icon;
            Color color;
            
            switch (vehicleType) {
              case 'subway':
              case 'heavy_rail':
              case 'commuter_train':
              case 'rail':
                icon = Icons.train;
                color = Colors.grey.shade800;
                break;
              case 'light_rail':
              case 'tram':
                icon = Icons.tram;
                color = Colors.green.shade700;
                break;
              case 'bus':
                icon = Icons.directions_bus;
                color = Colors.amber.shade700;
                break;
              case 'ferry':
                icon = Icons.directions_boat;
                color = Colors.blue.shade700;
                break;
              default:
                icon = Icons.directions_transit;
                color = Colors.purple.shade700;
            }

            // Get line name or number
            String lineName = '';
            if (line.containsKey('short_name') && line['short_name'] != null) {
              lineName = line['short_name'];
            } else if (line.containsKey('name') && line['name'] != null) {
              lineName = line['name'];
            }
            
            // Extract stop information with codes if available
            final departureStop = transitDetails['departure_stop'];
            final arrivalStop = transitDetails['arrival_stop'];
            
            String departureStopName = departureStop['name'];
            if (departureStop.containsKey('stop_code') && departureStop['stop_code'] != null) {
              departureStopName += ' (${departureStop['stop_code']})';
            }
            
            String arrivalStopName = arrivalStop['name'];
            if (arrivalStop.containsKey('stop_code') && arrivalStop['stop_code'] != null) {
              arrivalStopName += ' (${arrivalStop['stop_code']})';
            }
            
            // Add agency and vehicle color if available
            Color transitColor = color;
            if (line.containsKey('color')) {
              try {
                // Try to parse the hex color
                final hexColor = line['color'];
                transitColor = Color(int.parse('0xFF${hexColor.replaceAll('#', '')}'));
              } catch (e) {
                // Use default if parsing fails
                debugPrint('Failed to parse transit color: $e');
              }
            }
            
            segments.add({
              'type': vehicleType,
              'line': lineName,
              'duration': Duration(seconds: step['duration']['value']),
              'icon': icon,
              'color': transitColor,
              'departure_stop': departureStopName,
              'arrival_stop': arrivalStopName,
              'departure_time': transitDetails['departure_time']['text'],
              'arrival_time': transitDetails['arrival_time']['text'],
              'num_stops': transitDetails['num_stops'],
              'headsign': transitDetails.containsKey('headsign') ? transitDetails['headsign'] : null,
              'polyline': step['polyline']['points'], // Store encoded polyline
              'agency': line.containsKey('agencies') && line['agencies'].isNotEmpty ? line['agencies'][0]['name'] : null,
              'start_location': {
                'lat': step['start_location']['lat'],
                'lng': step['start_location']['lng'],
              },
              'end_location': {
                'lat': step['end_location']['lat'],
                'lng': step['end_location']['lng'],
              },
            });
          }
        }
        
        // Extract summary instructions if available
        String summary = route['summary'] ?? 'Transit route';
        if (leg.containsKey('steps') && leg['steps'].isNotEmpty) {
          final firstStep = leg['steps'][0];
          if (firstStep['travel_mode'] == 'WALKING' && firstStep.containsKey('html_instructions')) {
            summary = firstStep['html_instructions']
              .toString()
              .replaceAll(RegExp(r'<[^>]*>'), ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
          }
        }
        
        routes.add({
          'id': 'route-${routes.length}',
          'duration': duration,
          'arrival_time': arrivalTime,
          'departure_time': departureTime,
          'segments': segments,
          'departure_station': leg.containsKey('start_address') ? leg['start_address'] : null,
          'destination': leg.containsKey('end_address') ? leg['end_address'] : null,
          'summary': summary,
          'fare': route.containsKey('fare') ? route['fare']['text'] : null,
          'transit_count': transitCount,
          'polyline': route['overview_polyline']['points'],
          'bounds': {
            'northeast': {
              'lat': route['bounds']['northeast']['lat'],
              'lng': route['bounds']['northeast']['lng'],
            },
            'southwest': {
              'lat': route['bounds']['southwest']['lat'],
              'lng': route['bounds']['southwest']['lng'],
            },
          },
        });
      } catch (e) {
        debugPrint('Error parsing route: $e');
      }
    }
    
    return routes;
  }

  // Format duration string for display
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }
  
  // Format time string for display
  String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
} 