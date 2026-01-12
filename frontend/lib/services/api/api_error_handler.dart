import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Centralized API error handling and logging
class ApiErrorHandler {
  /// Handle API calls with consistent error handling and logging
  static Future<T> handleApiCall<T>({
    required String method,
    required String endpoint,
    required Uri uri,
    required String errorPrefix,
    required Future<T> Function() apiCall,
  }) async {
    try {
      return await apiCall();
    } on http.ClientException catch (e) {
      _logConnectionError(method, endpoint, uri, e);
      rethrow;
    } catch (e) {
      _logError(method, endpoint, uri, e);
      rethrow;
    }
  }

  /// Handle HTTP errors with detailed logging
  static void handleHttpError(
    String method,
    String endpoint,
    http.Response response,
    Uri uri,
  ) {
    _logHttpError(method, endpoint, response, uri);
  }

  /// Log connection errors (network issues)
  static void _logConnectionError(
    String method,
    String endpoint,
    Uri uri,
    dynamic error,
  ) {
    if (kDebugMode) {
      debugPrint(
        '╔═══════════════════════════════════════════════════════════',
      );
      debugPrint(
        '║ API CONNECTION ERROR - ${DateTime.now().toIso8601String()}',
      );
      debugPrint(
        '╠═══════════════════════════════════════════════════════════',
      );
      debugPrint('║ Method: $method');
      debugPrint('║ Endpoint: $endpoint');
      debugPrint('║ Full URL: $uri');
      debugPrint(
        '║ Base URL: ${uri.origin}${uri.path.split('/').take(3).join('/')}',
      );
      debugPrint('║ Error Type: ${error.runtimeType}');
      debugPrint('║ Error Message: $error');
      debugPrint('║');
      debugPrint('║ Environment Config:');
      debugPrint('║   - API_HOST: ${uri.host}');
      debugPrint('║   - API_PORT: ${uri.port}');
      debugPrint('║   - API_PROTOCOL: ${uri.scheme}');
      debugPrint('║   - API_PATH: ${uri.path.split('/').take(3).join('/')}');
      debugPrint(
        '╚═══════════════════════════════════════════════════════════',
      );
    }
  }

  /// Log HTTP errors (non-200 status codes)
  static void _logHttpError(
    String method,
    String endpoint,
    http.Response response,
    Uri uri,
  ) {
    if (kDebugMode) {
      debugPrint(
        '╔═══════════════════════════════════════════════════════════',
      );
      debugPrint('║ API HTTP ERROR - ${DateTime.now().toIso8601String()}');
      debugPrint(
        '╠═══════════════════════════════════════════════════════════',
      );
      debugPrint('║ Method: $method');
      debugPrint('║ Endpoint: $endpoint');
      debugPrint('║ Full URL: $uri');
      debugPrint('║ Status Code: ${response.statusCode}');
      debugPrint('║ Response Body: ${response.body}');
      debugPrint(
        '║ Base URL: ${uri.origin}${uri.path.split('/').take(3).join('/')}',
      );
      debugPrint(
        '╚═══════════════════════════════════════════════════════════',
      );
    }
  }

  /// Log general errors
  static void _logError(
    String method,
    String endpoint,
    Uri uri,
    dynamic error,
  ) {
    if (kDebugMode) {
      debugPrint(
        '╔═══════════════════════════════════════════════════════════',
      );
      debugPrint('║ API ERROR - ${DateTime.now().toIso8601String()}');
      debugPrint(
        '╠═══════════════════════════════════════════════════════════',
      );
      debugPrint('║ Method: $method');
      debugPrint('║ Endpoint: $endpoint');
      debugPrint('║ Full URL: $uri');
      debugPrint('║ Error: $error');
      debugPrint(
        '╚═══════════════════════════════════════════════════════════',
      );
    }
  }
}
