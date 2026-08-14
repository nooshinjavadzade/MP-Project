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
    
    // فید شدن همزمان با شروع پر شدن
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut), 
      ),
    );

    _progressController.repeat(); // Loop the loading animation just like CSS
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
        padding: const EdgeInsets.symmetric(horizontal: 48.0), // px-margin-desktop
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'IS LOADING...',
              style: TextStyle(
                color: Color(0xFFBCC9C8), // on-surface-variant
                fontSize: 12, // label-sm
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2, // tracking-wider
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 4, // h-1 in Tailwind
              constraints: const BoxConstraints(maxWidth: 384), // max-w-sm
              decoration: BoxDecoration(
                color: const Color(0xFF0C2E3B), // surface-container-high
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
                  // شبیه‌سازی انیمیشن CSS: در 50٪ زمان، طول آن 60٪ می‌شود
                  double progress = _progressController.value;
                  double mappedProgress;
                  if (progress <= 0.5) {
                    mappedProgress = progress * 1.2; // 0 to 0.6
                  } else {
                    mappedProgress = 0.6 + ((progress - 0.5) * 0.8); // 0.6 to 1.0
                  }
                  
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: mappedProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFB1C2), // from-tertiary
                            Color(0xFF29B5B5), // to-primary-container
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


