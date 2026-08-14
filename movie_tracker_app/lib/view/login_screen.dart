import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presenters/auth/auth_presenter.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    final presenter = context.read<AuthPresenter>();
    await presenter.login(email, password);

    if (presenter.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(presenter.errorMessage!)),
        );
      }
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00161F),
      body: Stack(
        children: [
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
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFCBBEFF).withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 150, sigmaY: 150),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'welcome_logo',
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida/AP1WRLuerJhXjzYwOZPW4Ru4zFslLiPZneeQfPA03fV2yFiTFALOQh5R616C5q6oy3VPwbqDy9TV1YFN9I8JCChRYKiA84KIail2f6bs4ypvKor-I8fCjKVhln9HwD7gU93BKivNf9sKrJPxBrFgh8XKKLaX7UL3ZA-9raCUzczA7tXgcCbcOBvYO-ueYd3qIpJH9RZmddN7YD0snbRC8XliVHj_F0qOK-I5-exc94bzKzupcO7L6qL4kJ0lztCd',
                          width: 112,
                          height: 112,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'TV Time',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF5AD9D9),
                          shadows: [
                            Shadow(
                              color: Color(0x4D5AD9D9),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 64),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF001F2A).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF869393).withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                  label: 'آدرس ایمیل',
                                  hint: 'name@example.com',
                                  icon: Icons.mail_outline,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 24),
                                _buildTextField(
                                  label: 'رمز عبور',
                                  hint: '••••••••',
                                  icon: Icons.lock_outline,
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                const SizedBox(height: 32),
                                
                                Consumer<AuthPresenter>(
                                  builder: (context, presenter, _) {
                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: presenter.isLoading ? null : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFF08DA5),
                                          foregroundColor: const Color(0xFF3F0018),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          elevation: 4,
                                          shadowColor: const Color(0xFFF08DA5).withOpacity(0.4),
                                        ),
                                        child: presenter.isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Color(0xFF3F0018),
                                                ),
                                              )
                                            : const Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'ورود',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Manrope',
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(Icons.arrow_forward, size: 20),
                                                ],
                                              ),
                                      ),
                                    );
                                  }
                                ),
                                
                                const SizedBox(height: 24),
                                Center(
                                  child: Column(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(0xFF5AD9D9),
                                        ),
                                        child: const Text(
                                          'رمز عبور را فراموش کردید؟',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                            fontFamily: 'Manrope',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        width: 48,
                                        height: 1,
                                        color: const Color(0xFF3C4949).withOpacity(0.2),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'حساب کاربری ندارید؟ ',
                                            style: TextStyle(
                                              color: Color(0xFFBCC9C8),
                                              fontSize: 16,
                                              fontFamily: 'Manrope',
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => const SignUpScreen()),
                                              );
                                            },
                                            child: const Text(
                                              'ثبت‌نام',
                                              style: TextStyle(
                                                color: Color(0xFF5AD9D9),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Manrope',
                                                decoration: TextDecoration.underline,
                                                decorationColor: Color(0x4D5AD9D9),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    VoidCallback? onVisibilityToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: const Color(0xFFBCC9C8).withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              fontFamily: 'Manrope',
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF193846).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF3C4949).withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Color(0xFFC7E7F8),
              fontSize: 16,
              fontFamily: 'Manrope',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color(0xFFBCC9C8).withOpacity(0.4),
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF5AD9D9).withOpacity(0.6),
              ),
              suffixIcon: onVisibilityToggle != null
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFFBCC9C8).withOpacity(0.6),
                      ),
                      onPressed: onVisibilityToggle,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}