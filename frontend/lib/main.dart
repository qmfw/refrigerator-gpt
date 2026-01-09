import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/photo_review_screen.dart';
import 'screens/loading_detect_screen.dart';
import 'screens/confirm_ingredients_screen.dart';
import 'screens/loading_generate_screen.dart';
import 'screens/recipe_results_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/language_screen.dart';
import 'screens/diet_preferences_screen.dart';
import 'theme/app_colors.dart';
import 'localization/localizations_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // .env file is optional - will use defaults in url.dart
    debugPrint('Warning: Could not load .env file: $e');
  }

  runApp(const FridgeGPTApp());
}

class FridgeGPTApp extends StatelessWidget {
  const FridgeGPTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LocalizationsProvider(
      child: MaterialApp(
        title: 'FridgeGPT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.background,
          fontFamily:
              '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/scan': (context) => const ScanScreen(),
          '/photo-review': (context) => const PhotoReviewScreen(),
          '/loading-detect': (context) => const LoadingDetectScreen(),
          '/confirm-ingredients': (context) => const ConfirmIngredientsScreen(),
          '/loading-generate': (context) => const LoadingGenerateScreen(),
          '/recipe-results': (context) => const RecipeResultsScreen(),
          '/history': (context) => const HistoryScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/about': (context) => const AboutScreen(),
          '/privacy': (context) => const PrivacyScreen(),
          '/language': (context) => const LanguageScreen(),
          '/diet-preferences': (context) => const DietPreferencesScreen(),
        },
      ),
    );
  }
}
