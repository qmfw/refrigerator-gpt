import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

/// Service to persist and retrieve language preferences
/// Uses SharedPreferences to persist language across app restarts
class LanguageService {
  static const String _languageKey = 'app_language';

  /// Get the saved language preference from persistent storage
  Future<AppLanguage?> getLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);

      if (languageCode != null) {
        return _parseLanguage(languageCode);
      }

      // Default to English if nothing is saved
      return AppLanguage.english;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading language: $e');
      }
      return AppLanguage.english;
    }
  }

  /// Save the language preference to persistent storage
  Future<void> saveLanguage(AppLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.name);

      if (kDebugMode) {
        print('Language saved: ${language.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving language: $e');
      }
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
