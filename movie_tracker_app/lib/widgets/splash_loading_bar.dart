import 'package:flutter/material.dart';

class SplashLoadingBar extends StatefulWidget {
  const SplashLoadingBar({super.key});

  @override
  State<SplashLoadingBar> createState() => _SplashLoadingBarState();
}

class _SplashLoadingBarState extends State<SplashLoadingBar> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut), 
      ),
    );

    _progressController.repeat();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'در حال بارگذاری...',
              style: TextStyle(
                color: Color(0xFFBCC9C8),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 4,
              constraints: const BoxConstraints(maxWidth: 384),
              decoration: BoxDecoration(
                color: const Color(0xFF0C2E3B),
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF29B5B5).withOpacity(0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  double progress = _progressController.value;
                  double mappedProgress;
                  if (progress <= 0.5) {
                    mappedProgress = progress * 1.2;
                  } else {
                    mappedProgress = 0.6 + ((progress - 0.5) * 0.8);
                  }
                  
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: mappedProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999),
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
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}