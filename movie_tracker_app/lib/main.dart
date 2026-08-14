import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// API Client
import 'services/api/api_client.dart';

// Services
import 'services/api/admin_service.dart';
import 'services/api/auth_service.dart';
import 'services/api/interactions_service.dart';
import 'services/api/progress_service.dart';
import 'services/local/biometric_service.dart';
import 'services/local/local_storage_service.dart';
import 'services/api/media_service.dart';

// Presenters
import 'presenters/admin/admin_presenter.dart';
import 'presenters/auth/auth_presenter.dart';
import 'presenters/interactions/interactions_presenter.dart';
import 'presenters/progress/progress_presenter.dart';
import 'presenters/media/media_presenter.dart';

// Screens
import 'view/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Instantiate the shared API Client
  final apiClient = ApiClient();

  // 2. Instantiate Services with the API Client
  final authService = AuthService(apiClient);
  final adminService = AdminService(apiClient);
  final interactionsService = InteractionsService(apiClient);
  final progressService = ProgressService(apiClient);
  final mediaService = MediaService(apiClient);

  // 3. Instantiate Local Services
  final biometricService = BiometricService();
  final localStorageService = LocalStorageService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthPresenter>(
          create: (_) => AuthPresenter(
            authService,
            biometricService: biometricService,
            localStorageService: localStorageService,
          ),
        ),
        ChangeNotifierProvider<AdminPresenter>(
          create: (_) => AdminPresenter(adminService),
        ),
        ChangeNotifierProvider<InteractionsPresenter>(
          create: (_) => InteractionsPresenter(interactionsService),
        ),
        ChangeNotifierProvider<ProgressPresenter>(
          create: (_) => ProgressPresenter(progressService),
        ),
        ChangeNotifierProvider<MediaPresenter>(
          create: (_) => MediaPresenter(mediaService), // اصلاح: پاس دادن mediaService به MediaPresenter
        ),
      ],
      child: const TVTimeApp(),
    ),
  );
}

class TVTimeApp extends StatelessWidget {
  const TVTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Time Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF00161F),
        primaryColor: const Color(0xFF5AD9D9),
        fontFamily: 'Manrope',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
