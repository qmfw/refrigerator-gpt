import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../models/ingredient_detection_response.dart';
import '../../config/url.dart';
import '../image_preprocessing_service.dart';
import 'api_error_handler.dart';

/// Detection service for ingredient detection from images
///
/// COST REDUCTION: Images are preprocessed before upload
class DetectionService {
  /// Get base URL from environment configuration
  String get baseUrl => AppUrl.baseUrl;

  /// Detect ingredients from images
  ///
  /// Images are automatically preprocessed (resized & compressed) before upload
  /// This reduces Vision API costs by 50%+
  Future<IngredientDetectionResponse> detectIngredients({
    required List<Uint8List> imageBytes,
    String language = 'en',
    String? appAccountToken,
  }) async {
    // COST REDUCTION: Preprocess all images before upload
    final processedImages = await Future.wait(
      imageBytes.map(
        (bytes) => ImagePreprocessingService.preprocessImage(bytes),
      ),
    );

    // Create multipart request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/detect-ingredients'),
    );

    // Add language parameter
    request.fields['language'] = language;

    // Add appAccountToken if provided
    if (appAccountToken != null) {
      request.fields['appAccountToken'] = appAccountToken;
    }

    // Add processed images
    // Note: FastAPI expects multiple files with the same field name 'images'
    for (int i = 0; i < processedImages.length; i++) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'images', // Same field name for all images
          processedImages[i],
          filename: 'image_$i.jpg',
          contentType: http.MediaType('image', 'jpeg'),
        ),
      );
    }

    // Send request
    return ApiErrorHandler.handleApiCall<IngredientDetectionResponse>(
      method: 'POST',
      endpoint: '/detect-ingredients',
      uri: request.url,
      errorPrefix: 'Failed to detect ingredients',
      apiCall: () async {
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode != 200) {
          ApiErrorHandler.handleHttpError(
            'POST',
            '/detect-ingredients',
            response,
            request.url,
          );
          throw Exception('Failed to detect ingredients: ${response.body}');
        }

        final jsonData = json.decode(response.body);
        return IngredientDetectionResponse.fromJson(jsonData);
      },
    );
  }
}
