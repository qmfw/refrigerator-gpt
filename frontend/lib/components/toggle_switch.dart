import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Toggle switch component for settings
/// Matches the design from the HTML export
class ToggleSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ToggleSwitch({super.key, required this.value, this.onChanged});

  @override
  State<ToggleSwitch> createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged?.call(!widget.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 51,
        height: 31,
        decoration: BoxDecoration(
          color: widget.value ? AppColors.primary : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(15.5),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 2,
              left: widget.value ? 20 : 2,
              child: Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(38),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
