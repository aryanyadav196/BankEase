import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_session.dart';

class AuthStorage {
  AuthStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _sessionKey = 'bankease_auth_session';
  final FlutterSecureStorage _storage;

  Future<void> save(AuthSession session) {
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    );
  }

  Future<AuthSession?> read() async {
    final value = await _storage.read(key: _sessionKey);
    if (value == null || value.isEmpty) return null;

    try {
      return AuthSession.fromJson(jsonDecode(value) as Map<String, dynamic>);
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _sessionKey);
}
