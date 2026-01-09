import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../localization/app_localizations_extension.dart';

class DietPreferencesScreen extends StatefulWidget {
  const DietPreferencesScreen({super.key});

  @override
  State<DietPreferencesScreen> createState() => _DietPreferencesScreenState();
}

class _DietPreferencesScreenState extends State<DietPreferencesScreen> {
  // Avoid ingredients
  final Map<String, bool> _avoidIngredients = {
    'Nuts': false,
    'Shellfish': false,
    'Dairy': false,
    'Eggs': false,
    'Gluten': false,
    'Soy': false,
  };

  // Diet style
  final Map<String, bool> _dietStyle = {
    'Vegan': false,
    'Vegetarian': false,
    'Pescatarian': false,
  };

  // Cooking preferences
  final Map<String, bool> _cookingPreferences = {
    'Low carb': false,
    'Low fat': false,
  };

  // Religious
  final Map<String, bool> _religious = {'Halal': false, 'Kosher': false};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            SimpleHeader(
              title: context.l10n.dietPreferences,
              showBackButton: true,
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),

            // Helper text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                context.l10n.dietPreferencesHelper,
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
                    title: 'AVOID INGREDIENTS',
                    preferences: _avoidIngredients,
                  ),
                  const SizedBox(height: 32),
                  _buildPreferenceGroup(
                    title: 'DIET STYLE',
                    preferences: _dietStyle,
                  ),
                  const SizedBox(height: 32),
                  _buildPreferenceGroup(
                    title: 'COOKING PREFERENCES',
                    preferences: _cookingPreferences,
                  ),
                  const SizedBox(height: 32),
                  _buildPreferenceGroup(
                    title: 'RELIGIOUS',
                    preferences: _religious,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceGroup({
    required String title,
    required Map<String, bool> preferences,
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
            label: entry.key,
            value: entry.value,
            onChanged: (newValue) {
              setState(() {
                preferences[entry.key] = newValue;
              });
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
