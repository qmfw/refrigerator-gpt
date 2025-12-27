import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Photo thumbnail with remove button
/// Used on Photo Review screen
class PhotoThumbnail extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final Widget? child; // Image widget or placeholder

  const PhotoThumbnail({
    super.key,
    this.isActive = false,
    this.onTap,
    this.onRemove,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD1D5DB), Color(0xFF9CA3AF)],
              ),
              border: Border.all(
                color: isActive ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
            child: child ??
                const Center(
                  child: Icon(Icons.image, color: Colors.white, size: 32),
                ),
          ),
          if (onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: const Center(
                    child: Text(
                      '×',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Main photo preview area
/// Used on Photo Review screen
class PhotoPreview extends StatelessWidget {
  final int photoCount;
  final Widget? image; // Main image widget
  final String? placeholderText;

  const PhotoPreview({
    super.key,
    required this.photoCount,
    this.image,
    this.placeholderText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 320),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE5E7EB), Color(0xFFD1D5DB)],
        ),
      ),
      child: Stack(
        children: [
          if (image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: image!,
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    placeholderText ?? 'Tap a thumbnail to preview',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          // Photo count badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$photoCount photo${photoCount != 1 ? 's' : ''}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

