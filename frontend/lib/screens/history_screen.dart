import 'package:flutter/material.dart';
import '../components/components.dart';
import '../theme/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  final List<Map<String, String>> _historyItems = const [
    {'emoji': '🍝', 'title': 'Creamy Tomato Pasta', 'time': '2 hours ago'},
    {'emoji': '🥗', 'title': 'Garden Fresh Salad', 'time': 'Yesterday'},
    {'emoji': '🍲', 'title': 'Chicken Stir Fry', 'time': '2 days ago'},
    {'emoji': '🥘', 'title': 'Vegetable Curry', 'time': '3 days ago'},
    {'emoji': '🍕', 'title': 'Margherita Pizza', 'time': '5 days ago'},
    {'emoji': '🍳', 'title': 'Spanish Omelette', 'time': '1 week ago'},
    {'emoji': '🥙', 'title': 'Mediterranean Wrap', 'time': '1 week ago'},
    {'emoji': '🍜', 'title': 'Ramen Bowl', 'time': '2 weeks ago'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: const Text(
                'History',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // History List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _historyItems.length,
                itemBuilder: (context, index) {
                  final item = _historyItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HistoryItem(
                      emoji: item['emoji']!,
                      title: item['title']!,
                      timeAgo: item['time']!,
                      onTap: () {
                        Navigator.pushNamed(context, '/recipe-results');
                      },
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation
            BottomNav(
              activeItem: NavItem.history,
              onItemTap: (item) {
                switch (item) {
                  case NavItem.home:
                    Navigator.pushReplacementNamed(context, '/');
                    break;
                  case NavItem.scan:
                    Navigator.pushReplacementNamed(context, '/scan');
                    break;
                  case NavItem.history:
                    // Already on history
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

