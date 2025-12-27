import 'package:flutter/material.dart';

/// FridgeGPT Design System Colors
/// Based on the HTML export and README specifications
class AppColors {
  // Primary Colors - Soft Mint Green
  static const Color primaryStart = Color(0xFF10B981); // #10b981
  static const Color primaryEnd = Color(0xFF059669); // #059669
  static const Color primary = Color(0xFF10B981);

  // Background Colors
  static const Color background = Color(0xFFFDFBF7); // #fdfbf7 - Off-white warm
  static const Color backgroundSecondary = Color(0xFFF1F5F9); // #f1f5f9 - Light gray
  static const Color white = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937); // #1f2937 - Near black
  static const Color textSecondary = Color(0xFF6B7280); // #6b7280 - Medium gray
  static const Color textHint = Color(0xFF9CA3AF); // #9ca3af - Light gray

  // UI Element Colors
  static const Color border = Color(0xFFE5E7EB); // #e5e7eb - Light border
  static const Color borderLight = Color(0xFFF3F4F6); // #f3f4f6 - Very light border
  static const Color chipBackground = Color(0xFFF3F4F6); // #f3f4f6 - Chip background
  static const Color chipBackgroundHover = Color(0xFFE5E7EB); // #e5e7eb - Chip hover

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );

  // Recipe Badge Colors
  static const Color badgeBackground = Color(0xFFF3F4F6);
  static const Color badgeText = Color(0xFF6B7280);

  // Destructive Actions
  static const Color destructive = Color(0xFFEF4444); // #ef4444 - Red

  // Camera/Scan Screen
  static const Color cameraBackground = Color(0xFF1A1A1A); // Dark background for camera
  static const Color cameraOverlay = Color(0x80000000); // Semi-transparent overlay
}

