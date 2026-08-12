import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presenters/auth/auth_presenter.dart';
import '../view/login_screen.dart';
import 'auth_text_field.dart';
import 'auth_password_field.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    // Bio is collected but auth_presenter does not currently accept it.
    
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    final presenter = context.read<AuthPresenter>();
    await presenter.register(username, email, password, fullName: fullName.isNotEmpty ? fullName : null);

    if (presenter.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(presenter.errorMessage!)),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome Aboard! Account created.')),
        );
        Navigator.pop(context); // Go back to login
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthTextField(
          label: 'Full Name',
          hint: 'John Doe',
          icon: Icons.person_outline,
          controller: _fullNameController,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Username',
          hint: 'johndoe123',
          icon: Icons.account_circle_outlined,
          controller: _usernameController,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Email Address',
          hint: 'name@example.com',
          icon: Icons.mail_outline,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AuthPasswordField(
          label: 'Password',
          hint: '••••••••',
          icon: Icons.lock_outline,
          controller: _passwordController,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Biography',
          hint: 'Tell us about your movie tastes...',
          icon: Icons.edit_note_outlined,
          controller: _bioController,
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 32),
        Consumer<AuthPresenter>(
          builder: (context, presenter, _) {
            return Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF08DA5),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF08DA5).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: presenter.isLoading ? null : _handleSignUp,
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: presenter.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF5B152D), // on-tertiary
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF5B152D),
                                  fontSize: 24, // headline-lg-mobile
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Color(0xFF5B152D), size: 24),
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
