import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presenters/auth/auth_presenter.dart';
import '../view/verify_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetRequest() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    final presenter = context.read<AuthPresenter>();
    await presenter.requestPasswordReset(email);

    if (presenter.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(presenter.errorMessage!)),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('دستورالعمل‌های بازنشانی رمز عبور به ایمیل شما ارسال شد.')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifyCodeScreen(email: email)),
        );
      }
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
                      const Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: Color(0xFF5AD9D9),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'بازنشانی رمز عبور',
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
                      const SizedBox(height: 16),
                      const Text(
                        'آدرس ایمیل خود را وارد کنید تا دستورالعمل‌های بازنشانی رمز عبور برای شما ارسال شود.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFBCC9C8),
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 48),

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
                                const SizedBox(height: 32),
                                
                                Consumer<AuthPresenter>(
                                  builder: (context, presenter, _) {
                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: presenter.isLoading ? null : _handleResetRequest,
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
                                                    'ارسال لینک بازنشانی',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Manrope',
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(Icons.send, size: 20),
                                                ],
                                              ),
                                      ),
                                    );
                                  }
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
    TextInputType? keyboardType,
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
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}