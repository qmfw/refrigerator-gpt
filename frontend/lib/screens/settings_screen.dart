import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations_extension.dart';
import '../services/api/recipe_service.dart';
import '../services/history_cache_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final RecipeService _recipeService = RecipeService();

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
                        try {
                          // Get device ID
                          final prefs = await SharedPreferences.getInstance();
                          String? appAccountToken = prefs.getString(
                            'device_id',
                          );
                          if (appAccountToken == null ||
                              appAccountToken.isEmpty) {
                            appAccountToken = const Uuid().v4();
                            await prefs.setString('device_id', appAccountToken);
                          }

                          // Clear history from server
                          await _recipeService.clearHistory(
                            appAccountToken: appAccountToken,
                          );

                          // Immediately fetch history to update cache with empty result
                          final currentLanguage = context.languageCode;
                          final history = await _recipeService.getHistory(
                            appAccountToken: appAccountToken,
                            language: currentLanguage,
                          );

                          // Update global cache with empty history
                          HistoryCacheService().updateCache(
                            history,
                            currentLanguage,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n.historyCleared),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to clear history: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
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
