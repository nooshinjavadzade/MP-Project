import 'package:flutter/material.dart';
import 'dart:ui';

class FakeSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const FakeSearchBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0x66193846),
                border: Border.all(
                  color: const Color(0x1AF08DA5),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Color(0xFF6C5FA6),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'جستجوی فیلم، سریال...',
                    style: TextStyle(
                      color: const Color(0xFFBCC9C8).withOpacity(0.5),
                      fontSize: 16,
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