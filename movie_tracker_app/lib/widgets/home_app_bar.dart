import 'package:flutter/material.dart';
import 'dart:ui';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: preferredSize.height,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 16, // px-margin-mobile
            right: 16,
          ),
          decoration: const BoxDecoration(
            color: Color(0xCC00161F), // bg-surface/80 (0.8 * #00161F)
            border: Border(
              bottom: BorderSide(
                color: Color(0x33193846), // border-surface-variant/20
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // آیکون گرادیانتی
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF08DA5), // coral-pink
                      Color(0xFF6C5FA6), // lavender-shadow
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.movie_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // متن گرادیانتی
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFF08DA5),
                    Color(0xFF6C5FA6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text(
                  'TV Time',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24, // headline-lg-mobile
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}


