import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_page.dart';
import 'screens/route_page.dart';
import 'screens/reward_page.dart';
import 'screens/my_trip_page.dart';
import 'screens/qr_scanner_page.dart';
import 'utils/app_theme.dart';
import 'services/rewards_service.dart';
import 'services/theme_service.dart';
import 'services/location_service.dart';
import 'services/place_service.dart';
import 'services/favorites_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/api_keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("Environment variables loaded successfully");
  } catch (e) {
    debugPrint("Failed to load environment variables: $e");
    // App can still run with the fallback API keys
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RewardsService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => FavoritesService()),
        Provider<PlaceService>(
          create: (_) => PlaceService(apiKey: ApiKeys.googleMapsApiKey),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Transit Go',
          theme: AppTheme.currentTheme,
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool _pulseGrowing = true; // Animation direction state
  
  final List<Widget> _pages = [
    const HomePage(),
    const MyTripPage(),
    const RoutePage(),
    const RewardPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      if (index == 2) {
        // Launch QR scanner as a standalone page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRScannerPage()),
        );
      } else if (index > 2) {
        // Adjust index for pages array (skip QR scanner in the pages list)
        _selectedIndex = index - 1;
      } else {
        _selectedIndex = index;
      }
    });
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    // Get theme service for color
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    // Determine if this nav item is selected
    bool isSelected;
    if (index < 2) {
      isSelected = _selectedIndex == index;
    } else {
      isSelected = _selectedIndex == index - 1;
    }
    
    return NavigationDestination(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Transform.scale(
              scale: isSelected ? 1.2 : 1.0,
              child: Icon(
                icon,
                color: isSelected ? primaryColor : Colors.grey.shade600,
                size: isSelected ? 24 : 22,
              ),
            ),
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? primaryColor : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            child: Text(label),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(top: 4),
            width: isSelected ? 20 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
      label: label,
    );
  }

  Widget _buildScanButton(int index) {
    // Get theme service for colors
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    final accentColor = themeService.accentColor;
    
    return NavigationDestination(
      icon: Transform.translate(
        offset: const Offset(0, -22), // Keep the same offset to maintain position
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withAlpha((0.3 * 255).round()),
                blurRadius: 12,
                offset: const Offset(0, 5),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _onItemTapped(index);
              },
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated pulsing circle
                    Builder(
                      builder: (context) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: _pulseGrowing ? 0.0 : 1.6,
                            end: _pulseGrowing ? 1.6 : 0.0,
                          ),
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                          onEnd: () {
                            // Flip the direction for continuous animation
                            _pulseGrowing = !_pulseGrowing;
                            setState(() {});
                          },
                        );
                      },
                    ),
                    // QR code icon
                    const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      label: '',  // Empty label to avoid text under the floating button
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate display index for highlighting (accounting for QR scanner position)
    int displayIndex = _selectedIndex;
    if (_selectedIndex >= 2) {
      displayIndex = _selectedIndex + 1;
    }
    
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 2,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: NavigationBar(
          height: 64,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedIndex: displayIndex,
          onDestinationSelected: _onItemTapped,
          animationDuration: const Duration(milliseconds: 400),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          indicatorColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          destinations: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.directions_bus, 'My Trip', 1),
            _buildScanButton(2),
            _buildNavItem(Icons.map, 'Route', 3),
            _buildNavItem(Icons.card_giftcard, 'Reward', 4),
          ],
        ),
      ),
    );
  }
}
