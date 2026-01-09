import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations_extension.dart';
import '../models/models.dart';
import '../services/api/recipe_service.dart';
import '../services/history_storage_service.dart';

class LoadingGenerateScreen extends StatefulWidget {
  const LoadingGenerateScreen({super.key});

  @override
  State<LoadingGenerateScreen> createState() => _LoadingGenerateScreenState();
}

class _LoadingGenerateScreenState extends State<LoadingGenerateScreen> {
  @override
  void initState() {
    super.initState();
    // Defer loading until after first frame to ensure route is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateRecipes();
    });
  }

  Future<void> _generateRecipes() async {
    try {
      // Get ingredients from route arguments
      final args = ModalRoute.of(context)?.settings.arguments;

      List<Ingredient> ingredients = [];
      if (args != null) {
        if (args is List<Ingredient>) {
          ingredients = args;
        } else if (args is List) {
          // Try to convert list of dynamic to List<Ingredient>
          try {
            ingredients = args.whereType<Ingredient>().toList();
          } catch (e) {
            // If conversion fails, use empty list
            ingredients = [];
          }
        }
      }

      if (ingredients.isEmpty) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/recipe-results',
            arguments: <Recipe>[],
          );
        }
        return;
      }

      // Call RecipeService
      final recipeService = RecipeService();
      final language = context.languageCode;

      final response = await recipeService.generateRecipes(
        ingredients: ingredients,
        language: language,
        maxRecipes: 3,
      );

      // Save first recipe to history (local storage)
      final historyService = HistoryStorageService();
      if (response.recipes.isNotEmpty) {
        final recipe = response.recipes.first;
        await historyService.saveHistoryEntry(
          HistoryEntry(
            id: recipe.id,
            emoji: recipe.emoji,
            title: recipe.title,
            createdAt: DateTime.now(),
            languageCode: language,
          ),
        );
      }

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/recipe-results',
          arguments: response.recipes,
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate recipes: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: LoadingIndicator(message: context.l10n.fridgeHasPotential),
        ),
      ),
    );
  }
}
