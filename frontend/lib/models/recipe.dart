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
  final String? imageUrl; // Foodish API image URL

  const Recipe({
    required this.id,
    required this.emoji,
    required this.badge,
    required this.title,
    required this.steps,
    this.ingredients,
    this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    RecipeBadge parseBadge(String badgeStr) {
      switch (badgeStr) {
        case 'fastLazy':
          return RecipeBadge.fastLazy;
        case 'actuallyGood':
          return RecipeBadge.actuallyGood;
        case 'shouldntWork':
          return RecipeBadge.shouldntWork;
        default:
          return RecipeBadge.fastLazy;
      }
    }

    return Recipe(
      id: json['id'] as String,
      emoji: json['emoji'] as String,
      badge: parseBadge(json['badge'] as String),
      title: json['title'] as String,
      steps: List<String>.from(json['steps'] as List),
      ingredients:
          json['ingredients'] != null
              ? List<String>.from(json['ingredients'] as List)
              : null,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    String badgeToString(RecipeBadge badge) {
      switch (badge) {
        case RecipeBadge.fastLazy:
          return 'fastLazy';
        case RecipeBadge.actuallyGood:
          return 'actuallyGood';
        case RecipeBadge.shouldntWork:
          return 'shouldntWork';
      }
    }

    return {
      'id': id,
      'emoji': emoji,
      'badge': badgeToString(badge),
      'title': title,
      'steps': steps,
      'ingredients': ingredients,
    };
  }

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
