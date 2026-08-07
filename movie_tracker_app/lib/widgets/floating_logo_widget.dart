import 'package:flutter/material.dart';

class FloatingLogoWidget extends StatefulWidget {
  const FloatingLogoWidget({Key? key}) : super(key: key);

  @override
  State<FloatingLogoWidget> createState() => _FloatingLogoWidgetState();
}

class _FloatingLogoWidgetState extends State<FloatingLogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -12).animate(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'TV Time',
            style: TextStyle(
              color: Color(0xFF5AD9D9),
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF29B5B5).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Image.asset(
              'assets/logo.jpg',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}