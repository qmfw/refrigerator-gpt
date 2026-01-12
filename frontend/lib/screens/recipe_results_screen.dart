import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations_extension.dart';
import '../models/models.dart';
import '../services/api/recipe_service.dart';

class RecipeResultsScreen extends StatefulWidget {
  const RecipeResultsScreen({super.key});

  @override
  State<RecipeResultsScreen> createState() => _RecipeResultsScreenState();
}

class _RecipeResultsScreenState extends State<RecipeResultsScreen> {
  List<Recipe> _recipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Defer loading until after first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadRecipes();
      }
    });
  }

  Future<void> _loadRecipes() async {
    // Get recipes or recipe ID from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is List<Recipe>) {
      // Recipes passed directly (from recipe generation)
      if (mounted) {
        setState(() {
          _recipes = args;
          _isLoading = false;
        });
      }
    } else if (args is String) {
      // Recipe ID passed (from history)
      try {
        final recipeService = RecipeService();
        final language = context.languageCode;
        final recipe = await recipeService.getRecipe(
          recipeId: args,
          language: language,
        );
        if (mounted) {
          setState(() {
            _recipes = [recipe];
            _isLoading = false;
          });
        }
      } catch (e) {
        // Failed to fetch recipe - show empty state
        if (mounted) {
          setState(() {
            _recipes = [];
            _isLoading = false;
          });
        }
      }
    } else {
      // No arguments - empty state
      if (mounted) {
        setState(() {
          _recipes = [];
          _isLoading = false;
        });
      }
    }
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
                                    // Pass empty list to start fresh
                                    Navigator.pushNamed(
                                      context,
                                      '/confirm-ingredients',
                                      arguments: <Ingredient>[],
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
