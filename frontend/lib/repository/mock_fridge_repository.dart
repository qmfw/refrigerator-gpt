import '../models/models.dart';

/// Mock repository for fridge/recipe data
/// In production, this would be replaced with an API service
class MockFridgeRepository {
  static final MockFridgeRepository _instance =
      MockFridgeRepository._internal();
  factory MockFridgeRepository() => _instance;
  MockFridgeRepository._internal();

  /// Get detected ingredients (mock data)
  Future<List<Ingredient>> getDetectedIngredients() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    return const [
      Ingredient(name: 'Tomatoes'),
      Ingredient(name: 'Onions'),
      Ingredient(name: 'Garlic'),
      Ingredient(name: 'Pasta'),
      Ingredient(name: 'Olive oil'),
      Ingredient(name: 'Basil'),
      Ingredient(name: 'Mozzarella'),
      Ingredient(name: 'Eggs'),
      Ingredient(name: 'Milk'),
      Ingredient(name: 'Butter'),
      Ingredient(name: 'Chicken breast'),
    ];
  }

  /// Get recipe history (mock data)
  Future<List<HistoryEntry>> getHistory() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    return [
      HistoryEntry(
        id: '1',
        emoji: '🍝',
        title: 'Creamy Tomato Pasta',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      HistoryEntry(
        id: '2',
        emoji: '🥗',
        title: 'Garden Fresh Salad',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      HistoryEntry(
        id: '3',
        emoji: '🍲',
        title: 'Chicken Stir Fry',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      HistoryEntry(
        id: '4',
        emoji: '🥘',
        title: 'Vegetable Curry',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      HistoryEntry(
        id: '5',
        emoji: '🍕',
        title: 'Margherita Pizza',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      HistoryEntry(
        id: '6',
        emoji: '🍳',
        title: 'Spanish Omelette',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      HistoryEntry(
        id: '7',
        emoji: '🥙',
        title: 'Mediterranean Wrap',
        createdAt: now.subtract(const Duration(days: 7, hours: 12)),
      ),
      HistoryEntry(
        id: '8',
        emoji: '🍜',
        title: 'Ramen Bowl',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ];
  }

  /// Generate recipes from ingredients (mock data)
  Future<List<Recipe>> generateRecipes(List<Ingredient> ingredients) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Recipe(
        id: '1',
        emoji: '🍳',
        badge: RecipeBadge.fastLazy,
        title: 'Scrambled Eggs & Toast',
        steps: const [
          'Beat eggs with milk and butter',
          'Cook on medium heat, stirring',
          'Toast bread while eggs cook',
          'Season and serve',
        ],
        ingredients: const ['Eggs', 'Milk', 'Butter'],
      ),
      Recipe(
        id: '2',
        emoji: '🍝',
        badge: RecipeBadge.actuallyGood,
        title: 'Creamy Tomato Pasta',
        steps: const [
          'Boil pasta according to package',
          'Sauté garlic and onions in olive oil',
          'Add chopped tomatoes, simmer 10 min',
          'Stir in milk and mozzarella',
          'Toss with pasta and fresh basil',
        ],
        ingredients: const [
          'Pasta',
          'Tomatoes',
          'Garlic',
          'Onions',
          'Olive oil',
          'Milk',
          'Mozzarella',
          'Basil',
        ],
      ),
      Recipe(
        id: '3',
        emoji: '🍗',
        badge: RecipeBadge.shouldntWork,
        title: 'Chicken Parm Surprise',
        steps: const [
          'Flatten chicken with butter wrapper',
          'Coat in beaten egg, then breadcrumbs',
          'Pan-fry in olive oil until golden',
          'Top with tomato sauce & mozzarella',
          'Broil 2 min, garnish with basil',
          'Serve over any leftover pasta',
        ],
        ingredients: const [
          'Chicken breast',
          'Eggs',
          'Butter',
          'Olive oil',
          'Mozzarella',
          'Basil',
          'Pasta',
        ],
      ),
    ];
  }

  /// Get a specific recipe by ID (mock data)
  Future<Recipe?> getRecipeById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    final recipes = await generateRecipes([]);
    try {
      return recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear history (mock implementation)
  Future<void> clearHistory() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // In production, this would call an API to clear history
  }
}
