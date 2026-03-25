import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/api_error.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../services/location_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/motoh_button.dart';
import '../../widgets/status_badge.dart';
import '../../app_routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LocationService _location = LocationService();
  bool _onlineLocal = false;
  bool _syncingSwitch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final d = context.read<DriverProvider>();
    await d.loadDashboardData();
    if (!mounted) return;
    setState(() => _onlineLocal = d.profile?.isOnline ?? false);
  }

  Future<void> _toggleOnline(bool v) async {
    setState(() {
      _syncingSwitch = true;
      _onlineLocal = v;
    });
    final d = context.read<DriverProvider>();
    try {
      await d.setOnline(v);
      if (!mounted) return;
      setState(() => _onlineLocal = d.profile?.isOnline ?? v);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _onlineLocal = !_onlineLocal);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _onlineLocal = !_onlineLocal);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _syncingSwitch = false);
    }
  }

  Future<void> _sendPosition() async {
    final d = context.read<DriverProvider>();
    if (!await _location.isServiceEnabled()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activez la localisation dans les réglages du téléphone.')),
      );
      return;
    }
    final pos = await _location.getCurrentPosition();
    if (!mounted) return;
    if (pos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’obtenir la position. Vérifiez les autorisations.')),
      );
      return;
    }
    try {
      await d.sendLocation(pos.latitude, pos.longitude);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Position envoyée')));
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.read<DriverProvider>().clear();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.phone, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final driver = context.watch<DriverProvider>();
    final name = driver.profile?.fullName ?? auth.user?.fullName ?? 'Chauffeur';
    final sub = driver.subscription;
    final hasSub = driver.profile?.hasSubscription == true || (sub?.isActive ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Profil',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfile),
          ),
          IconButton(
            icon: const Icon(Icons.subscriptions_rounded),
            tooltip: 'Abonnement',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.subscription),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Déconnexion',
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Bonjour, $name',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(
                  label: hasSub ? 'Abonnement actif' : 'Sans abonnement',
                  positive: hasSub,
                  icon: hasSub ? Icons.verified_rounded : Icons.info_outline_rounded,
                ),
                if (driver.profile?.isVisible == true)
                  const StatusBadge(
                    label: 'Visible',
                    positive: true,
                    icon: Icons.visibility_rounded,
                  ),
              ],
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statut en ligne',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _onlineLocal
                          ? 'Les clients peuvent vous voir sur la carte.'
                          : 'Vous êtes hors ligne. Activez pour être visible.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _onlineLocal ? 'En ligne' : 'Hors ligne',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: _onlineLocal ? AppColors.success : AppColors.textSecondary,
                                ),
                          ),
                        ),
                        if (_syncingSwitch)
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        else
                          Transform.scale(
                            scale: 1.15,
                            child: Switch(
                              value: _onlineLocal,
                              onChanged: driver.isBusy ? null : _toggleOnline,
                              materialTapTargetSize: MaterialTapTargetSize.padded,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ma position',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      driver.lastLatitude != null && driver.lastLongitude != null
                          ? 'Dernière position : ${driver.lastLatitude!.toStringAsFixed(5)}, ${driver.lastLongitude!.toStringAsFixed(5)}'
                          : 'Aucune position envoyée pour le moment.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    MotohButton(
                      label: 'Obtenir et envoyer ma position',
                      variant: MotohButtonVariant.secondary,
                      icon: Icons.my_location_rounded,
                      loading: driver.isBusy,
                      onPressed: driver.isBusy ? null : _sendPosition,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
