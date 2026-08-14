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
        // هدر لیست (عنوان و دکمه More)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // px-margin-mobile
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFC7E7F8), // text-on-surface
                  fontSize: 20, // text-title-md
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Manrope',
                ),
              ),
              GestureDetector(
                onTap: onMoreTap,
                child: Row(
                  children: [
                    const Text(
                      'More',
                      style: TextStyle(
                        color: Color(0xFFF08DA5), // text-coral-pink
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
        const SizedBox(height: 16), // space-y-4
        
        // لیست افقی
        SizedBox(
          height: 240, // محاسبه تقریبی با توجه به aspect ratio و متن زیرش
          child: isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFF08DA5)))
            : items.isEmpty
              ? const Center(child: Text('No data found.', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16.0), // padding اولیه
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
