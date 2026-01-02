import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'localizations_provider.dart'
    show LocalizationsProvider, LocalizationsInherited;

/// Extension to easily access localizations from BuildContext
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n {
    final inherited = LocalizationsInherited.of(this);
    if (inherited != null) {
      return inherited.localizations;
    }
    // Fallback to English if provider is not found
    return AppLocalizations(AppLanguage.english);
  }

  /// Get the current language
  AppLanguage get currentLanguage {
    final inherited = LocalizationsInherited.of(this);
    return inherited?.currentLanguage ?? AppLanguage.english;
  }

  /// Change the app language
  Future<void> setLanguage(AppLanguage language) async {
    final provider = LocalizationsProvider.of(this);
    if (provider != null) {
      await provider.setLanguage(language);
    }
  }
}
