/// History entry model representing a past recipe scan
class HistoryEntry {
  final String id;
  final String emoji;
  final String title;
  final DateTime createdAt;

  const HistoryEntry({
    required this.id,
    required this.emoji,
    required this.title,
    required this.createdAt,
  });

  /// Get a human-readable time ago string
  /// This should be localized in production
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 14) {
      return '1 week ago';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks weeks ago';
    }
  }
}
