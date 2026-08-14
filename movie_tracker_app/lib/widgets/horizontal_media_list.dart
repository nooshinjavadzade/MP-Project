import 'package:flutter/material.dart';
import '../../../../models/common/media_base.dart';
import 'media_card.dart';

class HorizontalMediaList extends StatelessWidget {
  final String title;
  final List<MediaBase> items;
  final bool isLoading;
  final VoidCallback onMoreTap;
  final Function(MediaBase) onItemTap;

  const HorizontalMediaList({
    super.key,
    required this.title,
    required this.items,
    required this.isLoading,
    required this.onMoreTap,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFC7E7F8),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Manrope',
                ),
              ),
              GestureDetector(
                onTap: onMoreTap,
                child: Row(
                  children: [
                    const Text(
                      'بیشتر',
                      style: TextStyle(
                        color: Color(0xFFF08DA5),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: const Color(0xFFF08DA5),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        SizedBox(
          height: 240,
          child: isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFF08DA5)))
            : items.isEmpty
              ? const Center(child: Text('داده‌ای یافت نشد.', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16.0),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final media = items[index];
                    return MediaCard(
                      media: media,
                      onTap: () => onItemTap(media),
                    );
                  },
                ),
        ),
      ],
    );
  }
}