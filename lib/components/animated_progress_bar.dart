import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatefulWidget {
  final double progress; // Value between 0.0 and 1.0
  final double maxValue; // The 100% value
  final double currentValue; // The current value
  final bool isExpanded; // Whether the progress details are expanded
  final Color backgroundColor;
  final Color progressColor;
  final String? leftLabel; // Optional label for remaining progress
  final String? rightLabel; // Optional label for total

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    required this.maxValue,
    required this.currentValue,
    required this.isExpanded,
    this.backgroundColor = const Color(0x66FFFFFF), // Default semi-transparent white
    this.progressColor = Colors.white,
    this.leftLabel,
    this.rightLabel,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Only animate when the bar is expanded
    if (widget.isExpanded) {
      _progressAnimationController.forward();
    }
  }
  
  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If expansion state changed
    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded) {
        // Always reset and animate when expanding, regardless of previous state
        _progressAnimation = Tween<double>(
          begin: 0.0, // Always start from 0
          end: widget.progress,
        ).animate(CurvedAnimation(
          parent: _progressAnimationController,
          curve: Curves.easeOutCubic,
        ));
        
        _progressAnimationController.reset();
        _progressAnimationController.forward();
      } else {
        // If collapsed, reset progress
        _progressAnimationController.reset();
      }
    } 
    // If only the progress value changed (while expanded)
    else if (oldWidget.progress != widget.progress && widget.isExpanded) {
      _progressAnimation = Tween<double>(
        begin: 0.0, // Always animate from 0 for better effect
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeOutCubic,
      ));
      
      _progressAnimationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: const SizedBox(height: 0),
      secondChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          // Progress bar
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              return Container(
                width: double.infinity,
                height: 5,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Row(
                      children: [
                        Container(
                          width: barWidth * _progressAnimation.value, // Use the actual container width
                          decoration: BoxDecoration(
                            color: widget.progressColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }
          ),
          const SizedBox(height: 8),
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.leftLabel ?? '${(widget.maxValue - widget.currentValue).round()} points to next level',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                widget.rightLabel ?? '${widget.maxValue.round()}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      crossFadeState: widget.isExpanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }
}