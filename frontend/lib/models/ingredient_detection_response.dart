import 'ingredient.dart';

/// Response model for ingredient detection
class IngredientDetectionResponse {
  final List<Ingredient> ingredients;
  final String detectionId;
  final double confidence;

  const IngredientDetectionResponse({
    required this.ingredients,
    required this.detectionId,
    required this.confidence,
  });

  factory IngredientDetectionResponse.fromJson(Map<String, dynamic> json) {
    return IngredientDetectionResponse(
      ingredients:
          (json['ingredients'] as List)
              .map((ing) => Ingredient.fromJson(ing as Map<String, dynamic>))
              .toList(),
      detectionId: json['detection_id'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}
