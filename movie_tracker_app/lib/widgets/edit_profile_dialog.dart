import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/auth/user.dart';

class EditProfileDialog extends StatefulWidget {
  final User user;

  const EditProfileDialog({super.key, required this.user});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0C2E3B).withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF08DA5).withOpacity(0.3),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تنظیمات ویرایش پروفایل',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8DE6E3),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField('نام کامل', _nameController),
                  const SizedBox(height: 16),
                  _buildTextField('آدرس ایمیل', _emailController),
                  const SizedBox(height: 16),
                  _buildTextField('بیوگرافی', _bioController, maxLines: 3),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00232F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'احراز هویت بیومتریک',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: Color(0xFFBCC9C8),
                              ),
                            ),
                            Text(
                              'فعال‌سازی ورود با بیومتریک',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 16,
                                color: Color(0xFFC7E7F8),
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _biometricEnabled,
                          onChanged: (val) {
                            setState(() {
                              _biometricEnabled = val;
                            });
                          },
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xFF29B5B5),
                          inactiveThumbColor: const Color(0xFF869393),
                          inactiveTrackColor: const Color(0xFF193846),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF08DA5),
                        foregroundColor: const Color(0xFF00161F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'ذخیره تغییرات',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFBCC9C8),
                      ),
                      child: const Text(
                        'لغو تغییرات',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Color(0xFFBCC9C8),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            color: Color(0xFFC7E7F8),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF00232F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFF08DA5), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
        ),
      ],
    );
  }
}