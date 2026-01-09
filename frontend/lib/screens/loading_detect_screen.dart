import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations_extension.dart';
import '../services/api/detection_service.dart';
import '../models/models.dart';

class LoadingDetectScreen extends StatefulWidget {
  final List<Uint8List>? imageBytes;

  const LoadingDetectScreen({super.key, this.imageBytes});

  @override
  State<LoadingDetectScreen> createState() => _LoadingDetectScreenState();
}

class _LoadingDetectScreenState extends State<LoadingDetectScreen> {
  @override
  void initState() {
    super.initState();
    _detectIngredients();
  }

  Future<void> _detectIngredients() async {
    try {
      // Get images from route arguments or widget parameter
      final images =
          widget.imageBytes ??
          (ModalRoute.of(context)?.settings.arguments as List<Uint8List>?);

      if (images == null || images.isEmpty) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/confirm-ingredients',
            arguments: <Ingredient>[],
          );
        }
        return;
      }

      // Call DetectionService
      final detectionService = DetectionService();
      final language = context.languageCode;

      final response = await detectionService.detectIngredients(
        imageBytes: images,
        language: language,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/confirm-ingredients',
          arguments: response.ingredients,
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to detect ingredients: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: LoadingIndicator(message: context.l10n.lookingClosely),
        ),
      ),
    );
  }
}
