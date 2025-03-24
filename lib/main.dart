import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/route_page.dart';
import 'screens/reward_page.dart';
import 'screens/profile_page.dart';
import 'screens/my_trip_page.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transit Go',
      theme: AppTheme.themeData,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 2;

  final List<Widget> _pages = [
    const RewardPage(),
    const MyTripPage(),
    const HomePage(),
    const RoutePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
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
                color: isSelected ? Colors.blue : Colors.grey.shade600,
                size: isSelected ? 28 : 24,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue : Colors.grey.shade600,
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
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        height: 75,
        elevation: 0,
        backgroundColor: Colors.white,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        animationDuration: const Duration(milliseconds: 400),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: [
          _buildNavItem(Icons.card_giftcard, 'Reward', 0),
          _buildNavItem(Icons.directions_bus, 'My Trip', 1),
          _buildNavItem(Icons.home, 'Home', 2),
          _buildNavItem(Icons.map, 'Map', 3),
          _buildNavItem(Icons.person, 'Profile', 4),
        ],
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
