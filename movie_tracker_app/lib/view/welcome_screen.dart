import 'package:flutter/material.dart';
import '../widgets/welcome_background.dart';
import '../widgets/welcome_logo.dart';
import '../widgets/welcome_buttons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00161F),
      body: Stack(
        children: [
          const WelcomeBackground(),
          
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WelcomeLogo(),
                      
                      SizedBox(height: 64),
                      
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