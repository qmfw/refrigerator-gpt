import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing and retrieving diet preferences locally
/// Preferences are stored locally for cost efficiency and synced to server on save
class DietPreferencesStorageService {
  static const String _preferencesKey = 'diet_preferences';

  /// Get diet preferences from local storage
  Future<Map<String, List<String>>> getPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = prefs.getString(_preferencesKey);

      if (preferencesJson == null || preferencesJson.isEmpty) {
        return {
          'avoid_ingredients': [],
          'diet_style': [],
          'cooking_preferences': [],
          'religious': [],
        };
      }

      final Map<String, dynamic> preferences = json.decode(preferencesJson);
      return {
        'avoid_ingredients': List<String>.from(
          preferences['avoid_ingredients'] ?? [],
        ),
        'diet_style': List<String>.from(preferences['diet_style'] ?? []),
        'cooking_preferences': List<String>.from(
          preferences['cooking_preferences'] ?? [],
        ),
        'religious': List<String>.from(preferences['religious'] ?? []),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error loading diet preferences from storage: $e');
      }
      return {
        'avoid_ingredients': [],
        'diet_style': [],
        'cooking_preferences': [],
        'religious': [],
      };
    }
  }

  /// Save diet preferences to local storage
  Future<void> savePreferences({
    required List<String> avoidIngredients,
    required List<String> dietStyle,
    required List<String> cookingPreferences,
    required List<String> religious,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = json.encode({
        'avoid_ingredients': avoidIngredients,
        'diet_style': dietStyle,
        'cooking_preferences': cookingPreferences,
        'religious': religious,
      });
      await prefs.setString(_preferencesKey, preferencesJson);

      if (kDebugMode) {
        print('Diet preferences saved to local storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving diet preferences to storage: $e');
      }
    }
  }

  /// Clear all diet preferences from local storage
  Future<void> clearPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_preferencesKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing diet preferences: $e');
      }
    }
  }
}
