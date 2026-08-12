import 'package:flutter/material.dart';
import '../models/user_content/watch_status.dart';
import '../models/movie/watchlist_item.dart';

class WatchlistCard extends StatelessWidget {
  final WatchlistItem item;

  const WatchlistCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C2E3B).withOpacity(0.4), // glass-panel
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF5AD9D9).withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Image Section
          SizedBox(
            height: 192,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF00161F),
                    child: const Icon(Icons.broken_image, color: Colors.white54),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF001018), // surface-container-lowest
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5],
                      ),
                    ),
                  ),
                ),
                // Tags
                if (item.tag != null)
                  Positioned(
                    top: 12,
                    right: 12, // HTML sometimes uses left, sometimes right. Let's use right or map it.
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTagBgColor(item.status).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _getTagBorderColor(item.status)),
                      ),
                      child: Text(
                        item.tag!.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getTagTextColor(item.status),
                        ),
                      ),
                    ),
                  ),
                // Play button for unwatched
                if (item.status == WatchStatus.planToWatch)
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFF001018).withOpacity(0.4),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5AD9D9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.play_arrow, color: Color(0xFF003737), size: 32),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFC7E7F8),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        item.isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: item.isFavorite ? const Color(0xFFFFB1C2) : const Color(0xFFBCC9C8).withOpacity(0.4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      color: const Color(0xFFBCC9C8).withOpacity(0.7),
                    ),
                  ),
                  const Spacer(),
                  // Progress Bar Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.progressLabel.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getProgressColor(item.status),
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '${(item.progress * 100).toInt()}%',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getProgressColor(item.status),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF001018), // surface-container-lowest
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: item.progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getProgressColor(item.status),
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: item.status != WatchStatus.planToWatch
                              ? [
                                  BoxShadow(
                                    color: _getProgressColor(item.status).withOpacity(0.3),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(WatchStatus status) {
    switch (status) {
      case WatchStatus.loved:
        return const Color(0xFF29B5B5); // Green/Teal (primary-container)
      case WatchStatus.completed:
        return const Color(0xFFCBBEFF); // Purple (secondary)
      case WatchStatus.dropped:
      case WatchStatus.onHold:
        return const Color(0xFFFFB4AB); // Red (error)
      case WatchStatus.watching:
        return const Color(0xFFE8879F); // Yellow/Amber map to (tertiary-container)
      case WatchStatus.planToWatch:
      default:
        return Colors.transparent; // Black/Transparent
    }
  }

  Color _getTagBgColor(WatchStatus status) {
    if (status == WatchStatus.completed) return const Color(0xFF493C81); // secondary-container
    return const Color(0xFF00232F); // surface-container
  }

  Color _getTagBorderColor(WatchStatus status) {
    if (status == WatchStatus.completed) return Colors.transparent;
    return const Color(0xFF5AD9D9).withOpacity(0.2); // primary/20
  }

  Color _getTagTextColor(WatchStatus status) {
    if (status == WatchStatus.completed) return const Color(0xFFE6DEFF); // secondary-fixed
    return const Color(0xFF5AD9D9); // primary-fixed-dim
  }
}
