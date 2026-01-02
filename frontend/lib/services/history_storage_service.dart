import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Service for storing and retrieving recipe history locally
/// This reduces API calls and costs by keeping history on the device
class HistoryStorageService {
  static const String _historyKey = 'recipe_history';
  static const int _maxHistoryItems = 100; // Limit history size

  /// Get all history entries from local storage
  Future<List<HistoryEntry>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);

      if (historyJson == null || historyJson.isEmpty) {
        return [];
      }

      final List<dynamic> historyList = json.decode(historyJson);
      return historyList
          .map(
            (item) => HistoryEntry(
              id: item['id'] as String,
              emoji: item['emoji'] as String,
              title: item['title'] as String,
              createdAt: DateTime.parse(item['created_at'] as String),
              languageCode: item['language_code'] as String?,
            ),
          )
          .toList()
        ..sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        ); // Most recent first
    } catch (e) {
      if (kDebugMode) {
        print('Error loading history from storage: $e');
      }
      return [];
    }
  }

  /// Save a history entry to local storage
  /// This is called when a recipe is generated
  Future<void> saveHistoryEntry(HistoryEntry entry) async {
    try {
      final history = await getHistory();

      // Remove duplicate if exists (by ID)
      history.removeWhere((item) => item.id == entry.id);

      // Add new entry at the beginning
      history.insert(0, entry);

      // Limit history size
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      // Save to storage
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        history
            .map(
              (item) => {
                'id': item.id,
                'emoji': item.emoji,
                'title': item.title,
                'created_at': item.createdAt.toIso8601String(),
                if (item.languageCode != null)
                  'language_code': item.languageCode,
              },
            )
            .toList(),
      );
      await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving history entry: $e');
      }
    }
  }

  /// Save multiple history entries (e.g., when syncing)
  Future<void> saveHistoryEntries(List<HistoryEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        entries
            .map(
              (item) => {
                'id': item.id,
                'emoji': item.emoji,
                'title': item.title,
                'created_at': item.createdAt.toIso8601String(),
                if (item.languageCode != null)
                  'language_code': item.languageCode,
              },
            )
            .toList(),
      );
      await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving history entries: $e');
      }
    }
  }

  /// Clear all history from local storage
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing history: $e');
      }
    }
  }

  /// Get a specific history entry by ID
  Future<HistoryEntry?> getHistoryEntryById(String id) async {
    try {
      final history = await getHistory();
      try {
        return history.firstWhere((item) => item.id == id);
      } catch (e) {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting history entry by ID: $e');
      }
      return null;
    }
  }

  /// Get the most recent history entry
  Future<HistoryEntry?> getLastHistoryEntry() async {
    try {
      final history = await getHistory();
      return history.isNotEmpty ? history.first : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting last history entry: $e');
      }
      return null;
    }
  }
}
