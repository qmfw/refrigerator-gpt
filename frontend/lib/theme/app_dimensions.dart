import 'package:flutter/material.dart';

/// FridgeGPT Design System Dimensions
/// Centralized spacing, sizing, and layout constants
class AppDimensions {
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 12.0;
  static const double spacingLG = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;

  // Padding
  static const EdgeInsets paddingXS = EdgeInsets.all(4.0);
  static const EdgeInsets paddingSM = EdgeInsets.all(8.0);
  static const EdgeInsets paddingMD = EdgeInsets.all(12.0);
  static const EdgeInsets paddingLG = EdgeInsets.all(16.0);
  static const EdgeInsets paddingXL = EdgeInsets.all(20.0);
  static const EdgeInsets paddingXXL = EdgeInsets.all(24.0);

  // Horizontal Padding
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(
    horizontal: 8.0,
  );
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(
    horizontal: 12.0,
  );
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(
    horizontal: 16.0,
  );
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(
    horizontal: 20.0,
  );
  static const EdgeInsets paddingHorizontalXXL = EdgeInsets.symmetric(
    horizontal: 24.0,
  );
  static const EdgeInsets paddingHorizontalXXXL = EdgeInsets.symmetric(
    horizontal: 32.0,
  );

  // Vertical Padding
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(
    vertical: 8.0,
  );
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(
    vertical: 12.0,
  );
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(
    vertical: 16.0,
  );
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(
    vertical: 20.0,
  );
  static const EdgeInsets paddingVerticalXXL = EdgeInsets.symmetric(
    vertical: 24.0,
  );
  static const EdgeInsets paddingVerticalXXXL = EdgeInsets.symmetric(
    vertical: 32.0,
  );

  // Button Padding
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 10.0,
  );
  static const EdgeInsets buttonPaddingMedium = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 18.0,
  );
  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 24.0,
  );
  static const EdgeInsets buttonPaddingXLarge = EdgeInsets.symmetric(
    horizontal: 32.0,
    vertical: 32.0,
  );

  // Icon Sizes
  static const double iconSizeXS = 16.0;
  static const double iconSizeSM = 20.0;
  static const double iconSizeMD = 24.0;
  static const double iconSizeLG = 28.0;
  static const double iconSizeXL = 40.0;

  // Border Radius
  static const double borderRadiusSM = 6.0;
  static const double borderRadiusMD = 10.0;
  static const double borderRadiusLG = 12.0;
  static const double borderRadiusXL = 16.0;
  static const double borderRadiusXXL = 20.0;
  static const double borderRadiusXXXL = 24.0;

  // Border Width
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;
  static const double borderWidthThick = 3.0;
  static const double borderWidthXThick = 4.0;

  // Card/Container Heights
  static const double cardHeightSmall = 60.0;
  static const double cardHeightMedium = 72.0;
  static const double cardHeightLarge = 180.0;
  static const double cardHeightXLarge = 320.0;

  // Common SizedBox Spacers
  static const SizedBox spacerXS = SizedBox(
    width: spacingXS,
    height: spacingXS,
  );
  static const SizedBox spacerSM = SizedBox(
    width: spacingSM,
    height: spacingSM,
  );
  static const SizedBox spacerMD = SizedBox(
    width: spacingMD,
    height: spacingMD,
  );
  static const SizedBox spacerLG = SizedBox(
    width: spacingLG,
    height: spacingLG,
  );
  static const SizedBox spacerXL = SizedBox(
    width: spacingXL,
    height: spacingXL,
  );
  static const SizedBox spacerXXL = SizedBox(
    width: spacingXXL,
    height: spacingXXL,
  );

  // Horizontal Spacers
  static const SizedBox spacerHorizontalXS = SizedBox(width: spacingXS);
  static const SizedBox spacerHorizontalSM = SizedBox(width: spacingSM);
  static const SizedBox spacerHorizontalMD = SizedBox(width: spacingMD);
  static const SizedBox spacerHorizontalLG = SizedBox(width: spacingLG);
  static const SizedBox spacerHorizontalXL = SizedBox(width: spacingXL);
  static const SizedBox spacerHorizontalXXL = SizedBox(width: spacingXXL);
  static const SizedBox spacerHorizontalXXXL = SizedBox(width: spacingXXXL);

  // Vertical Spacers
  static const SizedBox spacerVerticalXS = SizedBox(height: spacingXS);
  static const SizedBox spacerVerticalSM = SizedBox(height: spacingSM);
  static const SizedBox spacerVerticalMD = SizedBox(height: spacingMD);
  static const SizedBox spacerVerticalLG = SizedBox(height: spacingLG);
  static const SizedBox spacerVerticalXL = SizedBox(height: spacingXL);
  static const SizedBox spacerVerticalXXL = SizedBox(height: spacingXXL);
  static const SizedBox spacerVerticalXXXL = SizedBox(height: spacingXXXL);
}
