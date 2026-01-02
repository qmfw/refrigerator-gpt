import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final bool showSettingsButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSettingsPressed;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.showSettingsButton = false,
    this.onBackPressed,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.textSecondary,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (showBackButton) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headerTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(subtitle!, style: AppTextStyles.headerSubtitle),
                ],
              ],
            ),
          ),
          if (showSettingsButton)
            IconButton(
              icon: const Icon(Icons.settings, color: AppColors.textSecondary),
              onPressed: onSettingsPressed,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

/// Simple header with just title and optional action button
class SimpleHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const SimpleHeader({
    super.key,
    required this.title,
    this.action,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.textSecondary,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (showBackButton) const SizedBox(width: 16),
          Expanded(child: Text(title, style: AppTextStyles.headerTitle)),
          if (action != null) action!,
        ],
      ),
    );
  }
}
