import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../services/rewards_service.dart';
import '../models/transit_record.dart';
import '../services/wallet_service.dart';
import '../services/balance_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
                content: Text('You have unclaimed points from your last trip'),
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

    // Simulate 5-second NFC scanning process
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
    final entryStation = _getRandomStation();
    final now = DateTime.now();
    
    setState(() {
      _currentTrip = TransitRecord(
        entryStation: entryStation,
        entryTime: now,
        fare: 0.0, // Will be calculated on exit
        pointsEarned: 0, // Will be calculated on exit
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
    final exitStation = _getRandomStation(exclude: _currentTrip!.entryStation);
    final now = DateTime.now();
    
    // Calculate trip duration in minutes
    final tripDuration = now.difference(_currentTrip!.entryTime).inMinutes;
    
    // Calculate fare based on distance (simple model)
    // Real-world pricing would depend on station-to-station distance
    final fare = (tripDuration < 30) ? 2.50 : 4.00;
    
    // Fixed points per trip: 150 points
    const pointsEarned = 150;
    
    // Update the current trip
    setState(() {
      _currentTrip = _currentTrip!.copyWith(
        exitStation: exitStation,
        exitTime: now,
        fare: fare,
        pointsEarned: pointsEarned,
      );
      
      _isScanning = false;
      _showSuccessScreen = true;
      _showClaimPoints = true;
    });
    
    // Save the updated trip state
    _saveActiveTrip();
    
    // Deduct fare from both wallet services
    walletService.deductMoney(fare);
    balanceService.deductBalance(fare, title: 'MRT/LRT Fare', iconType: IconType.bus);
  }

  void _claimPoints() {
    if (_currentTrip == null) return;
    
    final rewardsService = Provider.of<RewardsService>(context, listen: false);
    final walletService = Provider.of<WalletService>(context, listen: false);
    
    // Add points to rewards
    rewardsService.addPoints(
      _currentTrip!.pointsEarned,
      title: 'Transit trip from ${_currentTrip!.entryStation} to ${_currentTrip!.exitStation}',
    );
    
    // Add trip to history
    walletService.addTripToHistory(_currentTrip!);
    
    // Reset the state
    setState(() {
      _hasActiveTrip = false;
      _showSuccessScreen = false;
      _showClaimPoints = false;
      _currentTrip = null;
    });
    
    // Clear the active trip from storage
    _clearActiveTrip();
    
    // Navigate back to home page (index 0 in bottom navigation)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _resetScreen() {
    setState(() {
      _showSuccessScreen = false;
    });
  }

  String _getRandomStation({String? exclude}) {
    // Real KL MRT/LRT station names
    final stations = [
      // MRT Kajang Line (MRT1)
      'Sungai Buloh MRT',
      'Kampung Selamat MRT',
      'Kwasa Damansara MRT',
      'Kwasa Sentral MRT',
      'Kota Damansara MRT',
      'Surian MRT',
      'Mutiara Damansara MRT',
      'Bandar Utama MRT',
      'TTDI MRT',
      'Phileo Damansara MRT',
      'Pusat Bandar Damansara MRT',
      'Semantan MRT',
      'Muzium Negara MRT',
      'Pasar Seni MRT',
      'Merdeka MRT',
      'Bukit Bintang MRT',
      'Tun Razak Exchange MRT',
      'Cochrane MRT',
      'Maluri MRT',
      'Taman Pertama MRT',
      'Taman Midah MRT',
      'Taman Connaught MRT',
      'Taman Suntex MRT',
      'Sri Raya MRT',
      'Bandar Tun Hussein Onn MRT',
      'Batu 11 Cheras MRT',
      'Bukit Dukung MRT',
      'Sungai Jernih MRT',
      'Stadium Kajang MRT',
      'Kajang MRT',
      
      // LRT Kelana Jaya Line
      'Gombak LRT',
      'Taman Melati LRT',
      'Wangsa Maju LRT',
      'Sri Rampai LRT',
      'Setiawangsa LRT',
      'Jelatek LRT',
      'Dato Keramat LRT',
      'Damai LRT',
      'Ampang Park LRT',
      'KLCC LRT',
      'Kampung Baru LRT',
      'Dang Wangi LRT',
      'Masjid Jamek LRT',
      'Pasar Seni LRT',
      'KL Sentral LRT',
      'Bangsar LRT',
      'Abdullah Hukum LRT',
      'Kerinchi LRT',
      'Universiti LRT',
      'Taman Jaya LRT',
      'Asia Jaya LRT',
      'Taman Paramount LRT',
      'Taman Bahagia LRT',
      'Kelana Jaya LRT',
      
      // LRT Sri Petaling Line
      'Sentul Timur LRT',
      'Sentul LRT',
      'Titiwangsa LRT',
      'PWTC LRT',
      'Sultan Ismail LRT',
      'Bandaraya LRT',
      'Masjid Jamek LRT',
      'Plaza Rakyat LRT',
      'Hang Tuah LRT',
      'Pudu LRT',
      'Chan Sow Lin LRT',
      'Cheras LRT',
      'Salak Selatan LRT',
      'Bandar Tun Razak LRT',
      'Bandar Tasik Selatan LRT',
      'Sungai Besi LRT',
      'Sri Petaling LRT',
      'Bukit Jalil LRT',
      'Awan Besar LRT',
      'Muhibbah LRT',
      'Alam Sutera LRT',
      'Kinrara BK5 LRT',
      'IOI Puchong LRT',
      'Puteri LRT',
      'Puchong Perdana LRT',
      'Puchong Prima LRT',
      'Putra Heights LRT',
    ];
    
    if (exclude != null) {
      stations.removeWhere((s) => s == exclude);
    }
    
    return stations[DateTime.now().millisecond % stations.length];
  }

  @override
  Widget build(BuildContext context) {
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
        body: _isScanning
            ? _buildScanScreen() // Show scanning screen when scanning either for entry or exit
            : _showSuccessScreen 
                ? _buildSuccessScreen() 
                : _hasActiveTrip 
                    ? _buildActiveTripScreen() 
                    : _buildScanScreen(),
      ),
    );
  }

  Widget _buildScanScreen() {
    // Determine if this is an exit scan based on whether we have an active trip
    // and we're explicitly in exit scan mode
    final isExitScanMode = _hasActiveTrip && _isExitScan;
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    final secondaryColor = themeService.secondaryColor;
    
    final color = isExitScanMode ? secondaryColor : primaryColor;
    
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
        children: [
              // NFC Animation Container
              Stack(
                alignment: Alignment.center,
                children: [
                  // Circular ripple effects
                  if (_isScanning) ...[
                    _buildRippleEffect(300, 2.5, color),
                    _buildRippleEffect(240, 2.0, color),
                    _buildRippleEffect(180, 1.5, color),
                  ],
                  
                  // Main circular container
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: _isScanning ? 10 : 2,
                        ),
                      ],
                      border: Border.all(
                        color: color.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: _isScanning
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.nfc_rounded,
                                size: 80,
                                color: color,
          ),
          const SizedBox(height: 16),
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(color),
                                ),
                              ),
                            ],
                          )
                        : Icon(
                            Icons.nfc_rounded,
                            size: 100,
                            color: color,
                          ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Scanning text
              Text(
                _isScanning
                    ? 'Scanning...'
                    : isExitScanMode 
                        ? 'Tap your phone to exit the station'
                        : 'Tap your phone to the station reader',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Instructions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        isExitScanMode
                            ? 'Hold your device near the NFC reader at the exit gate'
                            : 'Hold your device near the NFC reader at the station gate',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Action button - Updated to match design in top_up_page.dart
              if (!_isScanning)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _startNfcScan(isExitScanMode),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: Text(
                      isExitScanMode ? 'Simulate Exit Scan' : 'Simulate Entry Scan',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRippleEffect(double size, double seconds, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: Duration(seconds: seconds.toInt()),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: (1 - value) * 0.7,
          child: Container(
            width: size * value,
            height: size * value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 2,
              ),
            ),
          ),
        );
      },
      onEnd: () {
        // Force a rebuild to repeat the animation
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildActiveTripScreen() {
    if (_currentTrip == null) return const SizedBox.shrink();
    
    final balanceService = Provider.of<BalanceService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    final secondaryColor = themeService.secondaryColor;
    final balanceAmount = balanceService.balance;
    
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Top color band
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Wallet balance card
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Card(
                    elevation: 6,
                    shadowColor: primaryColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
      child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              color: primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Balance',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'RM ${balanceAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Main content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                            Container(
                              width: 5,
                              height: 24,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Active Trip Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Trip card
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Trip line visualization
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.green.shade100,
                                                width: 2,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.login_rounded,
                                              color: Colors.green.shade500,
                                              size: 28,
                                            ),
                                          ),
                                          Container(
                                            width: 2,
                                            height: 60,
                                            margin: const EdgeInsets.symmetric(vertical: 8),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.green.shade400,
                                                  Colors.blue.shade200,
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 2,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.logout_rounded,
                                              color: Colors.grey.shade500,
                                              size: 28,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 12),
                                            // Entry station
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.shade100,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        'ENTRY',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.green.shade800,
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                Text(
                                                      _formatTime(_currentTrip!.entryTime),
                                                      style: TextStyle(
                                                        color: Colors.grey.shade600,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  _currentTrip!.entryStation,
                  style: const TextStyle(
                                                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            
                                            const SizedBox(height: 54),
                                            
                                            // Exit station (muted until scanned)
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade200,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        'EXIT',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.grey.shade600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                const Text(
                                                  'Tap to scan at exit station',
                                                  style: TextStyle(
                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Information panel
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 24,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Don\'t forget to scan when you exit the station to complete your journey.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue.shade900,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Scan to exit button - updated to match top_up_page.dart button design
                        Container(
                          width: double.infinity,
                          height: 56,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ElevatedButton(
                            onPressed: _isScanning ? null : () {
                              setState(() {
                                _isExitScan = true;
                              });
                              _startNfcScan(true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              disabledBackgroundColor: primaryColor.withOpacity(0.6),
                            ),
                            child: _isScanning
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Processing...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.nfc_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Scan to Exit Station',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    if (_currentTrip == null) return const SizedBox.shrink();
    
    final balanceService = Provider.of<BalanceService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    final secondaryColor = themeService.secondaryColor;
    
    final color = _isExitScan ? primaryColor : primaryColor;
    
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              
              // Success animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        
                        // Middle circle
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                        ),
                        
                        // Inner circle with icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                            border: Border.all(
                              color: color,
                              width: 4,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _isExitScan ? Icons.logout_rounded : Icons.login_rounded,
                              size: 50,
                              color: color,
                            ),
                          ),
                        ),
                        
                        // Check mark overlay that fades in
                        Positioned(
                          right: 30,
                          bottom: 30,
                          child: AnimatedOpacity(
                            opacity: value > 0.7 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: color,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.check,
                                  size: 25,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Success text with animated reveal
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Text(
                        _isExitScan ? 'Exit Successful' : 'Entry Successful',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle with station info
              Text(
                _isExitScan
                    ? 'You have exited from ${_currentTrip!.exitStation}'
                    : 'You have entered ${_currentTrip!.entryStation}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Trip details card with enhanced design
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
        child: Padding(
                  padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
                      if (_isExitScan) ...[
                        // Trip summary with badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                            const Text(
                              'Trip Summary',
                              style: TextStyle(
                                fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                  ),
                  decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: primaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Completed',
                    style: TextStyle(
                                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                                  ),
                                ],
                  ),
                ),
              ],
            ),
                        
            const SizedBox(height: 16),
                        
                        // From - To with better styling
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
              children: [
                              Column(
                  children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.circle,
                                      size: 12,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Container(
                                    width: 2,
                                    height: 24,
                                    color: Colors.grey.shade300,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: secondaryColor.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: secondaryColor,
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
                                      _currentTrip!.entryStation,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      _currentTrip!.exitStation!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Divider(height: 24),
                        
                        // Trip details in grid layout
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                'Fare',
                                'RM ${_currentTrip!.fare.toStringAsFixed(2)}',
                                Icons.payment,
                                secondaryColor,
                              ),
                            ),
                            Expanded(
                              child: _buildDetailItem(
                                'Balance',
                                'RM ${balanceService.balance.toStringAsFixed(2)}',
                                Icons.account_balance_wallet,
                                primaryColor,
                              ),
                            ),
                          ],
                        ),
                        
                        if (_showClaimPoints) ...[
                      const SizedBox(height: 16),
                          
                          // Points earned with animation
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.orange.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.orange.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                      Text(
                                  'Points Earned:',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: _currentTrip!.pointsEarned.toDouble()),
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Text(
                                      '+${value.toInt()}',
                                      style: TextStyle(
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    );
                                  },
                      ),
                    ],
                  ),
                ),
                          
                          const SizedBox(height: 24),
                          
                          // Slide to claim points widget
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ClaimPointsButton(
                              pointsAmount: _currentTrip!.pointsEarned,
                              onClaimed: () {
                                _claimPoints();
                              },
                            ),
                          ),
                        ],
                      ] else ...[
                        // Entry details
                        _buildDetailItem(
                          'Station',
                          _currentTrip!.entryStation,
                          Icons.train,
                          primaryColor,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildDetailItem(
                          'Time',
                          _formatTime(_currentTrip!.entryTime),
                          Icons.access_time,
                          secondaryColor,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildDetailItem(
                          'Wallet Balance',
                          'RM ${balanceService.balance.toStringAsFixed(2)}',
                          Icons.account_balance_wallet,
                          primaryColor,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Done button with updated styling to match top_up_page.dart
                        Container(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _resetScreen,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                label,
                      style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                      ),
                    ),
                  ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    
    return '$hour:$minute $period';
  }
}

class ClaimPointsButton extends StatefulWidget {
  final int pointsAmount;
  final VoidCallback onClaimed;

  const ClaimPointsButton({
    Key? key,
    required this.pointsAmount,
    required this.onClaimed,
  }) : super(key: key);

  @override
  State<ClaimPointsButton> createState() => _ClaimPointsButtonState();
}

class _ClaimPointsButtonState extends State<ClaimPointsButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Track drag position
  double _dragValue = 0.0;
  bool _isDragging = false;
  bool _isCompleted = false;
  
  // Animation values
  final double _buttonSize = 60.0;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    
    _controller.addListener(() {
      if (_controller.isCompleted && !_isCompleted) {
        setState(() {
          _isCompleted = true;
        });
        
        // Delay navigation to show the success animation for longer
        Future.delayed(const Duration(milliseconds: 1500), () {
          widget.onClaimed();
        });
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 48.0;
    final maxDragDistance = width - _buttonSize - 16.0;
    
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
      ),
      child: Stack(
        children: [
          // Background track
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade100,
                  Colors.orange.shade50,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Center(
              child: AnimatedOpacity(
                opacity: _isCompleted ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: const Text(
                  'Slide to claim points',
                      style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          
          // Static sparkles for visual interest without animation burden
          ...List.generate(5, (index) {
            return Positioned(
              left: 16 + (width - 32) * (index / 4),
              top: 10 + (index % 2 == 0 ? 12 : 40),
              child: Opacity(
                opacity: _isCompleted ? 0.0 : 0.7,
                child: Icon(
                  Icons.star,
                  color: Colors.orange.shade300,
                  size: 12,
        ),
      ),
    );
          }),
          
          // Slider button
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              // Calculate position based on drag or animation
              double position = _isDragging 
                  ? _dragValue 
                  : _animation.value * maxDragDistance;
                  
              // If completed, animate to the end
              if (_isCompleted) {
                position = maxDragDistance;
              }
              
              return Positioned(
                left: 8 + position,
                top: 5,
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    if (!_isCompleted) {
                      setState(() {
                        _isDragging = true;
                      });
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (_isDragging && !_isCompleted) {
                      setState(() {
                        _dragValue += details.delta.dx;
                        _dragValue = _dragValue.clamp(0.0, maxDragDistance);
                        
                        // Auto-complete when dragged past 90%
                        if (_dragValue >= maxDragDistance * 0.9) {
                          _controller.forward(from: _dragValue / maxDragDistance);
                          _isDragging = false;
                        }
                      });
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isDragging && !_isCompleted) {
                      if (_dragValue > maxDragDistance * 0.5) {
                        // Complete the animation if dragged more than halfway
                        _controller.forward(from: _dragValue / maxDragDistance);
                      } else {
                        // Spring back to start if not dragged far enough
                        _controller.reverse(from: _dragValue / maxDragDistance);
                      }
                      setState(() {
                        _isDragging = false;
                        _dragValue = 0;
                      });
                    }
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.orange.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 30,
                          )
                        : const Icon(
                            Icons.monetization_on,
                            color: Colors.white,
                            size: 30,
                          ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Success animation
          if (_isCompleted)
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: value,
                        child: Text(
                          '+${widget.pointsAmount} Points Claimed!',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
