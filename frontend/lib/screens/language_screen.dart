import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../localization/app_localizations.dart';
import '../localization/app_localizations_extension.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLanguage = context.currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            SimpleHeader(
              title: context.l10n.languageLabel,
              showBackButton: true,
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),

            // Language List
            Expanded(
              child: ListView(
                children: [
                  _buildLanguageItem(
                    context,
                    language: AppLanguage.english,
                    label: context.l10n.useDeviceLanguage,
                    sublabel: context.l10n.defaultLabel,
                    isSelected: currentLanguage == AppLanguage.english,
                  ),
                  ...AppLanguage.values
                      .where((lang) => lang != AppLanguage.english)
                      .map(
                        (language) => _buildLanguageItem(
                          context,
                          language: language,
                          label: _getLanguageName(language),
                          isSelected: currentLanguage == language,
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(
    BuildContext context, {
    required AppLanguage language,
    required String label,
    String? sublabel,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () async {
        await context.setLanguage(language);
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black.withAlpha(5) : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: AppColors.borderLight, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (sublabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      sublabel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textHint,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _buildRadioIndicator(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioIndicator(bool isSelected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFD1D5DB),
          width: 2,
        ),
      ),
      child:
          isSelected
              ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
              )
              : null,
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
