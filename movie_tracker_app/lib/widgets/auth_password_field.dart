import 'package:flutter/material.dart';

class AuthPasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputAction textInputAction;

  const AuthPasswordField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            widget.label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFBCC9C8), // on-surface-variant
              fontSize: 12, // label-sm
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              fontFamily: 'Manrope',
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F5F66).withOpacity(0.2), // glass-panel
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.transparent, // Initial border is handled by InputDecoration
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: _obscureText,
            textInputAction: widget.textInputAction,
            style: const TextStyle(
              color: Color(0xFFC7E7F8), // on-surface
              fontSize: 16,
              fontFamily: 'Manrope',
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: const Color(0xFFBCC9C8).withOpacity(0.5),
              ),
              prefixIcon: Icon(
                widget.icon,
                color: const Color(0xFF5AD9D9), // primary
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: const Color(0xFFBCC9C8),
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF5AD9D9), width: 2), // glow-input focus
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}


