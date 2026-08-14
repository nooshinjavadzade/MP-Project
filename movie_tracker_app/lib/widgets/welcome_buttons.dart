import 'package:flutter/material.dart';
import '../view/login_screen.dart';
import '../view/home_screen.dart';

class WelcomeButtons extends StatelessWidget {
  const WelcomeButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // دکمه Enter App
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), // rounded-xl
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFB1C2), // tertiary
                Color(0xFF29B5B5), // primary-container
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB1C2).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
              },
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0), // py-4
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Enter App',
                      style: TextStyle(
                        color: Color(0xFFC7E7F8), // text-on-surface
                        fontSize: 20, // title-md
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    SizedBox(width: 8), // gap-2
                    Icon(
                      Icons.arrow_forward,
                      color: Color(0xFFC7E7F8),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24), // gap-md

        // دکمه Log In
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12.0), // py-3
              side: const BorderSide(color: Color(0xFF3C4949)), // border-outline-variant
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // rounded-xl
              ),
              foregroundColor: const Color(0xFFBCC9C8), // رنگ افکت کلیک
            ),
            child: const Text(
              'Log In',
              style: TextStyle(
                color: Color(0xFFBCC9C8), // text-on-surface-variant
                fontSize: 12, // label-sm
                fontWeight: FontWeight.w700,
                fontFamily: 'Manrope',
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


