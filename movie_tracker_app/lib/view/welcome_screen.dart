import 'package:flutter/material.dart';
import '../widgets/welcome_background.dart';
import '../widgets/welcome_logo.dart';
import '../widgets/welcome_buttons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00161F), // bg-background
      body: Stack(
        children: [
          // پس‌زمینه محو و افکت‌های نوری
          const WelcomeBackground(),
          
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0), // px-margin-mobile
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448), // max-w-md
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // بخش لوگو و عنوان برنامه
                      WelcomeLogo(),
                      
                      SizedBox(height: 64), // mb-xl
                      
                      // دکمه‌های ورود به برنامه و لاگین
                      WelcomeButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

