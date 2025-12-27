import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Large primary scan button with icon and text
/// Used on Home screen as the main CTA
class ScanButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String? text;

  const ScanButton({
    super.key,
    required this.onPressed,
    this.text,
  });

  @override
  State<ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<ScanButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: AppColors.primaryStart.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.primaryStart.withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                widget.text ?? 'Scan my fridge',
                style: AppTextStyles.buttonLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

