import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../models/common/media_base.dart';

class MediaCard extends StatelessWidget {
  final MediaBase media;
  final VoidCallback onTap;

  const MediaCard({
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140, // w-[140px]
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عکس و امتیاز
            AspectRatio(
              aspectRatio: 2 / 3, // aspect-[2/3]
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)), // ring-1 ring-white/5
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (posterUrl != null && posterUrl.isNotEmpty)
                        Image.network(posterUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF193846)))
                      else
                        Container(color: const Color(0xFF193846)), // Placeholder color

                      // گرادیانت روی عکس
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF00161F).withOpacity(0.95), // rgba(0, 22, 31, 0.95)
                              const Color(0xFF00161F).withOpacity(0.0),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: const [0.0, 0.6],
                          ),
                        ),
                      ),
                      
                      // نشان امتیاز
                      if (rating > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                color: const Color(0xFFF08DA5).withOpacity(0.9), // bg-coral-pink/90
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, color: Colors.white, size: 10),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
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
            const SizedBox(height: 8),
            
            // عنوان فیلم/سریال
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFC7E7F8), // text-on-surface
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


