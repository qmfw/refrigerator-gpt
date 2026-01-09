import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations_extension.dart';

class PhotoReviewScreen extends StatefulWidget {
  const PhotoReviewScreen({super.key});

  @override
  State<PhotoReviewScreen> createState() => _PhotoReviewScreenState();
}

class _PhotoReviewScreenState extends State<PhotoReviewScreen> {
  final ImagePicker _picker = ImagePicker();
  int selectedIndex = 0;
  List<Uint8List> _images = [];
  static const int maxPhotos = 3;

  @override
  void initState() {
    super.initState();
    // Get initial images from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List<Uint8List>) {
      _images = List.from(args);
    }
  }

  Future<void> _addPhoto() async {
    if (_images.length >= maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $maxPhotos photos allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show dialog to choose camera or gallery
      final source = await showDialog<ImageSource>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Add Photo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Take Photo'),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Choose from Gallery'),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            ),
      );

      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 100, // Will be compressed later in preprocessing
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _images.add(bytes);
          selectedIndex = _images.length - 1;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _images.removeAt(index);
      if (selectedIndex >= _images.length && _images.isNotEmpty) {
        selectedIndex = _images.length - 1;
      } else if (_images.isEmpty) {
        selectedIndex = 0;
      }
    });
  }

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
                        itemCount: _images.length,
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
                              onRemove: () => _removePhoto(index),
                              child: Image.memory(
                                _images[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Main Preview
                    PhotoPreview(
                      photoCount: _images.length,
                      placeholderText: context.l10n.tapThumbnailToPreview,
                      image:
                          _images.isNotEmpty && selectedIndex < _images.length
                              ? Image.memory(
                                _images[selectedIndex],
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),

                    const SizedBox(height: 24),

                    // Actions
                    Column(
                      children: [
                        PrimaryButton(
                          text: context.l10n.thisIsEnough,
                          onPressed:
                              _images.isEmpty
                                  ? null
                                  : () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/loading-detect',
                                      arguments: _images,
                                    );
                                  },
                          fullWidth: true,
                        ),
                        if (_images.length < maxPhotos) ...[
                          const SizedBox(height: 12),
                          SecondaryButton(
                            text: context.l10n.addAnotherPhoto,
                            icon: Icons.add,
                            onPressed: _addPhoto,
                            fullWidth: true,
                          ),
                        ],
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
