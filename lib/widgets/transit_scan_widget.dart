import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import 'package:provider/provider.dart';

class TransitScanWidget extends StatelessWidget {
  final bool isExitScanMode;
  final bool isScanning;
  final VoidCallback onScanPressed;

  const TransitScanWidget({
    Key? key,
    required this.isExitScanMode,
    required this.isScanning,
    required this.onScanPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  if (isScanning) ...[
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
                          spreadRadius: isScanning ? 10 : 2,
                        ),
                      ],
                      border: Border.all(
                        color: color.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: isScanning
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
                isScanning
                    ? 'Scanning...'
                    : isExitScanMode 
                        ? 'Tap your phone to exit the station'
                        : 'Tap your phone to the station reader',
                style: const TextStyle(
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
              
              // Action button
              if (!isScanning)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onScanPressed,
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
    );
  }
} 