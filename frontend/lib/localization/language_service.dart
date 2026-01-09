import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

/// Service to persist and retrieve language preferences
/// Uses SharedPreferences to persist language across app restarts
class LanguageService {
  static const String _languageKey = 'app_language';
  static const String _useDeviceLanguageKey = 'use_device_language';

  /// Get the saved language preference from persistent storage
  /// Returns null if "use device language" is selected
  Future<AppLanguage?> getLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if "use device language" is enabled
      final useDeviceLanguage = prefs.getBool(_useDeviceLanguageKey) ?? false;
      if (useDeviceLanguage) {
        return null; // null means use device language
      }

      final languageCode = prefs.getString(_languageKey);
      if (languageCode != null) {
        return _parseLanguage(languageCode);
      }

      // Default to null (use device language) if nothing is saved
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading language: $e');
      }
      return null; // Default to device language on error
    }
  }

  /// Save the language preference to persistent storage
  /// Pass null to enable "use device language"
  Future<void> saveLanguage(AppLanguage? language) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (language == null) {
        // Enable "use device language"
        await prefs.setBool(_useDeviceLanguageKey, true);
        await prefs.remove(_languageKey); // Remove saved language
        if (kDebugMode) {
          print('Language set to: use device language');
        }
      } else {
        // Save specific language
        await prefs.setBool(_useDeviceLanguageKey, false);
        await prefs.setString(_languageKey, language.name);
        if (kDebugMode) {
          print('Language saved: ${language.name}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving language: $e');
      }
    }
  }

  /// Detect device language from system locale
  static AppLanguage detectDeviceLanguage() {
    try {
      final deviceLocale = PlatformDispatcher.instance.locale;
      return _localeToAppLanguage(deviceLocale);
    } catch (e) {
      if (kDebugMode) {
        print('Error detecting device language: $e');
      }
      return AppLanguage.english; // Fallback to English
    }
  }

  /// Convert Flutter Locale to AppLanguage
  static AppLanguage _localeToAppLanguage(dynamic locale) {
    // PlatformDispatcher.instance.locale returns a Locale object
    final languageCode = locale.languageCode.toLowerCase();

    // Map language codes to AppLanguage enum
    switch (languageCode) {
      case 'en':
        return AppLanguage.english;
      case 'ar':
        return AppLanguage.arabic;
      case 'bn':
        return AppLanguage.bengali;
      case 'zh':
        return AppLanguage.chinese;
      case 'da':
        return AppLanguage.danish;
      case 'nl':
        return AppLanguage.dutch;
      case 'fi':
        return AppLanguage.finnish;
      case 'fr':
        return AppLanguage.french;
      case 'de':
        return AppLanguage.german;
      case 'el':
        return AppLanguage.greek;
      case 'he':
        return AppLanguage.hebrew;
      case 'hi':
        return AppLanguage.hindi;
      case 'id':
        return AppLanguage.indonesian;
      case 'it':
        return AppLanguage.italian;
      case 'ja':
        return AppLanguage.japanese;
      case 'ko':
        return AppLanguage.korean;
      case 'no':
        return AppLanguage.norwegian;
      case 'pl':
        return AppLanguage.polish;
      case 'pt':
        return AppLanguage.portuguese;
      case 'ro':
        return AppLanguage.romanian;
      case 'ru':
        return AppLanguage.russian;
      case 'es':
        return AppLanguage.spanish;
      case 'sv':
        return AppLanguage.swedish;
      case 'th':
        return AppLanguage.thai;
      case 'tr':
        return AppLanguage.turkish;
      case 'uk':
        return AppLanguage.ukrainian;
      case 'vi':
        return AppLanguage.vietnamese;
      default:
        return AppLanguage.english; // Fallback to English
    }
  }

  AppLanguage? _parseLanguage(String languageName) {
    try {
      return AppLanguage.values.firstWhere((lang) => lang.name == languageName);
    } catch (e) {
      return null;
    }
  }
}
