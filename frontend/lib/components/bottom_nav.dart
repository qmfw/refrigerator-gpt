import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum NavItem { home, scan, history }

class BottomNav extends StatelessWidget {
  final NavItem activeItem;
  final Function(NavItem) onItemTap;

  const BottomNav({
    super.key,
    required this.activeItem,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavButton(
              icon: Icons.home,
              label: 'Home',
              isActive: activeItem == NavItem.home,
              onTap: () => onItemTap(NavItem.home),
            ),
            _NavButton(
              icon: Icons.camera_alt,
              label: 'Scan',
              isActive: activeItem == NavItem.scan,
              onTap: () => onItemTap(NavItem.scan),
            ),
            _NavButton(
              icon: Icons.history,
              label: 'History',
              isActive: activeItem == NavItem.history,
              onTap: () => onItemTap(NavItem.history),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isActive ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

