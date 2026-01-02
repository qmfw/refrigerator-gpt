import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations_extension.dart';
import '../models/models.dart';
import '../repository/mock_fridge_repository.dart';

class ConfirmIngredientsScreen extends StatefulWidget {
  const ConfirmIngredientsScreen({super.key});

  @override
  State<ConfirmIngredientsScreen> createState() =>
      _ConfirmIngredientsScreenState();
}

class _ConfirmIngredientsScreenState extends State<ConfirmIngredientsScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final MockFridgeRepository _repository = MockFridgeRepository();
  List<Ingredient> _ingredients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    final ingredients = await _repository.getDetectedIngredients();
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
