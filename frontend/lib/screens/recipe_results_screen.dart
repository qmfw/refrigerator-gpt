import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';

class RecipeResultsScreen extends StatelessWidget {
  const RecipeResultsScreen({super.key});

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Here's what you can make",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '3 recipes found',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Recipes List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Recipe 1: Fast & Lazy
                    RecipeCard(
                      emoji: '🍳',
                      badge: 'Fast & Lazy',
                      title: 'Scrambled Eggs & Toast',
                      steps: [
                        'Beat eggs with milk and butter',
                        'Cook on medium heat, stirring',
                        'Toast bread while eggs cook',
                        'Season and serve',
                      ],
                      onShare: () {
                        // Share recipe
                      },
                    ),

                    // Recipe 2: Actually Good
                    RecipeCard(
                      emoji: '🍝',
                      badge: 'Actually Good',
                      title: 'Creamy Tomato Pasta',
                      steps: [
                        'Boil pasta according to package',
                        'Sauté garlic and onions in olive oil',
                        'Add chopped tomatoes, simmer 10 min',
                        'Stir in milk and mozzarella',
                        'Toss with pasta and fresh basil',
                      ],
                      onShare: () {
                        // Share recipe
                      },
                    ),

                    // Recipe 3: This Shouldn't Work
                    RecipeCard(
                      emoji: '🍗',
                      badge: 'This Shouldn\'t Work',
                      title: 'Chicken Parm Surprise',
                      steps: [
                        'Flatten chicken with butter wrapper',
                        'Coat in beaten egg, then breadcrumbs',
                        'Pan-fry in olive oil until golden',
                        'Top with tomato sauce & mozzarella',
                        'Broil 2 min, garnish with basil',
                        'Serve over any leftover pasta',
                      ],
                      onShare: () {
                        // Share recipe
                      },
                    ),

                    const SizedBox(height: 20),

                    // Secondary Actions
                    Column(
                      children: [
                        SecondaryButton(
                          text: 'Edit ingredients',
                          icon: Icons.edit,
                          onPressed: () {
                            Navigator.pushNamed(context, '/confirm-ingredients');
                          },
                          fullWidth: true,
                        ),
                        const SizedBox(height: 12),
                        SecondaryButton(
                          text: 'Scan again',
                          icon: Icons.camera_alt,
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/scan');
                          },
                          fullWidth: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            BottomNav(
              activeItem: NavItem.scan,
              onItemTap: (item) {
                switch (item) {
                  case NavItem.home:
                    Navigator.pushReplacementNamed(context, '/');
                    break;
                  case NavItem.scan:
                    // Already on scan flow
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

