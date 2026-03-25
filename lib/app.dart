import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/driver_provider.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/phone_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile/complete_profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/subscription/subscription_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

class MotoHApp extends StatelessWidget {
  const MotoHApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoH Business',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.paystackWebView) {
          final url = settings.arguments as String? ?? '';
          return MaterialPageRoute<void>(
            builder: (_) => PaystackCheckoutScreen(url: url),
            settings: settings,
          );
        }
        return null;
      },
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.phone: (_) => const PhoneScreen(),
        AppRoutes.otp: (_) => const OtpScreen(),
        AppRoutes.completeProfile: (_) => const CompleteProfileScreen(),
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.editProfile: (_) => const EditProfileScreen(),
        AppRoutes.subscription: (_) => const SubscriptionScreen(),
      },
    );
  }
}

class MotoHRoot extends StatelessWidget {
  const MotoHRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService();
    final api = ApiClient(storage: storage);
    final authService = AuthService(client: api);

    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        Provider<ApiClient>.value(value: api),
        Provider<AuthService>.value(value: authService),
        Provider<LocationService>.value(value: LocationService()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            storage: storage,
            authService: authService,
          )..bootstrap(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, DriverProvider>(
          create: (ctx) => DriverProvider(apiClient: ctx.read<ApiClient>()),
          update: (_, auth, previous) {
            final d = previous ?? DriverProvider(apiClient: api);
            if (!auth.isAuthenticated) d.clear();
            return d;
          },
        ),
      ],
      child: const MotoHApp(),
    );
  }
}
