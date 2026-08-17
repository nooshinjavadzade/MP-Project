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
import 'services/api/profile_service.dart';
import 'services/api/report_service.dart';

// Presenters
import 'presenters/admin/admin_presenter.dart';
import 'presenters/auth/auth_presenter.dart';
import 'presenters/interactions/interactions_presenter.dart';
import 'presenters/progress/progress_presenter.dart';
import 'presenters/media/media_presenter.dart';
import 'presenters/profile/profile_presenter.dart';
import 'presenters/report/report_presenter.dart';

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
  final profileService = ProfileService(apiClient);
  final reportService = ReportService(apiClient);

  // 3. Instantiate Local Services
  final localStorageService = LocalStorageService();
  await localStorageService.init();
  final biometricService = BiometricService(localStorageService: localStorageService);

  runApp(
    MultiProvider(
      providers: [
        // 🔸 این نمونه همونیه که بالاتر await init() روش صدا زده شده.
        // با .value ثبتش می‌کنیم تا خودِ Provider دوباره نسازتش، و هر
        // ویجتی (مثل WatchlistCard) بتونه با context.read<LocalStorageService>()
        // دقیقاً همین نمونه‌ی init-شده رو بگیره، نه یه LocalStorageService()
        // تازه و init-نشده.
        // 🔸 قبلاً progressService فقط داخل ProgressPresenter تزریق شده بود.
        // ولی WatchlistCard مستقیماً context.read<ProgressService>() صدا
        // می‌زنه (بدون واسطه‌ی presenter)، و چون هیچ Provider<ProgressService>
        // مستقلی ثبت نشده بود، هر بار با خطای "Could not find the correct
        // Provider<ProgressService>" fail می‌شد.
        Provider<ProgressService>.value(value: progressService),
        Provider<LocalStorageService>.value(value: localStorageService),
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
          create: (_) => ProgressPresenter(progressService, localStorageService),
        ),
        ChangeNotifierProvider<MediaPresenter>(
          create: (_) => MediaPresenter(mediaService, localStorageService, profileService),
        ),
        ChangeNotifierProvider<ProfilePresenter>(
          create: (_) => ProfilePresenter(profileService, localStorageService),
        ),
        ChangeNotifierProvider<ReportPresenter>(
          create: (_) => ReportPresenter(reportService),
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