import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../models/recipe_generation_response.dart';
import '../../config/url.dart';

/// Recipe service for recipe generation and retrieval
class RecipeService {
  /// Get base URL from environment configuration
  String get baseUrl => AppUrl.baseUrl;

  /// Generate recipes from ingredients
  Future<RecipeGenerationResponse> generateRecipes({
    required List<Ingredient> ingredients,
    String language = 'en',
    int maxRecipes = 3,
    String? appAccountToken,
  }) async {
    final requestBody = {
      'ingredients':
          ingredients
              .map((ing) => {'id': ing.id ?? '', 'name': ing.name})
              .toList(),
      'language': language,
      'max_recipes': maxRecipes,
      if (appAccountToken != null) 'appAccountToken': appAccountToken,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/generate-recipes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate recipes: ${response.body}');
    }

    final jsonData = json.decode(response.body);
    return RecipeGenerationResponse.fromJson(jsonData);
  }

  /// Get recipe by ID in specific language
  Future<Recipe> getRecipe({
    required String recipeId,
    String language = 'en',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/recipes/$recipeId',
      ).replace(queryParameters: {'language': language}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get recipe: ${response.body}');
    }

    final jsonData = json.decode(response.body);
    return Recipe.fromJson(jsonData);
  }
}
