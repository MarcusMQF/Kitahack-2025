import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/theme_service.dart';

class TransitMap extends StatefulWidget {
  final LatLng? initialPosition;
  final LatLng? destinationPosition;
  final Function(LatLng)? onMapTap;
  final Function(GoogleMapController)? onMapCreated;
  
  const TransitMap({
    super.key,
    this.initialPosition,
    this.destinationPosition,
    this.onMapTap,
    this.onMapCreated,
  });

  @override
  State<TransitMap> createState() => _TransitMapState();
}

class _TransitMapState extends State<TransitMap> {
  final Map<MarkerId, Marker> _markers = {};
  GoogleMapController? _mapController;
  bool _isMapLoaded = false;
  bool _isGettingLocation = false;
  DateTime _lastLocationRequest = DateTime(2000); // Initial value in past

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }
  
  @override
  void didUpdateWidget(TransitMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update markers if destination position changes
    if (widget.destinationPosition != oldWidget.destinationPosition) {
      _updateMarkers();
      
      // Focus on destination when it changes
      if (widget.destinationPosition != null && _mapController != null) {
        _focusOnDestination();
      }
    }
  }

  void _initializeMap() async {
    // Initialize with destination marker if position is provided
    _updateMarkers();
  }
  
  void _updateMarkers() {
    setState(() {
      _markers.clear();
      
      // Only add destination marker
      if (widget.destinationPosition != null) {
        final destinationMarkerId = const MarkerId('destination');
        final destinationMarker = Marker(
          markerId: destinationMarkerId,
          position: widget.destinationPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Destination'),
        );
        _markers[destinationMarkerId] = destinationMarker;
      }
    });
  }
  
  // Focus camera on destination
  void _focusOnDestination() {
    if (_mapController == null || widget.destinationPosition == null) return;
    
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(widget.destinationPosition!, 15),
    );
  }
  
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapLoaded = true;
    });
    
    if (widget.onMapCreated != null) {
      widget.onMapCreated!(controller);
    }
    
    // Focus on destination with a slight delay to ensure map is fully loaded
    Future.delayed(const Duration(milliseconds: 300), () {
      if (widget.destinationPosition != null) {
        _focusOnDestination();
      }
    });
  }

  // Safe method to go to current location with debouncing
  Future<void> _goToCurrentLocation() async {
    // Prevent multiple simultaneous requests
    if (_isGettingLocation) return;
    
    // Debounce - prevent rapid clicks (minimum 1 second between clicks)
    final now = DateTime.now();
    if (now.difference(_lastLocationRequest).inMilliseconds < 1000) return;
    _lastLocationRequest = now;
    
    try {
      setState(() {
        _isGettingLocation = true;
      });
      
      final locationService = Provider.of<LocationService>(context, listen: false);
      
      // Check if we already have a location
      if (locationService.currentPosition != null) {
        final currentLocation = LatLng(
          locationService.currentPosition!.latitude,
          locationService.currentPosition!.longitude,
        );
        
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(currentLocation, 16),
        );
      } else {
        // Try to get current location
        await locationService.getCurrentLocation();
        
        // Verify we're still mounted before updating state
        if (!mounted) return;
        
        if (locationService.currentPosition != null) {
          final currentLocation = LatLng(
            locationService.currentPosition!.latitude,
            locationService.currentPosition!.longitude,
          );
          
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(currentLocation, 16),
          );
        } else {
          // Show error if couldn't get location
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not access your location. Please check permissions.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error accessing location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error accessing location services.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // Only update state if still mounted
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    // Determine initial camera position - prefer destination
    LatLng initialCameraPosition;
    
    if (widget.destinationPosition != null) {
      initialCameraPosition = widget.destinationPosition!;
    } else if (locationService.currentPosition != null) {
      initialCameraPosition = LatLng(
        locationService.currentPosition!.latitude,
        locationService.currentPosition!.longitude,
      );
    } else {
      // Default to Kuala Lumpur if no other position available
      initialCameraPosition = const LatLng(3.1390, 101.6869);
    }
    
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialCameraPosition,
            zoom: 15,
          ),
          markers: Set<Marker>.of(_markers.values),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
          onMapCreated: _onMapCreated,
          onTap: widget.onMapTap,
        ),
        
        // Loading indicator while map initializes
        if (!_isMapLoaded)
          Container(
            color: Colors.white.withOpacity(0.7),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ),
          
        // Map control buttons column
        Positioned(
          right: 16,
          bottom: 130, // Moved down from previous position
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current location button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _isGettingLocation ? null : _goToCurrentLocation,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: _isGettingLocation
                        ? Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.my_location,
                              color: primaryColor,
                              size: 20,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Destination marker button
              if (widget.destinationPosition != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _focusOnDestination,
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
} 