import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
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
                  colors: [
                    Color(0xFF374151),
                    Color(0xFF1A202C),
                  ],
                ),
              ),
              child: Center(
                child: Opacity(
                  opacity: 0.1,
                  child: const Text(
                    '📷',
                    style: TextStyle(fontSize: 96),
                  ),
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
                      child: HelperText(
                        text: 'Take 1–3 photos. Messy is okay.',
                      ),
                    ),
                  ),

                  // Bottom controls
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    child: Column(
                      children: [
                        ShutterButton(
                          onPressed: () {
                            // Take photo
                            Navigator.pushNamed(context, '/photo-review');
                          },
                        ),
                        const SizedBox(height: 16),
                        UploadButton(
                          onPressed: () {
                            // Open gallery
                            Navigator.pushNamed(context, '/photo-review');
                          },
                        ),
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

