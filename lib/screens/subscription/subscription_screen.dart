import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../models/api_error.dart';
import '../../providers/driver_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/motoh_button.dart';
import '../../app_routes.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().loadSubscription();
    });
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    const months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _openPaystack(String plan) async {
    final d = context.read<DriverProvider>();
    try {
      final url = await d.initializeSubscription(plan: plan);
      if (!mounted) return;
      await Navigator.pushNamed(context, AppRoutes.paystackWebView, arguments: url);
      if (!mounted) return;
      await d.loadSubscription();
      await d.loadProfile();
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _toggleAuto(bool v) async {
    final d = context.read<DriverProvider>();
    try {
      await d.setAutoRenew(v);
      if (!mounted) return;
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<DriverProvider>();
    final sub = d.subscription;
    final active = sub?.isActive ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Abonnement')),
      body: RefreshIndicator(
        onRefresh: () async {
          await d.loadSubscription();
          await d.loadProfile();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Formule actuelle',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      sub?.plan != null && sub!.plan!.isNotEmpty
                          ? sub.plan!.toUpperCase()
                          : (active ? 'Actif' : 'Aucun abonnement'),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expire le : ${_formatDate(sub?.expiresAt)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                    ),
                    if (active) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Renouvellement automatique',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Switch(
                            value: sub?.autoRenew ?? false,
                            onChanged: d.isBusy ? null : _toggleAuto,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Souscrire',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Paiement sécurisé via Paystack. Après paiement, revenez à l’app pour actualiser.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            MotohButton(
              label: 'Abonnement hebdomadaire',
              icon: Icons.payment_rounded,
              loading: d.isBusy,
              onPressed: d.isBusy ? null : () => _openPaystack('weekly'),
            ),
          ],
        ),
      ),
    );
  }
}

class PaystackCheckoutScreen extends StatefulWidget {
  const PaystackCheckoutScreen({super.key, required this.url});

  final String url;

  @override
  State<PaystackCheckoutScreen> createState() => _PaystackCheckoutScreenState();
}

class _PaystackCheckoutScreenState extends State<PaystackCheckoutScreen> {
  late final WebViewController _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (mounted) setState(() => _progress = p);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement Paystack'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          if (_progress < 100)
            LinearProgressIndicator(
              value: _progress / 100,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            ),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}
