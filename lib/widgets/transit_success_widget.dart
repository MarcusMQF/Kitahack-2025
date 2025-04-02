import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../models/transit_record.dart';
import '../services/balance_service.dart';
import '../services/theme_service.dart';
import '../utils/date_time_utils.dart';
import '../widgets/transit_detail_item.dart';

class TransitSuccessWidget extends StatelessWidget {
  final TransitRecord currentTrip;
  final bool isExitScan;
  final bool showClaimPoints;
  final VoidCallback onClaimPoints;
  final VoidCallback onReset;

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
    final primaryColor = themeService.primaryColor;
    final secondaryColor = themeService.secondaryColor;
    
    final color = isExitScan ? primaryColor : primaryColor;
    
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
                              isExitScan ? Icons.logout_rounded : Icons.login_rounded,
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
                        isExitScan ? 'Exit Successful' : 'Entry Successful',
                        style: const TextStyle(
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
                isExitScan
                    ? 'You have exited from ${currentTrip.exitStation}'
                    : 'You have entered ${currentTrip.entryStation}',
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
                      if (isExitScan) ...[
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
                                      currentTrip.entryStation,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      currentTrip.exitStation!,
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
                              child: TransitDetailItem(
                                label: 'Fare',
                                value: 'RM ${currentTrip.fare.toStringAsFixed(2)}',
                                icon: Icons.payment,
                                color: secondaryColor,
                              ),
                            ),
                            Expanded(
                              child: TransitDetailItem(
                                label: 'Balance',
                                value: 'RM ${balanceService.balance.toStringAsFixed(2)}',
                                icon: Icons.account_balance_wallet,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        
                        if (showClaimPoints) ...[
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
                                  tween: Tween(begin: 0, end: currentTrip.pointsEarned.toDouble()),
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
                            child: SlideAction(
                              onSubmit: () {
                                onClaimPoints();
                                return Future.value(false);
                              },
                              text: 'Slide to claim points',
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              outerColor: Colors.orange.shade50,
                              innerColor: Colors.orange.shade600,
                              elevation: 0,
                              borderRadius: 30,
                              height: 70,
                              sliderButtonIcon: const Icon(
                                Icons.monetization_on,
                                color: Colors.white,
                              ),
                              submittedIcon: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              sliderRotate: false,
                            ),
                          ),
                        ],
                      ] else ...[
                        // Entry details
                        TransitDetailItem(
                          label: 'Station',
                          value: currentTrip.entryStation,
                          icon: Icons.train,
                          color: primaryColor,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TransitDetailItem(
                          label: 'Time',
                          value: DateTimeUtils.formatTime(currentTrip.entryTime),
                          icon: Icons.access_time,
                          color: secondaryColor,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TransitDetailItem(
                          label: 'Wallet Balance',
                          value: 'RM ${balanceService.balance.toStringAsFixed(2)}',
                          icon: Icons.account_balance_wallet,
                          color: primaryColor,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Done button with updated styling to match top_up_page.dart
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: onReset,
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
} 