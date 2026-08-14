import 'package:flutter/material.dart';

class WelcomeLogo extends StatefulWidget {
  const WelcomeLogo({super.key});

  @override
  State<WelcomeLogo> createState() => _WelcomeLogoState();
}

class _WelcomeLogoState extends State<WelcomeLogo> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    // انیمیشن شناور شدن (Float)
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: Column(
        children: [
          // بخش لوگو
          Container(
            margin: const EdgeInsets.only(bottom: 40), // mb-lg
            child: Stack(
              alignment: Alignment.center,
              children: [
                // هاله درخشان پشت لوگو (Glow)
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5AD9D9).withOpacity(0.2), // bg-primary/20
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // عکس لوگو
                Image.asset(
                  'assets/logo.jpg',
                  width: 160, // w-32 md:w-40
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),

          // نام برنامه
          const Text(
            'TV Time',
            style: TextStyle(
              color: Color(0xFFC7E7F8), // text-on-background
              fontSize: 32, // headline-lg
              fontWeight: FontWeight.w600,
              fontFamily: 'Plus Jakarta Sans',
              letterSpacing: -0.5, // tracking-tight
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8), // space-y-xs
          
          // توضیحات زیر نام برنامه
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Track your journey through the cinematic deep.',
              style: TextStyle(
                color: Color(0xFFBCC9C8), // text-on-surface-variant
                fontSize: 16, // body-md
                fontWeight: FontWeight.w400,
                fontFamily: 'Manrope',
                height: 1.625, // leading-relaxed
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}


