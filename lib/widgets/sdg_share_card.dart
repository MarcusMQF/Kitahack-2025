import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sdg_impact_service.dart';

class SdgShareCard extends StatelessWidget {
  const SdgShareCard({super.key});

  @override
  Widget build(BuildContext context) {
    final impactService = Provider.of<SdgImpactService>(context);
    final impact = impactService.impact;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.86,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Handle and title
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Share Your SDG Impact',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Share preview card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              child: Column(
                children: [
                  _buildSharePreview(impact, context),
                  const SizedBox(height: 32),

                  // Share options
                  const Text(
                    'Share to',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 22),

                  _buildShareOptions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSharePreview(dynamic impact, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with app logo and name
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Image.asset(
                    'lib/images/TransitGo.png',
                    width: 28,
                    height: 28,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback icon if image can't be loaded
                      return const Icon(
                        Icons.directions_transit,
                        color: Colors.blue,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'TransitGo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // QR code placeholder (in actual app, generate QR for app download)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.qr_code,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // SDG impact title
          const Text(
            'My Sustainable Development Impact',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // SDG impact metrics
          _buildImpactMetric(
            icon: Icons.eco,
            title: 'CO₂ Saved',
            value: '${impact.co2Saved.toStringAsFixed(1)} kg',
            subtitle: 'SDG 13: Climate Action',
          ),
          
          const SizedBox(height: 16),
          
          _buildImpactMetric(
            icon: Icons.directions_walk,
            title: 'Steps Walked',
            value: '${impact.stepsWalked}',
            subtitle: 'SDG 3: Good Health',
          ),
          
          const SizedBox(height: 16),
          
          _buildImpactMetric(
            icon: Icons.directions_bus,
            title: 'Transit Trips',
            value: '${impact.publicTransitTrips}',
            subtitle: 'SDG 11: Sustainable Cities',
          ),
          
          const SizedBox(height: 24),
          
          // Join me message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Join me in reducing carbon emissions!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImpactMetric({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildShareOptions() {
    final platforms = [
      {'name': 'Instagram', 'icon': Icons.camera_alt},
      {'name': 'Twitter', 'icon': Icons.chat_bubble_outline},
      {'name': 'Facebook', 'icon': Icons.facebook},
      {'name': 'WhatsApp', 'icon': Icons.chat},
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: platforms.map((platform) {
        return Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                platform['icon'] as IconData,
                color: Colors.grey.shade700,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              platform['name'] as String,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 12,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
} 