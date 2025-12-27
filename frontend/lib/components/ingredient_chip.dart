import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Editable ingredient chip component
/// Used on Confirm Ingredients screen
class IngredientChip extends StatefulWidget {
  final String ingredient;
  final VoidCallback? onRemove;

  const IngredientChip({
    super.key,
    required this.ingredient,
    this.onRemove,
  });

  @override
  State<IngredientChip> createState() => _IngredientChipState();
}

class _IngredientChipState extends State<IngredientChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.chipBackgroundHover : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.ingredient,
              style: AppTextStyles.bodyMedium,
            ),
            if (widget.onRemove != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: _isHovered ? AppColors.textSecondary : AppColors.textHint,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Add ingredient input field
class AddIngredientInput extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSubmitted;
  final String? placeholder;

  const AddIngredientInput({
    super.key,
    this.controller,
    this.onSubmitted,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.add, color: AppColors.textHint, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: placeholder ?? 'Add something else…',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => onSubmitted?.call(),
            ),
          ),
        ],
      ),
    );
  }
}

