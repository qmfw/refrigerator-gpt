import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations_extension.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.appName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Scan Button
                    ScanButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/scan');
                      },
                    ),

                    const SizedBox(height: 24),

                    // Last Result Card (optional)
                    LastResultCard(
                      recipeName: 'Creamy Tomato Pasta',
                      timeAgo: '2 hours ago',
                      emoji: '🍝',
                      recipeCount: 3,
                      onTap: () {
                        Navigator.pushNamed(context, '/recipe-results');
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            BottomNav(
              activeItem: NavItem.home,
              onItemTap: (item) {
                switch (item) {
                  case NavItem.home:
                    // Already on home
                    break;
                  case NavItem.scan:
                    Navigator.pushReplacementNamed(context, '/scan');
                    break;
                  case NavItem.history:
                    Navigator.pushReplacementNamed(context, '/history');
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
