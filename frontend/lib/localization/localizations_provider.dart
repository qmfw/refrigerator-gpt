import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'language_service.dart';

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
        _localizations = AppLocalizations(_currentLanguage);
      });
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
