import 'package:flutter/foundation.dart';
import 'app_localizations.dart';

/// Service to persist and retrieve language preferences
/// Uses a simple in-memory storage for now (can be replaced with SharedPreferences)
class LanguageService {
  // In-memory storage (replace with SharedPreferences if needed)
  // To use SharedPreferences, uncomment and add shared_preferences to pubspec.yaml:
  // static const String _languageKey = 'app_language';
  static String? _cachedLanguage;

  /// Get the saved language preference
  Future<AppLanguage?> getLanguage() async {
    try {
      // For now, use in-memory cache
      // In production, you can use SharedPreferences:
      // final prefs = await SharedPreferences.getInstance();
      // final languageCode = prefs.getString(_languageKey);

      if (_cachedLanguage != null) {
        return _parseLanguage(_cachedLanguage!);
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

  /// Save the language preference
  Future<void> saveLanguage(AppLanguage language) async {
    try {
      _cachedLanguage = language.name;

      // In production, use SharedPreferences:
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString(_languageKey, language.name);

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
