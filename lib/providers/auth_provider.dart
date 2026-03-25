import 'package:flutter/foundation.dart';

import '../models/api_error.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required StorageService storage,
    required AuthService authService,
  })  : _storage = storage,
        _authService = authService;

  final StorageService _storage;
  final AuthService _authService;

  User? _user;
  String? _pendingUserId;
  String? _pendingPhone;
  bool _busy = false;
  String? _lastError;
  bool _bootstrapped = false;

  User? get user => _user;
  String? get pendingUserId => _pendingUserId;
  String? get pendingPhone => _pendingPhone;
  bool get isBusy => _busy;
  String? get lastError => _lastError;
  bool get isAuthenticated => _user != null;
  bool get bootstrapped => _bootstrapped;

  void _setBusy(bool v) {
    _busy = v;
    notifyListeners();
  }

  Future<void> bootstrap() async {
    _lastError = null;
    final jwt = await _storage.readJwt();
    if (jwt == null || jwt.isEmpty) {
      _user = null;
      _bootstrapped = true;
      notifyListeners();
      return;
    }
    _setBusy(true);
    try {
      _user = await _authService.me();
    } on ApiError catch (e) {
      await _storage.clearJwt();
      _user = null;
      _lastError = e.message;
    } catch (e) {
      await _storage.clearJwt();
      _user = null;
      _lastError = e.toString();
    } finally {
      _bootstrapped = true;
      _setBusy(false);
    }
  }

  Future<void> requestOtp(String phone) async {
    _lastError = null;
    _setBusy(true);
    try {
      final r = await _authService.requestOtp(phone);
      _pendingUserId = r.userId;
      _pendingPhone = phone;
    } on ApiError catch (e) {
      _lastError = e.message;
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> verifyOtp(String code) async {
    final uid = _pendingUserId;
    if (uid == null || uid.isEmpty) {
      _lastError = 'Session expirée. Recommencez.';
      notifyListeners();
      return false;
    }
    _lastError = null;
    _setBusy(true);
    try {
      final r = await _authService.verifyOtp(userId: uid, code: code);
      await _storage.saveJwt(r.token);
      _user = r.user.id.isNotEmpty ? r.user : User(id: uid, phone: _pendingPhone);
      _pendingUserId = null;
      _pendingPhone = null;
      notifyListeners();
      return r.isNewUser;
    } on ApiError catch (e) {
      _lastError = e.message;
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> refreshMe() async {
    if (!isAuthenticated) return;
    _setBusy(true);
    try {
      _user = await _authService.me();
    } on ApiError catch (e) {
      _lastError = e.message;
    } finally {
      _setBusy(false);
    }
  }

  void setUser(User u) {
    _user = u;
    notifyListeners();
  }

  Future<void> completeDriverProfile({
    required String fullName,
    required String city,
    required String photo,
    required String identityDocument,
    required String motorcyclePlate,
  }) async {
    _lastError = null;
    _setBusy(true);
    try {
      await _authService.completeDriverProfile(
        fullName: fullName,
        city: city,
        photo: photo,
        identityDocument: identityDocument,
        motorcyclePlate: motorcyclePlate,
      );
      _user = await _authService.me();
    } on ApiError catch (e) {
      _lastError = e.message;
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() async {
    await _storage.clearJwt();
    _user = null;
    _pendingUserId = null;
    _pendingPhone = null;
    _lastError = null;
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
