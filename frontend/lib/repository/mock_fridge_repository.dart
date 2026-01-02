import '../models/models.dart';
import '../services/history_storage_service.dart';

/// Mock repository for fridge/recipe data
/// In production, this would be replaced with an API service
///
/// Cost-saving strategy: History is stored locally to avoid API calls
class MockFridgeRepository {
  static final MockFridgeRepository _instance =
      MockFridgeRepository._internal();
  factory MockFridgeRepository() => _instance;
  MockFridgeRepository._internal();

  final HistoryStorageService _historyStorage = HistoryStorageService();

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

  /// Get recipe history from local storage
  /// Uses local storage to avoid API calls and reduce costs
  Future<List<HistoryEntry>> getHistory() async {
    return await _historyStorage.getHistory();
  }

  /// Save a recipe to history (local storage)
  /// Called when recipes are generated to save the first recipe
  ///
  /// Note: Title is stored in the language it was generated.
  /// When viewing the recipe, fetch it from API with current language.
  /// This avoids storing multiple translations and keeps storage minimal.
  Future<void> saveRecipeToHistory(
    Recipe recipe, {
    String? languageCode,
  }) async {
    final historyEntry = HistoryEntry(
      id: recipe.id,
      emoji: recipe.emoji,
      title: recipe.title, // Stored in language when generated
      createdAt: DateTime.now(),
      languageCode: languageCode, // Optional: track original language
    );
    await _historyStorage.saveHistoryEntry(historyEntry);
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

  /// Clear history from local storage
  Future<void> clearHistory() async {
    await _historyStorage.clearHistory();
  }
}
