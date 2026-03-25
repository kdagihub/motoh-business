import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardPageData(
      icon: Icons.two_wheeler_rounded,
      title: 'Soyez visible',
      body: 'Les clients vous trouvent quand vous êtes en ligne. Activez votre statut pour recevoir plus de courses.',
    ),
    _OnboardPageData(
      icon: Icons.location_on_rounded,
      title: 'Partagez votre position',
      body: 'MotoH envoie votre position pour que les passagers sachent que vous êtes disponible près d’eux.',
    ),
    _OnboardPageData(
      icon: Icons.workspace_premium_rounded,
      title: 'Abonnement simple',
      body: 'Souscrivez en quelques minutes via un paiement sécurisé Paystack. Gérez le renouvellement depuis l’app.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<StorageService>().setOnboardingCompleted(true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        actions: [
          TextButton(
            onPressed: _finish,
            child: const Text('Passer'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final p = _pages[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(p.icon, size: 64, color: AppColors.primary),
                      ),
                      const SizedBox(height: 36),
                      Text(
                        p.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        p.body,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _page ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () {
                  if (_page < _pages.length - 1) {
                    _controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
                  } else {
                    _finish();
                  }
                },
                child: Text(_page < _pages.length - 1 ? 'Suivant' : 'Commencer'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPageData {
  const _OnboardPageData({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}
