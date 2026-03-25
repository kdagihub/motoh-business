import 'package:flutter/foundation.dart';

import '../models/api_error.dart';
import '../models/driver_profile.dart';
import '../models/subscription.dart';
import '../services/api_client.dart';

class DriverProvider extends ChangeNotifier {
  DriverProvider({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  DriverProfile? _profile;
  Subscription? _subscription;
  double? _lastLatitude;
  double? _lastLongitude;
  bool _busy = false;
  String? _lastError;

  DriverProfile? get profile => _profile;
  Subscription? get subscription => _subscription;
  double? get lastLatitude => _lastLatitude;
  double? get lastLongitude => _lastLongitude;
  bool get isBusy => _busy;
  String? get lastError => _lastError;

  void clear() {
    _profile = null;
    _subscription = null;
    _lastLatitude = null;
    _lastLongitude = null;
    _lastError = null;
    notifyListeners();
  }

  void _setBusy(bool v) {
    _busy = v;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    _lastError = null;
    _setBusy(true);
    try {
      final data = await _api.get('/drivers/profile') as Map<String, dynamic>;
      _profile = DriverProfile.fromJson(data);
    } on ApiError catch (e) {
      _lastError = e.message;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> loadSubscription() async {
    _lastError = null;
    try {
      final data = await _api.get('/subscriptions/current');
      if (data is Map<String, dynamic>) {
        _subscription = Subscription.fromJson(data);
      } else {
        _subscription = null;
      }
    } on ApiError catch (e) {
      if (e.code.contains('404') || e.message.contains('404')) {
        _subscription = null;
      } else {
        _lastError = e.message;
      }
    }
    notifyListeners();
  }

  Future<void> loadDashboardData() async {
    await loadProfile();
    await loadSubscription();
  }

  Future<void> setOnline(bool online) async {
    _lastError = null;
    _setBusy(true);
    try {
      await _api.put('/drivers/status', body: {'is_online': online});
      if (_profile != null) {
        _profile = _profile!.copyWith(isOnline: online);
      } else {
        _profile = DriverProfile(isOnline: online);
      }
    } on ApiError catch (e) {
      _lastError = e.message;
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> sendLocation(double lat, double lng) async {
    _lastError = null;
    _setBusy(true);
    try {
      await _api.post('/drivers/location', body: {'latitude': lat, 'longitude': lng});
      _lastLatitude = lat;
      _lastLongitude = lng;
    } on ApiError catch (e) {
      _lastError = e.message;
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? city,
    String? photo,
    String? defaultZone,
  }) async {
    _lastError = null;
    _setBusy(true);
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (city != null) body['city'] = city;
      if (photo != null) body['photo'] = photo;
      if (defaultZone != null) body['default_zone'] = defaultZone;
      final data = await _api.put('/drivers/profile', body: body) as Map<String, dynamic>;
      _profile = DriverProfile.fromJson(data);
    } on ApiError catch (e) {
      _lastError = e.message;
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<String> initializeSubscription({required String plan}) async {
    _lastError = null;
    _setBusy(true);
    try {
      final data = await _api.post('/subscriptions/initialize', body: {'plan': plan}) as Map<String, dynamic>;
      final url = data['authorization_url'] as String? ?? '';
      if (url.isEmpty) throw ApiError(code: 'NO_URL', message: 'Lien de paiement indisponible');
      return url;
    } on ApiError catch (e) {
      _lastError = e.message;
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> setAutoRenew(bool value) async {
    _lastError = null;
    _setBusy(true);
    try {
      await _api.put('/subscriptions/auto-renew', body: {'auto_renew': value});
      if (_subscription != null) {
        _subscription = _subscription!.copyWith(autoRenew: value);
      }
    } on ApiError catch (e) {
      _lastError = e.message;
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
