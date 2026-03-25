import 'dart:convert';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:http/http.dart' as http;

import '../models/api_error.dart';
import 'storage_service.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, StorageService? storage})
      : _http = httpClient ?? http.Client(),
        _storage = storage ?? StorageService();

  final http.Client _http;
  final StorageService _storage;

  static String get baseUrl {
    const env = String.fromEnvironment('API_BASE_URL');
    if (env.isNotEmpty) return env;
    if (kIsWeb) return 'http://localhost:8080';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://127.0.0.1:8080';
  }

  Uri _uri(String path) {
    final b = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$b$p');
  }

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final t = await _storage.readJwt();
      if (t != null && t.isNotEmpty) {
        h['Authorization'] = 'Bearer $t';
      }
    }
    return h;
  }

  void _throwIfError(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) return;
    Map<String, dynamic>? map;
    try {
      final d = jsonDecode(r.body);
      if (d is Map<String, dynamic>) map = d;
    } catch (_) {}
    if (map != null && map.containsKey('code')) {
      throw ApiError.fromJson(map);
    }
    throw ApiError(
      code: 'HTTP_${r.statusCode}',
      message: map?['message'] as String? ?? 'Erreur réseau (${r.statusCode})',
      details: r.body.isNotEmpty ? r.body : null,
    );
  }

  Future<dynamic> get(String path, {bool auth = true}) async {
    final r = await _http.get(_uri(path), headers: await _headers(auth: auth));
    _throwIfError(r);
    if (r.body.isEmpty) return null;
    return jsonDecode(r.body);
  }

  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    final r = await _http.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    _throwIfError(r);
    if (r.body.isEmpty) return null;
    return jsonDecode(r.body);
  }

  Future<dynamic> put(String path, {Object? body, bool auth = true}) async {
    final r = await _http.put(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    _throwIfError(r);
    if (r.body.isEmpty) return null;
    return jsonDecode(r.body);
  }

  void close() => _http.close();
}
