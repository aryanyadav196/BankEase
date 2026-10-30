import 'package:flutter/foundation.dart';

import '../models/auth_session.dart';
import '../services/auth_storage.dart';
import '../services/bankease_api.dart';

class SessionController extends ChangeNotifier {
  SessionController({required BankEaseApi api, AuthStorage? storage})
    : _api = api,
      _storage = storage ?? AuthStorage();

  final BankEaseApi _api;
  final AuthStorage _storage;

  BankEaseApi get api => _api;

  AuthSession? session;
  bool isLoading = false;
  String? errorMessage;

  bool get isAuthenticated => session != null;

  Future<void> restore() async {
    session = await _storage.read();
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.login(email: email, password: password);
      final nextSession = AuthSession.fromJson(response);
      const roles = {'CUSTOMER', 'EMPLOYEE', 'ADMIN'};

      if (nextSession.token.isEmpty || !roles.contains(nextSession.role)) {
        throw Exception('The server returned an invalid login session.');
      }
      if (nextSession.role != expectedRole) {
        throw Exception(
          'These credentials belong to a ${nextSession.role.toLowerCase()} account. Select the matching role.',
        );
      }

      session = nextSession;
      await _storage.save(nextSession);
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> registerCustomer({
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) {
    return _register(
      () => _api.registerCustomer(
        fullName: fullName,
        email: email,
        phone: phone,
        address: address,
        password: password,
      ),
    );
  }

  Future<String?> registerStaff({
    required String role,
    required String email,
    required String password,
  }) {
    return _register(
      () => _api.registerStaff(role: role, email: email, password: password),
    );
  }

  Future<String?> _register(
    Future<Map<String, dynamic>> Function() operation,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await operation();
      return response['message'] as String? ?? 'Registration submitted.';
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    session = null;
    errorMessage = null;
    await _storage.clear();
    notifyListeners();
  }

  // Dashboard API calls in later phases can use this when the backend returns 401.
  Future<void> handleUnauthorized() => logout();
}
