import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/components.dart' show BottomNav, NavItem, HistoryItem;
import '../theme/app_colors.dart';
import '../localization/app_localizations_extension.dart';
import '../models/models.dart' show HistoryEntry;
import '../services/api/recipe_service.dart';
import '../services/history_cache_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();

  // Static method to mark history for refresh (delegates to global service)
  static void markForRefresh() {
    HistoryCacheService().markForRefresh();
  }

  // Static method to clear cache (delegates to global service)
  static void clearCache() {
    HistoryCacheService().clearCache();
  }
}

class _HistoryScreenState extends State<HistoryScreen> {
  final RecipeService _recipeService = RecipeService();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  List<HistoryEntry> _historyItems = [];
  bool _isLoading = true;
  String? _lastLanguage; // Track last language to detect changes
  bool _hasLoadedInitially = false; // Track if initial load is done

  @override
  void initState() {
    super.initState();
    // Defer language check until after first frame (context is available)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkCacheAndLoad();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Track language changes - just set flag, don't call API yet
    if (_hasLoadedInitially) {
      final currentLanguage = context.languageCode;
      if (_lastLanguage != null && _lastLanguage != currentLanguage) {
        if (kDebugMode) {
          print(
            'History: Language changed from $_lastLanguage to $currentLanguage, clearing cache and setting refresh flag',
          );
        }
        // Clear cache when language changes and set refresh flag
        // API will be called when user navigates to history screen
        HistoryCacheService().markForRefresh();
      }
      _lastLanguage = currentLanguage;
    }
  }

  void _checkCacheAndLoad() {
    if (!mounted) return;

    // Check if we have cached data and language matches
    final currentLanguage = context.languageCode;
    final cacheService = HistoryCacheService();

    if (cacheService.isCacheValid(currentLanguage)) {
      // Use cached data - no API call needed!
      if (kDebugMode) {
        print('History: Using cached data, no API call');
      }
      setState(() {
        _historyItems = cacheService.cachedHistory!;
        _isLoading = false;
        _hasLoadedInitially = true;
        _lastLanguage = currentLanguage;
      });
    } else {
      // Need to load - either no cache, language changed, or refresh needed
      if (kDebugMode) {
        print(
          'History: Loading - cache=${cacheService.cachedHistory != null}, '
          'langMatch=${cacheService.cachedLanguage == currentLanguage}, '
          'shouldRefresh=${cacheService.shouldRefresh}',
        );
      }
      _initializeHistory();
    }
  }

  /// Manual refresh (pull-to-refresh)
  Future<void> _onRefresh() async {
    if (kDebugMode) {
      print('History: Manual refresh triggered');
    }
    await _loadHistory();
  }

  Future<void> _initializeHistory() async {
    await _loadHistory();
    _hasLoadedInitially = true;
  }

  Future<void> _loadHistory() async {
    // Capture language code before async operations
    if (!mounted) return;
    final language = context.languageCode;
    _lastLanguage = language; // Update last language

    final cacheService = HistoryCacheService();

    // Get or generate device ID
    final prefs = await SharedPreferences.getInstance();
    String? appAccountToken = prefs.getString('device_id');
    if (appAccountToken == null || appAccountToken.isEmpty) {
      appAccountToken = const Uuid().v4();
      await prefs.setString('device_id', appAccountToken);
    }

    try {
      // Use Future-based getHistory - automatically deduplicates concurrent requests
      final history = await cacheService.getHistory(
        language: language,
        fetchFunction:
            () => _recipeService.getHistory(
              appAccountToken: appAccountToken!,
              language: language,
            ),
      );

      if (mounted) {
        if (kDebugMode) {
          print('📡 [HistoryScreen] Loaded ${history.length} items, cached');
        }

        setState(() {
          _historyItems = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('📡 [HistoryScreen] Failed to load history: $e');
      }
      if (mounted) {
        setState(() {
          _historyItems = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text(
                context.l10n.history,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // History List with Pull-to-Refresh
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _historyItems.isEmpty
                      ? RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _onRefresh,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(
                              child: Text(
                                context.l10n.emptyHistory,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      : RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _historyItems.length,
                          itemBuilder: (context, index) {
                            final item = _historyItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: HistoryItem(
                                emoji: item.emoji,
                                title: item.title,
                                timeAgo: context.l10n.formatTimeAgo(
                                  item.createdAt,
                                ),
                                onTap: () {
                                  // Pass all recipes if grouped, otherwise just the single recipe
                                  final recipes =
                                      item.recipes ?? [item.toRecipe()];
                                  Navigator.pushNamed(
                                    context,
                                    '/recipe-results',
                                    arguments: recipes, // Pass List<Recipe>
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
            ),

            // Bottom Navigation
            BottomNav(
              activeItem: NavItem.history,
              onItemTap: (item) {
                switch (item) {
                  case NavItem.home:
                    Navigator.pushReplacementNamed(context, '/');
                    break;
                  case NavItem.scan:
                    Navigator.pushReplacementNamed(context, '/scan');
                    break;
                  case NavItem.history:
                    // Already on history
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
