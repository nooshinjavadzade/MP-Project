import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/welcome_brand_container.dart';
import '../widgets/welcome_action_buttons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // پس‌زمینه محو و هاله‌های نور
          const AtmosphericBackground(),

          // محتوای اصلی
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const WelcomeBrandContainer(),
                    const SizedBox(height: 64),
                    // دکمه‌های متصل به Provider
                    const WelcomeActionButtons(),
                  ],
                ),
              ),
            ),
          ),

          // نمایش لودینگ تمام‌صفحه هنگام عملیات
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isLoading) {
                return Container(
                  color: AppColors.background.withOpacity(0.6),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}