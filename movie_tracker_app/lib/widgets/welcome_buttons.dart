import 'package:flutter/material.dart';
import '../view/login_screen.dart';
import '../view/home_screen.dart';

class WelcomeButtons extends StatelessWidget {
  const WelcomeButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFB1C2),
                Color(0xFF29B5B5),
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
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ورود به برنامه',
                      style: TextStyle(
                        color: Color(0xFFC7E7F8),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    SizedBox(width: 8),
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
        
        const SizedBox(height: 24),

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
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              side: const BorderSide(color: Color(0xFF3C4949)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: const Color(0xFFBCC9C8),
            ),
            child: const Text(
              'ورود',
              style: TextStyle(
                color: Color(0xFFBCC9C8),
                fontSize: 12,
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