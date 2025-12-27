import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';

class LoadingGenerateScreen extends StatelessWidget {
  const LoadingGenerateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulate loading, then navigate
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/recipe-results');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: LoadingIndicator(
            message: 'This fridge has potential.',
          ),
        ),
      ),
    );
  }
}

