import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class LogoCenterpiece extends StatefulWidget {
  const LogoCenterpiece({super.key});

  @override
  State<LogoCenterpiece> createState() => _LogoCenterpieceState();
}

class _LogoCenterpieceState extends State<LogoCenterpiece>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // هاله نورانی پشت لوگو
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // لوگوی اصلی
          Image.asset(
            'assets/logo.jpg',
            width: 128,
            height: 128,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}