import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/theme_service.dart';
import '../../services/location_service.dart';
import '../../components/transit_map.dart';
import 'suggested_routes_page.dart';
import 'search_starting_point_page.dart';
import 'search_destination_page.dart';

class RoutePlannerPage extends StatefulWidget {
  final Map<String, dynamic> destination;
  
  const RoutePlannerPage({
    super.key,
    required this.destination,
  });

  @override
  State<RoutePlannerPage> createState() => _RoutePlannerPageState();
}

class _RoutePlannerPageState extends State<RoutePlannerPage> {
  // Default to empty starting point
  Map<String, dynamic>? _startingPoint;
  
  // Locations for map markers
  LatLng? _destinationLocation;
  LatLng? _startingLocation;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to run after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDestinationLocation();
    });
  }
  
  // Only initialize the destination location, not the starting point
  Future<void> _initializeDestinationLocation() async {
    // Try to extract destination coordinates if available
    if (widget.destination.containsKey('latitude') && 
        widget.destination.containsKey('longitude')) {
      setState(() {
        _destinationLocation = LatLng(
          widget.destination['latitude'], 
          widget.destination['longitude'],
        );
      });
    } else {
      // For demo, let's set a default location for Pavilion KL
      if (widget.destination['name'] == 'Pavilion Kuala Lumpur') {
        setState(() {
          _destinationLocation = const LatLng(3.1488, 101.7133);
        });
      } else {
        // Default to KLCC
        setState(() {
          _destinationLocation = const LatLng(3.1577, 101.7117);
        });
      }
    }
  }

  // Get the user's current location
  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    
    try {
      final locationService = Provider.of<LocationService>(context, listen: false);
      await locationService.initLocationService();
      
      if (locationService.currentPosition != null) {
        setState(() {
          _startingPoint = {
            'id': 'current_location',
            'name': 'Current Location',
            'address': 'Using your device location',
            'latitude': locationService.currentPosition!.latitude,
            'longitude': locationService.currentPosition!.longitude,
            'type': 'current_location',
            'icon': Icons.my_location,
          };
          
          _startingLocation = LatLng(
            locationService.currentPosition!.latitude,
            locationService.currentPosition!.longitude,
          );
        });
      } else {
        // Show error if couldn't get location
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not access your location. Please check permissions.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error accessing location services.'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }
  
  // Navigate to select a starting point manually
  void _selectStartingPoint() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchStartingPointPage(),
      ),
    );
    
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _startingPoint = result;
        if (result.containsKey('latitude') && result.containsKey('longitude')) {
          _startingLocation = LatLng(
            result['latitude'],
            result['longitude'],
          );
        }
      });
    }
  }
  
  // Navigate to select a new destination
  void _changeDestination() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchDestinationPage(),
      ),
    );
    
    if (result != null && result is Map<String, dynamic>) {
      // Return to previous page with new destination
      Navigator.pop(context, result);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Plan Route',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              // Show route filters
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Route input section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              children: [
                // Starting point input with integrated location button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Main starting point input field
                        Expanded(
                          child: InkWell(
                            onTap: _selectStartingPoint,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade200,
                                    ),
                                    child: Icon(
                                      Icons.trip_origin,
                                      size: 16,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _startingPoint != null
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _startingPoint!['name'],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (_startingPoint!['address'] != null)
                                                Text(
                                                  _startingPoint!['address'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                          )
                                        : const Text(
                                            'Choose starting point',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Current location button (integrated in the same container)
                        Container(
                          width: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(0),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(0),
                            ),
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(0),
                              ),
                              onTap: _isLoadingLocation ? null : _useCurrentLocation,
                              child: Center(
                                child: _isLoadingLocation
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                      ),
                                    )
                                  : Icon(
                                      Icons.my_location,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Destination display - now clickable to change
                InkWell(
                  onTap: _changeDestination,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          offset: const Offset(0, 2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: 16,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.destination['name'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (widget.destination['address'] != null)
                                Text(
                                  widget.destination['address'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        // Add chevron icon to indicate it's clickable
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Map section
          Expanded(
            child: TransitMap(
              initialPosition: _startingLocation,
              destinationPosition: _destinationLocation,
              onMapTap: (latLng) {
                // This could be extended to allow users to tap on the map to set a location
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 6,
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _startingPoint != null
                  ? () => _findRoutes()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 0,
              ),
              child: const Text(
                'Find routes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _findRoutes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuggestedRoutesPage(
          startingPoint: _startingPoint!,
          destination: widget.destination,
          departureTime: DateTime.now(),
        ),
      ),
    );
  }
} 