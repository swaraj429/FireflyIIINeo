import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:neo_firefly_adapter/neo_firefly_adapter.dart';

/// AuthService handles login, PIN auth, biometrics, and session management.
class AuthService {
  final NeoApiClient _client;
  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  static const _tokenKey = 'neo_access_token';
  static const _pinKey = 'neo_pin_hash';

  AuthService(this._client)
      : _storage = const FlutterSecureStorage(),
        _localAuth = LocalAuthentication();

  // ── Token Management ──────────────────────────────────────────────────────

  Future<String?> getStoredToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    _client.setToken(token);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    _client.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await getStoredToken();
    return token != null && token.isNotEmpty;
  }

  // ── PIN Management ────────────────────────────────────────────────────────

  Future<void> savePIN(String pin) async {
    // Store PIN directly (the server does bcrypt, locally we just cache for quick auth)
    await _storage.write(key: _pinKey, value: pin);
  }

  Future<bool> checkPIN(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    return stored == pin;
  }

  Future<bool> hasPIN() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  // ── Biometrics ────────────────────────────────────────────────────────────

  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics &&
          await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access FireflyIII Neo',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  // ── API Auth ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    final svc = AuthApiService(_client);
    final resp = await svc.login(email: email, password: password);
    await saveToken(resp['token'] as String);
    return resp;
  }

  Future<Map<String, dynamic>> register(
      String email, String password, String displayName) async {
    final svc = AuthApiService(_client);
    final resp = await svc.register(
        email: email, password: password, displayName: displayName);
    await saveToken(resp['token'] as String);
    return resp;
  }

  Future<void> logout() async {
    await clearSession();
  }
}
