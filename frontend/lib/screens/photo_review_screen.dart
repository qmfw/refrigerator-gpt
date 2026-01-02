import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations_extension.dart';

class PhotoReviewScreen extends StatefulWidget {
  const PhotoReviewScreen({super.key});

  @override
  State<PhotoReviewScreen> createState() => _PhotoReviewScreenState();
}

class _PhotoReviewScreenState extends State<PhotoReviewScreen> {
  int selectedIndex = 0;
  final int photoCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            SimpleHeader(
              title: context.l10n.reviewPhotos,
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
                    // Thumbnails
                    SizedBox(
                      height: 88,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: photoCount,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: PhotoThumbnail(
                              isActive: selectedIndex == index,
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              onRemove: () {
                                // Remove photo
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Main Preview
                    PhotoPreview(
                      photoCount: photoCount,
                      placeholderText: context.l10n.tapThumbnailToPreview,
                    ),

                    const SizedBox(height: 24),

                    // Actions
                    Column(
                      children: [
                        PrimaryButton(
                          text: context.l10n.thisIsEnough,
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/loading-detect',
                            );
                          },
                          fullWidth: true,
                        ),
                        const SizedBox(height: 12),
                        SecondaryButton(
                          text: context.l10n.addAnotherPhoto,
                          icon: Icons.add,
                          onPressed: () {
                            // Add photo
                          },
                          fullWidth: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            BottomNav(
              activeItem: NavItem.scan,
              onItemTap: (item) {
                switch (item) {
                  case NavItem.home:
                    Navigator.pushReplacementNamed(context, '/');
                    break;
                  case NavItem.scan:
                    // Already on scan flow
                    break;
                  case NavItem.history:
                    Navigator.pushReplacementNamed(context, '/history');
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
