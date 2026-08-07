import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'primary_cta_button.dart';
import 'secondary_cta_button.dart';

class WelcomeActionButtons extends StatelessWidget {
  const WelcomeActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            // دکمه ورود به عنوان مهمان
            PrimaryCTAButton(
              text: 'Enter App',
              isLoading: authProvider.isLoading,
              onPressed: () {
                authProvider.enterAsGuest();
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            const SizedBox(height: 16),

            // دکمه ورود به حساب کاربری - فعلاً غیرفعال
            SecondaryCTAButton(
              text: 'Log In',
              isLoading: false,
              onPressed: () {
                // TODO: وقتی سرویس لاگین آماده شد، این بخش را فعال کنید
                // Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }
}