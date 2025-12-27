import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Intro section with title and subtitle
/// Used on Confirm Ingredients screen
class IntroSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const IntroSection({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headerTitle.copyWith(
            fontSize: 24, // 1.5rem
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AppTextStyles.headerSubtitle,
        ),
      ],
    );
  }
}

