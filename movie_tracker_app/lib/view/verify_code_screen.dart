import 'dart:ui';
import 'package:flutter/material.dart';
import 'new_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  void _handleVerify() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewPasswordScreen(email: widget.email, otp: code),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 4-digit code.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00161F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC7E7F8)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient/Orbs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5AD9D9).withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo & Branding
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5AD9D9).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 24.0),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida/AP1WRLuerJhXjzYwOZPW4Ru4zFslLiPZneeQfPA03fV2yFiTFALOQh5R616C5q6oy3VPwbqDy9TV1YFN9I8JCChRYKiA84KIail2f6bs4ypvKor-I8fCjKVhln9HwD7gU93BKivNf9sKrJPxBrFgh8XKKLaX7UL3ZA-9raCUzczA7tXgcCbcOBvYO-ueYd3qIpJH9RZmddN7YD0snbRC8XliVHj_F0qOK-I5-exc94bzKzupcO7L6qL4kJ0lztCd',
                          width: 64,
                          height: 64,
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
                      const SizedBox(height: 64),

                      // Verification Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(40.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF001F2A).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF869393).withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Verify your identity',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: Color(0xFFC7E7F8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Enter the 4-digit code sent to your email',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFBCC9C8), // on-surface-variant
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                                const SizedBox(height: 40),
                                
                                // OTP Inputs
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(4, (index) {
                                    return Container(
                                      width: 56,
                                      height: 64,
                                      margin: EdgeInsets.only(
                                        right: index < 3 ? 24.0 : 0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF193846).withOpacity(0.4),
                                        border: Border.all(
                                          color: const Color(0xFF5AD9D9).withOpacity(0.3),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: TextField(
                                        controller: _controllers[index],
                                        focusNode: _focusNodes[index],
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        maxLength: 1,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Manrope',
                                          color: Color(0xFF5AD9D9),
                                        ),
                                        decoration: const InputDecoration(
                                          counterText: "",
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (value) => _onChanged(value, index),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 40),
                                
                                // Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _handleVerify,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF08DA5),
                                      foregroundColor: const Color(0xFF5B152D), // on-tertiary
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 8,
                                      shadowColor: const Color(0xFFF08DA5).withOpacity(0.4),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Verify & Proceed',
                                          style: TextStyle(
                                            fontSize: 20, // title-md
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Manrope',
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
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


