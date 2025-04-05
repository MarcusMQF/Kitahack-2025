import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/balance_service.dart';
import 'dart:math' as math;
import '../widgets/particle_background.dart';
import 'top_up_page.dart';
import 'transaction_history_page.dart';
import '../services/wallet_service.dart';

class EWalletPage extends StatefulWidget {
  const EWalletPage({super.key});

  @override
  State<EWalletPage> createState() => _EWalletPageState();
}

class _EWalletPageState extends State<EWalletPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    final currentScroll = _scrollController.position.pixels;
    final showButton = currentScroll > 200;
    
    if (showButton != _showFloatingButton) {
      setState(() {
        _showFloatingButton = showButton;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    final secondaryColor = themeService.secondaryColor;
    final balanceService = Provider.of<BalanceService>(context);
    final walletService = Provider.of<WalletService>(context);
    
    // Show loading indicator while services initialize
    if (!balanceService.isInitialized || !walletService.isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading your wallet data...',
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
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'E-Wallet',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _showFloatingButton ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          onPressed: () {
            _showTopUpDialog(context, primaryColor);
          },
          backgroundColor: primaryColor,
          child: const Icon(Icons.add),
        ),
      ),
      body: Stack(
        children: [
          // Gradient background at top
          Container(
            height: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // White background for rest of the content
          Positioned(
            top: 260,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance card with animated balance
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _buildBalanceCard(primaryColor, secondaryColor),
                  ),
                  
                  // Card section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        const SizedBox(height: 24),
 
                        // Recent transactions section
                        Row(
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
                                  'Recent Transactions',
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
                                  MaterialPageRoute(
                                    builder: (context) => ChangeNotifierProvider.value(
                                      value: Provider.of<BalanceService>(context, listen: false),
                                      child: const TransactionHistoryPage(),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              child: Text(
                                'See All',
                                style: TextStyle(
                                  color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Transactions list with real data
                        Consumer<BalanceService>(
                          builder: (context, balanceService, child) {
                            final transactions = balanceService.recentTransactions;
                            
                            if (transactions.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.receipt_long,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No transactions yet',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            return Column(
                              children: [
                                ...transactions.take(5).map((transaction) {
                                  final amount = transaction.isDebit
                                      ? '-RM ${transaction.amount.toStringAsFixed(2)}'
                                      : '+RM ${transaction.amount.toStringAsFixed(2)}';
                                  
                                  // Format date
                                  final now = DateTime.now();
                                  final today = DateTime(now.year, now.month, now.day);
                                  final yesterday = today.subtract(const Duration(days: 1));
                                  final txDate = DateTime(
                                    transaction.date.year,
                                    transaction.date.month,
                                    transaction.date.day,
                                  );
                                  
                                  String formattedDate;
                                  if (txDate == today) {
                                    formattedDate = 'Today, ${_formatTime(transaction.date)}';
                                  } else if (txDate == yesterday) {
                                    formattedDate = 'Yesterday, ${_formatTime(transaction.date)}';
                                  } else {
                                    formattedDate = '${transaction.date.day} ${_getMonthName(transaction.date.month)}, ${_formatTime(transaction.date)}';
                                  }
                                  
                                  // Get icon
                                  IconData icon;
                                  switch (transaction.iconType) {
                                    case IconType.bus:
                                      icon = Icons.directions_bus;
                                      break;
                                    case IconType.wallet:
                                      icon = Icons.account_balance_wallet;
                                      break;
                                    case IconType.transfer:
                                      icon = Icons.swap_horiz;
                                      break;
                                    case IconType.payment:
                                      icon = Icons.payment;
                                      break;
                                    case IconType.train:
                                      icon = Icons.train;
                                      break;
                                  }
                                  
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
                                          color: Colors.grey.withOpacity(0.05),
                                          blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTransactionDetails(
            context, 
                                          transaction.title, 
            amount, 
                                          formattedDate, 
            icon, 
                                          transaction.isDebit, 
                                          primaryColor
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Transaction icon
                Container(
                                                width: 45,
                                                height: 45,
                  decoration: BoxDecoration(
                                                  color: transaction.isDebit ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: (transaction.isDebit ? Colors.red : Colors.green).withOpacity(0.1),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                      spreadRadius: -2,
                                                    ),
                                                  ],
                  ),
                  child: Icon(
                    icon,
                                                  color: transaction.isDebit ? Colors.red : Colors.green,
                                                  size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                
                // Transaction details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                                                      transaction.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                                                      formattedDate,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                
                                              // Amount
                                              Text(
                                                amount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                                                  color: transaction.isDebit ? Colors.red : Colors.green,
                                                ),
                ),
              ],
            ),
          ),
        ),
                                    ),
                                  );
                                }).toList(),
                                // Add gap at the bottom
                                const SizedBox(height: 24),
                              ],
                            );
                          },
                        ),
                        
                        // Remove the special offers section
                        // const SizedBox(height: 24),
                        
                        // _buildPromotionsSection(primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(Color primaryColor, Color secondaryColor) {
    // Create a more contrasting gradient that still uses theme colors
    final cardGradientStart = Color.lerp(primaryColor, Colors.white, 0.15)!;
    final cardGradientEnd = Color.lerp(secondaryColor, Colors.white, 0.1)!;
    
    return Hero(
      tag: 'balance_card',
      child: CardTiltEffect(
        depth: 15.0,
        child: Stack(
          children: [
            // Add particle background inside the card with better animation
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ParticleBackground(
                  particleCount: 15,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.5),
                  ],
                  maxRadius: 2.5,
                  maxSpeed: 0.5,
                  child: const SizedBox(),
                ),
              ),
            ),
            
            // Card with shimmer gradient overlay for subtle animation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cardGradientStart, cardGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: cardGradientEnd.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RM',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Consumer<BalanceService>(
                        builder: (context, balanceService, child) {
                          return ShimmerText(
                            text: balanceService.balance.toStringAsFixed(2),
                            style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        baseColor: Colors.white,
                        highlightColor: Colors.white,
                        isEnabled: true,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Card Number section
                  Row(
                    children: [
                      Icon(
                        Icons.payment,
                        color: Colors.white.withOpacity(0.8),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const ShimmerText(
                        text: '1300 6051 5517',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                        baseColor: Colors.white70,
                        highlightColor: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Top Up button with pulse animation
                  Center(
                    child: Container(
                      width: 180,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => _showTopUpDialog(context, primaryColor),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle,
                                color: cardGradientStart,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Top Up',
                                style: TextStyle(
                                  color: cardGradientStart,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
          ],
        ),
      ),
    );
  }

  void _showTopUpDialog(BuildContext context, Color primaryColor) {
    // Navigate to the dedicated TopUpPage instead of showing a bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TopUpPage()),
    );
  }
  
  void _showTransactionDetails(BuildContext context, String title, String amount, String date, IconData icon, bool isDebit, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Transaction icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isDebit ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isDebit ? Colors.red : Colors.green,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Amount
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDebit ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Title and date
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Transaction details
                _buildTransactionDetailRow('Transaction ID', '#TRX${date.hashCode.abs()}'),
                const SizedBox(height: 8),
                _buildTransactionDetailRow('Status', 'Completed'),
                const SizedBox(height: 8),
                _buildTransactionDetailRow('Method', 'Transit Go Card'),
                const SizedBox(height: 24),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Receipt saved to gallery'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Save Receipt'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Receipt shared'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTransactionDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Helper methods for formatting dates
  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final int particleCount = 30;
  final math.Random random = math.Random(42); // Fixed seed for consistent pattern
  
  ParticlePainter({required this.animationValue, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particleCount; i++) {
      final x = size.width * (0.1 + 0.8 * random.nextDouble()) + 
                20 * math.sin((animationValue * 0.2 + i * 0.1) * math.pi * 2);
      
      final y = (i / particleCount) * size.height * 0.8 + 
                10 * math.cos((animationValue * 0.2 + i * 0.1) * math.pi * 2);
      
      final radius = 1.0 + random.nextDouble() * 2.5;
      final opacity = 0.1 + 0.2 * random.nextDouble();
      
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Color baseColor;
  final Color highlightColor;
  final bool isEnabled;

  const ShimmerText({
    super.key,
    required this.text,
    required this.style,
    required this.baseColor,
    required this.highlightColor,
    this.isEnabled = true,
  });

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1500));
  }
  
  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return Text(
        widget.text,
        style: widget.style,
      );
    }
    
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: _SlidingGradientTransform(
                slidePercent: _shimmerController.value
              ),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style,
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  
  const _SlidingGradientTransform({
    required this.slidePercent,
  });
  
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class AnimatedCounter extends StatefulWidget {
  final double value;
  final TextStyle style;
  final Duration duration;
  final String prefix;
  
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 1500),
    this.prefix = "",
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _oldValue;
  
  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(
      begin: _oldValue,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _oldValue,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.reset();
      _controller.forward();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix}${_animation.value.toStringAsFixed(2)}',
          style: widget.style,
        );
      },
    );
  }
}

class CardTiltEffect extends StatefulWidget {
  final Widget child;
  final double depth;
  
  const CardTiltEffect({
    super.key,
    required this.child,
    this.depth = 30.0,
  });

  @override
  State<CardTiltEffect> createState() => _CardTiltEffectState();
}

class _CardTiltEffectState extends State<CardTiltEffect> {
  double _rotateX = 0;
  double _rotateY = 0;
  double _scale = 1;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final size = box.size;
        final position = details.localPosition;
        
        setState(() {
          // Calculate rotation based on pointer position
          _rotateY = ((position.dx / size.width) - 0.5) * widget.depth;
          _rotateX = -((position.dy / size.height) - 0.5) * widget.depth;
          _scale = 1.05; // Slightly enlarge when interacting
        });
      },
      onPanEnd: (_) {
        setState(() {
          // Reset rotation and scale when interaction ends
          _rotateX = 0;
          _rotateY = 0;
          _scale = 1.0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutQuad,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective
          ..rotateX(_rotateX * (math.pi / 180))
          ..rotateY(_rotateY * (math.pi / 180))
          ..scale(_scale),
        child: widget.child,
      ),
    );
  }
}