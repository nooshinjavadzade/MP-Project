import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/new_password_form.dart';

class NewPasswordScreen extends StatelessWidget {
  final String email;
  final String otp;

  const NewPasswordScreen({super.key, required this.email, required this.otp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00161F),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC7E7F8)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Ambient Background Orbs
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.2,
            left: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF29B5B5).withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.2,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8879F).withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Main Content Canvas
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header Minimalist
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida/AP1WRLtEUe-bNyAvLXNgHf26HruVGuWcLNTg7X1Qu8N4H-KIcdpuZNrC83OQSJEVvDzPjXWLNf8X9DrMuA1Uxc2gD2dpmBHi7RNMC2OqAi-OU2zye-tXOCclNFM3xiM3arSe686yKowCj_R1sdyykJ8P15BKz16N02DEgG6VwJWKpNZDKhgY8mU_ooXVtI3Mx16nFw_65EemIM2C_j9DodebLA1yeyh1O7nV7k5U6XHqm34U0f8rFxfVoEKegZcD',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'TV Time',
                            style: TextStyle(
                              fontSize: 24, // headline-lg-mobile
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Plus Jakarta Sans',
                              color: Color(0xFF5AD9D9), // primary
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 64),

                      // Glass Panel Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(40.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F5F66).withOpacity(0.2), // glass-panel
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF869393).withOpacity(0.2), // outline/20
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Create New Password',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: Color(0xFFC7E7F8), // on-surface
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Your new password must be different from previous passwords.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFBCC9C8), // on-surface-variant
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // Form Widget
                                NewPasswordForm(email: email, otp: otp),
                              ],
                            ),
                          ),
                        ),
                      ),
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
