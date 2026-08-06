import 'package:flutter/material.dart';

class LoadingSectionWidget extends StatefulWidget {
  const LoadingSectionWidget({Key? key}) : super(key: key);

  @override
  State<LoadingSectionWidget> createState() => _LoadingSectionWidgetState();
}

class _LoadingSectionWidgetState extends State<LoadingSectionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          const Text(
            'IS LOADING...',
            style: TextStyle(
              color: Color(0xFFBCC9C8),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 4,
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 384),
            decoration: BoxDecoration(
              color: const Color(0xFF0C2E3B),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF29B5B5).withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            alignment: Alignment.centerLeft,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFB1C2),
                          Color(0xFF29B5B5),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5AD9D9).withOpacity(0.5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}