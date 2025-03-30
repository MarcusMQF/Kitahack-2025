import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';
import '../../services/place_service.dart';
import '../../services/favorites_service.dart';
import 'route_planner_page.dart';

class SearchDestinationPage extends StatefulWidget {
  const SearchDestinationPage({super.key});

  @override
  State<SearchDestinationPage> createState() => _SearchDestinationPageState();
}

class _SearchDestinationPageState extends State<SearchDestinationPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  bool _isLoading = false;
  
  // Place service for search
  late PlaceService _placeService;
  
  // Recent locations and search results
  final List<Map<String, dynamic>> _recentLocations = [
    {
      'id': 'loc1',
      'name': 'LRT Universiti Station (KJ19)',
      'address': 'Jalan Kerinchi, Pantai Dalam, Kuala Lumpur, Federal Territory of Kuala Lumpur, Malaysia',
      'type': 'location',
      'icon': Icons.train_outlined,
      'latitude': 3.1182,
      'longitude': 101.6591,
    },
    {
      'id': 'loc2',
      'name': 'KL Eco City',
      'address': 'Kuala Lumpur, Federal Territory of Kuala Lumpur, Malaysia',
      'type': 'building',
      'icon': Icons.location_on_outlined,
      'latitude': 3.1172,
      'longitude': 101.6737,
    },
    {
      'id': 'loc3',
      'name': 'Terminal Bersepadu Selatan (TBS)',
      'address': 'Kuala Lumpur',
      'type': 'bus_station',
      'icon': Icons.directions_bus_outlined,
      'latitude': 3.0799,
      'longitude': 101.6892,
    },
    {
      'id': 'loc4',
      'name': 'LRT Universiti (Timur) (KI1440)',
      'address': 'Kuala Lumpur',
      'type': 'bus_stop',
      'icon': Icons.directions_bus_outlined,
      'latitude': 3.1183,
      'longitude': 101.6612,
    },
    {
      'id': 'loc5',
      'name': 'Pavilion Kuala Lumpur',
      'address': 'Jalan Bukit Bintang, Bukit Bintang, Kuala Lumpur, Federal Territory of Kuala Lumpur, Malaysia',
      'type': 'mall',
      'icon': Icons.shopping_bag_outlined,
      'latitude': 3.1488,
      'longitude': 101.7133,
    },
  ];
  
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
    
    // Initialize place service
    _placeService = PlaceService(apiKey: 'AIzaSyB7CcobaXgTjKpctqRVlsS9RipWMMXl27g');
    
    // Add listener for text changes
    _searchController.addListener(_onSearchTextChanged);
  }

  // Separate method for the listener to make it easier to remove
  void _onSearchTextChanged() {
    if (!mounted) return;
    
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
    });
    
    // Only search if text is not empty and has at least 3 characters
    if (_searchController.text.length >= 3) {
      _searchPlaces(_searchController.text);
    } else if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = [];
      });
    }
  }

  @override
  void dispose() {
    // Remove the listener before disposing the controller
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) return;
    
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      final results = await _placeService.searchPlaces(query);
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error searching places: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _selectLocation(Map<String, dynamic> location) {
    // Add to recent locations (in real app, you'd save this to storage)
    // For demo, we'll skip this step
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutePlannerPage(destination: location),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Where do you want to go?',
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
      ),
      body: Column(
        children: [
          // Search input field
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _searchFocusNode.hasFocus 
                      ? primaryColor 
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search for a place or address',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                  ),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              ),
            ),
          
          // Quick search options
          if (!_isSearching)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 24,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Options',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                
                _buildSearchOption(
                  icon: Icons.train,
                  color: primaryColor,
                  title: 'Search for transit stations',
                  onTap: () {
                    _searchController.text = 'train station near me';
                  },
                ),
                
                _buildSearchOption(
                  icon: Icons.map,
                  color: Colors.blue.shade600,
                  title: 'Choose on map',
                  onTap: () {
                    // This would navigate to a map selection screen
                    // For now, we'll just use a preset location
                    _selectLocation({
                      'id': 'map_selection',
                      'name': 'Selected Location',
                      'address': 'Kuala Lumpur, Malaysia',
                      'type': 'location',
                      'icon': Icons.location_on,
                      'latitude': 3.1390,
                      'longitude': 101.6869,
                    });
                  },
                ),
              ],
            ),
          
          // Recent locations header
          if (!_isSearching && _recentLocations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 24,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Recent',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          // Clear recent locations
                          // In a real app, you'd clear storage as well
                          setState(() {
                            // In demo, we won't actually clear this
                            // _recentLocations.clear();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Results list (either search results or recent locations)
          Expanded(
            child: _isSearching && _searchResults.isEmpty && !_isLoading
                ? _buildNoResultsMessage()
                : ListView.builder(
                    itemCount: _isSearching ? _searchResults.length : _recentLocations.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final location = _isSearching 
                          ? _searchResults[index] 
                          : _recentLocations[index];
                          
                      return _buildLocationItem(location);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoResultsMessage() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchOption({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLocationItem(Map<String, dynamic> location) {
    final favoritesService = Provider.of<FavoritesService>(context, listen: false);
    final isStarred = favoritesService.isFavorite(location['id']);
    
    return InkWell(
      onTap: () => _selectLocation(location),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              location['icon'] ?? Icons.location_on_outlined,
              color: Colors.grey.shade700,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  if (location['address'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        location['address'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                // Convert icon to string representation for storage
                final locationToSave = Map<String, dynamic>.from(location);
                if (locationToSave['icon'] is IconData) {
                  locationToSave['icon'] = _getIconString(locationToSave['icon']);
                }
                
                // Toggle favorite without calling setState() directly
                favoritesService.toggleFavorite(locationToSave).then((_) {
                  // Only call setState if the widget is still mounted
                  if (mounted) {
                    setState(() {});  // Refresh UI to show the star change
                    
                    // Show appropriate snackbar message based on action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isStarred 
                            ? 'Removed from favorites' 
                            : 'Added to favorites'
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Tooltip(
                  message: isStarred ? 'Remove from favorites' : 'Add to favorites',
                  child: Icon(
                    isStarred ? Icons.star : Icons.star_border,
                    color: isStarred ? Colors.amber : Colors.grey.shade500,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to convert IconData to string for storage
  String _getIconString(IconData icon) {
    if (icon == Icons.train_outlined || icon == Icons.train) {
      return 'train';
    } else if (icon == Icons.directions_bus_outlined || icon == Icons.directions_bus) {
      return 'bus';
    } else if (icon == Icons.shopping_bag_outlined || icon == Icons.shopping_bag) {
      return 'shopping';
    } else {
      return 'place';
    }
  }
} 