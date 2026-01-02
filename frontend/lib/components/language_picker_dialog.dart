import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations.dart';
import '../localization/app_localizations_extension.dart';

/// Reusable language picker dialog
/// Shows a scrollable list of available languages with selection
class LanguagePickerDialog extends StatelessWidget {
  const LanguagePickerDialog({super.key});

  /// Show the language picker dialog
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (dialogContext) => const LanguagePickerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.selectLanguage),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                AppLanguage.values.map((language) {
                  final isSelected = context.currentLanguage == language;
                  return ListTile(
                    title: Text(_getLanguageName(language)),
                    trailing:
                        isSelected
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                    onTap: () async {
                      await context.setLanguage(language);
                      if (context.mounted) {
                        Navigator.pop(context);
                        // Rebuild the parent screen to show updated language
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/settings');
                      }
                    },
                  );
                }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.ok),
        ),
      ],
    );
  }

  String _getLanguageName(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.arabic:
        return 'العربية';
      case AppLanguage.bengali:
        return 'বাংলা';
      case AppLanguage.chinese:
        return '中文';
      case AppLanguage.danish:
        return 'Dansk';
      case AppLanguage.dutch:
        return 'Nederlands';
      case AppLanguage.finnish:
        return 'Suomi';
      case AppLanguage.french:
        return 'Français';
      case AppLanguage.german:
        return 'Deutsch';
      case AppLanguage.greek:
        return 'Ελληνικά';
      case AppLanguage.hebrew:
        return 'עברית';
      case AppLanguage.hindi:
        return 'हिन्दी';
      case AppLanguage.indonesian:
        return 'Bahasa Indonesia';
      case AppLanguage.italian:
        return 'Italiano';
      case AppLanguage.japanese:
        return '日本語';
      case AppLanguage.korean:
        return '한국어';
      case AppLanguage.norwegian:
        return 'Norsk';
      case AppLanguage.polish:
        return 'Polski';
      case AppLanguage.portuguese:
        return 'Português';
      case AppLanguage.romanian:
        return 'Română';
      case AppLanguage.russian:
        return 'Русский';
      case AppLanguage.spanish:
        return 'Español';
      case AppLanguage.swedish:
        return 'Svenska';
      case AppLanguage.thai:
        return 'ไทย';
      case AppLanguage.turkish:
        return 'Türkçe';
      case AppLanguage.ukrainian:
        return 'Українська';
      case AppLanguage.vietnamese:
        return 'Tiếng Việt';
    }
  }
}
