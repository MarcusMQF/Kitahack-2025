import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'profile_page.dart';
// ignore: unused_import
import 'dart:io';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../components/animated_progress_bar.dart';
import '../config/api_keys.dart'; // Import API keys from config
import 'package:provider/provider.dart';
import '../services/rewards_service.dart';
import '../services/theme_service.dart'; // Add theme service import
import 'reward_page.dart';
import '../services/sdg_impact_service.dart';
import 'sdg_impact_page.dart';
import '../services/wallet_service.dart';
import 'transit_history_page.dart';
import 'transit_assistant_page.dart'; // Add the new transit assistant page
import 'pay_for_transit_page.dart'; // For the Scan & Pay page

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class ParticleAnimation extends StatefulWidget {
  final double width;
  final double height;
  
  const ParticleAnimation({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<ParticleAnimation> createState() => _ParticleAnimationState();
}

class _ParticleAnimationState extends State<ParticleAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final int _particleCount = 20;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialize particles
    _initParticles();
    
    // Add controller listener to update particles
    _controller.addListener(_updateParticles);
  }
  
  void _initParticles() {
    for (int i = 0; i < _particleCount; i++) {
      _addParticle();
    }
  }
  
  void _addParticle() {
    _particles.add(
      Particle(
        x: _random.nextDouble() * widget.width,
        y: widget.height + _random.nextDouble() * 20, // Start below the container
        size: 1 + _random.nextDouble() * 3,
        speed: 0.5 + _random.nextDouble() * 1.5,
        opacity: 0.1 + _random.nextDouble() * 0.4,
      ),
    );
  }
  
  void _updateParticles() {
    if (!mounted) return;
    
    setState(() {
      for (int i = 0; i < _particles.length; i++) {
        // Move particle up
        _particles[i].y -= _particles[i].speed;
        
        // Decrease opacity as it moves up
        _particles[i].opacity -= 0.003;
        
        // Reset particle if it's out of bounds or too transparent
        if (_particles[i].y < 0 || _particles[i].opacity <= 0) {
          _particles[i] = Particle(
            x: _random.nextDouble() * widget.width,
            y: widget.height + _random.nextDouble() * 10,
            size: 1 + _random.nextDouble() * 3, 
            speed: 0.5 + _random.nextDouble() * 1.5,
            opacity: 0.1 + _random.nextDouble() * 0.4,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateParticles);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: ParticlePainter(particles: _particles),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  
  ParticlePainter({required this.particles});
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final weatherIcons = {
    // Main conditions from OpenWeatherMap
    'Clear': '☀️',
    'Clouds': '⛅',
    'Drizzle': '🌦️',
    'Rain': '🌧️',
    'Thunderstorm': '⛈️',
    'Snow': '❄️',
    'Mist': '🌫️',
    'Fog': '🌫️',
    'Haze': '🌫️',
    'Smoke': '🌫️',
    'Dust': '🌫️',
    'Ash': '🌫️',
    'Squall': '💨',
    'Tornado': '🌪️',
    
    // More specific conditions based on weather descriptions
    'FewClouds': '🌤️',
    'BrokenClouds': '☁️',
    'LightRain': '🌦️',
  };
  String currentWeather = '😊';
  String temperature = '28°C';
  String cityName = 'Loading...';
  String weatherDescription = '';
  bool isExpanded = false;
  final WeatherService _weatherService = WeatherService(apiKey: ApiKeys.openWeatherApiKey);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _fetchWeather();
  }
  
  Future<void> _fetchWeather() async {
    try {
      // Get the current city
      final city = await _weatherService.getCurrentCity();
      
      // Get weather for the city
      final Weather weather = await _weatherService.getWeather(city);
      
      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          cityName = weather.cityName;
          temperature = '${weather.temperature.round()}°C';
          weatherDescription = weather.description;
          
          // Get appropriate weather icon based on both main condition and description
          String iconKey = weather.getWeatherIconKey();
          currentWeather = weatherIcons[iconKey] ?? '😊';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          cityName = 'Error';
          temperature = 'N/A';
          weatherDescription = '';
          currentWeather = '😊';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rewardsService = Provider.of<RewardsService>(context);
    final themeService = Provider.of<ThemeService>(context); // Add ThemeService
    final points = rewardsService.points;
    final credits = rewardsService.credits;
    final currentRank = rewardsService.currentRank;
    final nextRank = rewardsService.nextRank;
    final progressToNext = rewardsService.progressToNextRank;
    final pointsToNext = rewardsService.pointsToNextRank;
    
    // Get theme colors
    final primaryColor = themeService.primaryColor;
    final secondaryColor = themeService.secondaryColor;
    
    return Container(
      color: Colors.white,
      child: Scaffold(
      backgroundColor: Colors.white,
        appBar: null,
        body: SafeArea(
          child: AnimatedList(
            initialItemCount: 1,
            itemBuilder: (context, index, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutQuint,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Custom header with greeting and profile button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hello,',
                                  style: TextStyle(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ProfileData.username,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                // Navigate to profile page
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                                ).then((_) {
                                  // Refresh to show updated profile image
                                  setState(() {});
                                });
                              },
                              child: Builder(
                                builder: (context) {
                                  // Check if profile image exists
                                  final profileImage = ProfileData.sharedProfileImage;
                                  
                                  if (profileImage != null && profileImage.existsSync()) {
                                    try {
                                      return CircleAvatar(
                                        radius: 24,
                                        backgroundImage: FileImage(profileImage),
                                      );
                                    } catch (e) {
                                      // Fallback to default if any error with the file
                                      return CircleAvatar(
                                        radius: 24,
                                        backgroundColor: primaryColor.withAlpha((0.2 * 255).round()),
                                        child: Icon(Icons.person, color: primaryColor, size: 26),
                                      );
                                    }
                                  } else {
                                    return CircleAvatar(
                                      radius: 24,
                                      backgroundColor: primaryColor.withAlpha((0.2 * 255).round()),
                                      child: Icon(Icons.person, color: primaryColor, size: 26),
                                    );
                                  }
                                }
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // User points card with weather
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Card tap functionality removed - now only Level button expands
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                height: isExpanded ? 290 : 230,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, secondaryColor],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withAlpha(60),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                      spreadRadius: -4,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Particle animation layer
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            return ParticleAnimation(
                                              width: constraints.maxWidth,
                                              height: constraints.maxHeight,
                                            );
                                          }
                                        ),
                                      ),
                                    ),
                                    // Main content
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Top row: City Name & Weather
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _isLoading ? 'Loading...' : cityName,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                const Text(
                                                  'Less Traffic, Cleaner Air!',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                // Weather display (not a button)
                                                Container(
                                                  height: 32,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withAlpha(40),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      AnimatedBuilder(
                                                        animation: _controller,
                                                        builder: (context, child) {
                                                          return Transform.translate(
                                                            offset: Offset(0, 2 * math.sin(_controller.value * math.pi * 2)),
                                                            child: Text(
                                                              currentWeather,
                                                              style: const TextStyle(fontSize: 16),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        temperature,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                // Level button - activates expansion
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isExpanded = !isExpanded;
                                                    });
                                                  },
                                                  borderRadius: BorderRadius.circular(20),
                                                  child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withAlpha(40),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.emoji_events, 
                                                          color: currentRank.color, // Dynamic color based on rank
                                                          size: 14
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          currentRank.name, // Dynamic rank name
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        
                                        // Points display
                                        Padding(
                                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                                          child: GestureDetector(
                                            onLongPress: () {
                                              _showPointsTestDialog(context, rewardsService);
                                            },
                                            child: TweenAnimationBuilder<double>(
                                              tween: Tween<double>(begin: 0, end: 1),
                                              duration: const Duration(milliseconds: 800),
                                              curve: Curves.easeOutCubic,
                                              builder: (context, value, child) {
                                                return Transform.scale(
                                                  scale: 0.6 + (value * 0.4), // Scale from 0.6 to 1.0 instead of 0 to 1
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        credits.toStringAsFixed(0),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 40,
                                                          fontWeight: FontWeight.bold,
                                                          height: 0.9,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      const Padding(
                                                        padding: EdgeInsets.only(bottom: 6),
                                                        child: Text(
                                                          'credits',
                                                          style: TextStyle(
                                                            color: Colors.white70,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        
                                        // Show available points below credits
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: Text(
                                            '$points points available for rewards',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        
                                        // Progress indicator (shown only when expanded)
                                        if (nextRank != null) 
                                          AnimatedProgressBar(
                                            progress: progressToNext, // This is already correct (0.0 to 1.0)
                                            maxValue: (nextRank.creditsRequired - currentRank.creditsRequired).toDouble(), // Difference between ranks
                                            currentValue: (credits - currentRank.creditsRequired).toDouble(), // Points accumulated in current rank
                                            isExpanded: isExpanded,
                                            leftLabel: 'Need $pointsToNext more credits to ${nextRank.name}',
                                            rightLabel: '${nextRank.creditsRequired - currentRank.creditsRequired} credits',
                                          )
                                        else 
                                          // Custom display for highest rank achieved
                                          AnimatedCrossFade(
                                            firstChild: const SizedBox(height: 0),
                                            secondChild: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  const Row(
                                                    children: [
                                                      Icon(
                                                        Icons.workspace_premium,
                                                        color: Colors.white70,
                                                        size: 16,
                                                      ),
                                                      SizedBox(width: 6),
                                                      Text(
                                                        'Highest rank achieved!',
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    '${currentRank.creditsRequired}',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            crossFadeState: isExpanded
                                              ? CrossFadeState.showSecond
                                              : CrossFadeState.showFirst,
                                            duration: const Duration(milliseconds: 300),
                                          ),
                                        
                                        // Spacer that adapts to the expanded state - adjust to keep buttons aligned with bottom
                                        const Expanded(
                                          child: SizedBox(),
                                        ),
                                        
                                        // Action buttons at the bottom - consistent positioning
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(16),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.05),
                                                        blurRadius: 10,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () {
                                                        // Navigate to the rewards page with default tab (Overview)
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => const RewardPage(),
                                                          ),
                                                        );
                                                      },
                                                      borderRadius: BorderRadius.circular(16),
                                                      highlightColor: Colors.transparent,
                                                      splashColor: Colors.transparent,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(
                                                              Icons.wallet_giftcard, 
                                                              color: Provider.of<ThemeService>(context).primaryColor, 
                                                              size: 20,
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              'Redeem',
                                                              style: TextStyle(
                                                                color: Provider.of<ThemeService>(context).accentColor,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(16),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.05),
                                                        blurRadius: 10,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () {
                                                        // Navigate to the reward page with the History tab selected
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => const RewardPage(initialTabIndex: 2),
                                                          ),
                                                        );
                                                      },
                                                      borderRadius: BorderRadius.circular(16),
                                                      highlightColor: Colors.transparent,
                                                      splashColor: Colors.transparent,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(
                                                              Icons.history, 
                                                              color: Provider.of<ThemeService>(context).primaryColor, 
                                                              size: 20,
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              'History',
                                                              style: TextStyle(
                                                                color: Provider.of<ThemeService>(context).accentColor,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Quick actions section header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
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
                                'Quick Actions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.chat_bubble_outlined,
                                label: 'Assistant',
                                color: Colors.purple,
                                onTap: () {
                                  // Navigate to the transit assistant page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const TransitAssistantPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.contactless,
                                label: 'Scan & Pay',
                                color: Colors.teal,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PayForTransitPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.train_rounded,
                                label: 'Your Trips',
                                color: Colors.orange,
                                onTap: () {
                                  // Navigate to the transit history page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const TransitHistoryPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Recent trips section with theme colors
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 5,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: themeService.primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Recent Trips',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const TransitHistoryPage()),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: themeService.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'See All',
                                    style: TextStyle(
                                      color: themeService.primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Get actual trip history from the wallet service
                        Consumer<WalletService>(
                          builder: (context, walletService, child) {
                            final tripHistory = walletService.tripHistory;
                            
                            // If no trips, show a message
                            if (tripHistory.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.directions_bus_outlined,
                                        color: Colors.grey.shade400,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No trips completed yet',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            // Get the latest 3 trips (or less if fewer than 3 trips)
                            final latestTrips = tripHistory.take(3).toList();
                            
                            return Column(
                              children: latestTrips.map((trip) {
                                // Format date for display
                                final date = _formatTripDate(trip.exitTime!);
                                
                                // Format time for display
                                final time = _formatTripTime(trip.exitTime!);
                                
                                // Determine transit type based on station names
                                final isTrain = _isTrainStation(trip.entryStation) || _isTrainStation(trip.exitStation ?? '');
                                
                                return Column(
                                  children: [
                                    _buildTripHistoryCard(
                                      date: date,
                                      route: '${trip.entryStation} → ${trip.exitStation}',
                                      time: time,
                                      points: '+${trip.pointsEarned}',
                                      isTrain: isTrain,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                );
                              }).toList(),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 22),
                        
                        // Deals section with horizontal scrolling cards
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 5,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Deals',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Horizontal scrollable deals cards
                        Container(
                          height: 200,
                          margin: const EdgeInsets.only(bottom: 32),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(right: 16),
                            children: [
                              _buildImageCard('lib/images/card1.png'),
                              const SizedBox(width: 10),
                              _buildImageCard('lib/images/card2.png'),
                              const SizedBox(width: 10),
                              _buildImageCard('lib/images/card3.png'),
                            ],
                          ),
                        ),                        
                        // Cityscape banner
                        _buildCityscapeBanner(),
                        
                        const SizedBox(height: 20),

                        // SDG Impact Card
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SdgImpactPage()),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // SDGs header
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4C9F38).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.eco,
                                            color: Color(0xFF4C9F38),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'SDG Impact',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Your contribution to UN Goals',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.black45,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // SDG impact metrics
                                    Consumer<SdgImpactService>(
                                      builder: (context, impactService, _) {
                                        final impact = impactService.impact;
                                        
                                        return Column(
                                          children: [
                                            // SDG goals row
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                _buildSdgIcon('3', const Color(0xFF4C9F38)),
                                                const SizedBox(width: 12),
                                                _buildSdgIcon('11', const Color(0xFFF99D26)),
                                                const SizedBox(width: 12),
                                                _buildSdgIcon('13', const Color(0xFF48773E)),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            
                                            // Impact stats
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _buildSdgStatItem(
                                                    value: '${impact.co2Saved.toStringAsFixed(1)} kg',
                                                    label: 'CO₂ Saved',
                                                    icon: Icons.cloud_outlined,
                                                    color: const Color(0xFF48773E),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: _buildSdgStatItem(
                                                    value: '${impact.stepsWalked}',
                                                    label: 'Steps Walked',
                                                    icon: Icons.directions_walk,
                                                    color: const Color(0xFF4C9F38),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: _buildSdgStatItem(
                                                    value: '${impact.publicTransitTrips}',
                                                    label: 'Trips',
                                                    icon: Icons.directions_bus,
                                                    color: const Color(0xFFF99D26),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((0.05 * 255).round()),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha((0.2 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(icon, color: color, size: 24),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color.withAlpha((0.9 * 255).round()),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTripHistoryCard({
    required String date,
    required String route,
    required String time,
    required String points,
    bool isTrain = false,
  }) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(40),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withAlpha((0.2 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isTrain ? Icons.train : Icons.directions_bus_filled,
                  color: primaryColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                points,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCityscapeBanner() {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    final accentColor = themeService.accentColor;
    
    // Create lighter versions of the primary color for a more vibrant gradient
    final lighterPrimary = Color.fromARGB(
      255,
      primaryColor.red + ((255 - primaryColor.red) * 0.3).round(),
      primaryColor.green + ((255 - primaryColor.green) * 0.3).round(),
      primaryColor.blue + ((255 - primaryColor.blue) * 0.3).round(),
    );
    
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
        gradient: LinearGradient(
          colors: [lighterPrimary, primaryColor, accentColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background gradient - using more vibrant colors
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      lighterPrimary,
                      primaryColor,
                      accentColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            
            // City silhouette at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'lib/images/city.png', // Cityscape silhouette image
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image fails to load
                  return Container(
                    height: 140,
                    color: Colors.transparent,
                    child: const Center(
                      child: Icon(
                        Icons.location_city,
                        color: Colors.white70,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Overlay content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explore Your City',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Discover amazing places in city',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      'Explore Now',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
  }

  void _showPointsTestDialog(BuildContext context, RewardsService rewardsService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Test Rewards System'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Set points/credits to test different rank levels:'),
              const SizedBox(height: 16),
              _buildPointsButton(context, 'Bronze', 0, rewardsService),
              const SizedBox(height: 8),
              _buildPointsButton(context, 'Silver', 5000, rewardsService),
              const SizedBox(height: 8),
              _buildPointsButton(context, 'Gold', 15000, rewardsService),
              const SizedBox(height: 8),
              _buildPointsButton(context, 'Platinum', 30000, rewardsService),
              const SizedBox(height: 8),
              _buildPointsButton(context, 'Diamond', 50000, rewardsService),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Set custom points value
                  final pointsController = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Enter Custom Points'),
                        content: TextField(
                          controller: pointsController,
                          decoration: const InputDecoration(
                            labelText: 'Points',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final points = int.tryParse(pointsController.text);
                              if (points != null) {
                                rewardsService.setPoints(points);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Set'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text('Custom Points'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPointsButton(BuildContext context, String rank, int points, RewardsService rewardsService) {
    // Get color based on rank
    Color rankColor;
    switch (rank) {
      case 'Bronze':
        rankColor = const Color(0xFFCD7F32);
        break;
      case 'Silver':
        rankColor = const Color(0xFFC0C0C0);
        break;
      case 'Gold':
        rankColor = const Color(0xFFDAA520);
        break;
      case 'Platinum':
        rankColor = const Color(0xFF3F51B5);
        break;
      case 'Diamond':
        rankColor = const Color(0xFF9C27B0);
        break;
      default:
        rankColor = Colors.blue;
    }

    return ElevatedButton(
      onPressed: () {
        rewardsService.setPoints(points);
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: rankColor,
        minimumSize: const Size(double.infinity, 45),
      ),
      child: Text('$rank ($points pts)'),
    );
  }

  // Helper methods for SDG widgets
  Widget _buildSdgIcon(String number, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildSdgStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 22,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // Helper methods for trip date/time formatting
  String _formatTripDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day} ${_getMonthName(date.month)}, ${date.year}';
    }
  }
  
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
  
  String _formatTripTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    
    final hourDisplay = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    
    return '$hourDisplay:$minute $period';
  }

  // Helper method to determine if a station is a train station
  bool _isTrainStation(String stationName) {
    // Keywords that indicate a train station (MRT/LRT)
    final trainKeywords = [
      'MRT', 'LRT', 'Train', 'Rail', 'Metro', 'Subway',
      'Station', 'Terminal', 'Central', 'Junction',
      'Line', 'Interchange', 'Depot', 'Platform',
    ];
    
    // Check if any of the train keywords are in the station name
    return trainKeywords.any((keyword) => 
      stationName.toLowerCase().contains(keyword.toLowerCase()));
  }

  // Helper method to build a blank card

  // Helper method to build an image card
  Widget _buildImageCard(String imagePath) {
    // Card dimensions
    final cardWidth = MediaQuery.of(context).size.width * 0.75;
    final cardHeight = 200.0;
    
    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imagePath,
          width: cardWidth,
          height: cardHeight,
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
        ),
      ),
    );
  }
}
