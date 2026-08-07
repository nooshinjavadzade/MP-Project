import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({
    super.key,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          bottom: BorderSide(color: AppColors.primaryContainer.withOpacity(0.3), width: 2),
        ),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
          fontFamily: 'Manrope',
          color: AppColors.onBackground,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.onSurfaceVariant.withOpacity(0.4),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primary.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
