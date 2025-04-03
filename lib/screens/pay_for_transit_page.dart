import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/transit_record.dart';
import '../services/rewards_service.dart';
import '../services/wallet_service.dart';
import '../services/balance_service.dart';
import '../widgets/transit_scan_widget.dart';
import '../widgets/transit_active_trip_widget.dart';
import '../widgets/transit_success_widget.dart';
import '../utils/transit_utils.dart';
import '../services/theme_service.dart';

class PayForTransitPage extends StatefulWidget {
  const PayForTransitPage({super.key});

  @override
  State<PayForTransitPage> createState() => _PayForTransitPageState();
}

class _PayForTransitPageState extends State<PayForTransitPage> {
  bool _isScanning = false;
  bool _hasActiveTrip = false;
  bool _showSuccessScreen = false;
  bool _isExitScan = false;
  bool _showClaimPoints = false;

  // Transit data
  TransitRecord? _currentTrip;

  @override
  void initState() {
    super.initState();
    _loadActiveTrip();
  }

  // Load any active trip from shared preferences
  Future<void> _loadActiveTrip() async {
    final prefs = await SharedPreferences.getInstance();
    final tripJson = prefs.getString('active_trip');
    
    if (tripJson != null) {
      final tripMap = json.decode(tripJson);
      setState(() {
        _currentTrip = TransitRecord(
          entryStation: tripMap['entryStation'],
          entryTime: DateTime.fromMillisecondsSinceEpoch(tripMap['entryTime']),
          exitStation: tripMap['exitStation'],
          exitTime: tripMap['exitTime'] != null 
              ? DateTime.fromMillisecondsSinceEpoch(tripMap['exitTime']) 
              : null,
          fare: tripMap['fare'].toDouble(),
          pointsEarned: tripMap['pointsEarned'],
          creditsEarned: tripMap['creditsEarned'] ?? tripMap['pointsEarned'] * 3, // Fallback for backward compatibility
        );
        _hasActiveTrip = true;
        
        // If trip has exit information, show success screen with claim points option
        if (_currentTrip!.exitStation != null && _currentTrip!.exitTime != null) {
          _isExitScan = true;
          _showSuccessScreen = true;
          _showClaimPoints = true;
          
          // Show a notification that points need to be claimed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You have unclaimed rewards from your last trip'),
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          });
        }
      });
    }
  }

  // Save the active trip to shared preferences
  Future<void> _saveActiveTrip() async {
    if (_currentTrip == null) {
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final tripMap = _currentTrip!.toMap();
    await prefs.setString('active_trip', json.encode(tripMap));
  }

  // Clear the active trip from shared preferences
  Future<void> _clearActiveTrip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_trip');
  }

  // Simulate NFC scan
  void _startNfcScan(bool isExit) {
    setState(() {
      _isScanning = true;
      _isExitScan = isExit;
      _showSuccessScreen = false; // Reset success screen to show scanning screen
    });

    // Simulate 3-second NFC scanning process
    Timer(const Duration(seconds: 3), () {
      if (isExit) {
        _processExitScan();
      } else {
        _processEntryScan();
      }
    });
  }

  void _processEntryScan() {
    // Get a random station from KL MRT/LRT stations
    final entryStation = TransitUtils.getRandomStation();
    final now = DateTime.now();
    
    setState(() {
      _currentTrip = TransitRecord(
        entryStation: entryStation,
        entryTime: now,
        fare: 0.0, // Will be calculated on exit
        pointsEarned: 0, // Will be calculated on exit
        creditsEarned: 0, // Will be calculated on exit
      );
      _isScanning = false;
      _showSuccessScreen = true;
      _hasActiveTrip = true;
    });
    
    // Save the active trip to persistent storage
    _saveActiveTrip();
  }

  void _processExitScan() {
    if (_currentTrip == null) return;
    
    final walletService = Provider.of<WalletService>(context, listen: false);
    final balanceService = Provider.of<BalanceService>(context, listen: false);
    
    // Get a random exit station different from the entry station
    final exitStation = TransitUtils.getRandomStation(exclude: _currentTrip!.entryStation);
    final now = DateTime.now();
    
    // Calculate trip duration in minutes
    final tripDuration = now.difference(_currentTrip!.entryTime).inMinutes;
    
    // Calculate fare based on distance (simple model)
    // Real-world pricing would depend on station-to-station distance
    final fare = (tripDuration < 30) ? 2.50 : 4.00;
    
    // Fixed points per trip (~50 points and ~150 credits)
    const pointsEarned = 50;
    const creditsEarned = 150;
    
    // Update the current trip
    setState(() {
      _currentTrip = _currentTrip!.copyWith(
        exitStation: exitStation,
        exitTime: now,
        fare: fare,
        pointsEarned: pointsEarned,
        creditsEarned: creditsEarned,
      );
      
      _isScanning = false;
      _showSuccessScreen = true;
      _showClaimPoints = true;
    });
    
    // Save the updated trip state
    _saveActiveTrip();
    
    // Deduct fare from both wallet services
    walletService.deductMoney(fare);
    balanceService.deductBalance(fare, title: 'MRT/LRT Fare', iconType: IconType.train);
  }

  void _claimPoints() async {
    if (_currentTrip == null) return;
    
    final rewardsService = Provider.of<RewardsService>(context, listen: false);
    final walletService = Provider.of<WalletService>(context, listen: false);
    
    try {
      // Add points and credits separately to rewards - this will trigger saving to SharedPreferences
      await rewardsService.claimTripRewards(
        _currentTrip!.pointsEarned,
        _currentTrip!.creditsEarned,
        title: 'Transit trip from ${_currentTrip!.entryStation} to ${_currentTrip!.exitStation}',
      );
      
      // Add trip to history after rewards are claimed
      walletService.addTripToHistory(_currentTrip!);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rewards claimed successfully!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear the active trip from storage first
      await _clearActiveTrip();
      
      // Reset the state after everything is saved
      setState(() {
        _hasActiveTrip = false;
        _showSuccessScreen = false;
        _showClaimPoints = false;
        _currentTrip = null;
      });
      
      // Navigate back to home page (index 0 in bottom navigation)
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      // Show error if claiming fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to claim rewards: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      print('Error claiming rewards: $e');
    }
  }

  void _resetScreen() {
    setState(() {
      _showSuccessScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletService = Provider.of<WalletService>(context);
    final balanceService = Provider.of<BalanceService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    // Show loading indicator while services initialize
    if (!balanceService.isInitialized || !walletService.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Scan & Pay',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading transit data...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return WillPopScope(
      onWillPop: () async {
        // If showing exit scan results with unclaimed points, don't allow back navigation
        if (_showSuccessScreen && _isExitScan && _showClaimPoints) {
          // Show a brief message to guide the user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please claim your points to complete your trip'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return false; // Prevent back navigation
        }
        return true; // Allow back navigation in other cases
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(
            _hasActiveTrip ? 'Active Trip' : 'Scan & Pay',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        centerTitle: true,
          automaticallyImplyLeading: !(_showSuccessScreen && _isExitScan && _showClaimPoints),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isScanning) {
      // Show scanning widget when scanning for either entry or exit
      return TransitScanWidget(
        isExitScanMode: _isExitScan,
        isScanning: _isScanning,
        onScanPressed: () => _startNfcScan(_isExitScan),
      );
    } else if (_showSuccessScreen) {
      // Show success screen after scanning
      return TransitSuccessWidget(
        currentTrip: _currentTrip!,
        isExitScan: _isExitScan,
        showClaimPoints: _showClaimPoints,
        onClaimPoints: _claimPoints,
        onReset: _resetScreen,
      );
    } else if (_hasActiveTrip) {
      // Show active trip screen
      return TransitActiveTripWidget(
        currentTrip: _currentTrip!,
        isScanning: _isScanning,
        onExitScanPressed: () {
                              setState(() {
                                _isExitScan = true;
                              });
                              _startNfcScan(true);
                            },
      );
    } else {
      // Default screen - show scan widget for entry
      return TransitScanWidget(
        isExitScanMode: false,
        isScanning: _isScanning,
        onScanPressed: () => _startNfcScan(false),
      );
    }
  }
}