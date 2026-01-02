import 'package:flutter/material.dart';
import '../localization/app_localizations_extension.dart';

/// Reusable info dialog component
/// Shows a simple dialog with title, content, and OK button
class InfoDialog extends StatelessWidget {
  final String title;
  final String content;

  const InfoDialog({super.key, required this.title, required this.content});

  /// Show an info dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return showDialog(
      context: context,
      builder: (context) => InfoDialog(title: title, content: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.ok),
        ),
      ],
    );
  }
}
