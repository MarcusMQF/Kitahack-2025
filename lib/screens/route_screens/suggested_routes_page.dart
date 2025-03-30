import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';
import '../../services/route_service.dart';
import '../../config/api_keys.dart';
import 'route_details_page.dart';

class SuggestedRoutesPage extends StatefulWidget {
  final Map<String, dynamic> startingPoint;
  final Map<String, dynamic> destination;
  final DateTime departureTime;
  
  const SuggestedRoutesPage({
    super.key,
    required this.startingPoint,
    required this.destination,
    required this.departureTime,
  });

  @override
  State<SuggestedRoutesPage> createState() => _SuggestedRoutesPageState();
}

class _SuggestedRoutesPageState extends State<SuggestedRoutesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _suggestedRoutes = [];
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }
  
  void _loadRoutes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final apiKey = ApiKeys.googleMapsApiKey;
      final routeService = RouteService(apiKey: apiKey);
      
      final routes = await routeService.getTransitRoutes(
        startLat: widget.startingPoint['latitude'], 
        startLng: widget.startingPoint['longitude'],
        endLat: widget.destination['latitude'], 
        endLng: widget.destination['longitude'],
        departureTime: widget.departureTime,
      );
      
      if (routes.isEmpty) {
        setState(() {
          _suggestedRoutes = [];
          _errorMessage = 'No transit routes found between these locations. Please try different locations or departure time.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _suggestedRoutes = routes;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _suggestedRoutes = [];
        _errorMessage = 'Error loading routes: $e. Please check your internet connection and try again.';
        _isLoading = false;
      });
    }
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
  
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Suggested Routes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoutes,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Finding the best routes...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From: ${widget.startingPoint['name']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'To: ${widget.destination['name']}',
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
                      IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: () {
                          // Show filters
                        },
                      ),
                    ],
                  ),
                ),
                
                // Show error message if any
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.amber.shade100,
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.amber.shade900,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                Expanded(
                  child: _suggestedRoutes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.directions_off,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No routes found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your departure time or locations',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _suggestedRoutes.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemBuilder: (context, index) {
                            final route = _suggestedRoutes[index];
                            return _buildRouteCard(route, context);
                          },
                        ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildRouteCard(Map<String, dynamic> route, BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Duration and arrival time
            Row(
              children: [
                Text(
                  _formatDuration(route['duration']),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '• Arrive at ${_formatTime(route['arrival_time'])}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                
                // Show fare if available
                if (route['fare'] != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '• ${route['fare']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ],
            ),

            // Transit count badge - similar to Google Maps style
            if (route.containsKey('transit_count')) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Ride ${route['transit_count']} ${route['transit_count'] == 1 ? 'transit' : 'transits'} • ${route['segments'].where((s) => s['type'] == 'walk').length} ${route['segments'].where((s) => s['type'] == 'walk').length == 1 ? 'walk' : 'walks'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Route segments visualization
            Row(
              children: [
                for (var i = 0; i < route['segments'].length; i++) ...[
                  _buildSegmentIcon(route['segments'][i]),
                  if (i < route['segments'].length - 1)
                    Icon(
                      Icons.arrow_right_alt,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),

                ],
              ],

            ),
            
            const SizedBox(height: 16),
            
            // Route segments breakdown
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var segment in route['segments']) ...[
                    _buildSegmentDetailChip(segment),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Departure station and time
            if (route['departure_station'] != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Leaves from ${route["departure_station"]}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (route.containsKey('departure_time')) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Departs at ${_formatTime(route["departure_time"])}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
            ],
            
            // View details button
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to route details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteDetailsPage(
                        route: route,
                        startingPoint: widget.startingPoint,
                        destination: widget.destination,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View details',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: primaryColor,
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
  
  Widget _buildSegmentIcon(Map<String, dynamic> segment) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: segment['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          segment['icon'],
          color: segment['color'],
          size: 20,
        ),
      ),
    );
  }
  
  Widget _buildSegmentDetailChip(Map<String, dynamic> segment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: segment['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: segment['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            segment['icon'],
            color: segment['color'],
            size: 16,
          ),
          const SizedBox(width: 6),
          if (segment['type'] == 'walk')
            Text(
              '${segment['distance']} km',
              style: TextStyle(
                color: segment['color'],
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            )
          else
            Text(
              segment['line'],
              style: TextStyle(
                color: segment['color'],
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }
} 