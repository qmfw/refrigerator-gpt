import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            SimpleHeader(
              title: 'Settings',
              showBackButton: true,
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),

            // Settings List
            Expanded(
              child: ListView(
                children: [
                  SettingsItem(
                    label: 'Clear history',
                    isDestructive: true,
                    onTap: () {
                      // Clear history
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('History cleared'),
                        ),
                      );
                    },
                  ),
                  SettingsItem(
                    label: 'About',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('About FridgeGPT'),
                          content: const Text('FridgeGPT v1\n\nA friendly app to help you cook with what you have.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SettingsItem(
                    label: 'Feedback',
                    onTap: () {
                      // Open feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feedback feature coming soon'),
                        ),
                      );
                    },
                  ),
                  SettingsItem(
                    label: 'Privacy',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Privacy'),
                          content: const Text('Your photos are processed securely and are not stored permanently.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

