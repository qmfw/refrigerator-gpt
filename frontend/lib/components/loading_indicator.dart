import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Loading indicator with animated dots and text
/// Used on Loading Detect and Loading Generate screens
class LoadingIndicator extends StatefulWidget {
  final String message;

  const LoadingIndicator({super.key, required this.message});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AnimatedDot(delay: 0, controller: _controller),
            const SizedBox(width: 12),
            _AnimatedDot(delay: 0.2, controller: _controller),
            const SizedBox(width: 12),
            _AnimatedDot(delay: 0.4, controller: _controller),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          widget.message,
          style: AppTextStyles.loadingText,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  final double delay;
  final AnimationController controller;

  const _AnimatedDot({required this.delay, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final animationValue = (controller.value + delay) % 1.0;
        final opacity = _getOpacity(animationValue);
        final scale = _getScale(animationValue);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  double _getOpacity(double value) {
    if (value < 0.5) {
      return 0.3 + (value * 1.4); // 0.3 to 1.0
    } else {
      return 1.0 - ((value - 0.5) * 1.4); // 1.0 to 0.3
    }
  }

  double _getScale(double value) {
    if (value < 0.5) {
      return 0.8 + (value * 0.8); // 0.8 to 1.2
    } else {
      return 1.2 - ((value - 0.5) * 0.8); // 1.2 to 0.8
    }
  }
}
