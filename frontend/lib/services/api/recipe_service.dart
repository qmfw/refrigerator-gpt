import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../../config/url.dart';
import 'api_error_handler.dart';

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
    Map<String, List<String>>? dietPreferences,
  }) async {
    final requestBody = {
      'ingredients':
          ingredients
              .map((ing) => {'id': ing.id ?? '', 'name': ing.name})
              .toList(),
      'language': language,
      'max_recipes': maxRecipes,
      if (appAccountToken != null) 'appAccountToken': appAccountToken,
      if (dietPreferences != null) 'diet_preferences': dietPreferences,
    };

    final uri = Uri.parse('$baseUrl/generate-recipes');

    return ApiErrorHandler.handleApiCall<RecipeGenerationResponse>(
      method: 'POST',
      endpoint: '/generate-recipes',
      uri: uri,
      errorPrefix: 'Failed to generate recipes',
      apiCall: () async {
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        if (response.statusCode != 200) {
          ApiErrorHandler.handleHttpError(
            'POST',
            '/generate-recipes',
            response,
            uri,
          );
          throw Exception('Failed to generate recipes: ${response.body}');
        }

        final jsonData = json.decode(response.body);
        return RecipeGenerationResponse.fromJson(jsonData);
      },
    );
  }

  /// Get recipe by ID in specific language
  Future<Recipe> getRecipe({
    required String recipeId,
    String language = 'en',
  }) async {
    final uri = Uri.parse(
      '$baseUrl/recipes/$recipeId',
    ).replace(queryParameters: {'language': language});

    return ApiErrorHandler.handleApiCall<Recipe>(
      method: 'GET',
      endpoint: '/recipes/$recipeId',
      uri: uri,
      errorPrefix: 'Failed to get recipe',
      apiCall: () async {
        final response = await http.get(uri);

        if (response.statusCode != 200) {
          ApiErrorHandler.handleHttpError(
            'GET',
            '/recipes/$recipeId',
            response,
            uri,
          );
          throw Exception('Failed to get recipe: ${response.body}');
        }

        final jsonData = json.decode(response.body);
        return Recipe.fromJson(jsonData);
      },
    );
  }

  /// Get user's recipe history with full recipe data
  /// Only requires language parameter - recipe IDs are determined from server
  Future<List<HistoryEntry>> getHistory({
    required String appAccountToken,
    required String language,
  }) async {
    final uri = Uri.parse('$baseUrl/history').replace(
      queryParameters: {
        'appAccountToken': appAccountToken,
        'language': language,
      },
    );

    return ApiErrorHandler.handleApiCall<List<HistoryEntry>>(
      method: 'GET',
      endpoint: '/history',
      uri: uri,
      errorPrefix: 'Failed to get history',
      apiCall: () async {
        final response = await http.get(uri);

        if (response.statusCode != 200) {
          ApiErrorHandler.handleHttpError('GET', '/history', response, uri);
          throw Exception('Failed to get history: ${response.body}');
        }

        final jsonData = json.decode(response.body);
        final historyList =
            (jsonData['history'] as List).map((item) {
              // Parse recipes if present (grouped recipes)
              List<Recipe>? recipes;
              if (item['recipes'] != null) {
                recipes =
                    (item['recipes'] as List)
                        .map((r) => Recipe.fromJson(r))
                        .toList();
              }

              return HistoryEntry(
                id: item['recipe_id'] as String,
                emoji: item['emoji'] as String,
                badge: item['badge'] as String,
                title: item['title'] as String,
                steps: List<String>.from(item['steps'] as List),
                ingredients:
                    item['ingredients'] != null
                        ? List<String>.from(item['ingredients'] as List)
                        : null,
                createdAt: DateTime.parse(item['created_at'] as String),
                recipes: recipes,
              );
            }).toList();

        return historyList;
      },
    );
  }

  /// Clear all history for a user
  Future<void> clearHistory({required String appAccountToken}) async {
    final uri = Uri.parse(
      '$baseUrl/history',
    ).replace(queryParameters: {'appAccountToken': appAccountToken});

    return ApiErrorHandler.handleApiCall<void>(
      method: 'DELETE',
      endpoint: '/history',
      uri: uri,
      errorPrefix: 'Failed to clear history',
      apiCall: () async {
        final response = await http.delete(uri);

        if (response.statusCode != 200) {
          ApiErrorHandler.handleHttpError('DELETE', '/history', response, uri);
          throw Exception('Failed to clear history: ${response.body}');
        }
      },
    );
  }

  /// Delete a recipe from history
  Future<void> deleteHistoryEntry({
    required String recipeId,
    required String appAccountToken,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/history/$recipeId',
    ).replace(queryParameters: {'appAccountToken': appAccountToken});

    return ApiErrorHandler.handleApiCall<void>(
      method: 'DELETE',
      endpoint: '/history/$recipeId',
      uri: uri,
      errorPrefix: 'Failed to delete history entry',
      apiCall: () async {
        final response = await http.delete(uri);

        if (response.statusCode != 200) {
          ApiErrorHandler.handleHttpError(
            'DELETE',
            '/history/$recipeId',
            response,
            uri,
          );
          throw Exception('Failed to delete history entry: ${response.body}');
        }
      },
    );
  }
}
