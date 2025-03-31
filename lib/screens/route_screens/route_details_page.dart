import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class RouteDetailsPage extends StatefulWidget {
  final Map<String, dynamic> route;
  final Map<String, dynamic> startingPoint;
  final Map<String, dynamic> destination;

  const RouteDetailsPage({
    super.key,
    required this.route,
    required this.startingPoint,
    required this.destination,
  });

  @override
  State<RouteDetailsPage> createState() => _RouteDetailsPageState();
}

class _RouteDetailsPageState extends State<RouteDetailsPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final DraggableScrollableController _bottomSheetController = DraggableScrollableController();
  bool _isMapReady = false;
  
  @override
  void initState() {
    super.initState();
    _initMap();
    
    // Listen to bottom sheet changes to adjust map
    _bottomSheetController.addListener(_onBottomSheetChanged);
  }
  
  void _onBottomSheetChanged() {
    // If map is ready and controller is available, adjust map view
    if (_isMapReady && _mapController != null) {
      _adjustMapForBottomSheet();
    }
  }
  
  void _adjustMapForBottomSheet() {
    // Only proceed if everything is ready
    if (!_isMapReady || _mapController == null) return;
    
    // The correct way to set padding on the map
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        _getRouteBounds(),
        0,
      ),
    );
  }
  
  // Helper method to get the route bounds
  LatLngBounds _getRouteBounds() {
    if (widget.route.containsKey('bounds')) {
      return LatLngBounds(
        southwest: LatLng(
          widget.route['bounds']['southwest']['lat'],
          widget.route['bounds']['southwest']['lng'],
        ),
        northeast: LatLng(
          widget.route['bounds']['northeast']['lat'],
          widget.route['bounds']['northeast']['lng'],
        ),
      );
    } else {
      // Fallback to manual bounds from markers
      return LatLngBounds(
        southwest: LatLng(
          math.min(widget.startingPoint['latitude'], widget.destination['latitude']), 
          math.min(widget.startingPoint['longitude'], widget.destination['longitude'])
        ),
        northeast: LatLng(
          math.max(widget.startingPoint['latitude'], widget.destination['latitude']), 
          math.max(widget.startingPoint['longitude'], widget.destination['longitude'])
        ),
      );
    }
  }

  void _initMap() {
    // Add markers for starting point and destination
    _markers = {
      Marker(
        markerId: const MarkerId('start'),
        position: LatLng(
          widget.startingPoint['latitude'], 
          widget.startingPoint['longitude']
        ),
        infoWindow: InfoWindow(title: widget.startingPoint['name']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(
          widget.destination['latitude'], 
          widget.destination['longitude']
        ),
        infoWindow: InfoWindow(title: widget.destination['name']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
    
    // Check if route has polyline data
    if (widget.route.containsKey('polyline')) {
      try {
        final List<LatLng> points = _decodePolyline(widget.route['polyline']);
        
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route_overview'),
            points: points,
            color: Colors.blue,
            width: 5,
          ),
        };
        
        // Add segment polylines with different colors
        int segmentIndex = 0;
        for (var segment in widget.route['segments']) {
          if (segment.containsKey('polyline')) {
            final List<LatLng> segmentPoints = _decodePolyline(segment['polyline']);
            _polylines.add(
              Polyline(
                polylineId: PolylineId('segment_$segmentIndex'),
                points: segmentPoints,
                color: segment['color'],
                width: 5,
              ),
            );
          }
          segmentIndex++;
        }
      } catch (e) {
        debugPrint('Error decoding polyline: $e');
        // Fallback to straight line if polyline decoding fails
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [
              LatLng(widget.startingPoint['latitude'], widget.startingPoint['longitude']),
              LatLng(widget.destination['latitude'], widget.destination['longitude']),
            ],
            color: Colors.blue,
            width: 5,
          ),
        };
      }
    } else {
      // Fallback to straight line if no polyline data
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(widget.startingPoint['latitude'], widget.startingPoint['longitude']),
            LatLng(widget.destination['latitude'], widget.destination['longitude']),
          ],
          color: Colors.blue,
          width: 5,
        ),
      };
    }

    // Also add markers for transit stops
    for (var segment in widget.route['segments']) {
      if (segment['type'] != 'walk' && segment.containsKey('departure_stop')) {
        // Add transit stops as markers with custom icons
      }
    }
  }

  // Function to fit the map to show both points
  void _fitMapToBounds({bool focusDestination = false}) {
    if (_mapController == null) return;
    
    if (focusDestination) {
      // Focus on destination
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              widget.destination['latitude'],
              widget.destination['longitude'],
            ),
            zoom: 17.0,
          ),
        ),
      );
    } else if (widget.route.containsKey('bounds')) {
      // Fit to route bounds
      try {
        // Get bounds
        final bounds = _getRouteBounds();
        
        // Account for bottom sheet by positioning camera higher
        final screenHeight = MediaQuery.of(context).size.height;
        final bottomSheetHeight = screenHeight * _bottomSheetController.size;
        
        // Position camera to account for bottom sheet
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(
          bounds, 
          40, // Padding around the bounds
        ));
        
        // After fitting bounds, move camera up to account for bottom sheet
        Future.delayed(const Duration(milliseconds: 300), () {
          final visibleBounds = _mapController?.getVisibleRegion();
          if (visibleBounds != null) {
            // Move the camera up a bit to account for bottom sheet
            _mapController!.animateCamera(
              CameraUpdate.scrollBy(0, -bottomSheetHeight * 0.25),
            );
          }
        });
      } catch (e) {
        debugPrint('Error fitting bounds: $e');
      }
    }
  }

  // Decode an encoded polyline string into a list of LatLng points
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }
  
  String _formatDate(DateTime time) {
    return DateFormat('EEEE, MMM d').format(time);
  }
  
  String _formatDistance(double distanceInKm) {
    if (distanceInKm < 1.0) {
      // Display in meters
      return '${(distanceInKm * 1000).round()} m';
    } else {
      // Display in kilometers
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Route Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Map takes the full screen
          SizedBox(
            height: screenHeight,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  (widget.startingPoint['latitude'] + widget.destination['latitude']) / 2,
                  (widget.startingPoint['longitude'] + widget.destination['longitude']) / 2,
                ),
                zoom: 13,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (controller) {
                _mapController = controller;
                
                // Set map as ready
                setState(() {
                  _isMapReady = true;
                });
                
                // Fit bounds after a short delay to ensure the map is fully loaded
                Future.delayed(const Duration(milliseconds: 300), () {
                  // Set padding to account for the bottom sheet
                  final bottomPadding = screenHeight * 0.6;
                  // Don't use setPadding, use camera positioning instead
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngBounds(_getRouteBounds(), 40)
                  );
                  
                  // After initial positioning, adjust camera upward to account for bottom sheet
                  Future.delayed(const Duration(milliseconds: 200), () {
                    _mapController!.animateCamera(
                      CameraUpdate.scrollBy(0, -bottomPadding * 0.3)
                    );
                  });
                });
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false, // We're creating our own buttons
              zoomControlsEnabled: false, // We're creating our own buttons
              mapToolbarEnabled: false,
            ),
          ),
          
          // Map controls - repositioned to avoid overflow
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                // My location button
                _buildMapButton(
                  icon: Icons.my_location,
                  onPressed: () {
                    _fitMapToBounds(focusDestination: true);
                  },
                ),
                const SizedBox(height: 8),
                // Zoom controls
                Card(
                  elevation: 4,
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          _mapController?.animateCamera(CameraUpdate.zoomIn());
                        },
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        child: Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          child: Icon(
                            Icons.add, 
                            size: 24,
                            color: themeService.primaryColor,
                          ),
                        ),
                      ),
                      Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
                      InkWell(
                        onTap: () {
                          _mapController?.animateCamera(CameraUpdate.zoomOut());
                        },
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          child: Icon(
                            Icons.remove, 
                            size: 24,
                            color: themeService.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom sheet with route details
          DraggableScrollableSheet(
            initialChildSize: 0.6, // Start with 60% of screen height
            minChildSize: 0.2, // Can be collapsed to 20%
            maxChildSize: 0.9, // Can expand to 90%
            controller: _bottomSheetController,
            snap: true,
            snapSizes: const [0.2, 0.6, 0.9],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Improved drag handle - more touch area and visual feedback
                    GestureDetector(
                      onVerticalDragUpdate: (details) {
                        // Manual control of the bottom sheet position
                        final currentSize = _bottomSheetController.size;
                        final newSize = currentSize - (details.delta.dy / screenHeight);
                        
                        // Clamp to valid range
                        final clampedSize = newSize.clamp(0.2, 0.9);
                        
                        // Check if we need to update
                        if (clampedSize != currentSize) {
                          _bottomSheetController.jumpTo(clampedSize);
                        }
                      },
                      onVerticalDragEnd: (details) {
                        // Snap to nearest position when drag ends
                        final currentSize = _bottomSheetController.size;
                        
                        // Snap to closest predefined position
                        if (currentSize < 0.4) {
                          _bottomSheetController.animateTo(
                            0.2,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        } else if (currentSize < 0.75) {
                          _bottomSheetController.animateTo(
                            0.6,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        } else {
                          _bottomSheetController.animateTo(
                            0.9,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                        
                        // Adjust map camera after sheet is repositioned
                        Future.delayed(const Duration(milliseconds: 350), () {
                          _adjustMapForBottomSheet();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          // Add subtle indicator for draggability
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.grey.shade200.withOpacity(0.3),
                              Colors.white,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Trip summary header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 30,
                                color: Colors.grey.shade300,
                              ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.startingPoint['name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  widget.destination['name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Trip duration and date
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(widget.route['arrival_time']),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDuration(widget.route['duration']),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Trip segments list
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.only(top: 24, bottom: 24),
                        itemCount: widget.route['segments'].length,
                        itemBuilder: (context, index) {
                          final segment = widget.route['segments'][index];
                          return _buildSegmentItem(segment, index);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSegmentItem(Map<String, dynamic> segment, int index) {
    final isWalking = segment['type'] == 'walk';
    final isLastSegment = index == widget.route['segments'].length - 1;
    
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - transit timeline with connected line
            SizedBox(
              width: 36,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Vertical connecting line that extends downward from the bottom of the icon
                  if (!isLastSegment)
                    Positioned(
                      top: 18, // Half of icon height
                      bottom: 0,
                      width: 4,
                      child: isWalking
                          ? Container(
                              alignment: Alignment.topCenter,
                              child: _buildDottedLine(segment['color']),
                            )
                          : Container(
                              width: 4,
                              color: segment['color'],
                            ),
                    ),
                  
                  // Line from previous segment that connects to this icon from above
                  if (index > 0) 
                    Positioned(
                      top: 0,
                      height: 18, // Half of icon height
                      width: 4,
                      child: widget.route['segments'][index - 1]['type'] == 'walk'
                          ? Container(
                              alignment: Alignment.bottomCenter,
                              child: _buildDottedLine(widget.route['segments'][index - 1]['color']),
                            )
                          : Container(
                              width: 4,
                              color: widget.route['segments'][index - 1]['color'],
                            ),
                    ),
                  
                  // Transit/walking icon centered over the connecting lines
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white, // White background to create a clean break in line
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: segment['color'],
                          width: 2, // Slightly thicker border to match Google Maps
                        ),
                      ),
                      child: Icon(
                        segment['icon'],
                        color: segment['color'],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Right side - segment details
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 8, bottom: isLastSegment ? 8 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Segment header
                    if (isWalking)
                      Text(
                        'Walk for ${segment['duration'].inMinutes} min (${_formatDistance(segment['distance'])})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: segment['color'],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              segment['line'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            '${segment['departure_time']} - ${segment['arrival_time']} (${segment['duration'].inMinutes} min)',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 4),
                    
                    // Additional information
                    if (isWalking && segment.containsKey('instructions'))
                      Text(
                        segment['instructions'].toString().replaceAll(RegExp(r'<[^>]*>'), ''),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      )
                    else if (!isWalking)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From: ${segment['departure_stop']}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'To: ${segment['arrival_stop']}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          if (segment.containsKey('headsign') && segment['headsign'] != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Direction: ${segment['headsign']}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          if (segment.containsKey('num_stops')) ...[
                            const SizedBox(height: 2),
                            Text(
                              segment['num_stops'] > 0 
                                  ? '${segment['num_stops']} ${segment['num_stops'] == 1 ? 'stop' : 'stops'}'
                                  : 'Direct',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Create dotted line for walking segments
  Widget _buildDottedLine(Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        // If height is too small, just return an empty container
        if (availableHeight <= 0) {
          return Container(width: 4);
        }
        
        final double dotSize = 4.0; // Slightly larger dots
        final double gapSize = 4.0; // Slightly larger gaps
        final int dotsCount = math.max(1, (availableHeight / (dotSize + gapSize)).floor());
        
        // Ensure we don't generate an invalid List.generate count
        final int itemCount = math.max(1, dotsCount * 2 - 1);
        
        // Center the dots to make sure they extend fully
        return Container(
          width: 4,
          height: availableHeight,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(itemCount, (index) {
              if (index.isEven) {
                return Container(
                  width: 4,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                );
              } else {
                return SizedBox(height: gapSize);
              }
            }),
          ),
        );
      },
    );
  }
  
  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          width: 40,
          alignment: Alignment.center,
          child: Icon(
            icon, 
            size: 22,
            color: primaryColor,
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    _bottomSheetController.dispose();
    super.dispose();
  }
} 