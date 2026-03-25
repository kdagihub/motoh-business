import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../models/api_error.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  Future<void> _verify(String code) async {
    if (code.length != 6) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    try {
      final isNew = await auth.verifyOtp(code);
      if (!mounted) return;
      if (isNew) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.completeProfile, (r) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (r) => false);
      }
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final phone = auth.pendingPhone ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Code de vérification')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Entrez le code',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                phone.isEmpty
                    ? 'Saisissez le code reçu par SMS.'
                    : 'Code envoyé au $phone',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 36),
              MaterialPinField(
                length: 6,
                onCompleted: _verify,
                keyboardType: TextInputType.number,
                theme: MaterialPinTheme(
                  shape: MaterialPinShape.outlined,
                  cellSize: const Size(48, 56),
                  spacing: 8,
                  borderRadius: BorderRadius.circular(12),
                  borderColor: AppColors.textSecondary.withValues(alpha: 0.35),
                  focusedBorderColor: AppColors.primary,
                  borderWidth: 1.5,
                  focusedBorderWidth: 2,
                ),
              ),
              const SizedBox(height: 24),
              if (auth.isBusy) const Center(child: CircularProgressIndicator()),
              const Spacer(),
              TextButton(
                onPressed: auth.isBusy
                    ? null
                    : () {
                        Navigator.pushReplacementNamed(context, AppRoutes.phone);
                      },
                child: const Text('Modifier le numéro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
