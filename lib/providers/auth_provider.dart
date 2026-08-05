import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService();

  final AuthService _authService;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  bool _loading = false;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<bool> restoreSession() async {
    final user = await _authService.restoreSession();
    if (user != null) {
      _user = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<bool> login({required String email, required String password}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _authService.login(email: email, password: password);
      _user = user;
      _status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  bool can(String permission) => _user?.can(permission) ?? false;

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
