import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../localization/app_localizations_extension.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            SimpleHeader(
              title: context.l10n.privacy,
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
                    const SizedBox(height: 16),
                    _buildPrivacyParagraph(
                      context,
                      context.l10n.privacyParagraph1,
                    ),
                    const SizedBox(height: 24),
                    _buildPrivacyParagraph(
                      context,
                      context.l10n.privacyParagraph2,
                    ),
                    const SizedBox(height: 24),
                    _buildPrivacyParagraph(
                      context,
                      context.l10n.privacyParagraph3,
                    ),
                    const SizedBox(height: 24),
                    _buildPrivacyParagraph(
                      context,
                      context.l10n.privacyParagraph4,
                    ),
                    const SizedBox(height: 24),
                    _buildPrivacyParagraph(
                      context,
                      context.l10n.privacyParagraph5,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyParagraph(BuildContext context, String text) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.7,
        fontSize: 16,
      ),
    );
  }
}
