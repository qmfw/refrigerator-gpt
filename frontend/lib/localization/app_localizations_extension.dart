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
  /// Pass null to use device language
  Future<void> setLanguage(AppLanguage? language) async {
    final provider = LocalizationsProvider.of(this);
    if (provider != null) {
      await provider.setLanguage(language);
    }
  }

  /// Get the current language code (e.g., "en", "es", "ja")
  String get languageCode {
    return _getLanguageCode(currentLanguage);
  }
}

/// Convert AppLanguage enum to language code string
/// Matches backend language codes: en, ar, bn, zh, da, nl, fi, fr, de, el, he, hi, id, it, ja, ko, no, pl, pt, ro, ru, es, sv, th, tr, uk, vi
String _getLanguageCode(AppLanguage language) {
  switch (language) {
    case AppLanguage.english:
      return 'en';
    case AppLanguage.arabic:
      return 'ar';
    case AppLanguage.bengali:
      return 'bn';
    case AppLanguage.chinese:
      return 'zh';
    case AppLanguage.danish:
      return 'da';
    case AppLanguage.dutch:
      return 'nl';
    case AppLanguage.finnish:
      return 'fi';
    case AppLanguage.french:
      return 'fr';
    case AppLanguage.german:
      return 'de';
    case AppLanguage.greek:
      return 'el';
    case AppLanguage.hebrew:
      return 'he';
    case AppLanguage.hindi:
      return 'hi';
    case AppLanguage.indonesian:
      return 'id';
    case AppLanguage.italian:
      return 'it';
    case AppLanguage.japanese:
      return 'ja';
    case AppLanguage.korean:
      return 'ko';
    case AppLanguage.norwegian:
      return 'no';
    case AppLanguage.polish:
      return 'pl';
    case AppLanguage.portuguese:
      return 'pt';
    case AppLanguage.romanian:
      return 'ro';
    case AppLanguage.russian:
      return 'ru';
    case AppLanguage.spanish:
      return 'es';
    case AppLanguage.swedish:
      return 'sv';
    case AppLanguage.thai:
      return 'th';
    case AppLanguage.turkish:
      return 'tr';
    case AppLanguage.ukrainian:
      return 'uk';
    case AppLanguage.vietnamese:
      return 'vi';
  }
}
