import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Image preprocessing service for cost reduction
///
/// COST REDUCTION STRATEGY:
/// - Resize images to max 512-768px width (reduces Vision API cost by ~50%)
/// - Compress JPEG to 70-80% quality (further reduces upload size)
///
/// Vision API cost scales with pixel count, so smaller images = much lower cost
class ImagePreprocessingService {
  static const int maxWidth =
      640; // 512-768px range, using 640 as middle ground
  static const int jpegQuality = 75; // 70-80% range, using 75%

  /// Preprocess image: resize and compress
  ///
  /// Returns processed image bytes ready for upload
  static Future<Uint8List> preprocessImage(Uint8List imageBytes) async {
    // Decode image
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize if image is larger than maxWidth
    if (image.width > maxWidth) {
      final aspectRatio = image.height / image.width;
      final newHeight = (maxWidth * aspectRatio).round();
      image = img.copyResize(
        image,
        width: maxWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear, // Faster than cubic
      );
    }

    // Compress as JPEG with quality setting
    final compressedBytes = Uint8List.fromList(
      img.encodeJpg(image, quality: jpegQuality),
    );

    return compressedBytes;
  }

  /// Preprocess image from file path
  static Future<Uint8List> preprocessImageFromFile(String filePath) async {
    final file = File(filePath);
    final imageBytes = await file.readAsBytes();
    return preprocessImage(imageBytes);
  }

  /// Get estimated cost savings info (for debugging/monitoring)
  static Map<String, dynamic> getCostSavingsInfo(
    int originalSize,
    int processedSize,
  ) {
    final sizeReduction = ((originalSize - processedSize) / originalSize * 100);
    return {
      'original_size_kb': (originalSize / 1024).toStringAsFixed(2),
      'processed_size_kb': (processedSize / 1024).toStringAsFixed(2),
      'size_reduction_percent': sizeReduction.toStringAsFixed(1),
      'estimated_cost_reduction':
          '~${(sizeReduction * 0.5).toStringAsFixed(1)}%', // Rough estimate
    };
  }
}
