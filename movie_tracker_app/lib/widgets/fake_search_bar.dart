import 'package:flutter/material.dart';
import 'dart:ui';

class FakeSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const FakeSearchBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // px-margin-mobile
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12), // rounded-xl
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0x66193846), // rgba(25, 56, 70, 0.4) - glass-card
                border: Border.all(
                  color: const Color(0x1AF08DA5), // rgba(240, 141, 165, 0.1)
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Color(0xFF6C5FA6), // text-lavender-shadow
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Search movies, series...',
                    style: TextStyle(
                      color: const Color(0xFFBCC9C8).withOpacity(0.5), // placeholder:text-on-surface-variant/50
                      fontSize: 16, // font-body-md
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


