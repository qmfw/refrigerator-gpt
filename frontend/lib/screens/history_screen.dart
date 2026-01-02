import 'package:flutter/material.dart';
import '../components/components.dart' show BottomNav, NavItem, HistoryItem;
import '../theme/app_colors.dart';
import '../localization/app_localizations_extension.dart';
import '../models/models.dart' show HistoryEntry;
import '../repository/mock_fridge_repository.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final MockFridgeRepository _repository = MockFridgeRepository();
  List<HistoryEntry> _historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = await _repository.getHistory();
    setState(() {
      _historyItems = items;
      _isLoading = false;
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text(
                context.l10n.history,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // History List
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _historyItems.isEmpty
                      ? Center(
                        child: Text(
                          context.l10n.emptyHistory,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _historyItems.length,
                        itemBuilder: (context, index) {
                          final item = _historyItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: HistoryItem(
                              emoji: item.emoji,
                              title: item.title,
                              timeAgo: item.getTimeAgo(),
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
