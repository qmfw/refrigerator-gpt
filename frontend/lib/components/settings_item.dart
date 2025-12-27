import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Settings list item component
/// Used on Settings screen
class SettingsItem extends StatefulWidget {
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;

  const SettingsItem({
    super.key,
    required this.label,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  State<SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isPressed
              ? Colors.black.withOpacity(0.02)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 17,
                color: widget.isDestructive
                    ? AppColors.destructive
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFD1D5DB),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

