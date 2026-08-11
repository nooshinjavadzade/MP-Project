import 'package:flutter/material.dart';

class SplashLogo extends StatefulWidget {
  const SplashLogo({super.key});

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _fadeController;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // انیمیشن Fade in
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // انیمیشن شناور شدن (Float)
    _floatController = AnimationController(
      duration: const Duration(seconds: 2), // 4s total in CSS, so 2s forward, 2s reverse
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0.0, end: -12.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // هاله درخشان پشت لوگو (Outer glow)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF29B5B5).withOpacity(0.2),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TV Time',
                  style: TextStyle(
                    color: Color(0xFF5AD9D9), // text-primary
                    fontSize: 24, // headline-lg-mobile
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Plus Jakarta Sans', 
                  ),
                ),
                const SizedBox(height: 24), // mb-md
                Image.asset(
                  'assets/logo.jpg',
                  width: 160, // w-40 to w-56 responsiveness
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}