import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/driver_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _routed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideRoute());
  }

  Future<void> _decideRoute() async {
    if (_routed || !mounted) return;
    final auth = context.read<AuthProvider>();
    final storage = context.read<StorageService>();

    await Future.wait([
      Future.delayed(const Duration(milliseconds: 900)),
      _waitBootstrap(auth),
    ]);

    if (!mounted || _routed) return;
    _routed = true;

    if (!auth.isAuthenticated) {
      final done = await storage.isOnboardingCompleted();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        done ? AppRoutes.phone : AppRoutes.onboarding,
      );
      return;
    }

    final driver = context.read<DriverProvider>();
    await driver.loadProfile();
    if (!mounted) return;

    final needs = driver.profile?.needsCompletion ?? true;
    Navigator.pushReplacementNamed(
      context,
      needs ? AppRoutes.completeProfile : AppRoutes.dashboard,
    );
  }

  Future<void> _waitBootstrap(AuthProvider auth) async {
    for (var i = 0; i < 300 && !auth.bootstrapped; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'M',
                  style: GoogleFonts.inter(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'MotoH Business',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chauffeurs moto-taxi',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
