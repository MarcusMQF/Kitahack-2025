import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/sdg_impact_service.dart';
import '../services/theme_service.dart';
import '../widgets/sdg_impact_tile.dart';
import '../widgets/sdg_share_card.dart';

class SdgImpactPage extends StatefulWidget {
  const SdgImpactPage({super.key});

  @override
  State<SdgImpactPage> createState() => _SdgImpactPageState();
}

class _SdgImpactPageState extends State<SdgImpactPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  
  // SDG colors
  static const Color sdg3Color = Color(0xFF4C9F38); // Good Health & Well-being
  static const Color sdg11Color = Color(0xFFF99D26); // Sustainable Cities
  static const Color sdg13Color = Color(0xFF48773E); // Climate Action
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeService>(context);
    final impactService = Provider.of<SdgImpactService>(context);
    final impact = impactService.impact;
    
    // Format numbers
    final formatter = NumberFormat("#,##0");
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Your SDG Impact',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const SdgShareCard(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // SDGs introduction card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sustainable Development Goals',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your use of public transportation contributes to the UN\'s Sustainable Development Goals. Below is your personal impact:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSdgIconBox('3', sdg3Color, 'Good Health & Well-being'),
                        const SizedBox(width: 10),
                        _buildSdgIconBox('11', sdg11Color, 'Sustainable Cities'),
                        const SizedBox(width: 10),
                        _buildSdgIconBox('13', sdg13Color, 'Climate Action'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Climate Action (SDG 13)
            SdgImpactTile(
              title: 'SDG 13: Climate Action',
              subtitle: 'CO₂ emissions reduced',
              color: sdg13Color,
              icon: Icons.eco,
              value: '${impact.co2Saved.toStringAsFixed(1)} kg',
              description: 'Equivalent to planting ${impact.treesEquivalent.toStringAsFixed(1)} trees',
              chartData: [
                impact.co2Saved,
                50 // Target goal to show progress
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Good Health & Well-being (SDG 3)
            SdgImpactTile(
              title: 'SDG 3: Good Health',
              subtitle: 'Steps walked',
              color: sdg3Color,
              icon: Icons.directions_walk,
              value: formatter.format(impact.stepsWalked),
              description: '${formatter.format(impact.caloriesBurned)} calories burned',
              chartData: [
                impact.stepsWalked.toDouble(),
                100000 // Target goal to show progress
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Sustainable Cities (SDG 11)
            SdgImpactTile(
              title: 'SDG 11: Sustainable Cities',
              subtitle: 'Public transit trips',
              color: sdg11Color,
              icon: Icons.directions_bus,
              value: formatter.format(impact.publicTransitTrips),
              description: 'Reduced urban congestion by ${impact.congestionReduction.toStringAsFixed(1)}%',
              chartData: [
                impact.publicTransitTrips.toDouble(),
                50 // Target goal to show progress
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Transit type breakdown
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Transit Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTransitTypeBreakdown(impact.transitTypeBreakdown),
                  const SizedBox(height: 16),
                  Text(
                    'Total distance traveled: ${impact.distanceTraveled.toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Personal Impact Report
            _buildImpactSummary(impactService),
            
            const SizedBox(height: 72), // Bottom padding
          ],
        ),
      ),
    );
  }
  
  Widget _buildSdgIconBox(String number, Color color, String title) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTransitTypeBreakdown(Map<String, double> breakdown) {
    final transitTypes = {
      'bus': {
        'icon': Icons.directions_bus,
        'color': Colors.amber.shade700,
        'label': 'Bus',
      },
      'subway': {
        'icon': Icons.train,
        'color': Colors.blueGrey.shade800,
        'label': 'Subway',
      },
      'tram': {
        'icon': Icons.tram,
        'color': Colors.green.shade700,
        'label': 'Tram',
      },
      'train': {
        'icon': Icons.train,
        'color': Colors.indigo.shade700,
        'label': 'Train',
      },
      'ferry': {
        'icon': Icons.directions_boat,
        'color': Colors.blue.shade700,
        'label': 'Ferry',
      },
      'walk': {
        'icon': Icons.directions_walk,
        'color': Colors.pink.shade400,
        'label': 'Walk',
      },
    };
    
    return Column(
      children: [
        for (final entry in breakdown.entries)
          if (entry.value > 0) 
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: transitTypes[entry.key]?['color'] as Color? ?? Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      transitTypes[entry.key]?['icon'] as IconData? ?? Icons.help_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    transitTypes[entry.key]?['label'] as String? ?? entry.key,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${entry.value.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
  
  Widget _buildImpactSummary(SdgImpactService impactService) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insert_chart,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Your Impact Report',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Share',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            impactService.generateSdgSummary(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Keep up the good work!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 