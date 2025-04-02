import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/favorites_service.dart';
import '../services/place_service.dart';
import '../config/api_keys.dart';
import './route_screens/search_destination_page.dart';
import './route_screens/route_planner_page.dart';
import '../services/address_service.dart';
import '../utils/lottie_cache.dart' as cache;

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  // The favorites are now managed by the FavoritesService
  
  // Timestamps to prevent multiple bottom sheet opens
  final DateTime _initialTime = DateTime(2000);
  late DateTime _lastAddBottomSheetTime;
  late DateTime _lastHomeBottomSheetTime;
  late DateTime _lastWorkBottomSheetTime;
  late DateTime _lastSchoolBottomSheetTime;
  
  @override
  void initState() {
    super.initState();
    _lastAddBottomSheetTime = _initialTime;
    _lastHomeBottomSheetTime = _initialTime;
    _lastWorkBottomSheetTime = _initialTime;
    _lastSchoolBottomSheetTime = _initialTime;
    
    // Use AddressService instead
    final addressService = Provider.of<AddressService>(context, listen: false);
    if (!addressService.isInitialized) {
      addressService.initialize();
    }
  }
  
  // Load saved addresses from storage - removed, handled by AddressService
  
  // Save a home address
  Future<void> _saveHomeAddress(Map<String, dynamic> address) async {
    // Use AddressService instead
    final addressService = Provider.of<AddressService>(context, listen: false);
    await addressService.saveHomeAddress(address);
  }
  
  // Save a work address
  Future<void> _saveWorkAddress(Map<String, dynamic> address) async {
    // Use AddressService instead
    final addressService = Provider.of<AddressService>(context, listen: false);
    await addressService.saveWorkAddress(address);
  }
  
  // Save a school address
  Future<void> _saveSchoolAddress(Map<String, dynamic> address) async {
    // Use AddressService instead
    final addressService = Provider.of<AddressService>(context, listen: false);
    await addressService.saveSchoolAddress(address);
  }
  
  // Delete home address
  Future<void> _deleteHomeAddress() async {
    // Use AddressService instead
    final addressService = Provider.of<AddressService>(context, listen: false);
    await addressService.deleteHomeAddress();
  }
  
  // Delete work address
  Future<void> _deleteWorkAddress() async {
    // Use AddressService instead
    final addressService = Provider.of<AddressService>(context, listen: false);
    await addressService.deleteWorkAddress();
  }
  
  // Delete school address
  Future<void> _deleteSchoolAddress() async {
    // Use AddressService instead
    final addressService = Provider.of<AddressService>(context, listen: false);
    await addressService.deleteSchoolAddress();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    final addressService = Provider.of<AddressService>(context); // Listen to address changes
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Transit Routes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => const SearchDestinationPage(),
                  ),
                ).then((result) {
                  // If result is a location, navigate to route planner
                  if (result != null && result is Map<String, dynamic>) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoutePlannerPage(
                          destination: result,
                        ),
                      ),
                    );
                  }
                  
                  // Refresh the UI when returning from search to show any new favorites
                  setState(() {});
                });
              },
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
          children: [
            Icon(
                      Icons.search,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Where do you want to go?',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Quick Access section
          _buildQuickAccessSection(context, primaryColor),
          
          // Home location button
          _buildQuickAccessItem(
            icon: Icons.home,
            title: 'Home',
            subtitle: addressService.homeAddress != null ? addressService.homeAddress!['address'] : 'Tap to set',
            iconColor: primaryColor,
            onTap: () {
              _showSetHomeLocationBottomSheet(context, primaryColor);
            },
            hasValue: addressService.homeAddress != null,
            onDelete: addressService.homeAddress != null ? () => _deleteHomeAddress() : null,
          ),
          
          // Work location button
          _buildQuickAccessItem(
            icon: Icons.work,
            title: 'Work',
            subtitle: addressService.workAddress != null ? addressService.workAddress!['address'] : 'Tap to set',
            iconColor: primaryColor,
            onTap: () {
              _showSetWorkLocationBottomSheet(context, primaryColor);
            },
            hasValue: addressService.workAddress != null,
            onDelete: addressService.workAddress != null ? () => _deleteWorkAddress() : null,
          ),
          
          // School location button
          _buildQuickAccessItem(
            icon: Icons.school,
            title: 'School',
            subtitle: addressService.schoolAddress != null ? addressService.schoolAddress!['address'] : 'Tap to set',
            iconColor: primaryColor,
            onTap: () {
              _showSetSchoolLocationBottomSheet(context, primaryColor);
            },
            hasValue: addressService.schoolAddress != null,
            onDelete: addressService.schoolAddress != null ? () => _deleteSchoolAddress() : null,
          ),
          
          const SizedBox(height: 20),
          
          // Favorites section
          _buildFavoritesSection(),
          
          // Favorite locations list
          Expanded(
            child: Consumer<FavoritesService>(
              builder: (context, favoritesService, child) {
                if (!favoritesService.isInitialized) {
                  // Show loading indicator while initializing
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                final favorites = favoritesService.favorites;
                
                if (favorites.isEmpty) {
                  return _buildEmptyFavoritesState();
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final location = favorites[index];
                    return _buildFavoriteLocationItem(location, primaryColor, favoritesService);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickAccessItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
    required bool hasValue,
    VoidCallback? onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0.5,
        shadowColor: Colors.grey.withOpacity(0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'location_icon_$title',
                  child: Container(
                    padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            hasValue ? Icons.check_circle : Icons.edit,
                            size: 12,
                            color: hasValue ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                                color: hasValue ? Colors.grey.shade700 : Colors.grey.shade500,
                          fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                            ),
                      ),
                    ],
                  ),
                    ],
                  ),
                ),
                if (hasValue && onDelete != null)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                      // Show confirmation dialog before deleting
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete ${title.toLowerCase()} location?'),
                          content: Text('This will remove your saved ${title.toLowerCase()} location.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                onDelete();
                                Navigator.pop(context);
                              },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.grey.shade500,
                          size: 22,
                        ),
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Update for empty favorites state to match the design
  Widget _buildEmptyFavoritesState() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: cache.LottieCache().getLottieWidget(
                url: cache.LottieCache.emptyFavoritesUrl,
                repeat: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Favorite Locations',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated favorite location item to match the design
  Widget _buildFavoriteLocationItem(Map<String, dynamic> location, Color primaryColor, FavoritesService favoritesService) {
    // Convert string icon representation back to IconData
    IconData iconData = _getIconFromString(location['icon']);
    final String id = location['id'];
    
    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      // Directly delete on dismiss
      confirmDismiss: (direction) async {
        // Remove this item from favorites
        favoritesService.removeFavorite(id);
        
        // Show a snackbar with undo option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Removed from favorites'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Add back the favorite
                favoritesService.addFavorite(location);
              },
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        return true;
      },
      // Background when swiping
      background: Container(
        color: Colors.transparent,
      ),
      secondaryBackground: Container(
        color: Colors.red.shade50,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete_outline,
          color: Colors.red.shade700,
          size: 24,
        ),
      ),
      // The actual list item
      child: InkWell(
        onTap: () {
          // Navigate directly to route planner with this location as destination
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoutePlannerPage(destination: location),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                iconData,
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
      ),
    );
  }
  
  // Helper method to convert string representation back to IconData
  IconData _getIconFromString(String iconString) {
    switch (iconString) {
      case 'train':
        return Icons.train;
      case 'bus':
        return Icons.directions_bus;
      case 'shopping':
        return Icons.shopping_bag;
      case 'school':
        return Icons.school;
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.place;
    }
  }
  
  // Placeholder methods for bottom sheets - these would be implemented with actual functionality
  // ignore: unused_element
  void _showAddQuickAccessBottomSheet(BuildContext context, Color primaryColor) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    bool _isLoading = false;
    bool _addToFavorites = true;
    
    // Prevent multiple shows
    final now = DateTime.now();
    if (now.difference(_lastAddBottomSheetTime).inMilliseconds < 500) return;
    _lastAddBottomSheetTime = now;
    
    // Use Future.microtask to show the bottom sheet after the current frame completes
    Future.microtask(() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        enableDrag: true,
        barrierColor: Colors.black54,
        useSafeArea: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle indicator
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Title
                        const Text(
                          'Add Quick Access Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Name field
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Location Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.bookmark_border),
                          ),
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 16),
                        
                        // Address field
                        TextField(
                          controller: addressController,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.map),
                              onPressed: _isLoading ? null : () async {
                                // Set loading while map functionality would be processed
                                setState(() {
                                  _isLoading = true;
                                });
                                
                                try {
                                  // Simulate map operation
                                  await Future.delayed(const Duration(milliseconds: 500));
                                  
                                  // In a real app, we would open a map selection UI
                                  if (context.mounted) {
                                    // Just a placeholder action for demo purposes
                                    addressController.text = "Selected from map";
                                  }
                                } catch (e) {
                                  debugPrint('Error selecting from map: $e');
                                } finally {
                                  if (context.mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 20),
                        
                        // Mark as favorite checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _addToFavorites,
                              onChanged: _isLoading ? null : (value) {
                                setState(() {
                                  _addToFavorites = value ?? true;
                                });
                              },
                              activeColor: primaryColor,
                            ),
                            const Text(
                              'Also add to favorites',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : () {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : () async {
                                  // Add the location to quick access and possibly favorites
                                  if (nameController.text.isNotEmpty && addressController.text.isNotEmpty) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    
                                    try {
                                      // Here you would save the location
                                      // For demo, we'll just simulate a delay
                                      await Future.delayed(const Duration(milliseconds: 500));
                                      
                                      // If add to favorites is checked, add to favorites as well
                                      if (_addToFavorites) {
                                        // Would add to favorites in a real app
                                        debugPrint('Added to favorites: ${nameController.text}');
                                      }
                                      
                                      // Close the bottom sheet if still mounted
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      debugPrint('Error saving location: $e');
                                      if (context.mounted) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading 
                                    ? const SizedBox(
                                        width: 20, 
                                        height: 20, 
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          );
        },
      ).then((_) {
        // Safely dispose controllers
        nameController.dispose();
        addressController.dispose();
      });
    });
  }
  
  void _showSetHomeLocationBottomSheet(BuildContext context, Color primaryColor) {
    final TextEditingController addressController = TextEditingController();
    final FocusNode addressFocusNode = FocusNode();
    
    // Move state variables outside of the builder to avoid recreation
    // These variables will be accessible to all callbacks
    bool isLoading = false;
    bool isSearching = false;
    List<Map<String, dynamic>> searchResults = [];
    Map<String, dynamic>? selectedPlace;
    
    // Prevent multiple shows
    final now = DateTime.now();
    if (now.difference(_lastHomeBottomSheetTime).inMilliseconds < 500) return;
    _lastHomeBottomSheetTime = now;
    
    // Get place service
    final placeService = PlaceService(apiKey: ApiKeys.googleMapsApiKey);
    
    // Function to handle place search
    Future<void> searchPlaces(String query) async {
      if (query.isEmpty || query.length < 3) {
        isSearching = false;
        searchResults = [];
        return;
      }
      
      isSearching = true;
      isLoading = true;
      
      try {
        final results = await placeService.searchPlaces(query);
        
        if (!addressFocusNode.hasFocus) {
          // If focus is lost, don't update UI to avoid conflicts
          return;
        }
        
        searchResults = results;
        isLoading = false;
      } catch (e) {
        debugPrint('Error searching places: $e');
        isLoading = false;
      }
    }
    
    // Function to select a search result
    void selectSearchResult(Map<String, dynamic> place, StateSetter updateState) {
      selectedPlace = Map<String, dynamic>.from(place);
      addressController.text = '${place['name']}, ${place['address']}';
      
      // Update state immediately after selection
      updateState(() {
        searchResults = [];
        isSearching = false;
        isLoading = false; // Ensure loading is false
      });
    }
    
    // Use Future.microtask to show the bottom sheet after the current frame completes
    Future.microtask(() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        enableDrag: false, // Disable drag to dismiss
        barrierColor: Colors.black54,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8, // Make it taller
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              
              // Safely update the modal's state
              void updateModalState(VoidCallback fn) {
                if (context.mounted) {
                  setModalState(fn);
                }
              }
              
              // Add listener to text field
              addressController.addListener(() {
                if (addressController.text.length >= 3) {
                  searchPlaces(addressController.text).then((_) {
                    updateModalState(() {});
                  });
                } else if (addressController.text.isEmpty) {
                  updateModalState(() {
                    isSearching = false;
                    searchResults = [];
                  });
                }
              });
              
              return Container(
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with title and close button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Row(
                          children: [
                            // Hero animation for the icon
                            Hero(
                              tag: 'location_icon_Home',
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.home,
                                  color: primaryColor,
                                  size: 26,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Set Home Location',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Material(
                              color: Colors.grey.shade100,
                              shape: const CircleBorder(),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () {
                                // Important: Remove listeners before disposing
                                addressController.removeListener(() {});
                                addressFocusNode.unfocus();
                                Navigator.of(context).pop();
                              },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.close,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Divider after header
                      Divider(color: Colors.grey.shade200),
                      
                      // Description text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                        child: Text(
                          'Your home address will be used for quick navigation and route planning.',
                          style: TextStyle(
                            fontSize: 14,
                                    color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Address search field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: TextField(
                          controller: addressController,
                          focusNode: addressFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Search for home address',
                            hintText: 'Enter your home address',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                            prefixIcon: Icon(
                              Icons.home,
                              color: primaryColor,
                            ),
                            suffixIcon: isSearching && addressController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    addressController.clear();
                                    updateModalState(() {
                                      isSearching = false;
                                      searchResults = [];
                                    });
                                  },
                                )
                              : null,
                          ),
                          enabled: !isLoading,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      
                      // Loading indicator or search results
                      Expanded(
                        child: isLoading
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                              child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Searching for locations...',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : searchResults.isNotEmpty
                            ? NotificationListener<OverscrollIndicatorNotification>(
                                onNotification: (overscroll) {
                                  overscroll.disallowIndicator();
                                  return true;
                                },
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    final place = searchResults[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(color: Colors.grey.shade200),
                                      ),
                                      elevation: 0,
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                        place['icon'] ?? Icons.location_on,
                                        color: primaryColor,
                                            size: 24,
                                          ),
                                        ),
                                        title: Text(
                                          place['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      subtitle: Text(
                                        place['address'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14,
                                          ),
                                      ),
                                      onTap: () {
                                        selectSearchResult(place, setModalState);
                                      },
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : isSearching && addressController.text.isNotEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 60,
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
                                      Text(
                                        'Try a different search term',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                    textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.home_outlined,
                                        size: 60,
                                        color: Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Search for your home',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                      ),
                      
                      // Bottom action buttons
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, -4),
                            ),
                          ],
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade200, width: 1),
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isLoading 
                                  ? null 
                                  : () {
                                    // Important: Remove listener before navigation
                                    final controller = addressController;
                                    final node = addressFocusNode;
                                    node.unfocus();
                                    // Remove the listener before popping
                                    controller.removeListener(() {});
                                    // Only pop if the context is still valid
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLoading || addressController.text.isEmpty 
                                  ? null 
                                  : () async {
                                    updateModalState(() {
                                      isLoading = true;
                                    });
                                    
                                    // Get a local copy of the text for saving
                                    final address = addressController.text;
                                    final place = selectedPlace != null ? Map<String, dynamic>.from(selectedPlace!) : null;
                                    
                                    // Remove the listener and unfocus before saving and navigation
                                    addressController.removeListener(() {});
                                    addressFocusNode.unfocus();
                                    
                                    try {
                                      // Create the home location using the local copies
                                      Map<String, dynamic> homeLocation;
                                      
                                      if (place != null) {
                                        homeLocation = place;
                                        homeLocation['id'] = 'home_location';
                                        homeLocation['name'] = 'Home';
                                        homeLocation['type'] = 'home';
                                      } else {
                                        homeLocation = {
                                          'name': 'Home',
                                          'address': address,
                                          'id': 'home_location',
                                          'icon': 'home',
                                          'type': 'home'
                                        };
                                      }
                                      
                                      // Save the home location
                                      await _saveHomeAddress(homeLocation);
                                      
                                      // Show success message
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Home location saved successfully'),
                                            duration: Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        
                                        Navigator.of(context).pop();
                                      }
                                    } catch (e) {
                                      debugPrint('Error saving home location: $e');
                                      
                                      // Show error message if context is still valid
                                      if (context.mounted) {
                                        updateModalState(() {
                                          isLoading = false;
                                        });
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error saving home location: ${e.toString()}'),
                                            duration: const Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  disabledBackgroundColor: Colors.grey.shade300,
                                ),
                                child: isLoading 
                                    ? const SizedBox(
                                        width: 20, 
                                        height: 20, 
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Save',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (!isLoading && selectedPlace != null) ...[
                                            const SizedBox(width: 8),
                                            Icon(Icons.check_circle, size: 18),
                                          ],
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ).then((_) {
        // Do nothing here, as controllers are already handled within the widget
      });
    });
  }
  
  void _showSetWorkLocationBottomSheet(BuildContext context, Color primaryColor) {
    final TextEditingController addressController = TextEditingController();
    final FocusNode addressFocusNode = FocusNode();
    
    // Move state variables outside of the builder to avoid recreation
    // These variables will be accessible to all callbacks
    bool isLoading = false;
    bool isSearching = false;
    List<Map<String, dynamic>> searchResults = [];
    Map<String, dynamic>? selectedPlace;
    
    // Prevent multiple shows
    final now = DateTime.now();
    if (now.difference(_lastWorkBottomSheetTime).inMilliseconds < 500) return;
    _lastWorkBottomSheetTime = now;
    
    // Get place service
    final placeService = PlaceService(apiKey: ApiKeys.googleMapsApiKey);
    
    // Function to handle place search
    Future<void> searchPlaces(String query) async {
      if (query.isEmpty || query.length < 3) {
        isSearching = false;
        searchResults = [];
        return;
      }
      
      isSearching = true;
      isLoading = true;
      
      try {
        final results = await placeService.searchPlaces(query);
        
        if (!addressFocusNode.hasFocus) {
          // If focus is lost, don't update UI to avoid conflicts
          return;
        }
        
        searchResults = results;
        isLoading = false;
      } catch (e) {
        debugPrint('Error searching places: $e');
        isLoading = false;
      }
    }
    
    // Function to select a search result
    void selectSearchResult(Map<String, dynamic> place, StateSetter updateState) {
      selectedPlace = Map<String, dynamic>.from(place);
      addressController.text = '${place['name']}, ${place['address']}';
      
      // Update state immediately after selection
      updateState(() {
        searchResults = [];
        isSearching = false;
        isLoading = false; // Ensure loading is false
      });
    }
    
    // Use Future.microtask to show the bottom sheet after the current frame completes
    Future.microtask(() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        enableDrag: false, // Disable drag to dismiss
        barrierColor: Colors.black54,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8, // Make it taller
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              
              // Safely update the modal's state
              void updateModalState(VoidCallback fn) {
                if (context.mounted) {
                  setModalState(fn);
                }
              }
              
              // Add listener to text field
              addressController.addListener(() {
                if (addressController.text.length >= 3) {
                  searchPlaces(addressController.text).then((_) {
                    updateModalState(() {});
                  });
                } else if (addressController.text.isEmpty) {
                  updateModalState(() {
                    isSearching = false;
                    searchResults = [];
                  });
                }
              });
              
              return Container(
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with title and close button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Row(
                          children: [
                            // Hero animation for the icon
                            Hero(
                              tag: 'location_icon_Work',
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.work,
                                  color: primaryColor,
                                  size: 26,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Set Work Location',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Material(
                              color: Colors.grey.shade100,
                              shape: const CircleBorder(),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () {
                                  // Important: Remove listeners before disposing
                                  addressController.removeListener(() {});
                                  addressFocusNode.unfocus();
                                  Navigator.of(context).pop();
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.close,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Divider after header
                      Divider(color: Colors.grey.shade200),
                      
                      // Description text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your work address will be used for quick navigation and commute planning.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Address search field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: TextField(
                          controller: addressController,
                          focusNode: addressFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Search for work address',
                            hintText: 'Enter your work address',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                            prefixIcon: Icon(
                              Icons.work,
                              color: primaryColor,
                            ),
                            suffixIcon: isSearching && addressController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    addressController.clear();
                                    updateModalState(() {
                                      isSearching = false;
                                      searchResults = [];
                                    });
                                  },
                                )
                              : null,
                          ),
                          enabled: !isLoading,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      
                      // Loading indicator or search results
                      Expanded(
                        child: isLoading
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Searching for locations...',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : searchResults.isNotEmpty
                            ? NotificationListener<OverscrollIndicatorNotification>(
                                onNotification: (overscroll) {
                                  overscroll.disallowIndicator();
                                  return true;
                                },
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    final place = searchResults[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(color: Colors.grey.shade200),
                                      ),
                                      elevation: 0,
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            place['icon'] ?? Icons.location_on,
                                            color: primaryColor,
                                            size: 24,
                                          ),
                                        ),
                                        title: Text(
                                          place['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        subtitle: Text(
                                          place['address'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        onTap: () {
                                          selectSearchResult(place, setModalState);
                                        },
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : isSearching && addressController.text.isNotEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 60,
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
                                      Text(
                                        'Try a different search term',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.work_outlined,
                                        size: 60,
                                        color: Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Search for your work',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                      ),
                      
                      // Bottom action buttons
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, -4),
                            ),
                          ],
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade200, width: 1),
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isLoading 
                                  ? null 
                                  : () {
                                    // Important: Remove listener before navigation
                                    final controller = addressController;
                                    final node = addressFocusNode;
                                    node.unfocus();
                                    // Remove the listener before popping
                                    controller.removeListener(() {});
                                    // Only pop if the context is still valid
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLoading || addressController.text.isEmpty 
                                  ? null 
                                  : () async {
                                    updateModalState(() {
                                      isLoading = true;
                                    });
                                    
                                    // Get a local copy of the text for saving
                                    final address = addressController.text;
                                    final place = selectedPlace != null ? Map<String, dynamic>.from(selectedPlace!) : null;
                                    
                                    // Remove the listener and unfocus before saving and navigation
                                    addressController.removeListener(() {});
                                    addressFocusNode.unfocus();
                                    
                                    try {
                                      // Create the work location using the local copies
                                      Map<String, dynamic> workLocation;
                                      
                                      if (place != null) {
                                        workLocation = place;
                                        workLocation['id'] = 'work_location';
                                        workLocation['name'] = 'Work';
                                        workLocation['type'] = 'work';
                                      } else {
                                        workLocation = {
                                          'name': 'Work',
                                          'address': address,
                                          'id': 'work_location',
                                          'icon': 'work',
                                          'type': 'work'
                                        };
                                      }
                                      
                                      // Save the work location
                                      await _saveWorkAddress(workLocation);
                                      
                                      // Show success message
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Work location saved successfully'),
                                            duration: Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        
                                        Navigator.of(context).pop();
                                      }
                                    } catch (e) {
                                      debugPrint('Error saving work location: $e');
                                      
                                      // Show error message if context is still valid
                                      if (context.mounted) {
                                        updateModalState(() {
                                          isLoading = false;
                                        });
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error saving work location: ${e.toString()}'),
                                            duration: const Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  disabledBackgroundColor: Colors.grey.shade300,
                                ),
                                child: isLoading 
                                    ? const SizedBox(
                                        width: 20, 
                                        height: 20, 
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Save',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (!isLoading && selectedPlace != null) ...[
                                            const SizedBox(width: 8),
                                            Icon(Icons.check_circle, size: 18),
                                          ],
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ).then((_) {
        // Do nothing here, as controllers are already handled within the widget
      });
    });
  }
  
  void _showSetSchoolLocationBottomSheet(BuildContext context, Color primaryColor) {
    final TextEditingController addressController = TextEditingController();
    final FocusNode addressFocusNode = FocusNode();
    
    // Move state variables outside of the builder to avoid recreation
    // These variables will be accessible to all callbacks
    bool isLoading = false;
    bool isSearching = false;
    List<Map<String, dynamic>> searchResults = [];
    Map<String, dynamic>? selectedPlace;
    
    // Prevent multiple shows
    final now = DateTime.now();
    if (now.difference(_lastSchoolBottomSheetTime).inMilliseconds < 500) return;
    _lastSchoolBottomSheetTime = now;
    
    // Get place service
    final placeService = PlaceService(apiKey: ApiKeys.googleMapsApiKey);
    
    // Function to handle place search
    Future<void> searchPlaces(String query) async {
      if (query.isEmpty || query.length < 3) {
        isSearching = false;
        searchResults = [];
        return;
      }
      
      isSearching = true;
      isLoading = true;
      
      try {
        final results = await placeService.searchPlaces(query);
        
        if (!addressFocusNode.hasFocus) {
          // If focus is lost, don't update UI to avoid conflicts
          return;
        }
        
        searchResults = results;
        isLoading = false;
      } catch (e) {
        debugPrint('Error searching places: $e');
        isLoading = false;
      }
    }
    
    // Function to select a search result
    void selectSearchResult(Map<String, dynamic> place, StateSetter updateState) {
      selectedPlace = Map<String, dynamic>.from(place);
      addressController.text = '${place['name']}, ${place['address']}';
      
      // Update state immediately after selection
      updateState(() {
        searchResults = [];
        isSearching = false;
        isLoading = false; // Ensure loading is false
      });
    }
    
    // Use Future.microtask to show the bottom sheet after the current frame completes
    Future.microtask(() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        enableDrag: false, // Disable drag to dismiss
        barrierColor: Colors.black54,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8, // Make it taller
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              
              // Safely update the modal's state
              void updateModalState(VoidCallback fn) {
                if (context.mounted) {
                  setModalState(fn);
                }
              }
              
              // Add listener to text field
              addressController.addListener(() {
                if (addressController.text.length >= 3) {
                  searchPlaces(addressController.text).then((_) {
                    updateModalState(() {});
                  });
                } else if (addressController.text.isEmpty) {
                  updateModalState(() {
                    isSearching = false;
                    searchResults = [];
                  });
                }
              });
              
              return Container(
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with title and close button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Row(
                          children: [
                            // Hero animation for the icon
                            Hero(
                              tag: 'location_icon_School',
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.school,
                                  color: primaryColor,
                                  size: 26,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Set School Location',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Material(
                              color: Colors.grey.shade100,
                              shape: const CircleBorder(),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () {
                                  // Important: Remove listeners before disposing
                                  addressController.removeListener(() {});
                                  addressFocusNode.unfocus();
                                  Navigator.of(context).pop();
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.close,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Divider after header
                      Divider(color: Colors.grey.shade200),
                      
                      // Description text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your school address will be used for quick navigation and route planning.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Address search field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: TextField(
                          controller: addressController,
                          focusNode: addressFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Search for school address',
                            hintText: 'Enter your school address',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                            prefixIcon: Icon(
                              Icons.school,
                              color: primaryColor,
                            ),
                            suffixIcon: isSearching && addressController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    addressController.clear();
                                    updateModalState(() {
                                      isSearching = false;
                                      searchResults = [];
                                    });
                                  },
                                )
                              : null,
                          ),
                          enabled: !isLoading,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      
                      // Loading indicator or search results
                      Expanded(
                        child: isLoading
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Searching for locations...',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : searchResults.isNotEmpty
                            ? NotificationListener<OverscrollIndicatorNotification>(
                                onNotification: (overscroll) {
                                  overscroll.disallowIndicator();
                                  return true;
                                },
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    final place = searchResults[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(color: Colors.grey.shade200),
                                      ),
                                      elevation: 0,
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            place['icon'] ?? Icons.location_on,
                                            color: primaryColor,
                                            size: 24,
                                          ),
                                        ),
                                        title: Text(
                                          place['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        subtitle: Text(
                                          place['address'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        onTap: () {
                                          selectSearchResult(place, setModalState);
                                        },
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : isSearching && addressController.text.isNotEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 60,
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
                                      Text(
                                        'Try a different search term',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.school_outlined,
                                        size: 60,
                                        color: Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Search for your school',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                      ),
                      
                      // Bottom action buttons
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, -4),
                            ),
                          ],
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade200, width: 1),
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isLoading 
                                  ? null 
                                  : () {
                                    // Important: Remove listener before navigation
                                    final controller = addressController;
                                    final node = addressFocusNode;
                                    node.unfocus();
                                    // Remove the listener before popping
                                    controller.removeListener(() {});
                                    // Only pop if the context is still valid
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLoading || addressController.text.isEmpty 
                                  ? null 
                                  : () async {
                                    updateModalState(() {
                                      isLoading = true;
                                    });
                                    
                                    // Get a local copy of the text for saving
                                    final address = addressController.text;
                                    final place = selectedPlace != null ? Map<String, dynamic>.from(selectedPlace!) : null;
                                    
                                    // Remove the listener and unfocus before saving and navigation
                                    addressController.removeListener(() {});
                                    addressFocusNode.unfocus();
                                    
                                    try {
                                      // Create the school location using the local copies
                                      Map<String, dynamic> schoolLocation;
                                      
                                      if (place != null) {
                                        schoolLocation = place;
                                        schoolLocation['id'] = 'school_location';
                                        schoolLocation['name'] = 'School';
                                        schoolLocation['type'] = 'school';
                                      } else {
                                        schoolLocation = {
                                          'name': 'School',
                                          'address': address,
                                          'id': 'school_location',
                                          'icon': 'school',
                                          'type': 'school'
                                        };
                                      }
                                      
                                      // Save the school location
                                      await _saveSchoolAddress(schoolLocation);
                                      
                                      // Show success message
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('School location saved successfully'),
                                            duration: Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        
                                        Navigator.of(context).pop();
                                      }
                                    } catch (e) {
                                      debugPrint('Error saving school location: $e');
                                      
                                      // Show error message if context is still valid
                                      if (context.mounted) {
                                        updateModalState(() {
                                          isLoading = false;
                                        });
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error saving school location: ${e.toString()}'),
                                            duration: const Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  disabledBackgroundColor: Colors.grey.shade300,
                                ),
                                child: isLoading 
                                    ? const SizedBox(
                                        width: 20, 
                                        height: 20, 
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Save',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (!isLoading && selectedPlace != null) ...[
                                            const SizedBox(width: 8),
                                            Icon(Icons.check_circle, size: 18),
                                          ],
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ).then((_) {
        // Do nothing here, as controllers are already handled within the widget
      });
    });
  }

  // Quick Access section
  Widget _buildQuickAccessSection(BuildContext context, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                'Quick Access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Material(
              color: Colors.transparent,
            shape: const CircleBorder(),
            child: Tooltip(
              message: 'Save your frequently used locations here for quick access',
              showDuration: const Duration(seconds: 3),
              padding: const EdgeInsets.all(12),
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Set addresses to quickly plan routes from your favorite locations',
                        style: TextStyle(color: Colors.white),
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: primaryColor,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.help_outline_rounded,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Favorites section - updated to match recent design
  Widget _buildFavoritesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 24,
                decoration: BoxDecoration(
                  color: Provider.of<ThemeService>(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Favorites',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Consumer<FavoritesService>(
            builder: (context, favoritesService, child) {
              if (favoritesService.favorites.isEmpty) {
                return const SizedBox.shrink();
              }
              
              final primaryColor = Provider.of<ThemeService>(context).primaryColor;
              return Container(
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
                      // Show confirmation dialog before clearing
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear favorites?'),
                          content: const Text('This will remove all your favorite locations.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                favoritesService.clearAllFavorites();
                                Navigator.pop(context);
                              },
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      );
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
              );
            },
          ),
        ],
      ),
    );
  }
}
