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
          Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5AD9D9).withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/logo.jpg',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),

          const Text(
            'TV Time',
            style: TextStyle(
              color: Color(0xFFC7E7F8),
              fontSize: 32,
              fontWeight: FontWeight.w600,
              fontFamily: 'Plus Jakarta Sans',
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'سفر خود را در اعماق سینما دنبال کنید.',
              style: TextStyle(
                color: Color(0xFFBCC9C8),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Manrope',
                height: 1.625,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}