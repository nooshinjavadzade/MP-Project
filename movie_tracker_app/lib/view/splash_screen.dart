import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ایمپورت ویجت‌های شکسته شده


import '../widgets/background_glow.dart';
import '../widgets/floating_logo_widget.dart';
import '../widgets/loading_section_widget.dart';

// ایمپورت پرزنترهای خودتان را اینجا قرار دهید:
// import '../presenters/auth_presenter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialData();
  }

  Future<void> _checkInitialData() async {
    // شبیه‌سازی زمان لودینگ اولیه. در اینجا می‌توانید با استفاده از Provider
    // چک کنید که آیا کاربر از قبل لاگین هست یا خیر و توکن دارد یا نه.
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // مثال استفاده از Provider برای تصمیم‌گیری مسیر بعدی:
    // final authPresenter = context.read<AuthPresenter>();
    // if (authPresenter.isLoggedIn) {
    //   Navigator.pushReplacementNamed(context, '/home');
    // } else {
    //   Navigator.pushReplacementNamed(context, '/login');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00161F),
      body: Stack(
        fit: StackFit.expand,
        children: const [
          BackgroundGlow(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              FloatingLogoWidget(),
              Spacer(),
              LoadingSectionWidget(),
              SizedBox(height: 64),
            ],
          ),
        ],
      ),
    );
  }
}