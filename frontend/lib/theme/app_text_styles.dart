import 'package:flutter/material.dart';
import 'app_colors.dart';

/// FridgeGPT Text Styles
/// Based on the HTML export specifications
class AppTextStyles {
  // Headers
  static TextStyle get appTitle => const TextStyle(
        fontSize: 28.0, // 1.75rem
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get headerTitle => const TextStyle(
        fontSize: 28.0, // 1.75rem
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get headerSubtitle => const TextStyle(
        fontSize: 16.0, // 1rem
        color: AppColors.textSecondary,
      );

  // Body Text
  static TextStyle get bodyLarge => const TextStyle(
        fontSize: 16.0, // 1rem
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontSize: 15.0, // 0.9375rem
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontSize: 14.0, // 0.875rem
        color: AppColors.textSecondary,
      );

  // Buttons
  static TextStyle get buttonLarge => const TextStyle(
        fontSize: 22.0, // 1.375rem
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get buttonMedium => const TextStyle(
        fontSize: 18.0, // 1.125rem
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get buttonSmall => const TextStyle(
        fontSize: 16.0, // 1rem
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get buttonSecondary => const TextStyle(
        fontSize: 16.0, // 1rem
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  // Labels
  static TextStyle get label => const TextStyle(
        fontSize: 12.0, // 0.75rem
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelUppercase => const TextStyle(
        fontSize: 14.0, // 0.875rem
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      );

  // Recipe Text
  static TextStyle get recipeTitle => const TextStyle(
        fontSize: 20.0, // 1.25rem
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get recipeStep => const TextStyle(
        fontSize: 15.0, // 0.9375rem
        color: AppColors.textPrimary,
        height: 1.6,
      );

  // Card Text
  static TextStyle get cardTitle => const TextStyle(
        fontSize: 14.0, // 0.875rem
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      );

  static TextStyle get cardDate => const TextStyle(
        fontSize: 12.0, // 0.75rem
        color: AppColors.textHint,
      );

  // Loading Text
  static TextStyle get loadingText => const TextStyle(
        fontSize: 18.0, // 1.125rem
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );
}

