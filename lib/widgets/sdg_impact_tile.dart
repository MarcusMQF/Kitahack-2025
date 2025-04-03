import 'package:flutter/material.dart';

class SdgImpactTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final String value;
  final String description;
  final List<double> chartData;

  const SdgImpactTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.value,
    required this.description,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Title row with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Value display
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                flex: 1,
                child: _buildProgressChart(chartData),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressChart(List<double> data) {
    final double current = data[0];
    final double target = data[1];
    final double percentage = current / target;
    final cappedPercentage = percentage > 1.0 ? 1.0 : percentage;
    
    return Container(
      height: 100,
      width: 100,
      padding: const EdgeInsets.all(6),
      child: CustomPaint(
        painter: CircularProgressPainter(
          backgroundColor: Colors.grey.shade200,
          valueColor: color,
          value: cappedPercentage,
        ),
        child: Center(
          child: Text(
            '${(cappedPercentage * 100).toInt()}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final Color backgroundColor;
  final Color valueColor;
  final double value;

  CircularProgressPainter({
    required this.backgroundColor,
    required this.valueColor,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Value arc
    final valuePaint = Paint()
      ..color = valueColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      rect,
      -90 * (3.14159 / 180), // Start from the top (270 degrees or -90 radians)
      value * 2 * 3.14159, // Full circle is 2pi radians
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
} 