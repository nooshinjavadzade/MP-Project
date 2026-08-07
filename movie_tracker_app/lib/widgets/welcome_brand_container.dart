import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'logo_centerpiece.dart';

class WelcomeBrandContainer extends StatelessWidget {
  const WelcomeBrandContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LogoCenterpiece(),
        const SizedBox(height: 40),
        const Text(
          'TV Time',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: AppColors.onBackground,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track your journey through the cinematic deep.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            color: AppColors.onSurfaceVariant.withOpacity(0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}