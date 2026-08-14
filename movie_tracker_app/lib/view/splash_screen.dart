import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presenters/auth/auth_presenter.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';
import '../widgets/splash_logo.dart';
import '../widgets/splash_loading_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      final presenter = context.read<AuthPresenter>();
      
      final results = await Future.wait([
        Future.delayed(const Duration(milliseconds: 2000)),
        presenter.checkAutoLogin(),
      ]);

      final isLoggedIn = results[1] as bool;

      if (!mounted) return;

      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00161F),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0x2629B5B5),
                  Color(0x0000161F),
                ],
                radius: 0.8,
                center: Alignment.center,
              ),
            ),
          ),
          const SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),
                SplashLogo(),
                Spacer(),
                SplashLoadingBar(),
                SizedBox(height: 64),
              ],
            ),
          ),
        ],
      ),
    );
  }
}