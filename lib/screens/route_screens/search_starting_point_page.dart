import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';
import '../../services/place_service.dart';

class SearchStartingPointPage extends StatefulWidget {
  const SearchStartingPointPage({super.key});

  @override
  State<SearchStartingPointPage> createState() => _SearchStartingPointPageState();
}

class _SearchStartingPointPageState extends State<SearchStartingPointPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  bool _isLoading = false;
  
  // Recent locations and search results
  final List<Map<String, dynamic>> _recentLocations = [
    {
      'id': 'loc1',
      'name': 'Kuala Lumpur Sentral',
      'address': 'Brickfields, Kuala Lumpur, Federal Territory of Kuala Lumpur, Malaysia',
      'type': 'station',
      'icon': Icons.train,
      'latitude': 3.1348,
      'longitude': 101.6841,
    },
    {
      'id': 'loc2',
      'name': 'KLCC',
      'address': 'Kuala Lumpur City Centre, Kuala Lumpur, Malaysia',
      'type': 'location',
      'icon': Icons.location_on_outlined,
      'latitude': 3.1577,
      'longitude': 101.7117,
    },
    {
      'id': 'loc3',
      'name': 'KL International Airport (KLIA)',
      'address': 'Sepang, Selangor, Malaysia',
      'type': 'airport',
      'icon': Icons.flight,
      'latitude': 2.7456,
      'longitude': 101.7099,
    },
  ];
  
  List<Map<String, dynamic>> _searchResults = [];

  late PlaceService _placeService;
  
  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
    
    // Get place service from provider
    _placeService = Provider.of<PlaceService>(context, listen: false);
    
    // Add listener for text changes
    _searchController.addListener(() {
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
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final results = await _placeService.searchPlaces(query);
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error searching places: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _selectLocation(Map<String, dynamic> location) {
    // Return the selected location to the route planner
    Navigator.pop(context, location);
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Choose starting point',
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
                  hintText: 'Search for a starting point',
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Text(
                    'Options',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                _buildSearchOption(
                  icon: Icons.home,
                  color: Colors.blue.shade600,
                  title: 'Set home location',
                  onTap: () {
                    // For demo, we'll use a hardcoded location
                    // In a real app, you'd have user-saved locations
                    _selectLocation({
                      'id': 'home',
                      'name': 'Home',
                      'address': 'Your saved home address',
                      'type': 'home',
                      'icon': Icons.home,
                      'latitude': 3.0738,
                      'longitude': 101.5183,
                    });
                  },
                ),
                
                _buildSearchOption(
                  icon: Icons.work,
                  color: primaryColor,
                  title: 'Set work location',
                  onTap: () {
                    // For demo, we'll use a hardcoded location
                    _selectLocation({
                      'id': 'work',
                      'name': 'Work',
                      'address': 'Your saved work address',
                      'type': 'work',
                      'icon': Icons.work,
                      'latitude': 3.1577,
                      'longitude': 101.7117,
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
                  const Text(
                    'Recent',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
          ],
        ),
      ),
    );
  }
} 