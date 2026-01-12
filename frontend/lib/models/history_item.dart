import 'recipe.dart';

/// History entry model representing a past recipe scan
///
/// Now fetched from server via bulk API with full recipe data - no additional API call needed
/// Supports single recipes or grouped recipes (multiple recipes generated together)
class HistoryEntry {
  final String id; // recipe_id (primary recipe ID)
  final String emoji; // Primary emoji
  final String badge; // fastLazy, actuallyGood, shouldntWork
  final String
  title; // Combined title for grouped recipes (e.g., "Recipe 1, Recipe 2, and Recipe 3")
  final List<String>
  steps; // Steps from primary recipe (for backward compatibility)
  final List<String>?
  ingredients; // Ingredients from primary recipe (for backward compatibility)
  final DateTime createdAt;
  final List<Recipe>?
  recipes; // All recipes in this batch (if grouped, null for single recipes)

  const HistoryEntry({
    required this.id,
    required this.emoji,
    required this.badge,
    required this.title,
    required this.steps,
    this.ingredients,
    required this.createdAt,
    this.recipes,
  });

  /// Convert to Recipe object for recipe results screen
  Recipe toRecipe() {
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
      id: id,
      emoji: emoji,
      badge: parseBadge(badge),
      title: title,
      steps: steps,
      ingredients: ingredients,
    );
  }

  /// Get a human-readable time ago string
  /// This should be localized in production
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 14) {
      return '1 week ago';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks weeks ago';
    }
  }
}
