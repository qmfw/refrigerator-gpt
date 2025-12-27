import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';

class ConfirmIngredientsScreen extends StatefulWidget {
  const ConfirmIngredientsScreen({super.key});

  @override
  State<ConfirmIngredientsScreen> createState() => _ConfirmIngredientsScreenState();
}

class _ConfirmIngredientsScreenState extends State<ConfirmIngredientsScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final List<String> _ingredients = [
    'Tomatoes',
    'Onions',
    'Garlic',
    'Pasta',
    'Olive oil',
    'Basil',
    'Mozzarella',
    'Eggs',
    'Milk',
    'Butter',
    'Chicken breast',
  ];

  void _addIngredient() {
    final text = _ingredientController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _ingredients.add(text);
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
    });
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            SimpleHeader(
              title: 'Confirm Ingredients',
              showBackButton: true,
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Intro Section
                    IntroSection(
                      title: "Here's what I think you have.",
                      subtitle: 'I might be wrong. Fix anything.',
                    ),

                    const SizedBox(height: 32),

                    // Ingredients Grid
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _ingredients.map((ingredient) {
                        return IngredientChip(
                          ingredient: ingredient,
                          onRemove: () => _removeIngredient(ingredient),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // Add Ingredient Input
                    AddIngredientInput(
                      controller: _ingredientController,
                      placeholder: 'Add something else…',
                      onSubmitted: _addIngredient,
                    ),

                    const SizedBox(height: 32),

                    // Spacer
                    const SizedBox(height: 24),

                    // Cook Button
                    PrimaryButton(
                      text: '🍳 Cook with this',
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          '/loading-generate',
                        );
                      },
                      fullWidth: true,
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

