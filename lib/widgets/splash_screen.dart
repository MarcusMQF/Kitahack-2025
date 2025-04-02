import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../utils/lottie_cache.dart' as cache;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _currentPage = 0;
  final int _totalPages = 4;
  bool _isLastPage = false;

  // Define colours
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color primaryGrey = Color(0xFF424242);
  static const Color secondaryGrey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color backgroundColor = primaryWhite;

  @override
  void initState() {
    super.initState();

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _animationController.forward();
    });

    // Add page change listener
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
        _isLastPage = _currentPage == _totalPages - 1;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToWelcomePage() {
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.animateToPage(
          _currentPage + 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut
      );
    } else {
      _navigateToWelcomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Main page view
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            children: [
              // New Intro page with logo and title animation
              _buildIntroPage(),
              // Real-time Transit Updates with Lottie animation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Feature title
                    const SizedBox(height: 120),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        "Real-time Transit Updates",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Lottie Animation in the middle
                    Expanded(
                      flex: 4,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Center(
                            child: cache.LottieCache().getLottieWidget(
                              url: cache.LottieCache.transitUpdatesUrl,
                              width: 300,
                              height: 300,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Feature description
                    const SizedBox(height: 0),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        "Get live updates about bus arrivals, departures and route changes in your city.",
                        style: TextStyle(
                          fontSize: 16,
                          color: secondaryGrey,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Space for bottom buttons
                    const Expanded(flex: 2, child: SizedBox()),
                  ],
                ),
              ),
              // Earn Green Points with Lottie animation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Feature title
                    const SizedBox(height: 120),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        "Earn Green Points",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Lottie Animation in the middle
                    Expanded(
                      flex: 4,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Center(
                            child: cache.LottieCache().getLottieWidget(
                              url: cache.LottieCache.greenPointsUrl,
                              width: 300,
                              height: 300,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Feature description
                    const SizedBox(height: 0),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        "Reduce your carbon footprint by using public transportation and earn reward points.",
                        style: TextStyle(
                          fontSize: 16,
                          color: secondaryGrey,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Space for bottom buttons
                    const Expanded(flex: 2, child: SizedBox()),
                  ],
                ),
              ),
              // NFC Scan and Pay with Lottie animation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Feature title
                    const SizedBox(height: 120),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        "NFC Scan and Pay",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Lottie Animation in the middle
                    Expanded(
                      flex: 4,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Center(
                            child: cache.LottieCache().getLottieWidget(
                              url: cache.LottieCache.nfcScanUrl,
                              width: 420,
                              height: 420,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Feature description
                    const SizedBox(height: 0),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        "Say goodbye to cards and wallets! Tap with a single phone and get into transit!",
                        style: TextStyle(
                          fontSize: 16,
                          color: secondaryGrey,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Space for bottom buttons
                    const Expanded(flex: 2, child: SizedBox()),
                  ],
                ),
              ),
            ],
          ),

          // Bottom navigation buttons and indicators
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _totalPages,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 10,
                      width: _currentPage == index ? 30 : 10,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? primaryBlue : lightGrey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Next or Get Started button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: primaryWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isLastPage ? "Get Started" : "Next",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildIntroPage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo with animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: primaryBlue.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'lib/images/TransitGo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // App title with typing animation
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Text(
                          'TransitGo',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: primaryGrey,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  FutureBuilder(
                    future: Future.delayed(const Duration(milliseconds: 800)),
                    builder: (context, snapshot) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: snapshot.connectionState == ConnectionState.done ? 1.0 : 0.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: const Text(
                              'Smart commuting for a greener tomorrow',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: secondaryGrey,
                                height: 1.5,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}