import 'package:flutter/material.dart';
import 'dart:ui';

class MovieSynopsisCard extends StatelessWidget {
  final String synopsis;

  const MovieSynopsisCard({
    super.key,
    required this.synopsis,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0x9900232F),
            border: Border.all(color: const Color(0x33869393)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Color(0xFF5AD9D9),
                  width: 4,
                ),
              ),
            ),
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'خلاصه داستان',
                  style: TextStyle(
                    color: Color(0xFF5AD9D9),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  synopsis.isNotEmpty ? synopsis : 'خلاصه‌ای در دسترس نیست.',
                  style: const TextStyle(
                    color: Color(0xFFBCC9C8),
                    fontSize: 18,
                    height: 1.55,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}