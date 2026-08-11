import 'package:flutter/material.dart';
import '../widgets/splash_logo.dart';
import '../widgets/splash_loading_bar.dart';



class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bg-background: #00161f
      backgroundColor: const Color(0xFF00161F),
      body: Stack(
        children: [
          // Radial Glow Background (معدل کلاس glow-radial)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0x2629B5B5), // rgba(41, 181, 181, 0.15)
                  Color(0x0000161F), // transparent
                ],
                radius: 0.8,
                center: Alignment.center,
              ),
            ),
          ),
          const SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),
                // بخش لوگو و عنوان که انیمیشن شناور دارد
                SplashLogo(),
                Spacer(),
                // بخش نوار وضعیت بارگذاری
                SplashLoadingBar(),
                SizedBox(height: 64), // معادل pb-16
              ],
            ),
          ),
        ],
      ),
    );
  }
}