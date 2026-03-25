import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/api_error.dart';
import '../../providers/driver_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/motoh_button.dart';
import '../../widgets/motoh_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _city;
  late final TextEditingController _zone;
  late final TextEditingController _photo;

  @override
  void initState() {
    super.initState();
    final p = context.read<DriverProvider>().profile;
    _name = TextEditingController(text: p?.fullName ?? '');
    _city = TextEditingController(text: p?.city ?? '');
    _zone = TextEditingController(text: p?.defaultZone ?? '');
    _photo = TextEditingController(text: p?.photo ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _zone.dispose();
    _photo.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final driver = context.read<DriverProvider>();
    try {
      await driver.updateProfile(
        fullName: _name.text.trim(),
        city: _city.text.trim(),
        defaultZone: _zone.text.trim().isEmpty ? null : _zone.text.trim(),
        photo: _photo.text.trim().isEmpty ? null : _photo.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour')));
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
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Vos informations',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 20),
                MotohTextField(
                  controller: _name,
                  label: 'Nom complet',
                  prefixIcon: Icons.person_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                ),
                const SizedBox(height: 16),
                MotohTextField(
                  controller: _city,
                  label: 'Ville',
                  prefixIcon: Icons.location_city_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                ),
                const SizedBox(height: 16),
                MotohTextField(
                  controller: _zone,
                  label: 'Zone par défaut',
                  hint: 'Quartier ou zone habituelle',
                  prefixIcon: Icons.map_rounded,
                ),
                const SizedBox(height: 16),
                MotohTextField(
                  controller: _photo,
                  label: 'Photo (URL)',
                  prefixIcon: Icons.image_rounded,
                ),
                const SizedBox(height: 32),
                Consumer<DriverProvider>(
                  builder: (context, d, _) {
                    return MotohButton(
                      label: 'Enregistrer',
                      loading: d.isBusy,
                      onPressed: d.isBusy ? null : _save,
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
