import 'package:flutter/material.dart';
import 'dart:ui';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF00232F).withOpacity(0.8),
            border: const Border(
              top: BorderSide(
                color: Color(0x33193846),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.home_filled,
                  label: 'خانه',
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.bookmark_outline,
                  label: 'لیست تماشا',
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: Icons.person_outline,
                  label: 'پروفایل',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required int index, required IconData icon, required String label}) {
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFFF08DA5) : const Color(0xFFBCC9C8).withOpacity(0.6);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'Manrope',
            ),
          ),
        ],
      ),
    );
  }
}