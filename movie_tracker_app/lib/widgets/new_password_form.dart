import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presenters/auth/auth_presenter.dart';
import '../view/login_screen.dart';
import 'auth_password_field.dart';

class NewPasswordForm extends StatefulWidget {
  final String email;
  final String otp;

  const NewPasswordForm({super.key, required this.email, required this.otp});

  @override
  State<NewPasswordForm> createState() => _NewPasswordFormState();
}

class _NewPasswordFormState extends State<NewPasswordForm> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً هر دو فیلد را پر کنید.')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رمزهای عبور مطابقت ندارند.')),
      );
      return;
    }

    final presenter = context.read<AuthPresenter>();
    await presenter.confirmPasswordReset(
      widget.email,
      widget.otp,
      newPassword,
      confirmPassword,
    );

    if (presenter.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(presenter.errorMessage!)),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رمز عبور با موفقیت بازنشانی شد! لطفاً وارد شوید.')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthPasswordField(
          label: 'رمز عبور جدید',
          hint: '••••••••',
          icon: Icons.lock_outline,
          controller: _newPasswordController,
        ),
        const SizedBox(height: 24),
        AuthPasswordField(
          label: 'تأیید رمز عبور',
          hint: '••••••••',
          icon: Icons.lock_clock_outlined,
          controller: _confirmPasswordController,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 32),
        Consumer<AuthPresenter>(
          builder: (context, presenter, _) {
            return Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8879F), Color(0xFF681F36)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8879F).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: presenter.isLoading ? null : _handleSubmit,
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: presenter.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'بازنشانی و ورود',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}