import 'package:flutter/material.dart';
import '../../../models/user_content/watch_status.dart';
import '../../../models/user_content/personal_list.dart';

class WatchlistCard extends StatelessWidget {
  final PersonalListItemResponse item;
  final VoidCallback? onTap;

  const WatchlistCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = WatchStatus.planToWatch;
    final progressVal = 0.0;

    final String title = item.media.title ?? 'عنوان ناشناخته';
    final String subtitle = 'افزوده شده در: ${item.addedAt.year}-${item.addedAt.month.toString().padLeft(2, '0')}-${item.addedAt.day.toString().padLeft(2, '0')}';

    // 🔹 قبلاً این‌جا یه URL ثابت (placeholder) بود که باعث می‌شد
    // پوستر واقعی هیچ‌وقت لود نشه. حالا از خود دیتای رسانه می‌خونیم.
    final String? imageUrl = item.media.posterUrl;
    final String progressLabel = status == WatchStatus.watching ? 'در حال تماشا' : 'وضعیت: ${status.value}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0C2E3B).withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF8DE6E3).withOpacity(0.1),
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF00161F),
                            child: const Icon(Icons.broken_image, color: Colors.white30, size: 40),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF00161F),
                          child: const Icon(Icons.image_not_supported, color: Colors.white30, size: 40),
                        ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            const Color(0xFF00161F).withOpacity(0.9),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5],
                        ),
                      ),
                    ),
                  ),
                  if (status == WatchStatus.loved)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00161F).withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Color(0xFFF08DA5),
                          size: 16,
                        ),
                      ),
                    ),
                  if (status == WatchStatus.completed)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getTagBgColor(status).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'تکمیل شده',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC7E7F8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      color: Color(0xFFBCC9C8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  if (status != WatchStatus.planToWatch) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          progressLabel.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getProgressColor(status),
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          '${(progressVal * 100).toInt()}%',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getProgressColor(status),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF001018),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progressVal.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getProgressColor(status),
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: status != WatchStatus.planToWatch
                                ? [
                                    BoxShadow(
                                      color: _getProgressColor(status).withOpacity(0.3),
                                      blurRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(WatchStatus status) {
    switch (status) {
      case WatchStatus.loved:
        return const Color(0xFF29B5B5);
      case WatchStatus.completed:
        return const Color(0xFFCBBEFF);
      case WatchStatus.dropped:
      case WatchStatus.onHold:
        return const Color(0xFFFFB4AB);
      case WatchStatus.watching:
        return const Color(0xFFE8879F);
      case WatchStatus.planToWatch:
      default:
        return Colors.transparent;
    }
  }

  Color _getTagBgColor(WatchStatus status) {
    if (status == WatchStatus.completed) return const Color(0xFF493C81);
    return const Color(0xFF00232F);
  }
}