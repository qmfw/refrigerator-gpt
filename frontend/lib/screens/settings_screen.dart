import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations_extension.dart';
import '../services/history_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final HistoryStorageService _historyService = HistoryStorageService();

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
                    label: context.l10n.dietPreferences,
                    onTap: () {
                      Navigator.pushNamed(context, '/diet-preferences');
                    },
                  ),
                  SettingsItem(
                    label: context.l10n.languageLabel,
                    onTap: () {
                      Navigator.pushNamed(context, '/language');
                    },
                  ),
                  SettingsItem(
                    label: context.l10n.clearHistory,
                    isDestructive: true,
                    onTap: () async {
                      final confirmed = await ConfirmationDialog.show(
                        context,
                        title: context.l10n.clearHistoryTitle,
                        body: context.l10n.clearHistoryBody,
                        confirmText: context.l10n.clearHistory,
                        isDestructive: true,
                      );
                      if (confirmed == true && context.mounted) {
                        await _historyService.clearHistory();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.historyCleared),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  SettingsItem(
                    label: context.l10n.about,
                    onTap: () {
                      Navigator.pushNamed(context, '/about');
                    },
                  ),
                  SettingsItem(
                    label: context.l10n.privacy,
                    onTap: () {
                      Navigator.pushNamed(context, '/privacy');
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
