import '../models/models.dart';

/// Global service for managing history cache and refresh state
/// Uses Future-based approach to prevent duplicate API calls
/// Used by both HistoryScreen and LastResultCard to share state
class HistoryCacheService {
  // Singleton instance
  static final HistoryCacheService _instance = HistoryCacheService._internal();
  factory HistoryCacheService() => _instance;
  HistoryCacheService._internal();

  // Cache state
  List<HistoryEntry>? cachedHistory;
  String? cachedLanguage;
  bool shouldRefresh = false;

  // Future-based deduplication: store ongoing fetch Future per language
  Future<List<HistoryEntry>>? _ongoingFetch;
  String? _ongoingFetchLanguage;

  /// Mark history for refresh (e.g., after deletion or new recipe generation)
  void markForRefresh() {
    shouldRefresh = true;
    cachedHistory = null; // Clear cache when refresh is needed
    cachedLanguage = null;
    _ongoingFetch = null; // Cancel ongoing fetch
    _ongoingFetchLanguage = null;
  }

  /// Clear all cache (e.g., on app restart)
  void clearCache() {
    cachedHistory = null;
    cachedLanguage = null;
    shouldRefresh = false;
    _ongoingFetch = null;
    _ongoingFetchLanguage = null;
  }

  /// Update cache with new history data
  void updateCache(List<HistoryEntry> history, String language) {
    cachedHistory = history;
    cachedLanguage = language;
    shouldRefresh = false; // Clear refresh flag after successful load
    _ongoingFetch = null; // Clear ongoing fetch
    _ongoingFetchLanguage = null;
  }

  /// Get or create a Future for fetching history
  /// If a fetch is already in progress for this language, returns the same Future
  /// Otherwise creates a new Future and stores it
  Future<List<HistoryEntry>> getHistory({
    required String language,
    required Future<List<HistoryEntry>> Function() fetchFunction,
  }) async {
    // If cache is valid, return immediately (no Future needed)
    if (isCacheValid(language)) {
      return cachedHistory!;
    }

    // If there's an ongoing fetch for this language, return the same Future
    if (_ongoingFetch != null && _ongoingFetchLanguage == language) {
      return _ongoingFetch!;
    }

    // Create new Future and store it
    _ongoingFetchLanguage = language;
    _ongoingFetch = fetchFunction()
        .then((history) {
          // Update cache when fetch completes
          updateCache(history, language);
          return history;
        })
        .catchError((error) {
          // Clear ongoing fetch on error
          _ongoingFetch = null;
          _ongoingFetchLanguage = null;
          throw error;
        });

    return _ongoingFetch!;
  }

  /// Check if cache is valid for the given language
  bool isCacheValid(String language) {
    return cachedHistory != null &&
        cachedLanguage == language &&
        !shouldRefresh;
  }

  /// Get the last history entry if available
  HistoryEntry? getLastEntry() {
    if (cachedHistory != null && cachedHistory!.isNotEmpty) {
      return cachedHistory!.first;
    }
    return null;
  }
}
