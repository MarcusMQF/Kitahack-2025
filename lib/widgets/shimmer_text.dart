import 'package:flutter/material.dart';
import 'dart:async';

class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerText({
    super.key,
    required this.text,
    required this.style,
    required this.baseColor,
    required this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText> {
  bool _isHighlighted = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(widget.duration, (timer) {
      if (mounted) {
        setState(() {
          _isHighlighted = !_isHighlighted;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: widget.duration,
      style: widget.style.copyWith(
        color: _isHighlighted ? widget.highlightColor : widget.baseColor,
      ),
      child: Text(widget.text),
    );
  }
} 