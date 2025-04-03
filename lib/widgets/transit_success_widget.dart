import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../models/transit_record.dart';
import '../services/balance_service.dart';
import '../services/theme_service.dart';
import '../services/rewards_service.dart';
import '../utils/date_time_utils.dart';

class TransitSuccessWidget extends StatelessWidget {
  final TransitRecord currentTrip;
  final bool isExitScan;
  final bool showClaimPoints;
  final VoidCallback onClaimPoints;
  final VoidCallback onReset;

  // ignore: use_super_parameters
  const TransitSuccessWidget({
    Key? key,
    required this.currentTrip,
    required this.isExitScan,
    required this.showClaimPoints,
    required this.onClaimPoints,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final balanceService = Provider.of<BalanceService>(context);
    final themeService = Provider.of<ThemeService>(context);
    Provider.of<RewardsService>(context);
    final primaryColor = themeService.primaryColor;
    final secondaryColor = themeService.secondaryColor;
    
    final color = isExitScan ? primaryColor : primaryColor;
    
    return Container(
      color: Colors.white,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                
                // Success animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                              border: Border.all(
                                color: color,
                                width: 3,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  isExitScan ? Icons.logout_rounded : Icons.login_rounded,
                                  size: 40,
                                  color: color,
                                ),
                                Positioned(
                                  right: 5,
                                  bottom: 5,
                                  child: AnimatedOpacity(
                                    opacity: value > 0.7 ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: color,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: color.withOpacity(0.3),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.check,
                                          size: 16,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
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
                          isExitScan ? 'Exit Successful' : 'Entry Successful',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Subtitle with station info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    isExitScan
                        ? 'You have exited from ${currentTrip.exitStation}'
                        : 'You have entered ${currentTrip.entryStation}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // ENHANCED DESIGN: Trip details card with modern design
                if (isExitScan) ...[
                  _buildCompactTripSummaryCard(context, primaryColor, secondaryColor),
                ] else ...[
                  // Entry details card - improved design
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Station info
                        _buildEntryDetailItem(
                          label: 'Station',
                          value: currentTrip.entryStation,
                          icon: Icons.train_rounded,
                          color: primaryColor,
                        ),
                        
                        const Divider(height: 1, indent: 70, endIndent: 20),
                        
                        // Time info
                        _buildEntryDetailItem(
                          label: 'Time',
                          value: DateTimeUtils.formatTime(currentTrip.entryTime),
                          icon: Icons.access_time_rounded,
                          color: secondaryColor,
                        ),
                        
                        const Divider(height: 1, indent: 70, endIndent: 20),
                        
                        // Wallet balance
                        _buildEntryDetailItem(
                          label: 'Wallet Balance',
                          value: 'RM ${balanceService.balance.toStringAsFixed(2)}',
                          icon: Icons.account_balance_wallet_rounded,
                          color: primaryColor,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Done button with updated styling
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: onReset,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
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
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildCompactTripSummaryCard(BuildContext context, Color primaryColor, Color secondaryColor) {
    Provider.of<RewardsService>(context, listen: false);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top header section with Trip Summary and Completed badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trip Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF303030),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F4FF),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF2196F3),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Route information section - more compact
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
                bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                // From section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FROM',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9E9E9E),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentTrip.entryStation,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF303030),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateTimeUtils.formatTime(currentTrip.entryTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow connector
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF9E9E9E),
                    size: 20,
                  ),
                ),
                
                // Destination section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'TO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9E9E9E),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentTrip.exitStation!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF303030),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateTimeUtils.formatTime(currentTrip.exitTime!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Trip details grid - 2x2 in a more compact layout
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Left column: Duration and Distance
                Expanded(
                  child: Column(
                    children: [
                      // Duration
                      _buildCompactTripDetailItem(
                        icon: Icons.timer_outlined,
                        iconColor: const Color(0xFF40C4FF),
                        iconBgColor: const Color(0xFFE1F5FE),
                        label: 'Duration',
                        value: _formatDuration(
                          currentTrip.exitTime!.difference(currentTrip.entryTime),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Distance
                      _buildCompactTripDetailItem(
                        icon: Icons.route_rounded,
                        iconColor: const Color(0xFFAB47BC),
                        iconBgColor: const Color(0xFFF3E5F5),
                        label: 'Distance',
                        value: '5.2 km',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Right column: Fare and Line
                Expanded(
                  child: Column(
                    children: [
                      // Fare
                      _buildCompactTripDetailItem(
                        icon: Icons.attach_money_rounded,
                        iconColor: const Color(0xFF66BB6A),
                        iconBgColor: const Color(0xFFE8F5E9),
                        label: 'Fare',
                        value: 'RM ${currentTrip.fare.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      // Line
                      _buildCompactTripDetailItem(
                        icon: Icons.train_rounded,
                        iconColor: const Color(0xFF546E7A),
                        iconBgColor: const Color(0xFFECEFF1),
                        label: 'Line',
                        value: 'MRT Kajang',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Points and Credits earned section with slide to claim
          if (showClaimPoints) ...[
            _buildRewardsClaimSection(context, primaryColor),
          ] else ...[
            // Done button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: onReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildRewardsClaimSection(BuildContext context, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade50,
            Colors.blue.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Points and Credits section in a row
            Row(
              children: [
                // Points
                Expanded(
                  child: _buildRewardTypeBox(
                    icon: Icons.star_rounded,
                    iconColor: Colors.amber.shade700,
                    bgColor: Colors.amber.shade50,
                    label: 'Reward Points',
                    value: '${currentTrip.pointsEarned}',
                    description: 'for rewards',
                  ),
                ),
                const SizedBox(width: 12),
                // Credits
                Expanded(
                  child: _buildRewardTypeBox(
                    icon: Icons.diamond_rounded,
                    iconColor: Colors.purple.shade700,
                    bgColor: Colors.purple.shade50,
                    label: 'TransitGo Credits',
                    value: '${currentTrip.creditsEarned}',
                    description: 'for rank progress',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Claim slider with pulsing animation
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: SlideAction(
                text: 'Slide to claim rewards',
                textStyle: const TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                outerColor: const Color.fromARGB(255, 255, 255, 255),
                innerColor: primaryColor,
                sliderButtonIcon: _PulsingButton(
                  color: primaryColor,
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                sliderRotate: false,
                borderRadius: 16,
                elevation: 0,
                height: 50,
                sliderButtonIconPadding: 10,
                sliderButtonYOffset: -5,
                submittedIcon: Icon(
                  Icons.check,
                  color: primaryColor,
                  size: 22,
                ),
                onSubmit: () {
                  onClaimPoints();
                  return Future.value(false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRewardTypeBox({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 10,
                    color: iconColor.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompactTripDetailItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF303030),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '$hours h $minutes min';
    } else {
      return '$minutes min';
    }
  }
  
  // Helper method for entry detail items
  Widget _buildEntryDetailItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Column(
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
          const Spacer(),
        ],
      ),
    );
  }
}

// Add a pulsing animation widget for the slide button
class _PulsingButton extends StatefulWidget {
  final Color color;
  final Widget child;

  const _PulsingButton({
    required this.color,
    required this.child,
  });

  @override
  State<_PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<_PulsingButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.3),
                  blurRadius: 8 * _scaleAnimation.value,
                  spreadRadius: 1 * _scaleAnimation.value,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
} 