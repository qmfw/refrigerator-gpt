import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../localization/app_localizations_extension.dart';
import '../services/diet_preferences_storage_service.dart';

class DietPreferencesScreen extends StatefulWidget {
  const DietPreferencesScreen({super.key});

  @override
  State<DietPreferencesScreen> createState() => _DietPreferencesScreenState();
}

class _DietPreferencesScreenState extends State<DietPreferencesScreen> {
  final DietPreferencesStorageService _storageService =
      DietPreferencesStorageService();
  bool _isLoading = true;
  bool _hasChanges = false;

  // Avoid ingredients - Translation keys to API keys mapping
  final Map<String, String> _avoidIngredientsMap = {
    'nuts': 'nuts',
    'shellfish': 'shellfish',
    'dairy': 'dairy',
    'eggs': 'eggs',
    'gluten': 'gluten',
    'soy': 'soy',
  };

  // Diet style - Translation keys to API keys mapping
  final Map<String, String> _dietStyleMap = {
    'vegan': 'vegan',
    'vegetarian': 'vegetarian',
    'pescatarian': 'pescatarian',
  };

  // Cooking preferences - Translation keys to API keys mapping
  final Map<String, String> _cookingPreferencesMap = {
    'lowCarb': 'low_carb',
    'lowFat': 'low_fat',
  };

  // Religious - Translation keys to API keys mapping
  final Map<String, String> _religiousMap = {
    'halal': 'halal',
    'kosher': 'kosher',
  };

  // Avoid ingredients - using translation keys as keys
  final Map<String, bool> _avoidIngredients = {
    'nuts': false,
    'shellfish': false,
    'dairy': false,
    'eggs': false,
    'gluten': false,
    'soy': false,
  };

  // Diet style - using translation keys as keys
  final Map<String, bool> _dietStyle = {
    'vegan': false,
    'vegetarian': false,
    'pescatarian': false,
  };

  // Cooking preferences - using translation keys as keys
  final Map<String, bool> _cookingPreferences = {
    'lowCarb': false,
    'lowFat': false,
  };

