import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_localizations_extension.dart';
import '../models/models.dart';
import '../services/api/recipe_service.dart';
import '../services/history_cache_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Widget that fetches and displays the last recipe result from history
/// Used on Home screen
class LastResultCard extends StatefulWidget {
  const LastResultCard({super.key});

  @override
  State<LastResultCard> createState() => _LastResultCardState();
}

class _LastResultCardState extends State<LastResultCard> {
  final RecipeService _recipeService = RecipeService();
  HistoryEntry? _lastEntry;
  bool _isLoading = true;
  String? _lastLanguage;
  bool _isLoadingInProgress = false;

  @override
  void initState() {
    super.initState();
    // Listen to cache changes
    HistoryCacheService().cacheNotifier.addListener(_onCacheChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadFromCache();
      }
    });
  }

  @override
  void dispose() {
    HistoryCacheService().cacheNotifier.removeListener(_onCacheChanged);
    super.dispose();
  }

  void _onCacheChanged() {
    // Use postFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cacheService = HistoryCacheService();

      // Get language code safely
      String? currentLanguage;
      try {
        currentLanguage = context.languageCode;
      } catch (e) {
        return;
      }

      // If cache is empty for current language, clear entry
      if (cacheService.cachedHistory != null &&
          cacheService.cachedHistory!.isEmpty &&
          cacheService.cachedLanguage == currentLanguage &&
          _lastEntry != null) {
        setState(() {
          _lastEntry = null;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLanguage = context.languageCode;
    final cacheService = HistoryCacheService();

    // Reload if language changed or cache was invalidated
    if (_lastLanguage != null && _lastLanguage != currentLanguage) {
      _lastLanguage = currentLanguage;

      // Check if cache is already valid (LocalizationsProvider might have fetched it)
      if (cacheService.isCacheValid(currentLanguage)) {
        final entry = cacheService.getLastEntry();
        if (mounted) {
          setState(() {
            _lastEntry = entry;
            _isLoading = false;
          });
        }
        return;
      }

      // Load from cache - Future-based approach handles deduplication automatically
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && !_isLoadingInProgress) {
          _loadFromCache();
        }
      });
    } else if (cacheService.shouldRefresh) {
      _loadFromCache();
    }
  }

  /// Load from cache or API using Future-based approach
  Future<void> _loadFromCache() async {
    if (!mounted || _isLoadingInProgress) return;

    final currentLanguage = context.languageCode;
    final cacheService = HistoryCacheService();

    // Use cache if valid
    if (cacheService.isCacheValid(currentLanguage)) {
      final entry = cacheService.getLastEntry();
      if (mounted) {
        setState(() {
          _lastEntry = entry;
          _isLoading = false;
          _lastLanguage = currentLanguage;
        });
      }
      return;
    }

    // Set flag to prevent duplicate calls
    _isLoadingInProgress = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) {
        _isLoadingInProgress = false;
        return;
      }

      final appAccountToken = prefs.getString('device_id');
      if (appAccountToken == null || appAccountToken.isEmpty) {
        if (mounted) {
          setState(() {
            _lastEntry = null;
            _isLoading = false;
            _lastLanguage = currentLanguage;
          });
        }
        _isLoadingInProgress = false;
        return;
      }

      // Use Future-based getHistory - automatically deduplicates concurrent requests
      final history = await cacheService.getHistory(
        language: currentLanguage,
        fetchFunction:
            () => _recipeService.getHistory(
              appAccountToken: appAccountToken,
              language: currentLanguage,
            ),
      );

      if (mounted) {
        setState(() {
          _lastEntry = history.isNotEmpty ? history.first : null;
          _isLoading = false;
          _lastLanguage = currentLanguage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastEntry = null;
          _isLoading = false;
          _lastLanguage = currentLanguage;
        });
      }
    } finally {
      _isLoadingInProgress = false;
    }
  }

  void _handleTap() {
    if (_lastEntry == null) return;
    final recipes = _lastEntry!.recipes ?? [_lastEntry!.toRecipe()];
    Navigator.pushNamed(context, '/recipe-results', arguments: recipes);
  }

  @override
  Widget build(BuildContext context) {
    // Check cache when returning from settings (history might have been deleted)
    if (!_isLoading && _lastEntry != null) {
      final cacheService = HistoryCacheService();
      final currentLanguage = context.languageCode;

      // If cache is empty for current language, clear the entry
      if (cacheService.cachedHistory != null &&
          cacheService.cachedHistory!.isEmpty &&
          cacheService.cachedLanguage == currentLanguage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _lastEntry = null;
              _isLoading = false;
            });
          }
        });
      }
    }

    if (_isLoading || _lastEntry == null) {
      return const SizedBox.shrink();
    }

    final recipeCount = _lastEntry!.recipes?.length ?? 1;
    final timeAgo = context.l10n.formatTimeAgo(_lastEntry!.createdAt);

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.l10n.lastResult, style: AppTextStyles.cardTitle),
                Text(timeAgo, style: AppTextStyles.cardDate),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Thumbnail - Show Foodish image if available, otherwise emoji
                _lastEntry!.imageUrl != null && _lastEntry!.imageUrl!.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _lastEntry!.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _lastEntry!.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _lastEntry!.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                    : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _lastEntry!.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lastEntry!.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.recipesFound(recipeCount),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
