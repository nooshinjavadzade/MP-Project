import 'package:flutter/material.dart';
import '../models/common.dart'; // مسیر به مدل MediaBase خودتان

class MediaSection extends StatelessWidget {
  final String title;
  final List<MediaBase> items;
  final VoidCallback onMoreTap;

  const MediaSection({
    super.key,
    required this.title,
    required this.items,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان و دکمه More
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC7E7F8),
                ),
              ),
              GestureDetector(
                onTap: onMoreTap,
                child: Row(
                  children: const [
                    Text(
                      'More',
                      style: TextStyle(
                        color: Color(0xFFF08DA5),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Color(0xFFF08DA5), size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // اسکرول افقی آیتم‌ها
        SizedBox(
          height: 240, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _MediaCard(item: item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MediaCard extends StatelessWidget {
  final MediaBase item;

  const _MediaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // با کلیک روی فیلم، به صفحه جزئیات می‌رویم
        // Navigator.pushNamed(context, '/details', arguments: item.id);
      },
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عکس پوستر
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      item.posterUrl != null 
                        ? Image.network(item.posterUrl!, fit: BoxFit.cover)
                        : Container(color: const Color(0xFF193846)), // عکس پیش‌فرض
                      
                      // گرادیانت تیره پایین عکس
                      Positioned(
                        bottom: 0, left: 0, right: 0, height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                const Color(0xFF00161F).withOpacity(0.95),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // امتیاز فیلم روی عکس
                      if (item.tmdbRating != null)
                        Positioned(
                          top: 8, right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF08DA5).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.white, size: 10),
                                const SizedBox(width: 2),
                                Text(
                                  item.tmdbRating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // عنوان فیلم زیر عکس
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFC7E7F8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}