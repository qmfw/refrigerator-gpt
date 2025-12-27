import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';

class LoadingDetectScreen extends StatelessWidget {
  const LoadingDetectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulate loading, then navigate
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/confirm-ingredients');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: LoadingIndicator(
            message: 'Looking closely…',
          ),
        ),
      ),
    );
  }
}

