import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  double x;
  double y;
  double radius;
  double speed;
  double direction;
  Color color;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.direction,
    required this.color,
    this.opacity = 1.0,
  });

  void update(Size size, double animationValue) {
    // Move the particle
    x += cos(direction) * speed * animationValue;
    y += sin(direction) * speed * animationValue;

    // Bounce off edges
    if (x < 0 || x > size.width) {
      direction = pi - direction;
      x = x < 0 ? 0 : size.width;
    }
    
    if (y < 0 || y > size.height) {
      direction = -direction;
      y = y < 0 ? 0 : size.height;
    }
    
    // Adjust opacity based on animation value - ensure it's between 0.0 and 1.0
    opacity = 0.3 + (sin(animationValue * 2 * pi) + 1) / 6;
    opacity = opacity.clamp(0.0, 1.0); // Ensure opacity is within valid range
  }
}

class ParticleBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final List<Color> colors;
  final double maxRadius;
  final double maxSpeed;
  
  const ParticleBackground({
    super.key,
    required this.child,
    this.particleCount = 15,
    this.colors = const [Colors.white],
    this.maxRadius = 5.0,
    this.maxSpeed = 1.0,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final Random _random = Random();
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _particles = [];
    _initParticles();
  }
  
  void _initParticles() {
    // We'll initialize with placeholder values and update properly in the first paint
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(
        Particle(
          x: _random.nextDouble() * 300,
          y: _random.nextDouble() * 500,
          radius: _random.nextDouble() * widget.maxRadius + 1,
          speed: _random.nextDouble() * widget.maxSpeed + 0.1,
          direction: _random.nextDouble() * 2 * pi,
          color: widget.colors[_random.nextInt(widget.colors.length)],
          opacity: _random.nextDouble() * 0.5 + 0.3,
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: ParticlePainter(
                particles: _particles,
                animationValue: _controller.value,
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  
  ParticlePainter({
    required this.particles,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Update and draw each particle
    for (var particle in particles) {
      particle.update(size, animationValue);
      
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.radius,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
} 