import 'package:flutter/material.dart';
import '../widgets/signup_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Color(0xFF0F5F66),
              Color(0xFF00161F),
            ],
            stops: [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida/AP1WRLuerJhXjzYwOZPW4Ru4zFslLiPZneeQfPA03fV2yFiTFALOQh5R616C5q6oy3VPwbqDy9TV1YFN9I8JCChRYKiA84KIail2f6bs4ypvKor-I8fCjKVhln9HwD7gU93BKivNf9sKrJPxBrFgh8XKKLaX7UL3ZA-9raCUzczA7tXgcCbcOBvYO-ueYd3qIpJH9RZmddN7YD0snbRC8XliVHj_F0qOK-I5-exc94bzKzupcO7L6qL4kJ0lztCd',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Text(
                      'TV TIME',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF5AD9D9),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'سفر سینمایی شما از اینجا شروع می‌شود',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFFBCC9C8).withOpacity(0.8),
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F5F66).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const SignUpForm(),
                    ),

                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'از قبل حساب کاربری دارید؟ ',
                          style: TextStyle(
                            color: Color(0xFFBCC9C8),
                            fontSize: 16,
                            fontFamily: 'Manrope',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'ورود',
                            style: TextStyle(
                              color: Color(0xFF5AD9D9),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Manrope',
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFF5AD9D9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}