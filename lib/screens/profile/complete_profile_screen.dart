import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../models/api_error.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/motoh_button.dart';
import '../../widgets/motoh_text_field.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _photo = TextEditingController();
  final _idDoc = TextEditingController();
  final _plate = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _photo.dispose();
    _idDoc.dispose();
    _plate.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    try {
      await auth.completeDriverProfile(
        fullName: _name.text.trim(),
        city: _city.text.trim(),
        photo: _photo.text.trim(),
        identityDocument: _idDoc.text.trim(),
        motorcyclePlate: _plate.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (r) => false);
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
      appBar: AppBar(title: const Text('Compléter le profil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Presque prêt',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Renseignez vos informations pour valider votre compte chauffeur.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                MotohTextField(
                  controller: _name,
                  label: 'Nom complet',
                  prefixIcon: Icons.person_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                MotohTextField(
                  controller: _city,
                  label: 'Ville',
                  prefixIcon: Icons.location_city_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                MotohTextField(
                  controller: _photo,
                  label: 'Photo (URL ou données)',
                  hint: 'Lien ou contenu attendu par le serveur',
                  prefixIcon: Icons.image_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                MotohTextField(
                  controller: _idDoc,
                  label: 'Pièce d’identité',
                  hint: 'URL ou référence du document',
                  prefixIcon: Icons.badge_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                MotohTextField(
                  controller: _plate,
                  label: 'Plaque moto',
                  prefixIcon: Icons.pin_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 32),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return MotohButton(
                      label: 'Enregistrer et continuer',
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
