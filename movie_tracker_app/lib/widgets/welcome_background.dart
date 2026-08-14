import 'package:flutter/material.dart';

class WelcomeBackground extends StatelessWidget {
  const WelcomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // هاله نوری پس‌زمینه (Radial Glow)
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color(0x1A29B5B5), // rgba(41, 181, 181, 0.1)
                Color(0x0000161F), // transparent
              ],
              radius: 1.2,
              center: Alignment.center,
            ),
          ),
        ),
        
        // افکت نوری بالا راست (Bioluminescent Glows)
        Positioned(
          top: -MediaQuery.of(context).size.width * 0.1,
          right: -MediaQuery.of(context).size.width * 0.1,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5AD9D9).withOpacity(0.05), // bg-primary/5
                  blurRadius: 120,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
        
        // افکت نوری پایین چپ (Bioluminescent Glows)
        Positioned(
          bottom: -MediaQuery.of(context).size.width * 0.1,
          left: -MediaQuery.of(context).size.width * 0.1,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB1C2).withOpacity(0.05), // bg-tertiary/5
                  blurRadius: 120,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


