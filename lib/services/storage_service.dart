import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  StorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _jwtKey = 'motoh_jwt';
  static const _onboardingKey = 'motoh_onboarding_done';

  final FlutterSecureStorage _storage;

  Future<void> saveJwt(String token) => _storage.write(key: _jwtKey, value: token);

  Future<String?> readJwt() => _storage.read(key: _jwtKey);

  Future<void> clearJwt() => _storage.delete(key: _jwtKey);

  Future<void> setOnboardingCompleted(bool done) =>
      _storage.write(key: _onboardingKey, value: done ? '1' : '0');

  Future<bool> isOnboardingCompleted() async {
    final v = await _storage.read(key: _onboardingKey);
    return v == '1';
  }
}
