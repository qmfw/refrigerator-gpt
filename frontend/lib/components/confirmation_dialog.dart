import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../localization/app_localizations_extension.dart';

/// Confirmation dialog component
/// Shows a dialog with title, body, and two buttons (Cancel and Confirm)
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String body;
  final String confirmText;
  final bool isDestructive;
  final VoidCallback? onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.body,
    required this.confirmText,
    this.isDestructive = false,
    this.onConfirm,
  });

  /// Show a confirmation dialog
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmationDialog(
            title: title,
            body: body,
            confirmText: confirmText,
            isDestructive: isDestructive,
            onConfirm: () => Navigator.of(context).pop(true),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: AppTextStyles.headerTitle.copyWith(fontSize: 20),
      ),
      content: Text(
        body,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            context.l10n.cancel,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(
            foregroundColor:
                isDestructive ? AppColors.destructive : AppColors.primary,
          ),
          child: Text(
            confirmText,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDestructive ? AppColors.destructive : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
