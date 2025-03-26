import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'profile_page.dart';
// ignore: unused_import
import 'dart:io';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../components/animated_progress_bar.dart';
import '../utils/api_keys.dart'; // Import API keys utilities

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
  };
  String currentWeather = '😊';
  String temperature = '28°C';
  String cityName = 'Loading...';
  bool isExpanded = false;
  final WeatherService _weatherService = WeatherService(apiKey: ApiKeys.weatherApiKey); // Use from ApiKeys class
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
          currentWeather = weatherIcons[weather.weather] ?? '😊';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          cityName = 'Error';
          temperature = 'N/A';
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
                                    fontSize: 15, 
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ProfileData.username.split(' ')[0], // Just show first name
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
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
                                        backgroundColor: Colors.blue.withAlpha((0.2 * 255).round()),
                                        child: const Icon(Icons.person, color: Colors.blue, size: 26),
                                      );
                                    }
                                  } else {
                                    return CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.blue.withAlpha((0.2 * 255).round()),
                                      child: const Icon(Icons.person, color: Colors.blue, size: 26),
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
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withAlpha(60),
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
                                                  'Keep the planet green!',
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
                                                    child: const Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.eco, color: Colors.white, size: 14),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          'Level 2',
                                                          style: TextStyle(
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
                                          child: TweenAnimationBuilder<double>(
                                            tween: Tween<double>(begin: 0, end: 1),
                                            duration: const Duration(milliseconds: 800),
                                            curve: Curves.easeOutCubic,
                                            builder: (context, value, child) {
                                              return Transform.scale(
                                                scale: 0.6 + (value * 0.4), // Scale from 0.6 to 1.0 instead of 0 to 1
                                                child: child,
                                              );
                                            },
                                            child: const Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '3,250',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 40,
                                                    fontWeight: FontWeight.bold,
                                                    height: 0.9,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: 6),
                                                  child: Text(
                                                    'Points',
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        
                                        // Progress indicator (shown only when expanded)
                                        AnimatedProgressBar(
                                          progress: 0.75, // 75% progress (3250 out of 4000)
                                          maxValue: 4000, // Target value
                                          currentValue: 3250, // Current points
                                          isExpanded: isExpanded,
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
                                                      onTap: () {},
                                                      borderRadius: BorderRadius.circular(16),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            const Icon(
                                                              Icons.wallet_giftcard, 
                                                              color: Colors.blue, 
                                                              size: 20,
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              'Redeem',
                                                              style: TextStyle(
                                                                color: Colors.blue.shade800,
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
                                                      onTap: () {},
                                                      borderRadius: BorderRadius.circular(16),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(
                                                              Icons.history, 
                                                              color: Colors.blue.shade700, 
                                                              size: 20,
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              'History',
                                                              style: TextStyle(
                                                                color: Colors.blue.shade800,
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
                        
                        const SizedBox(height: 25),
                        
                        // Quick actions section header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 5,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
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
                                icon: Icons.directions_bus,
                                label: 'Find Bus',
                                color: Colors.blue,
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.map,
                                label: 'Routes',
                                color: Colors.green,
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.credit_card,
                                label: 'Top Up',
                                color: Colors.orange,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Nearby buses section
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
                                      color: Colors.blue.shade600,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Nearby Buses',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.blue.shade100,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Live updates',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildBusCard(
                          busNumber: 'B1',
                          from: 'UM Central',
                          to: 'Shopping Mall',
                          time: '5 min',
                          crowdLevel: 'Low',
                          distance: '350m',
                          isPulsing: false,
                        ),
                        const SizedBox(height: 12),
                        _buildBusCard(
                          busNumber: 'A3',
                          from: 'Market Place',
                          to: 'Business District',
                          time: '12 min',
                          crowdLevel: 'Medium',
                          distance: '750m',
                          isPulsing: false,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Recent trips
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
                                      color: Colors.blue.shade600,
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'See All',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTripHistoryCard(
                          date: 'Today',
                          route: 'Central Station → Downtown',
                          time: '10:30 AM',
                          points: '+125',
                        ),
                        const SizedBox(height: 12),
                        _buildTripHistoryCard(
                          date: 'Yesterday',
                          route: 'Airport → Central Station',
                          time: '7:45 PM',
                          points: '+200',
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Cityscape banner
                        _buildCityscapeBanner(),
                        
                        const SizedBox(height: 20),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((0.15 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 3),
              spreadRadius: 0,
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
  
  Widget _buildBusCard({
    required String busNumber,
    required String from,
    required String to,
    required String time,
    required String crowdLevel,
    required String distance,
    required bool isPulsing,
  }) {
    Color crowdColor;
    if (crowdLevel == 'Low') {
      crowdColor = Colors.green;
    } else if (crowdLevel == 'Medium') {
      crowdColor = Colors.orange;
    } else {
      crowdColor = Colors.red;
    }
    
    // Ensure every bus card has a visible identifier
    String displayBusNumber = busNumber.isEmpty ? "B1" : busNumber;
    
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
                color: Colors.blue.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withAlpha((0.2 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: isPulsing
                ? TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 1.0, end: 1.15),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          final pulseValue = 1.0 + 0.1 * math.sin(_controller.value * math.pi * 2);
                          return Transform.scale(
                            scale: pulseValue,
                            child: child,
                          );
                        },
                        child: Center(
                          child: Text(
                            displayBusNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      displayBusNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 20,
                      ),
                    ),
                  ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        from,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPulsing ? Colors.blue.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPulsing ? Colors.blue.shade100 : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          distance,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isPulsing ? Colors.blue.shade700 : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.arrow_downward,
                          size: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        to,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPulsing ? Colors.blue.shade600 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isPulsing ? [
                      BoxShadow(
                        color: Colors.blue.withAlpha((0.2 * 255).round()),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                        spreadRadius: -2,
                      ),
                    ] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isPulsing 
                        ? TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return AnimatedBuilder(
                                animation: _controller,
                                builder: (context, _) {
                                  final pulseValue = 1.0 + 0.2 * math.sin(_controller.value * math.pi);
                                  return Transform.scale(
                                    scale: pulseValue,
                                    child: child,
                                  );
                                },
                                child: const Icon(Icons.directions_bus, color: Colors.white, size: 14),
                              );
                            },
                          )
                        : Icon(Icons.timer, color: Colors.blue.shade600, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          color: isPulsing ? Colors.white : Colors.blue.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: crowdColor.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: crowdColor.withAlpha((0.3 * 255).round()),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, size: 14, color: crowdColor),
                      const SizedBox(width: 4),
                      Text(
                        crowdLevel,
                        style: TextStyle(
                          color: crowdColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
    );
  }
  
  Widget _buildTripHistoryCard({
    required String date,
    required String route,
    required String time,
    required String points,
  }) {
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
                color: Colors.blue.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withAlpha((0.2 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_bus_filled,
                  color: Colors.blue,
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
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade800,
                      Colors.blue.shade600,
                      Colors.blue.shade300,
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
                    color: Colors.blue.shade900,
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
                    child: const Text(
                      'Explore Now',
                      style: TextStyle(
                        color: Colors.blue,
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
}
