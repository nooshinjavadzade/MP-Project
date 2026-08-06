import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isGuest = false;
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;

  // ورود به عنوان مهمان
  void enterAsGuest() {
    _isGuest = true;
    _isLoggedIn = false;
    notifyListeners();
  }

  // چک کردن وضعیت لاگین (برای Splash Screen)
  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    // اینجا توکن رو از حافظه محلی چک کنید
    await Future.delayed(const Duration(seconds: 2)); // موقت - حذف کنید
    _isLoggedIn = false;

    _isLoading = false;
    notifyListeners();
  }

  // خروج از حساب
  Future<void> logout() async {
    _isLoggedIn = false;
    _isGuest = false;
    notifyListeners();
  }
}