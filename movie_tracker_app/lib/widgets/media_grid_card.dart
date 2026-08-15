import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../models/common/media_base.dart';

class MediaGridCard extends StatelessWidget {
  final MediaBase media;
  final VoidCallback onTap;

  const MediaGridCard({
    super.key,
    required this.media,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String title = media.title;
    String? posterUrl = media.posterUrl;
    if (posterUrl != null && posterUrl.startsWith('/')) {
      posterUrl = 'https://image.tmdb.org/t/p/w500$posterUrl';
    }
    double rating = media.tmdbRating ?? 0.0;
    String year = media.releaseYear?.toString() ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 قبلاً AspectRatio بود؛ الان Expanded می‌گیره تا با هر ارتفاعی از گرید سازگار باشه
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x330F5F66),
                    border: Border.all(color: const Color(0x1A5AD9D9)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (posterUrl != null && posterUrl.isNotEmpty)
                        Image.network(
                          posterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF193846)),
                        )
                      else
                        Container(color: const Color(0xFF193846)),

                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 60,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF00161F),
                                const Color(0xFF00161F).withOpacity(0.0),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),

                      if (rating > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                color: const Color(0xCC00161F),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, color: Color(0xFFFFB1C2), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Color(0xFFFFB1C2),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFC7E7F8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (year.isNotEmpty)
            Text(
              year,
              style: TextStyle(
                color: const Color(0xFFBCC9C8).withOpacity(0.6),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}