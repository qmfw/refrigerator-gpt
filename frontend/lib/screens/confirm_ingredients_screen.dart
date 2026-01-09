import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations_extension.dart';
import '../models/models.dart';

class ConfirmIngredientsScreen extends StatefulWidget {
  const ConfirmIngredientsScreen({super.key});

  @override
  State<ConfirmIngredientsScreen> createState() =>
      _ConfirmIngredientsScreenState();
}

class _ConfirmIngredientsScreenState extends State<ConfirmIngredientsScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  List<Ingredient> _ingredients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Defer loading until after first frame to ensure route is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIngredients();
    });
  }

  void _loadIngredients() {
    // Get ingredients from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;

    List<Ingredient> ingredients = [];
    if (args != null) {
      if (args is List<Ingredient>) {
        ingredients = args;
      } else if (args is List) {
        // Try to convert list of dynamic to List<Ingredient>
        try {
          ingredients = args.whereType<Ingredient>().toList();
        } catch (e) {
          // If conversion fails, use empty list
          ingredients = [];
        }
      }
    }

    setState(() {
      _ingredients = ingredients;
      _isLoading = false;
    });
  }

  void _addIngredient() {
    final text = _ingredientController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _ingredients.add(Ingredient(name: text));
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(Ingredient ingredient) {
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
              title: context.l10n.confirmIngredients,
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
                      title: context.l10n.heresWhatIThink,
                      subtitle: context.l10n.mightBeWrong,
                    ),

                    const SizedBox(height: 32),

                    // Ingredients Grid
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            _ingredients.map((ingredient) {
                              return IngredientChip(
                                ingredient: ingredient.name,
                                onRemove: () => _removeIngredient(ingredient),
                              );
                            }).toList(),
                      ),

                    const SizedBox(height: 32),

                    // Add Ingredient Input
                    AddIngredientInput(
                      controller: _ingredientController,
                      placeholder: context.l10n.addSomethingElse,
                      onSubmitted: _addIngredient,
                    ),

                    const SizedBox(height: 32),

                    // Spacer
                    const SizedBox(height: 24),

                    // Cook Button
                    PrimaryButton(
                      text: context.l10n.cookWithThis,
                      onPressed:
                          _ingredients.isEmpty
                              ? null
                              : () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/loading-generate',
                                  arguments: _ingredients,
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
