import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/url.dart';

/// Common API error handling and logging utility
class ApiErrorHandler {
  /// Log connection errors with full details
  static void logConnectionError(
    String method,
    String endpoint,
    dynamic error,
    Uri? uri,
  ) {
    final timestamp = DateTime.now().toIso8601String();
    final url = uri?.toString() ?? '${AppUrl.baseUrl}$endpoint';

    debugPrint('╔═══════════════════════════════════════════════════════════');
    debugPrint('║ API CONNECTION ERROR - $timestamp');
    debugPrint('╠═══════════════════════════════════════════════════════════');
    debugPrint('║ Method: $method');
    debugPrint('║ Endpoint: $endpoint');
    debugPrint('║ Full URL: $url');
    debugPrint('║ Base URL: ${AppUrl.baseUrl}');
    debugPrint('║ Error Type: ${error.runtimeType}');
    debugPrint('║ Error Message: $error');
    debugPrint('║');
    debugPrint('║ Environment Config:');
    debugPrint('║   - API_HOST: ${AppUrl.host}');
    debugPrint('║   - API_PORT: ${AppUrl.port}');
    debugPrint('║   - API_PROTOCOL: ${AppUrl.protocol}');
    debugPrint('║   - API_PATH: /api/v1');
    debugPrint('╚═══════════════════════════════════════════════════════════');
  }

  /// Handle HTTP errors with detailed logging
  static void handleHttpError(
    String method,
    String endpoint,
    http.Response response,
    Uri? uri,
  ) {
    final timestamp = DateTime.now().toIso8601String();
    final url = uri?.toString() ?? '${AppUrl.baseUrl}$endpoint';

    debugPrint('╔═══════════════════════════════════════════════════════════');
    debugPrint('║ API HTTP ERROR - $timestamp');
    debugPrint('╠═══════════════════════════════════════════════════════════');
    debugPrint('║ Method: $method');
    debugPrint('║ Endpoint: $endpoint');
    debugPrint('║ Full URL: $url');
    debugPrint('║ Status Code: ${response.statusCode}');
    debugPrint('║ Response Body: ${response.body}');
    debugPrint('║ Base URL: ${AppUrl.baseUrl}');
    debugPrint('╚═══════════════════════════════════════════════════════════');
  }

  /// Wrap API calls with error handling
  static Future<T> handleApiCall<T>({
    required Future<T> Function() apiCall,
    required String method,
    required String endpoint,
    Uri? uri,
    String? errorPrefix,
  }) async {
    try {
      return await apiCall();
    } catch (e) {
      // Check if it's already a handled exception (contains error prefix)
      final isHandledException =
          errorPrefix != null && e.toString().contains(errorPrefix);

      if (!isHandledException) {
        logConnectionError(method, endpoint, e, uri);
      }
      rethrow;
    }
  }
}
