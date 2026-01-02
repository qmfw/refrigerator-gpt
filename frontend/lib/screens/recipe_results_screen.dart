import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations_extension.dart';
import '../models/models.dart';
import '../repository/mock_fridge_repository.dart';

class RecipeResultsScreen extends StatefulWidget {
  const RecipeResultsScreen({super.key});

  @override
  State<RecipeResultsScreen> createState() => _RecipeResultsScreenState();
}

class _RecipeResultsScreenState extends State<RecipeResultsScreen> {
  final MockFridgeRepository _repository = MockFridgeRepository();
  List<Recipe> _recipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    // In production, this would use the actual detected ingredients
    // For now, we'll use empty list to get mock recipes
    final ingredients = await _repository.getDetectedIngredients();
    final recipes = await _repository.generateRecipes(ingredients);

    // Save the first recipe to history (local storage)
    // This avoids API calls for history retrieval
    if (recipes.isNotEmpty) {
      await _repository.saveRecipeToHistory(recipes.first);
    }

    setState(() {
      _recipes = recipes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.heresWhatYouCanMake,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.recipesFound(_recipes.length),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Recipes List
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            ..._recipes.map((recipe) {
                              return RecipeCard(
                                emoji: recipe.emoji,
                                badge: recipe.getBadgeString(context),
                                title: recipe.title,
                                steps: recipe.steps,
                                onShare: () {
                                  // Share recipe
                                },
                              );
                            }),

                            const SizedBox(height: 20),

                            // Secondary Actions
                            Column(
                              children: [
                                SecondaryButton(
                                  text: context.l10n.editIngredients,
                                  icon: Icons.edit,
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/confirm-ingredients',
                                    );
                                  },
                                  fullWidth: true,
                                ),
                                const SizedBox(height: 12),
                                SecondaryButton(
                                  text: context.l10n.scanAgain,
                                  icon: Icons.camera_alt,
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/scan',
                                    );
                                  },
                                  fullWidth: true,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
            ),

            // Bottom Navigation
            BottomNav(
              activeItem: NavItem.scan,
              onItemTap: (item) {
                switch (item) {
                  case NavItem.home:
                    Navigator.pushReplacementNamed(context, '/');
                    break;
                  case NavItem.scan:
                    // Already on scan flow
                    break;
                  case NavItem.history:
                    Navigator.pushReplacementNamed(context, '/history');
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
