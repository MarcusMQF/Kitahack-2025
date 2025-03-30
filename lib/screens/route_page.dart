import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../services/theme_service.dart';
import '../services/favorites_service.dart';
import './route_screens/search_destination_page.dart';
import './route_screens/route_planner_page.dart';

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
  
  @override
  void initState() {
    super.initState();
    _lastAddBottomSheetTime = _initialTime;
    _lastHomeBottomSheetTime = _initialTime;
    _lastWorkBottomSheetTime = _initialTime;
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
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
                ).then((_) {
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
            subtitle: 'Tap to set',
            iconColor: primaryColor,
            onTap: () {
              _showSetHomeLocationBottomSheet(context, primaryColor);
            },
          ),
          
          // Work location button
          _buildQuickAccessItem(
            icon: Icons.work,
            title: 'Work',
            subtitle: 'Tap to set',
            iconColor: primaryColor,
            onTap: () {
              _showSetWorkLocationBottomSheet(context, primaryColor);
            },
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
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
      padding: const EdgeInsets.only(bottom: 80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Lottie.network(
                'https://lottie.host/afd0bcc2-4c2e-4907-b4bf-58f09a54a3ae/y3k9UjOHCQ.json',
                repeat: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Favorite Locations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45),
              child: Text(
                'Tap the star icon next to a location when searching to add it to your favorites',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
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
      default:
        return Icons.place;
    }
  }
  
  // Placeholder methods for bottom sheets - these would be implemented with actual functionality
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
                                    ? SizedBox(
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
    bool _isLoading = false;
    
    // Prevent multiple shows
    final now = DateTime.now();
    if (now.difference(_lastHomeBottomSheetTime).inMilliseconds < 500) return;
    _lastHomeBottomSheetTime = now;
    
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
                          'Set Home Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        Text(
                          'Your home address will be used for quick navigation and route planning.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Address field
                        TextField(
                          controller: addressController,
                          decoration: InputDecoration(
                            labelText: 'Home Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.home,
                              color: primaryColor,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.my_location),
                              onPressed: _isLoading ? null : () async {
                                // Set loading state
                                setState(() {
                                  _isLoading = true;
                                });
                                
                                try {
                                  // Here you would get current location
                                  // For demo, we'll just simulate a delay
                                  await Future.delayed(const Duration(milliseconds: 500));
                                  
                                  // Only update if the widget is still active
                                  if (context.mounted) {
                                    addressController.text = "Current Location";
                                  }
                                } catch (e) {
                                  // Handle error
                                  debugPrint('Error getting location: $e');
                                } finally {
                                  // Reset loading state if the widget is still mounted
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
                        const SizedBox(height: 16),
                        
                        // Search from map option
                        ListTile(
                          enabled: !_isLoading,
                          leading: Icon(
                            Icons.map,
                            color: _isLoading ? Colors.grey : primaryColor,
                          ),
                          title: const Text('Select location from map'),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            // Navigate to map selection safely
                            if (context.mounted) {
                              Navigator.pop(context);
                              // Here we would navigate to a map selection screen
                            }
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
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
                                  // Only proceed if we have an address
                                  if (addressController.text.isNotEmpty) {
                                    // Set loading state
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    
                                    try {
                                      // Here you would save the home location
                                      // For demo, we'll just simulate a delay
                                      await Future.delayed(const Duration(milliseconds: 500));
                                      
                                      // Close the bottom sheet if the context is still valid
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      // Handle error
                                      debugPrint('Error saving home location: $e');
                                      
                                      // Reset loading state if still mounted
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
                                    ? SizedBox(
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
        // Safely dispose the controller
        addressController.dispose();
      });
    });
  }
  
  void _showSetWorkLocationBottomSheet(BuildContext context, Color primaryColor) {
    final TextEditingController addressController = TextEditingController();
    bool _isLoading = false;
    
    // Prevent multiple shows
    final now = DateTime.now();
    if (now.difference(_lastWorkBottomSheetTime).inMilliseconds < 500) return;
    _lastWorkBottomSheetTime = now;
    
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
                          'Set Work Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        Text(
                          'Your work address will be used for quick navigation and commute planning.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Address field
                        TextField(
                          controller: addressController,
                          decoration: InputDecoration(
                            labelText: 'Work Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.work,
                              color: primaryColor,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.my_location),
                              onPressed: _isLoading ? null : () async {
                                // Set loading state
                                setState(() {
                                  _isLoading = true;
                                });
                                
                                try {
                                  // Here you would get current location
                                  // For demo, we'll just simulate a delay
                                  await Future.delayed(const Duration(milliseconds: 500));
                                  
                                  // Only update if the widget is still active
                                  if (context.mounted) {
                                    addressController.text = "Current Location";
                                  }
                                } catch (e) {
                                  // Handle error
                                  debugPrint('Error getting location: $e');
                                } finally {
                                  // Reset loading state if still mounted
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
                        const SizedBox(height: 16),
                        
                        // Search from map option
                        ListTile(
                          enabled: !_isLoading,
                          leading: Icon(
                            Icons.map,
                            color: _isLoading ? Colors.grey : primaryColor,
                          ),
                          title: const Text('Select location from map'),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            // Navigate to map selection safely
                            if (context.mounted) {
                              Navigator.pop(context);
                              // Here we would navigate to a map selection screen
                            }
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
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
                                  // Only proceed if we have an address
                                  if (addressController.text.isNotEmpty) {
                                    // Set loading state
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    
                                    try {
                                      // Here you would save the work location
                                      // For demo, we'll just simulate a delay
                                      await Future.delayed(const Duration(milliseconds: 500));
                                      
                                      // Close the bottom sheet if context is still valid
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      // Handle error
                                      debugPrint('Error saving work location: $e');
                                      
                                      // Reset loading state if still mounted
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
                                    ? SizedBox(
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
        // Safely dispose the controller
        addressController.dispose();
      });
    });
  }

  // Quick Access section
  Widget _buildQuickAccessSection(BuildContext context, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                  _showAddQuickAccessBottomSheet(context, primaryColor);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'Add',
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
