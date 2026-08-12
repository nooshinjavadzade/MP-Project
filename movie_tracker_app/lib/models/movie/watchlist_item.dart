
import '../user_content/watch_status.dart';
class WatchlistItem {
  final String title;
  final String imageUrl;
  final String subtitle;
  final String progressLabel;
  final double progress; // 0.0 to 1.0
  final WatchStatus status; // استفاده از Enum شما در اینجا
  final String? tag;
  final bool isFavorite;

  const WatchlistItem({
    required this.title,
    required this.imageUrl,
    required this.subtitle,
    required this.progressLabel,
    required this.progress,
    required this.status,
    this.tag,
    this.isFavorite = false,
  });
}