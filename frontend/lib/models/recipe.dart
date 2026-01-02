import '../localization/app_localizations_extension.dart';
import 'package:flutter/material.dart';

/// Recipe badge type
enum RecipeBadge { fastLazy, actuallyGood, shouldntWork }

/// Recipe model
class Recipe {
  final String id;
  final String emoji;
  final RecipeBadge badge;
  final String title;
  final List<String> steps;
  final List<String>? ingredients;

  const Recipe({
    required this.id,
    required this.emoji,
    required this.badge,
    required this.title,
    required this.steps,
    this.ingredients,
  });

  /// Get localized badge string
  String getBadgeString(BuildContext context) {
    switch (badge) {
      case RecipeBadge.fastLazy:
        return context.l10n.recipeBadgeFastLazy;
      case RecipeBadge.actuallyGood:
        return context.l10n.recipeBadgeActuallyGood;
      case RecipeBadge.shouldntWork:
        return context.l10n.recipeBadgeShouldntWork;
    }
  }
}
