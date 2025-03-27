import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _isFlashlightOn = false;
  final MobileScannerController _scannerController = MobileScannerController();
  String? _lastScanned;
  bool _showSuccessAnimation = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _toggleFlashlight() {
    setState(() {
      _isFlashlightOn = !_isFlashlightOn;
      _scannerController.toggleTorch();
    });
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final String code = barcodes.first.rawValue!;
      
      // Avoid processing the same QR code multiple times in succession
      if (_lastScanned == code) return;
      
      _lastScanned = code;
      
      setState(() {
        _showSuccessAnimation = true;
      });
      
      // Turn frame green for 1 second, then show dialog
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _showSuccessAnimation = false;
          });
          
          // Show success dialog after animation completes
          _showSuccessDialog(code);
        }
      });
    }
  }

  // Function to launch a URL
  Future<void> _launchUrl(String url) async {
    // Make sure URL has proper formatting
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    try {
      final Uri uri = Uri.parse(url);
      // Launch URL directly without canLaunchUrl check
      if (!mounted) return;
      
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // Show error on exception
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the link. Check if you have a browser installed.'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(String code) {
    // Better URL detection with regex
    final urlRegExp = RegExp(
      r'^(https?:\/\/)?([\w\-]+(\.[\w\-]+)+)([\/?#]\S*)?$',
      caseSensitive: false,
    );
    bool isUrl = urlRegExp.hasMatch(code);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue,
                      AppTheme.secondaryBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Successful Scan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isUrl ? 'URL Detected' : 'QR Code Detected',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Content section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scanned Content:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.primaryGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              code,
                              style: const TextStyle(
                                color: AppTheme.secondaryGrey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.copy,
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: code)).then((_) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied to clipboard'),
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              });
                            },
                            tooltip: 'Copy to clipboard',
                          ),
                        ],
                      ),
                    ),
                    
                    if (isUrl) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'The scanned code contains a URL. Would you like to open it?',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action buttons
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.secondaryGrey,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        if (isUrl) {
                          _launchUrl(code);
                        } else {
                          // Handle check-in functionality here
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Check-in successful'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      icon: Icon(
                        isUrl ? Icons.open_in_browser : Icons.check_circle_outline,
                        size: 18,
                      ),
                      label: Text(isUrl ? 'Open Link' : 'Check In'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            color: AppTheme.primaryGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGrey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Scanner View
          ClipRRect(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            ),
          ),
          
          // Overlay elements
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Scanner frame - positioned to match the camera overlay
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _showSuccessAnimation 
                            ? Colors.green 
                            : Colors.white,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: _showSuccessAnimation
                        ? Center(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: 0.8,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Instructions and flashlight button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Position the QR code within the frame',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _toggleFlashlight,
                        icon: Icon(
                          _isFlashlightOn ? Icons.flash_off : Icons.flash_on,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          _isFlashlightOn ? 'Turn off flashlight' : 'Turn on flashlight',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 