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
            color: const Color(0x9900232F), // rgba(0, 35, 47, 0.6)
            border: Border.all(color: const Color(0x33869393)), // outline/20
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Color(0xFF5AD9D9), // primary
                  width: 4,
                ),
              ),
            ),
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Synopsis',
                  style: TextStyle(
                    color: Color(0xFF5AD9D9),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  synopsis.isNotEmpty ? synopsis : 'No synopsis available.',
                  style: const TextStyle(
                    color: Color(0xFFBCC9C8), // on-surface-variant
                    fontSize: 18,
                    height: 1.55, // leading-relaxed
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
