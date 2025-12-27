# FridgeGPT Component Library

This directory contains all reusable Flutter components extracted from the 9-screen design export.

## Quick Start

```dart
import 'package:frontend/components/components.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
```

## Component Index

### Navigation

#### `BottomNav`
Bottom navigation bar with 3 tabs (Home, Scan, History).

```dart
BottomNav(
  activeItem: NavItem.home,
  onItemTap: (item) {
    // Handle navigation
  },
)
```

### Headers

#### `AppHeader`
Flexible header with title, optional subtitle, back button, and settings button.

```dart
AppHeader(
  title: 'Settings',
  showBackButton: true,
  onBackPressed: () => Navigator.pop(context),
)
```

#### `SimpleHeader`
Simplified header with just title and optional action.

```dart
SimpleHeader(
  title: 'Review Photos',
  showBackButton: true,
)
```

### Buttons

#### `ScanButton`
Large primary scan button with icon and text.

```dart
ScanButton(
  onPressed: () {
    // Navigate to scan screen
  },
  text: 'Scan my fridge', // Optional, defaults to "Scan my fridge"
)
```

#### `PrimaryButton`
Primary action button with gradient.

```dart
PrimaryButton(
  text: '🍳 Cook with this',
  icon: Icons.restaurant, // Optional
  onPressed: () {},
  fullWidth: true, // Optional
)
```

#### `SecondaryButton`
Secondary button with border.

```dart
SecondaryButton(
  text: 'Add another photo',
  icon: Icons.add,
  onPressed: () {},
)
```

### Cards

#### `LastResultCard`
Card showing the last recipe result (used on Home screen).

```dart
LastResultCard(
  recipeName: 'Creamy Tomato Pasta',
  timeAgo: '2 hours ago',
  emoji: '🍝',
  recipeCount: 3,
  onTap: () {
    // Navigate to recipe results
  },
)
```

#### `RecipeCard`
Full recipe display card with badge, steps, and actions.

```dart
RecipeCard(
  emoji: '🍝',
  badge: 'Actually Good',
  title: 'Creamy Tomato Pasta',
  steps: [
    'Boil pasta according to package',
    'Sauté garlic and onions in olive oil',
    'Add chopped tomatoes, simmer 10 min',
    'Stir in milk and mozzarella',
    'Toss with pasta and fresh basil',
  ],
  onShare: () {
    // Share recipe
  },
)
```

#### `HistoryItem`
List item for history screen.

```dart
HistoryItem(
  emoji: '🍝',
  title: 'Creamy Tomato Pasta',
  timeAgo: '2 hours ago',
  onTap: () {
    // Navigate to recipe
  },
)
```

### Forms & Inputs

#### `IngredientChip`
Editable ingredient chip with remove button.

```dart
IngredientChip(
  ingredient: 'Tomatoes',
  onRemove: () {
    // Remove ingredient
  },
)
```

#### `AddIngredientInput`
Input field for adding new ingredients.

```dart
AddIngredientInput(
  controller: _ingredientController,
  placeholder: 'Add something else…',
  onSubmitted: () {
    // Add ingredient
  },
)
```

### Loading

#### `LoadingIndicator`
Animated loading indicator with dots and message.

```dart
LoadingIndicator(
  message: 'Looking closely…',
)
```

### Settings

#### `SettingsItem`
Settings list item with optional destructive styling.

```dart
SettingsItem(
  label: 'Clear history',
  isDestructive: true,
  onTap: () {
    // Clear history
  },
)
```

### Camera (`camera.dart`)

#### `ShutterButton`
Camera shutter button.

```dart
ShutterButton(
  onPressed: () {
    // Take photo
  },
)
```

#### `HelperText`
Helper text overlay for camera.

```dart
HelperText(
  text: 'Take 1–3 photos. Messy is okay.',
)
```

#### `CameraCloseButton`
Close button for camera overlay.

```dart
CameraCloseButton(
  onPressed: () {
    // Close camera
  },
)
```

#### `UploadButton`
Upload from gallery button.

```dart
UploadButton(
  onPressed: () {
    // Open gallery
  },
)
```

### Photo Review (`photo_review.dart`)

#### `PhotoThumbnail`
Photo thumbnail with active state and remove button.

```dart
PhotoThumbnail(
  isActive: true,
  child: Image.network('...'), // Optional
  onTap: () {
    // Select photo
  },
  onRemove: () {
    // Remove photo
  },
)
```

#### `PhotoPreview`
Main photo preview area.

```dart
PhotoPreview(
  photoCount: 3,
  image: Image.network('...'), // Optional
  placeholderText: 'Tap a thumbnail to preview',
)
```

### Sections

#### `IntroSection`
Intro section with title and subtitle.

```dart
IntroSection(
  title: "Here's what I think you have.",
  subtitle: 'I might be wrong. Fix anything.',
)
```

## Design Tokens

All components use the design tokens from:

- `app_colors.dart` - Color system
- `app_text_styles.dart` - Typography

### Colors

```dart
AppColors.primary          // #10B981 - Soft mint green
AppColors.primaryStart     // #10B981
AppColors.primaryEnd       // #059669
AppColors.background      // #FDFBF7 - Off-white warm
AppColors.textPrimary      // #1F2937 - Near black
AppColors.textSecondary    // #6B7280 - Medium gray
AppColors.textHint         // #9CA3AF - Light gray
```

### Text Styles

```dart
AppTextStyles.headerTitle
AppTextStyles.headerSubtitle
AppTextStyles.bodyLarge
AppTextStyles.bodyMedium
AppTextStyles.bodySmall
AppTextStyles.buttonLarge
AppTextStyles.buttonMedium
AppTextStyles.buttonSmall
AppTextStyles.label
```

## Usage Examples

### Home Screen

```dart
Scaffold(
  body: Column(
    children: [
      AppHeader(
        title: 'FridgeGPT',
        showSettingsButton: true,
        onSettingsPressed: () {},
      ),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScanButton(onPressed: () {}),
            SizedBox(height: 24),
            LastResultCard(
              recipeName: 'Creamy Tomato Pasta',
              timeAgo: '2 hours ago',
              emoji: '🍝',
              recipeCount: 3,
            ),
          ],
        ),
      ),
      BottomNav(
        activeItem: NavItem.home,
        onItemTap: (item) {},
      ),
    ],
  ),
)
```

### Confirm Ingredients Screen

```dart
Scaffold(
  body: Column(
    children: [
      SimpleHeader(
        title: 'Confirm Ingredients',
        showBackButton: true,
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntroSection(
                title: "Here's what I think you have.",
                subtitle: 'I might be wrong. Fix anything.',
              ),
              SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  IngredientChip(ingredient: 'Tomatoes', onRemove: () {}),
                  IngredientChip(ingredient: 'Onions', onRemove: () {}),
                  // ... more chips
                ],
              ),
              SizedBox(height: 24),
              AddIngredientInput(
                controller: _controller,
                onSubmitted: () {},
              ),
              Spacer(),
              PrimaryButton(
                text: '🍳 Cook with this',
                onPressed: () {},
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
      BottomNav(activeItem: NavItem.scan, onItemTap: (_) {}),
    ],
  ),
)
```

## Notes

- All components follow the design system from the HTML export
- Components include proper animations and interactions
- All text styles and colors are centralized in theme files
- Components are fully customizable through parameters
- All components handle tap states and animations automatically

