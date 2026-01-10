import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';
import 'language_service.dart';
import '../services/api/recipe_service.dart';
import '../services/history_cache_service.dart';

// Make LocalizationsInherited accessible to the extension
// Export it so it can be used in app_localizations_extension.dart
class LocalizationsInherited extends InheritedWidget {
  final AppLocalizations localizations;
  final AppLanguage currentLanguage;
  final Future<void> Function(AppLanguage?) setLanguage;

  const LocalizationsInherited({
    super.key,
    required this.localizations,
    required this.currentLanguage,
    required this.setLanguage,
    required super.child,
  });

  @override
  bool updateShouldNotify(LocalizationsInherited oldWidget) {
    return localizations != oldWidget.localizations ||
        currentLanguage != oldWidget.currentLanguage;
  }

  static LocalizationsInherited? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocalizationsInherited>();
  }
}

/// Provider that manages the current app language
/// Uses InheritedWidget to provide AppLocalizations throughout the widget tree
class LocalizationsProvider extends StatefulWidget {
  final Widget child;
  final AppLanguage initialLanguage;

  const LocalizationsProvider({
    super.key,
    required this.child,
    this.initialLanguage = AppLanguage.english,
  });

  static LocalizationsProviderState? of(BuildContext context) {
    return context.findAncestorStateOfType<LocalizationsProviderState>();
  }

  @override
  State<LocalizationsProvider> createState() => LocalizationsProviderState();
}

class LocalizationsProviderState extends State<LocalizationsProvider> {
  late AppLanguage _currentLanguage;
  late AppLocalizations _localizations;
  final LanguageService _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.initialLanguage;
    _localizations = AppLocalizations(_currentLanguage);
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLanguage = await _languageService.getLanguage();

    if (savedLanguage == null) {
      // Use device language
      final deviceLanguage = LanguageService.detectDeviceLanguage();
      if (deviceLanguage != _currentLanguage) {
        setState(() {
          _currentLanguage = deviceLanguage;
          _localizations = AppLocalizations(_currentLanguage);
        });
      }
    } else if (savedLanguage != _currentLanguage) {
      // Use saved language
      setState(() {
        _currentLanguage = savedLanguage;
        _localizations = AppLocalizations(_currentLanguage);
      });
    }
  }

  /// Change the app language
  /// Pass null to use device language
  Future<void> setLanguage(AppLanguage? language) async {
    AppLanguage targetLanguage;

    if (language == null) {
      // Use device language
      targetLanguage = LanguageService.detectDeviceLanguage();
    } else {
      targetLanguage = language;
    }

    if (_currentLanguage != targetLanguage) {
      await _languageService.saveLanguage(
        language,
      ); // Save null for device language
      setState(() {
        _currentLanguage = targetLanguage;
        _localizations = AppLocalizations(targetLanguage);
      });

      // Immediately fetch history in the new language
      _fetchHistoryForNewLanguage(targetLanguage);
    }
  }

  /// Fetch history immediately after language change
  Future<void> _fetchHistoryForNewLanguage(AppLanguage newLanguage) async {
    final cacheService = HistoryCacheService();
    final languageCode = _getLanguageCode(newLanguage);

    try {
      // Get app account token
      final prefs = await SharedPreferences.getInstance();
      String? appAccountToken = prefs.getString('device_id');
      if (appAccountToken == null || appAccountToken.isEmpty) {
        // No token means no history exists, just clear cache
        cacheService.clearCache();
        return;
      }

      // Use Future-based getHistory - automatically deduplicates concurrent requests
      await cacheService.getHistory(
        language: languageCode,
        fetchFunction: () async {
          final recipeService = RecipeService();
          return await recipeService.getHistory(
            appAccountToken: appAccountToken,
            language: languageCode,
          );
        },
      );
    } catch (e) {
      // Don't fail language change if history fetch fails
      // Just clear cache so components will fetch on next access
      cacheService.markForRefresh();
    }
  }

  /// Convert AppLanguage enum to language code string
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

  AppLanguage get currentLanguage => _currentLanguage;
  AppLocalizations get localizations => _localizations;

  @override
  Widget build(BuildContext context) {
    return LocalizationsInherited(
      localizations: _localizations,
      currentLanguage: _currentLanguage,
      setLanguage: setLanguage,
      child: widget.child,
    );
  }
}
