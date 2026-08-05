import 'dart:convert';

import '../core/api/api_client.dart';
import '../core/storage/token_storage.dart';
import '../../models/user.dart';

class AuthService {
  AuthService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient.instance;

  final ApiClient _api;

  /// Login dan simpan token + profil user ke secure storage.
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.request(
      '/login',
      method: 'POST',
      data: {'email': email, 'password': password},
    );

    final data = response.data is Map<String, dynamic>
        ? (response.data as Map<String, dynamic>)['data']
        : null;
    final dataMap = data is Map<String, dynamic> ? data : const <String, dynamic>{};

    final token = dataMap['token'] as String? ?? '';
    final user = User.fromJson(dataMap['user'] as Map<String, dynamic>? ?? {});

    await TokenStorage.saveSession(token, jsonEncode(user.toJson()));
    return user;
  }

  Future<void> logout() async {
    try {
      await _api.request('/logout', method: 'POST');
    } finally {
      await TokenStorage.clear();
    }
  }

  /// Ubah password akun yang sedang login.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.request(
      '/password',
      method: 'PUT',
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );
  }

  Future<User?> restoreSession() async {
    final userJson = await TokenStorage.readUser();
    final token = await TokenStorage.readToken();
    if (userJson == null || token == null || token.isEmpty) return null;

    try {
      final user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      return user;
    } catch (_) {
      await TokenStorage.clear();
      return null;
    }
  }
}
