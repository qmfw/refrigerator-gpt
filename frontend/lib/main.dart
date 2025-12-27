import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/photo_review_screen.dart';
import 'screens/loading_detect_screen.dart';
import 'screens/confirm_ingredients_screen.dart';
import 'screens/loading_generate_screen.dart';
import 'screens/recipe_results_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const FridgeGPTApp());
}

class FridgeGPTApp extends StatelessWidget {
  const FridgeGPTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FridgeGPT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
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
      },
    );
  }
}