  // Religious - using translation keys as keys
  final Map<String, bool> _religious = {'halal': false, 'kosher': false};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// Load preferences from local storage
  Future<void> _loadPreferences() async {
    try {
      final savedPreferences = await _storageService.getPreferences();

      // Map API keys back to UI labels
      _mapApiToUi(savedPreferences);

      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading preferences: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Map API format to UI format
  void _mapApiToUi(Map<String, List<String>> apiPreferences) {
    // Map avoid ingredients
    for (final entry in _avoidIngredients.entries) {
      final apiKey = _avoidIngredientsMap[entry.key];
      _avoidIngredients[entry.key] =
          apiPreferences['avoid_ingredients']?.contains(apiKey) ?? false;
    }

    // Map diet style
    for (final entry in _dietStyle.entries) {
      final apiKey = _dietStyleMap[entry.key];
      _dietStyle[entry.key] =
          apiPreferences['diet_style']?.contains(apiKey) ?? false;
    }

    // Map cooking preferences
    for (final entry in _cookingPreferences.entries) {
      final apiKey = _cookingPreferencesMap[entry.key];
      _cookingPreferences[entry.key] =
          apiPreferences['cooking_preferences']?.contains(apiKey) ?? false;
    }

    // Map religious
    for (final entry in _religious.entries) {
      final apiKey = _religiousMap[entry.key];
      _religious[entry.key] =
          apiPreferences['religious']?.contains(apiKey) ?? false;
    }
  }

  /// Convert UI format to API format
  Map<String, List<String>> _mapUiToApi() {
    return {
      'avoid_ingredients':
          _avoidIngredients.entries
              .where((e) => e.value)
              .map((e) => _avoidIngredientsMap[e.key]!)
              .toList(),
      'diet_style':
          _dietStyle.entries
              .where((e) => e.value)
              .map((e) => _dietStyleMap[e.key]!)
              .toList(),
      'cooking_preferences':
          _cookingPreferences.entries
              .where((e) => e.value)
              .map((e) => _cookingPreferencesMap[e.key]!)
              .toList(),
      'religious':
          _religious.entries
              .where((e) => e.value)
              .map((e) => _religiousMap[e.key]!)
              .toList(),
    };
  }

  /// Save preferences to local storage
  Future<void> _saveToLocalStorage() async {
    try {
      final apiFormat = _mapUiToApi();
      await _storageService.savePreferences(
        avoidIngredients: apiFormat['avoid_ingredients']!,
        dietStyle: apiFormat['diet_style']!,
        cookingPreferences: apiFormat['cooking_preferences']!,
        religious: apiFormat['religious']!,
      );
      setState(() {
        _hasChanges = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving to local storage: $e');
      }
    }
  }

  @override
  void dispose() {
    // Save to local storage when leaving (non-blocking)
    if (_hasChanges) {
      _saveToLocalStorage();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Capture context-dependent values
    final dietPreferencesTitle = context.l10n.dietPreferences;
    final dietPreferencesHelper = context.l10n.dietPreferencesHelper;
    final navigator = Navigator.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Save when user presses back
        if (_hasChanges) {
          await _saveToLocalStorage();
        }
        // Check mounted before using navigator
        if (!mounted) return;
        navigator.pop(result);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              SimpleHeader(
                title: dietPreferencesTitle,
                showBackButton: true,
                onBackPressed: () async {
                  // Save when user presses back button
                  if (_hasChanges) {
                    await _saveToLocalStorage();
                  }
                  // Check mounted before using navigator
                  if (!mounted) return;
                  navigator.pop();
                },
              ),

              // Helper text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  dietPreferencesHelper,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Preferences List
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildPreferenceGroup(
                      title: context.l10n.avoidIngredients.toUpperCase(),
                      preferences: _avoidIngredients,
                      getLabel: (key) {
                        switch (key) {
                          case 'nuts':
                            return context.l10n.nuts;
                          case 'shellfish':
                            return context.l10n.shellfish;
                          case 'dairy':
                            return context.l10n.dairy;
                          case 'eggs':
                            return context.l10n.eggs;
                          case 'gluten':
                            return context.l10n.gluten;
                          case 'soy':
                            return context.l10n.soy;
                          default:
                            return key;
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildPreferenceGroup(
                      title: context.l10n.dietStyle.toUpperCase(),
                      preferences: _dietStyle,
                      getLabel: (key) {
                        switch (key) {
                          case 'vegan':
                            return context.l10n.vegan;
                          case 'vegetarian':
                            return context.l10n.vegetarian;
                          case 'pescatarian':
                            return context.l10n.pescatarian;
                          default:
                            return key;
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildPreferenceGroup(
                      title: context.l10n.cookingPreferences.toUpperCase(),
                      preferences: _cookingPreferences,
                      getLabel: (key) {
                        switch (key) {
                          case 'lowCarb':
                            return context.l10n.lowCarb;
                          case 'lowFat':
                            return context.l10n.lowFat;
                          default:
                            return key;
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildPreferenceGroup(
                      title: context.l10n.religious.toUpperCase(),
                      preferences: _religious,
                      getLabel: (key) {
                        switch (key) {
                          case 'halal':
                            return context.l10n.halal;
                          case 'kosher':
                            return context.l10n.kosher;
                          default:
                            return key;
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceGroup({
    required String title,
    required Map<String, bool> preferences,
    required String Function(String) getLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.05,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...preferences.entries.map(
          (entry) => _buildPreferenceItem(
            label: getLabel(entry.key),
            value: entry.value,
            onChanged: (newValue) async {
              setState(() {
                preferences[entry.key] = newValue;
                _hasChanges = true;
              });
              // Save to local storage immediately
              await _saveToLocalStorage();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceItem({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(color: AppColors.borderLight, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
            ToggleSwitch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
