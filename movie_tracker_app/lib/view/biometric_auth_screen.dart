import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presenters/auth/auth_presenter.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  Offset _mousePosition = Offset.zero;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _glowAnimation = Tween<double>(begin: 10.0, end: 25.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptBiometric();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _promptBiometric() async {
    final presenter = context.read<AuthPresenter>();
    final success = await presenter.authenticateWithBiometric();
    
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00161F),
      body: Stack(
        children: [
          // Background Radial Gradient
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x2629B5B5), // rgba(41, 181, 181, 0.15)
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 64),
                // Header Logo placeholder
                const SizedBox(height: 128),
                
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Biometric Icon Container with glow and tilt
                      MouseRegion(
                        onEnter: (_) => setState(() => _isHovering = true),
                        onExit: (_) => setState(() {
                          _isHovering = false;
                          _mousePosition = Offset.zero;
                        }),
                        onHover: (event) {
                          setState(() {
                            // Calculate local position relative to center of the 160x160 box
                            final renderBox = context.findRenderObject() as RenderBox?;
                            if (renderBox != null) {
                              _mousePosition = event.localPosition - const Offset(80, 80);
                            }
                          });
                        },
                        child: GestureDetector(
                          onTap: _promptBiometric,
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              // Tilt effect logic
                              final double rotateX = _isHovering ? -_mousePosition.dy / 300 : 0;
                              final double rotateY = _isHovering ? _mousePosition.dx / 300 : 0;
                              
                              final transform = Matrix4.identity()
                                ..setEntry(3, 2, 0.001) // perspective
                                ..rotateX(rotateX)
                                ..rotateY(rotateY)
                                ..scale(_scaleAnimation.value);

                              return Transform(
                                transform: transform,
                                alignment: FractionalOffset.center,
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF0C2E3B).withOpacity(0.8), // surface-container-high
                                    border: Border.all(
                                      color: const Color(0xFF5AD9D9).withOpacity(0.2), // primary/20
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF29B5B5).withOpacity(0.2),
                                        blurRadius: _glowAnimation.value,
                                        spreadRadius: _glowAnimation.value / 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                      child: const Center(
                                        child: Icon(
                                          Icons.fingerprint,
                                          size: 80,
                                          color: Color(0xFF5AD9D9),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Prompt Text
                      const Text(
                        'Authenticate to continue',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC7E7F8), // on-background
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Confirm your identity to access TV Time',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          color: Color(0xFFBCC9C8), // on-surface-variant
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Footer Actions
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    icon: const Icon(Icons.password, size: 20),
                    label: const Text('USE PASSWORD'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5AD9D9), // primary
                      side: BorderSide(
                        color: const Color(0xFF5AD9D9).withOpacity(0.3),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


