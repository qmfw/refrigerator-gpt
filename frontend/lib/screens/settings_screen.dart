import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations_extension.dart';
import '../repository/mock_fridge_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final MockFridgeRepository _repository = MockFridgeRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            SimpleHeader(
              title: context.l10n.settings,
              showBackButton: true,
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),

            // Settings List
            Expanded(
              child: ListView(
                children: [
                  SettingsItem(
                    label: context.l10n.clearHistory,
                    isDestructive: true,
                    onTap: () async {
                      await _repository.clearHistory();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.l10n.historyCleared)),
                        );
                      }
                    },
                  ),
                  SettingsItem(
                    label: context.l10n.about,
                    onTap: () {
                      InfoDialog.show(
                        context,
                        title: context.l10n.aboutTitle,
                        content: context.l10n.aboutContent,
                      );
                    },
                  ),
                  SettingsItem(
                    label: context.l10n.feedback,
                    onTap: () {
                      // Open feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.feedbackComingSoon),
                        ),
                      );
                    },
                  ),
                  SettingsItem(
                    label: context.l10n.privacy,
                    onTap: () {
                      InfoDialog.show(
                        context,
                        title: context.l10n.privacyTitle,
                        content: context.l10n.privacyContent,
                      );
                    },
                  ),
                  // Language picker (visible in debug mode or always)
                  if (kDebugMode || true) // Set to false to hide in production
                    SettingsItem(
                      label: context.l10n.languageLabel,
                      onTap: () {
                        LanguagePickerDialog.show(context);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
