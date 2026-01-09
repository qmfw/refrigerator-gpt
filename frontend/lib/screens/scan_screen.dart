import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations_extension.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // Will be compressed later in preprocessing
      );

      if (photo != null && mounted) {
        final bytes = await photo.readAsBytes();
        if (mounted) {
          Navigator.pushNamed(context, '/photo-review', arguments: [bytes]);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to take photo';
        if (e.toString().contains('permission') ||
            e.toString().contains('Permission')) {
          errorMessage =
              'Camera permission denied. Please enable camera access in settings.';
        } else if (e.toString().contains('camera')) {
          errorMessage =
              'Camera not available. Please check your device settings.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Will be compressed later in preprocessing
      );

      if (image != null && mounted) {
        final bytes = await image.readAsBytes();
        if (mounted) {
          Navigator.pushNamed(context, '/photo-review', arguments: [bytes]);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to pick image';
        if (e.toString().contains('permission') ||
            e.toString().contains('Permission')) {
          errorMessage =
              'Photo library permission denied. Please enable photo access in settings.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cameraBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Viewfinder (placeholder)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF374151), Color(0xFF1A202C)],
                ),
              ),
              child: Center(
                child: Opacity(
                  opacity: 0.1,
                  child: const Text('📷', style: TextStyle(fontSize: 96)),
                ),
              ),
            ),

            // Overlay
            Positioned.fill(
              child: Column(
                children: [
                  // Top section with close button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: CameraCloseButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),

                  // Helper text
                  Expanded(
                    child: Center(
                      child: HelperText(text: context.l10n.takePhotosHelper),
                    ),
                  ),

                  // Bottom controls
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    child: Column(
                      children: [
                        ShutterButton(onPressed: _takePhoto),
                        const SizedBox(height: 16),
                        UploadButton(onPressed: _pickFromGallery),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: BottomNav(
            activeItem: NavItem.scan,
            onItemTap: (item) {
              switch (item) {
                case NavItem.home:
                  Navigator.pushReplacementNamed(context, '/');
                  break;
                case NavItem.scan:
                  // Already on scan
                  break;
                case NavItem.history:
                  Navigator.pushReplacementNamed(context, '/history');
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}
