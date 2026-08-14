import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF5AD9D9), // primary
              fontSize: 12, // label-sm
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2, // tracking-widest
              fontFamily: 'Manrope',
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF00232F).withOpacity(0.5), // surface-container/50
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF3C4949).withOpacity(0.3), // outline-variant/30
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            maxLines: maxLines,
            style: const TextStyle(
              color: Color(0xFFC7E7F8), // on-surface
              fontSize: 16,
              fontFamily: 'Manrope',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color(0xFFBCC9C8).withOpacity(0.4),
              ),
              prefixIcon: Padding(
                padding: maxLines > 1 ? const EdgeInsets.only(bottom: 48.0) : EdgeInsets.zero,
                child: Icon(
                  icon,
                  color: const Color(0xFFBCC9C8).withOpacity(0.6), // on-surface-variant/60
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF5AD9D9), width: 1), // primary
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}
