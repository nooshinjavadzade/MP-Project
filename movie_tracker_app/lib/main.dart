import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_colors.dart';
import 'view/home_screen.dart';
import 'view/new_releases_screen.dart';
import 'view/popular_movies_screen.dart';
import 'view/popular_series_screen.dart';
import 'view/search_screen.dart';
import 'view/splash_screen.dart';
import 'view/welcome_screen.dart';

import 'presenters/media/media_presenter.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const TVTimeApp());
}

class TVTimeApp extends StatelessWidget {
  const TVTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MediaPresenter()..getTrending()..getPopularMovies()..getPopularSeries()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'TV Time',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          fontFamily: 'Manrope',
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.tertiary,
            surface: AppColors.surface,
          ),
          useMaterial3: true,
        ),
        home: const TestLauncherScreen(),
      ),
    );
  }
}

class TestLauncherScreen extends StatelessWidget {
  const TestLauncherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'TV Time - Test Launcher',
          style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.surfaceContainerHigh,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'صفحاتی که تا الان ساخته‌ایم:',
                style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Manrope', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              
              _buildLauncherButton(
                context: context,
                title: 'Splash Screen',
                color: AppColors.primary,
                targetScreen: const SplashScreen(),
              ),
              const SizedBox(height: 16),
              
              _buildLauncherButton(
                context: context,
                title: 'Welcome Screen',
                color: AppColors.primaryContainer,
                targetScreen: const WelcomeScreen(),
              ),
              const SizedBox(height: 16),
              
              _buildLauncherButton(
                context: context,
                title: 'Home Screen',
                color: AppColors.coralPink,
                targetScreen: const HomeScreen(),
              ),
              const SizedBox(height: 16),
              
              _buildLauncherButton(
                context: context,
                title: 'Search Screen',
                color: AppColors.tertiary,
                targetScreen: const SearchScreen(),
              ),
              const SizedBox(height: 16),
              
              _buildLauncherButton(
                context: context,
                title: 'New Releases',
                color: AppColors.lavenderShadow,
                targetScreen: const NewReleasesScreen(),
              ),
              const SizedBox(height: 16),
              
              _buildLauncherButton(
                context: context,
                title: 'Popular Movies',
                color: AppColors.surfaceTint,
                targetScreen: const PopularMoviesScreen(),
              ),
              const SizedBox(height: 16),
              
              _buildLauncherButton(
                context: context,
                title: 'Popular Series',
                color: AppColors.primaryFixed,
                targetScreen: const PopularSeriesScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLauncherButton({
    required BuildContext context,
    required String title,
    required Color color,
    required Widget targetScreen,
  }) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        minimumSize: const Size(250, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.surfaceContainerHigh, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}