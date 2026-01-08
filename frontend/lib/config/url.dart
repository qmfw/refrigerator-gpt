import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

/// URL configuration service
///
/// Reads backend URL from environment variables (.env file)
/// Falls back to localhost for development if not set
class AppUrl {
  /// Get the base API URL from environment variables
  ///
  /// Reads from .env file:
  /// - API_BASE_URL: Full base URL (e.g., https://api.example.com/api/v1)
  /// - API_HOST: Host only (e.g., api.example.com)
  /// - API_PORT: Port number (e.g., 8000)
  ///
  /// Priority: API_BASE_URL > API_HOST + API_PORT
  static String get baseUrl {
    // Try to get full base URL first
    final fullUrl = dotenv.env['API_BASE_URL'];
    if (fullUrl != null && fullUrl.isNotEmpty) {
      return fullUrl;
    }

    // Fall back to constructing from host and port
    final host = dotenv.env['API_HOST'] ?? 'localhost';
    final port = dotenv.env['API_PORT'] ?? '8000';
    final protocol =
        dotenv.env['API_PROTOCOL'] ?? (kDebugMode ? 'http' : 'https');
    final apiPath = dotenv.env['API_PATH'] ?? '/api/v1';

    return '$protocol://$host:$port$apiPath';
  }

  /// Get API host
  static String get host {
    return dotenv.env['API_HOST'] ?? 'localhost';
  }

  /// Get API port
  static String get port {
    return dotenv.env['API_PORT'] ?? '8000';
  }

  /// Get API protocol
  static String get protocol {
    return dotenv.env['API_PROTOCOL'] ?? (kDebugMode ? 'http' : 'https');
  }

  /// Check if environment is loaded
  static bool get isLoaded => dotenv.isInitialized;
}
