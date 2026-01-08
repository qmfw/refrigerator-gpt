import 'recipe.dart';

/// Response model for recipe generation
class RecipeGenerationResponse {
  final List<Recipe> recipes;
  final String generationId;

  const RecipeGenerationResponse({
    required this.recipes,
    required this.generationId,
  });

  factory RecipeGenerationResponse.fromJson(Map<String, dynamic> json) {
    return RecipeGenerationResponse(
      recipes:
          (json['recipes'] as List)
              .map((recipe) => Recipe.fromJson(recipe as Map<String, dynamic>))
              .toList(),
      generationId: json['generation_id'] as String,
    );
  }
}
