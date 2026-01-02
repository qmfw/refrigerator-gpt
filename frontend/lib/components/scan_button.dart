import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../localization/app_localizations_extension.dart';

/// Large primary scan button with icon and text
/// Used on Home screen as the main CTA
class ScanButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String? text;

  const ScanButton({super.key, required this.onPressed, this.text});

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
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXXXL),
            boxShadow:
                _isPressed
                    ? [
                      BoxShadow(
                        color: AppColors.primaryStart.withAlpha(
                          AppColors.alphaMedium,
                        ),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: AppColors.primaryStart.withAlpha(
                          AppColors.alphaMedium,
                        ),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
          ),
          padding: AppDimensions.buttonPaddingLarge,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: AppDimensions.iconSizeXL,
              ),
              AppDimensions.spacerHorizontalXL,
              Flexible(
                child: Text(
                  widget.text ?? context.l10n.scanMyFridge,
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: AppColors.ctaText,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
