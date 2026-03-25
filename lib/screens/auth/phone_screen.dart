import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/api_error.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/motoh_button.dart';
import '../../widgets/motoh_text_field.dart';
import '../../app_routes.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  String? _validatePhone(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Entrez votre numéro';
    if (!s.startsWith('+')) return 'Le numéro doit commencer par + (ex. +225...)';
    final digits = s.substring(1).replaceAll(RegExp(r'\s'), '');
    if (digits.length < 8) return 'Numéro incomplet';
    if (!RegExp(r'^\d+$').hasMatch(digits)) return 'Numéro invalide';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final raw = _phone.text.trim();
    try {
      await auth.requestOtp(raw);
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.otp);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Votre numéro',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nous vous enverrons un code SMS pour vérifier votre compte chauffeur.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),
                MotohTextField(
                  controller: _phone,
                  label: 'Téléphone',
                  hint: '+2250700000000',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_rounded,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d+\s]'))],
                  validator: _validatePhone,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  autocorrect: false,
                ),
                const SizedBox(height: 32),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return MotohButton(
                      label: 'Recevoir le code',
                      loading: auth.isBusy,
                      onPressed: auth.isBusy ? null : _submit,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
